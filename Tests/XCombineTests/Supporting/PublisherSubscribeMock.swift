//
//  PublisherSubscribeMock.swift
//
//
//  Created by Serhiy Butz.
//

import Combine
import Foundation

final class PublisherSubscribeMock<Input, Failure: Error>: Publisher {
    // MARK: - Types

    typealias Output = Input
    typealias Failure = Failure

    // MARK: - Properties

    @AtomicSync
    var isBusy = false

    @AtomicSync
    var collisions = 0

    @AtomicSync
    var runs = 0

    var subscriptionHandler: ((PublisherSubscribeMock) -> Void)?

    // MARK: - Publisher's Life Cycle
    
    func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
        defer { isBusy = false }
        $isBusy.mutate { isBusy in
            if isBusy {
                self.collisions += 1
            } else {
                isBusy = true
            }
        }
        Thread.sleep(forTimeInterval: 1)
        $runs.mutate { runs in
            runs += 1
        }
        subscriptionHandler?(self)
    }
}
