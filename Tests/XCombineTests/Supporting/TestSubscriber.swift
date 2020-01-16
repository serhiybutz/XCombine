//
//  TestSubscriber.swift
//
//
//  Created by Serge Bouts.
//

import Combine

final class TestSubscriber<INPUT, FAILURE: Error>: Subscriber {
    // MARK: - Types

    typealias Input = INPUT
    typealias Failure = FAILURE

    // MARK: - Properties

    var subscription: Subscription!

    let receiveValue: (INPUT) -> Subscribers.Demand
    let receiveCompletion: ((Subscribers.Completion<FAILURE>) -> Void)?

    // MARK: - Initialization

    init(receiveCompletion: ((Subscribers.Completion<FAILURE>) -> Void)? = nil,
         receiveValue: @escaping (INPUT) -> Subscribers.Demand)
    {
        self.receiveCompletion = receiveCompletion
        self.receiveValue = receiveValue
    }

    // MARK: - API

    func request(demand: Subscribers.Demand) {
        subscription.request(demand)
    }

    // MARK: - Subscriber's Life Cycle

    func receive(subscription: Subscription) {
        self.subscription = subscription
//        Don't request any elements for now so as we could be capable of doing that explicitly from tests
//        subscription.request(.unlimited)
    }

    func receive(_ input: INPUT) -> Subscribers.Demand {
        return receiveValue(input)
    }

    func receive(completion: Subscribers.Completion<FAILURE>) {
        receiveCompletion?(completion)
    }
}
