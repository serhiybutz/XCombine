//
//  XCombine+ZipGate.swift
//  XCombine
//
//  Created by Serhiy Butz on 12/3/2019.
//  Copyright © 2019 Serhiy Butz. All rights reserved.
//

import Foundation
import Combine

protocol XCombineZipGate: AnyObject {
    var lock: NSRecursiveLock { get }
    var isCancelledOrCompleted: Bool { get }
    var upstreams: [XCombineZipUpstreamSubscriber] { get }
    var demandTracker: XCombineZipDemandTracker! { get }
    var collector: XCombineZipCollector! { get }
    var processor: XCombineZipProcessor! { get }
    func emit()
    func handleCompletionWithFinishedIfAppropriate(finalizingWith finalization: (() -> Void)?)
    func handleCompletionWithFailure(finalizingWith finalization: (() -> Void)?)
}

extension XCombine {
    /// A subscription object that responds to demand requests.
    ///
    /// It's called `Gate` because it has the analogy of a gate, which opens when needed to let the event out and closes back. It also hosts all sub-components that form the operator's entire processing logic.
    final class ZipGate: XCombineZipGate {

        // MARK: - Properties

        private var demand: Subscribers.Demand = .none

        // Handlers:
        private let onEmit: () -> Subscribers.Demand
        private let onCompleteWithFinished: () -> Void
        private let onCompleteWithFailure: () -> Void

        // MARK: - Initialization

        init(upstreams: [XCombineZipUpstreamSubscriber],
             onEmit: @escaping () -> Subscribers.Demand,
             onCompleteWithFinished: @escaping () -> Void,
             onCompleteWithFailure: @escaping () -> Void,
             demandTracker: XCombineZipDemandTracker = ZipDemandTracker(),
             collector: XCombineZipCollector = ZipCollector(),
             processor: XCombineZipProcessor = ZipProcessor()
        ) {
            self.upstreams = upstreams

            self.onEmit = onEmit
            self.onCompleteWithFinished = onCompleteWithFinished
            self.onCompleteWithFailure = onCompleteWithFailure

            self.demandTracker = demandTracker
            self.collector = collector
            self.processor = processor

            configAndSubscribe()
        }

        // MARK: - API

        let lock = NSRecursiveLock()

        var isCancelledOrCompleted = false

        var upstreams: [XCombineZipUpstreamSubscriber]

        private(set) var demandTracker: XCombineZipDemandTracker!
        private(set) var collector: XCombineZipCollector!
        private(set) var processor: XCombineZipProcessor!

        func emit() {
            let additionalDemand = onEmit()
            demandTracker.addDemand(additionalDemand)
        }

        func handleCompletionWithFinishedIfAppropriate(finalizingWith finalization: (() -> Void)?) {
            guard !isCancelledOrCompleted else {
                finalization?()
                return;
            }

            let finishedCount = upstreams.filter({
                switch $0.completionState {
                case .completedWithFinished: return true
                default: return false }
            }).count

            if finishedCount == 0 {
                finalization?()
                return;
            }

            if finishedCount < upstreams.count && upstreams.first(where: { $0.isElementReceived }) != nil {
                finalization?()
                return;
            }

            isCancelledOrCompleted = true
            finalization?()
            onCompleteWithFinished()
        }

        func handleCompletionWithFailure(finalizingWith finalization: (() -> Void)?) {
            guard !isCancelledOrCompleted else {
                finalization?()
                return;
            }
            precondition(upstreams.first(where: {
                switch $0.completionState {
                case .completedWithFailure: return true
                default: return false }
            }) != nil)
            cancel()
            finalization?()
            onCompleteWithFailure()
        }
    }
}

// MARK: - Helpers
extension XCombine.ZipGate {
    private func configAndSubscribe() {
        lock.lock()
        defer { lock.unlock() }

        demandTracker.config(with: self)
        collector.config(with: self)
        processor.config(with: self)

        upstreams.forEach { $0.config(with: self) }
        upstreams.forEach { $0.subscribe() }
    }
}

// MARK: - Subscription
extension XCombine.ZipGate: Subscription {
    func request(_ demand: Subscribers.Demand) {
        lock.lock()

        guard !isCancelledOrCompleted else { return; }

        demandTracker.run(with: demand) {
            self.lock.unlock()
        }
    }

    func cancel() {
        lock.lock()
        defer { lock.unlock() }

        isCancelledOrCompleted = true

        upstreams.forEach { $0.cancel() }
        upstreams = []
    }
}

