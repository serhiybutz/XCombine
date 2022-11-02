//
//  XCombine+ZipUpstreamSubscriber.swift
//  XCombine
//
//  Created by Serhiy Butz on 12/3/2019.
//  Copyright © 2019 Serhiy Butz. All rights reserved.
//

import Combine
import Foundation

protocol XCombineZipUpstreamSubscriber: CustomCombineIdentifierConvertible {
    var isElementReceived: Bool { get }
    var sequenceNumber: Int? { get }
    var completionState: XCombine.ZipUpstreamCompletionState { get }
    func config(with gate: XCombineZipGate)
    func subscribe()
    func cancel()
    func requestElementIfAppropriate(for demandSequenceNumber: Int)
    func consume()
}

extension XCombine {
    enum ZipUpstreamCompletionState {
        case notCompleted
        case completedWithFinished
        case completedWithFailure
    }

    /// An upstream publisher's subscriber.
    ///
    /// This class is responsible for maintaining the state of requesting and receiving elements and completion events from the associated upstream publisher.
    final class ZipUpstreamSubscriber<P: Publisher>: XCombineZipUpstreamSubscriber {
        // MARK: - Types

        typealias Input = P.Output
        typealias Failure = P.Failure

        enum State {
            case elementRequested(sequenceNumber: Int)
            case elementReceived(sequenceNumber: Int, element: Input)
            case elementConsumed(sequenceNumber: Int)
            var sequenceNumber: Int {
                switch self {
                case .elementRequested(let sequenceNumber),
                     .elementReceived(let sequenceNumber, _),
                     .elementConsumed(let sequenceNumber):
                    return sequenceNumber
                }
            }
            var element: Input? {
                switch self {
                case .elementReceived(_, let element):
                    return element
                default:
                    return nil
                }
            }
        }

        // MARK: - Properties

        private var publisher: P?

        private var subscriptionState: UpstreamSubscriptionState = .initial

        private weak var gate: XCombineZipGate?
        private var collector: XCombineZipCollector { gate!.collector }
        private var processor: XCombineZipProcessor { gate!.processor }

        private var state: State?

        // MARK: - Initialization

        init(publisher: P) {
            self.publisher = publisher
        }

        // MARK: - API

        var element: P.Output? { state?.element }
        var sequenceNumber: Int? { state?.sequenceNumber }  // the element sequenceNumber in the incoming sequence the state is associated with

        private(set) var completionState: ZipUpstreamCompletionState = .notCompleted
        private(set) var failure: Failure?

        var isElementRequested: Bool {
            switch state {
            case .elementRequested: return true
            default: return false
            }
        }

        var isElementReceived: Bool {
            switch state {
            case .elementReceived: return true
            default: return false
            }
        }

        func config(with gate: XCombineZipGate) {
            self.gate = gate
        }

        func subscribe() {
            publisher?.subscribe(self)
        }

        func cancel() {
            guard let subscription = subscriptionState.subscription else { return; }
            subscription.cancel()
            subscriptionState = .closed
            publisher = nil
        }

        func requestElementIfAppropriate(for demandSequenceNumber: Int) {
            guard
                case .notCompleted = completionState,
                !isElementRequested,
                !isElementReceived,
                let subscription = subscriptionState.subscription
            else {
                return;
            }

            switch state {
            case nil:
                precondition(demandSequenceNumber == ZipDemandTracker.initialDemandSequenceNumber)
            case .elementConsumed(let sequenceNumber):
                precondition(demandSequenceNumber > ZipDemandTracker.initialDemandSequenceNumber
                    && demandSequenceNumber == sequenceNumber + 1)
            default:
                preconditionFailure()
            }

            state = .elementRequested(sequenceNumber: demandSequenceNumber)

            subscription.request(.max(1))
        }

        func consume() {
            guard case .elementReceived(let sequenceNumber, _) = state else { preconditionFailure() }
            state = .elementConsumed(sequenceNumber: sequenceNumber)
        }
    }
}

// MARK: - Subscriber
extension XCombine.ZipUpstreamSubscriber: Subscriber {
    func receive(subscription: Subscription) {
        guard let gate = gate else { return; }

        gate.lock.lock()
        defer { gate.lock.unlock() }

        guard
            case .initial = subscriptionState,
            !gate.isCancelledOrCompleted
        else { return; }

        subscriptionState = .subscribed(subscription)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        guard let gate = gate else { return .none }

        gate.lock.lock()
        var isLocked = true
        defer {
            if isLocked {
                gate.lock.unlock()
            }
        }

        guard
            case .subscribed = subscriptionState,
            !gate.isCancelledOrCompleted,
            case .notCompleted = completionState
        else { return .none }

        guard case .elementRequested(let sequenceNumber) = state else { preconditionFailure() }
        state = .elementReceived(sequenceNumber: sequenceNumber, element: input)

        switch collector.currentInitiator {
        case nil:
            guard
                let nextDemandSequenceNumber = collector.runOnBehalfOfUpstream(with: combineIdentifier, for: sequenceNumber, finalizingWith: {
                    gate.lock.unlock()
                    isLocked = false
                }),
                case .some(sequenceNumber) = processor.latestConsumedDemandSequenceNumber
            else {
                return .none
            }
            precondition(nextDemandSequenceNumber == sequenceNumber + 1)
            state = .elementRequested(sequenceNumber: nextDemandSequenceNumber)
            return .max(1)
        case .upstream(let currentUpstreamInitiatorId):
            precondition(currentUpstreamInitiatorId != combineIdentifier)
            return .none
        case .downstream:
            return .none
        }
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        guard let gate = gate else { return; }

        gate.lock.lock()
        var isLocked = true
        defer {
            if isLocked {
                gate.lock.unlock()
            }
        }

        guard
            case .subscribed = subscriptionState,
            !gate.isCancelledOrCompleted,
            case .notCompleted = completionState
        else {
            gate.lock.unlock()
            isLocked = false
            return;
        }

        switch completion {
        case .finished:
            completionState = .completedWithFinished

            if collector.currentInitiator == nil {
                gate.handleCompletionWithFinishedIfAppropriate {
                    gate.lock.unlock()
                    isLocked = false
                }
            }
        case .failure(let failure):
            completionState = .completedWithFailure
            self.failure = failure
            gate.handleCompletionWithFailure {
                gate.lock.unlock()
                isLocked = false
            }
        }
    }
}
