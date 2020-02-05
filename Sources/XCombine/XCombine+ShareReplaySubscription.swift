//
//  XCombine+ShareReplaySubscription.swift
//  XCombine
//
//  Created by Serge Bouts on 10/12/19.
//  Copyright © 2019 Serge Bouts. All rights reserved.
//

import Foundation
import Combine

protocol XCombineShareReplaySubscription: CustomCombineIdentifierConvertible {
    var nextSequenceNumber: Int { get }
    func consumeBuffered()
}

extension XCombine {
    final class ShareReplaySubscription<P: XCombineShareReplay>: XCombineShareReplaySubscription {
        // MARK: - Properties

        private weak var shareReplay: P?

        private var subscriber: AnySubscriber<P.Output, P.Failure>?

        private var isCancelledOrCompleted = false

        // MARK: - Initialization

        init<Downstream: Subscriber>(subscriber: Downstream, shareReplay: P)
            where Downstream.Failure == P.Failure, Downstream.Input == P.Output
        {
            self.subscriber = AnySubscriber(subscriber)
            self.shareReplay = shareReplay

            self.nextSequenceNumber = shareReplay.hub.capacity == 0
                ? shareReplay.hub.bufferingReferencePointOffset + shareReplay.hub.buffer.count  // `shareReplay.hub.buffer.count` should be either 1 or 0; by adding 1 we achieve no initial replaying, thus simulating `share(replay:)` with no underlying buffer (mailbox buffer) when a capacity of 0 is specified.
                : shareReplay.hub.bufferingReferencePointOffset
        }

        // MARK: - API

        private(set) var demand: Subscribers.Demand = .none  // `.none` is equivalent to `Demand.max(0)`.

        private(set) var nextSequenceNumber: Int

        func consumeBuffered() {
            guard
                !isCancelledOrCompleted,
                let shareReplay = shareReplay,
                let subscriber = subscriber
                else { return; }

            while demand > .none,
                  let pos = nextBufferPosition
            {
                demand -= .max(1)
                let additionalDemand = subscriber.receive(shareReplay.hub.buffer[safe: pos]!)
                demand += additionalDemand
                nextSequenceNumber = nextSequenceNumber + 1
            }

            if let completion = shareReplay.completion {
                cancel()  // invalidate the pipeline
                subscriber.receive(completion: completion)
            }
        }

        func cancel() {
            guard let shareReplay = shareReplay else { return; }

            shareReplay.lock.lock()
            defer { shareReplay.lock.unlock() }

            guard !isCancelledOrCompleted else { return; }

            // Sending a completion to the subscriber doesn't make sense at this point as the pipeline is invalidated and no other data will be received, so just do a cleanup.

            shareReplay.subscriptionsManager.remove(self)
            subscriber = nil

            isCancelledOrCompleted = true
        }

        deinit {
            // Since a publisher doesn't retain subscriptions, notify the operator explicitly about releasing of subscriptions in order it could autodisconnect.
            guard let shareReplay = shareReplay else { return; }
            shareReplay.lock.lock()
            defer { shareReplay.lock.unlock() }
            shareReplay.subscriptionsManager.remove(self)
        }
    }
}

// MARK: - Subscription
extension XCombine.ShareReplaySubscription: Subscription {
    func request(_ demand: Subscribers.Demand) {
        guard let shareReplay = shareReplay else { return; }  // extend object lifetime

        shareReplay.lock.lock()
        defer { shareReplay.lock.unlock() }

        guard !isCancelledOrCompleted else { return; }

        self.demand += demand

        guard self.demand > .none else { return; }

        consumeBuffered()

        shareReplay.hub.updateDemandFromDownstream()
    }
}

// MARK: - Helpers
extension XCombine.ShareReplaySubscription {
    private var nextBufferPosition: Int? {
        let result = nextSequenceNumber - shareReplay!.hub.bufferingReferencePointOffset
        return result >= 0 && result < shareReplay!.hub.buffer.count
            ? result
            : nil
    }
}
