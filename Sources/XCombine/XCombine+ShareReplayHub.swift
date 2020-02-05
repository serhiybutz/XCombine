//
//  XCombine+ShareReplayHub.swift
//  XCombine
//
//  Created by Serge Bouts on 10/12/19.
//  Copyright © 2019 Serge Bouts. All rights reserved.
//

import Foundation
import Combine

protocol XCombineShareReplayHub {
    associatedtype ShareReplay: XCombineShareReplay
    func config(with shareReplay: ShareReplay, capacity: Int)
    var capacity: Int! { get }
    var buffer: CircularBuffer<ShareReplay.Output>! { get }
    var bufferingReferencePointOffset: Int { get }
    func receiveElement(_ value: ShareReplay.Output)
    func updateDemandFromDownstream()
    var demand: Subscribers.Demand { get }
}

extension XCombine {
    final class ShareReplayHub<P: XCombineShareReplay>: XCombineShareReplayHub {
        private(set) var buffer: CircularBuffer<P.Output>!

        private(set) var capacity: Int!  // the logical capacity; the buffer's real capacity is `buffer.capacity`

        private(set) var bufferingReferencePointOffset = 0

        private unowned var shareReplay: P!

        func config(with shareReplay: P, capacity: Int) {
            self.shareReplay = shareReplay
            self.capacity = capacity
            let bufferCapacity = capacity > 0
                ? capacity
                : 1  // in case of the buffer's capacity of 0 the buffer downgrades to a "mailbox" buffer, so the minimum capacity of 1 is forced
            self.buffer = try! CircularBuffer<P.Output>(capacity: bufferCapacity)
        }

        func receiveElement(_ value: P.Output) {            
            if buffer.isFull {
                precondition(shareReplay.subscriptionsManager.fewestElementsConsumed > 0)
                try! buffer.removeFirst()
                bufferingReferencePointOffset += 1  // upon buffer space reusing, advance the sequence's buffering reference point offset
            }
            try! buffer.append(value)
            shareReplay.subscriptionsManager.broadcast()
        }

        var demand: Subscribers.Demand {
            let bufferLimit = buffer.freeSpace +
                shareReplay.subscriptionsManager.fewestElementsConsumed  // consumed elements buffer space will be reused

            if capacity == 0 {
                return shareReplay.subscriptionsManager.lowestDemand
            } else {
                return Swift.min(shareReplay.subscriptionsManager.lowestDemand,
                                 Subscribers.Demand.max(bufferLimit))
            }
        }

        func updateDemandFromDownstream() {
            guard demand > .none else { return; }
            shareReplay.updateDemandFromHub()
        }
    }
}

extension XCombine {
    struct AnyShareReplayHub<T: XCombineShareReplay>: XCombineShareReplayHub {
        private let _config: (T, Int) -> Void
        private let _capacity: () -> Int
        private let _buffer: () -> CircularBuffer<T.Output>
        private let _bufferingReferencePointOffset: () -> Int
        private let _receiveElement: (T.Output) -> Void
        private let _updateDemandFromDownstream: () -> Void
        private let _demand: () -> Subscribers.Demand

        init<U: XCombineShareReplayHub>(_ shareReplayHub: U) where U.ShareReplay == T {
            self._config = {
                shareReplayHub.config(with: $0, capacity: $1)
            }
            self._capacity = {
                shareReplayHub.capacity
            }
            self._buffer = {
                shareReplayHub.buffer
            }
            self._bufferingReferencePointOffset = {
                shareReplayHub.bufferingReferencePointOffset
            }
            self._receiveElement = {
                shareReplayHub.receiveElement($0)
            }
            self._updateDemandFromDownstream = {
                shareReplayHub.updateDemandFromDownstream()
            }
            self._demand = {
                shareReplayHub.demand
            }
        }
        func config(with shareReplay: T, capacity: Int) {
            _config(shareReplay, capacity)
        }
        var capacity: Int! {
            _capacity()
        }
        var buffer: CircularBuffer<T.Output>! {
            _buffer()
        }
        var bufferingReferencePointOffset: Int {
            _bufferingReferencePointOffset()
        }
        func receiveElement(_ value: T.Output) {
            _receiveElement(value)
        }
        func updateDemandFromDownstream() {
            _updateDemandFromDownstream()
        }
        var demand: Subscribers.Demand {
            _demand()
        }
    }
}
