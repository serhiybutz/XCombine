//
//  XCombine+ShareReplay.swift
//  XCombine
//
//  Created by Serhiy Butz on 10/12/19.
//  Copyright © 2019 Serhiy Butz. All rights reserved.
//

import Foundation
import Combine

protocol XCombineConnactable {
    func connect()
    func disconnect()
}

protocol XCombineShareReplay: AnyObject, XCombineConnactable {
    associatedtype Output
    associatedtype Failure: Error
    var lock: NSRecursiveLock { get }
    var completion: Subscribers.Completion<Failure>? { get }
    var subscriptionsManager: XCombine.AnyShareReplaySubscriptionsManager<Self> { get }
    var hub: XCombine.AnyShareReplayHub<Self> { get }
    func updateDemandFromHub()
}

extension XCombine {
    public final class ShareReplay<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        private let `internal`: ShareReplayInternal<Upstream>

        public init(upstream: Upstream, capacity: Int) {
            self.`internal` = ShareReplayInternal<Upstream>(upstream: upstream, capacity: capacity)
        }

        public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
            `internal`.receive(subscriber: subscriber)
        }
    }

    final class ShareReplayInternal<Upstream: Publisher>: XCombineShareReplay {
        // MARK: - Types

        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        // MARK: - Properties

        private let upstream: Upstream

        private var upstreamSubscriber: AnySubscriber<Output, Failure>?
        private var upstreamSubscription: UpstreamSubscriptionState = .initial
        private var upstreamDemand: Subscribers.Demand = .none  // Represents the upstream's tracked demand

        // MARK: - Initialization

        public init(upstream: Upstream,
                    capacity: Int,
                    hub: AnyShareReplayHub<ShareReplayInternal> = AnyShareReplayHub(ShareReplayHub()),
                    subscriptionsManager: AnyShareReplaySubscriptionsManager<ShareReplayInternal> = AnyShareReplaySubscriptionsManager(ShareReplaySubscriptionsManager())
        ) {
            self.subscriptionsManager = subscriptionsManager
            self.hub = hub

            self.upstream = upstream

            hub.config(with: self, capacity: capacity)
            subscriptionsManager.config(with: self)
        }

        // MARK: - API

        let lock = NSRecursiveLock()

        let hub: AnyShareReplayHub<ShareReplayInternal>

        let subscriptionsManager: AnyShareReplaySubscriptionsManager<ShareReplayInternal>

        /// The buffered completion event.
        private(set) var completion: Subscribers.Completion<Failure>?

        func updateDemandFromHub() {
            requestElementsIfNeeded()
        }
    }
}

// MARK: - Publisher
extension XCombine.ShareReplayInternal: Publisher {
    public func receive<Downstream: Subscriber>(subscriber: Downstream) where Downstream.Failure == Failure, Downstream.Input == Output {
        lock.lock()
        defer { lock.unlock() }

        let subscription = XCombine.ShareReplaySubscription<XCombine.ShareReplayInternal<Upstream>>(
            subscriber: subscriber,
            shareReplay: self)

        subscriptionsManager.append(subscription)

        subscriber.receive(subscription: subscription)
    }
}

// MARK: - Connectable
extension XCombine.ShareReplayInternal {
    func connect() {
        precondition(upstreamSubscriber == nil)

        guard completion == nil else { return; }

        upstreamSubscriber = AnySubscriber<Output, Failure>(
            receiveSubscription: receiveSubscription,
            receiveValue: receiveValue,
            receiveCompletion: receiveCompletion
        )

        upstream.subscribe(upstreamSubscriber!)
    }

    func disconnect() {
        upstreamSubscriber = nil
        upstreamDemand = .none
    }
}

// MARK: - AnySubscriber
extension XCombine.ShareReplayInternal {
    private func receiveSubscription(subscription: Subscription) {
        lock.lock()
        defer { lock.unlock() }

        guard
            completion == nil,
            case .initial = upstreamSubscription
        else {
            subscription.cancel()
            return;
        }

        upstreamSubscription = .subscribed(subscription)

        requestElementsIfNeeded()
    }

    private func receiveValue(value: Output) -> Subscribers.Demand {
        lock.lock()
        defer { lock.unlock() }

        guard
            case .subscribed = upstreamSubscription,
            completion == nil,
            upstreamDemand > 0
        else { return .none }

        upstreamDemand -= 1

        hub.receiveElement(value)

        let increase = increaseFromMergingUpstreamDemand(with: hub.demand)

        return increase
    }

    private func receiveCompletion(completion: Subscribers.Completion<Failure>) {
        lock.lock()
        defer { lock.unlock() }

        guard
            case .subscribed = upstreamSubscription,
            self.completion == nil
        else { return; }

        complete(with: completion)
    }
}

// MARK: - Helpers
extension XCombine.ShareReplayInternal {
    private func requestElementsIfNeeded() {
        guard
            completion == nil,
            let upstreamSubscription = upstreamSubscription.subscription
        else { return; }

        let demand = hub.demand

        guard demand > .none else { return; }

        let increase = increaseFromMergingUpstreamDemand(with: demand)

        if increase > .none {
            upstreamSubscription.request(increase)
        }
    }

    private func increaseFromMergingUpstreamDemand(with demand: Subscribers.Demand) -> Subscribers.Demand {
        let newUpstreamDemand = Swift.max(upstreamDemand, demand)
        let increase = newUpstreamDemand - upstreamDemand
        upstreamDemand = newUpstreamDemand
        return increase
    }

    private func complete(with completion: Subscribers.Completion<Failure>) {
        self.completion = completion

        subscriptionsManager.broadcast()

        upstreamSubscription = .closed  // invalidate the upstream pipeline
        upstreamDemand = .none
    }
}
