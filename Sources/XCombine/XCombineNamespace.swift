//
//  XCombineNamespace.swift
//  XCombine
//
//  Created by Serhiy Butz on 12/3/2019.
//  Copyright © 2019 Serhiy Butz. All rights reserved.
//

import Combine

/// A namespace for **XCombine**'s offered facilities.
///
/// `XCombineNamespace` encapsulates **XCombine**'s offered facilities and preserves the upsteam in an instance property to continue building the Combine operator pipeline.
public struct XCombineNamespace<Upstream: Publisher> {
    let upstream: Upstream
    public init(_ upstream: Upstream) {
        self.upstream = upstream
    }
}

extension Publisher {
    /// Provides access to **XCombine**'s offered facilities.
    ///
    ///     ["a", "b", "c"].publisher
    ///         .x.zip(other)  // using XCombine's zip operator
    ///
    public var x: XCombineNamespace<Self> { XCombineNamespace(self) }
}
