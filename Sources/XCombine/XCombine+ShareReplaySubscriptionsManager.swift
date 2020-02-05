//
//  XCombine+ShareReplaySubscriptionsManager.swift
//  XCombine
//
//  Created by Serge Bouts on 10/12/19.
//  Copyright © 2019 Serge Bouts. All rights reserved.
//

import Foundation
import Combine

protocol XCombineShareReplaySubscriptionsManager {
    associatedtype ShareReplay: XCombineShareReplay
    func config(with shareReplay: ShareReplay)
    func append(_ subscription: XCombine.ShareReplaySubscription<ShareReplay>)
    func remove(_ subscription: XCombine.ShareReplaySubscription<ShareReplay>)
    var fewestElementsConsumed: Int { get }
    var lowestDemand: Subscribers.Demand { get }
    func broadcast()
}

extension XCombine {
    final class ShareReplaySubscriptionsManager<P: XCombineShareReplay>: XCombineShareReplaySubscriptionsManager {
        private var shareSubscriptions = NSHashTable<ShareReplaySubscription<P>>.weakObjects()

        private unowned var shareReplay: P!

        func config(with shareReplay: P) {
            self.shareReplay = shareReplay
        }

        func append(_ subscription: ShareReplaySubscription<P>) {
            let prevCount = shareSubscriptions.count
            shareSubscriptions.add(subscription)
            // Handle autoconnect (reference counting) mechanism.
            if prevCount == 0 && shareSubscriptions.count == 1 {
                shareReplay.connect()
            }
        }

        func remove(_ subscription: ShareReplaySubscription<P>) {
            let prevCount = shareSubscriptions.count
            shareSubscriptions.remove(subscription)
            // Handle autodisconnect.
            if prevCount > 0 && shareSubscriptions.count == 0 {
                shareReplay.disconnect()
            }
        }

        var fewestElementsConsumed: Int {
            shareSubscriptions.allObjects.map {
                let emitted = $0.nextSequenceNumber - shareReplay.hub.bufferingReferencePointOffset
                precondition(emitted >= 0)
                return emitted
            }
            .min() ?? 0
        }

        var lowestDemand: Subscribers.Demand {
            shareSubscriptions
                .allObjects.map { $0.demand }
                .min() ?? .none
        }

        func broadcast() {
            shareSubscriptions.allObjects.forEach {
                $0.consumeBuffered()
            }
        }
    }
}

extension XCombine {
    struct AnyShareReplaySubscriptionsManager<T: XCombineShareReplay>: XCombineShareReplaySubscriptionsManager {
        private let _config: (T) -> Void
        private let _append: (ShareReplaySubscription<T>) -> Void
        private let _remove: (ShareReplaySubscription<T>) -> Void
        private let _fewestElementsConsumed: () -> Int
        private let _lowestDemand: () -> Subscribers.Demand
        private let _broadcast: () -> Void
        init<U: XCombineShareReplaySubscriptionsManager>(_ subscriptionsManager: U) where U.ShareReplay == T {
            self._config = {
                subscriptionsManager.config(with: $0)
            }
            self._append = {
                subscriptionsManager.append($0)
            }
            self._remove = {
                subscriptionsManager.remove($0)
            }
            self._fewestElementsConsumed = {
                subscriptionsManager.fewestElementsConsumed
            }
            self._lowestDemand = {
                subscriptionsManager.lowestDemand
            }
            self._broadcast = {
                subscriptionsManager.broadcast()
            }
        }
        func config(with shareReplay: T) {
            _config(shareReplay)
        }
        func append(_ subscription: ShareReplaySubscription<T>) {
            _append(subscription)
        }
        func remove(_ subscription: ShareReplaySubscription<T>) {
            _remove(subscription)
        }
        var fewestElementsConsumed: Int {
            _fewestElementsConsumed()
        }
        var lowestDemand: Subscribers.Demand {
            _lowestDemand()
        }
        func broadcast() {
            _broadcast()
        }
    }
}
