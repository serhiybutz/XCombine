//
//  Array+XCombineZipUpstreamSubscriber.swift
//  XCombine
//
//  Created by Serge Bouts on 12/11/2019.
//  Copyright © 2019 Serge Bouts. All rights reserved.
//

import Combine

extension Array where Element == XCombineZipUpstreamSubscriber {
    // A `Dictionary` containing the elements of `self` as values and the elements' combine identifiers as keys.
    var combineIdentifierKeyed: [CombineIdentifier: XCombineZipUpstreamSubscriber] {
        var result = [CombineIdentifier: XCombineZipUpstreamSubscriber]()
        self.forEach {
            precondition(!result.keys.contains($0.combineIdentifier))
            result[$0.combineIdentifier] = $0
        }
        return result
    }
}
