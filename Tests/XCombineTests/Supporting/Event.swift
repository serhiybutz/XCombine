//
//  Event.swift
//
//
//  Created by Serhiy Butz.
//

import Combine

enum Event<V, E: Error>: Equatable where V : Equatable, E: Equatable {
    case completion(Subscribers.Completion<E>)
    case value(V)
}
