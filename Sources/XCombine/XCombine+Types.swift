//
//  XCombine+Types.swift
//  XCombine
//
//  Created by Serge Bouts on 12/11/2019.
//  Copyright © 2019 Serge Bouts. All rights reserved.
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
