//
//  BlockingSubject.swift
//
//
//  Created by Serge Bouts.
//

import Combine
import Foundation

// A simple blocking Passthrough Subject for testing purposes.
final class BlockingSubject<Output, Failure: Error>: Publisher, CustomCombineIdentifierConvertible {
    // MARK: - Properties

    @AtomicSync
    var subscription: Internal?

    let sendCondition = NSCondition()

    // MARK: - Initialization

    init() {}

    // MARK: - API

    func send(_ value: Output) {
        guard let subscription = subscription else { return; }

        sendCondition.lock()

        while subscription.value != nil {
            sendCondition.wait()
        }

        subscription.value = value

        sendCondition.unlock()

        subscription.sendValueIfNeeded()
    }

    func send(completion: Subscribers.Completion<Failure>) {
        guard let subscription = subscription else { return; }

        subscription.cancel()

        subscription.downstream.receive(completion: completion)
    }

    // MARK: - Publisher's Life Cycle

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        $subscription.mutate { subscription in
            precondition(subscription == nil)
            subscription = Internal(publisher: self, downstream: AnySubscriber(subscriber))

            subscription!.downstream.receive(subscription: subscription!)
        }
    }
}

// MARK: - Blocking Subject's Subscription
extension BlockingSubject {
    final class Internal: Subscription {
        // MARK: - Types

        typealias Input = Output

        // MARK: - Properties

        let downstream: AnySubscriber<Input, Failure>

        let publisher: BlockingSubject

        var demand: Subscribers.Demand = .none

        // A "mailbox" buffer.
        var value: Output?

        let lock = NSRecursiveLock()

        // MARK: - Initialization

        init(publisher: BlockingSubject<Output, Failure>, downstream: AnySubscriber<Input, Failure>) {
            self.downstream = downstream
            self.publisher = publisher
        }

        // MARK: - Subscription's Life Cycle

        func request(_ demand: Subscribers.Demand) {
            lock.lock()
            defer { lock.unlock() }

            self.demand += demand

            sendValueIfNeeded()
        }

        func cancel() {
            publisher.subscription = nil
        }
    }
}

// MARK: - Helpers
private extension BlockingSubject.Internal {
    func sendValueIfNeeded() {
        lock.lock()
        defer { lock.unlock() }

        guard
            demand > .none,
            let value = value
            else { return; }

        let additionalDemand = downstream.receive(value)

        demand = (demand - .max(1)) + additionalDemand

        resetValue()
    }

    func resetValue() {
        publisher.sendCondition.lock()

        value = nil

        publisher.sendCondition.signal()
        publisher.sendCondition.unlock()
    }
}
