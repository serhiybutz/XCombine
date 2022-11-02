//
//  XCombine+Types.swift
//  XCombine
//
//  Created by Serhiy Butz on 12/11/2019.
//  Copyright © 2019 Serhiy Butz. All rights reserved.
//

import Combine

extension XCombine {
    enum UpstreamSubscriptionState {
        case initial
        case subscribed(Subscription)
        case closed
        var subscription: Subscription? {
            switch self {
            case .subscribed(let result):
                return result
            default:
                return nil
            }
        }
    }
}
