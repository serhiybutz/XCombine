//
//  Event.swift
//
//
//  Created by Serge Bouts.
//

import Combine

enum Event<V, E: Error>: Equatable where V : Equatable, E: Equatable {
    case completion(Subscribers.Completion<E>)
    case value(V)
}
