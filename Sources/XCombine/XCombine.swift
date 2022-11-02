//
//  XCombine.swift
//  XCombine
//
//  Created by Serhiy Butz on 12/11/2019.
//  Copyright © 2019 Serhiy Butz. All rights reserved.
//

import Combine

/// The XCombine namespace.
public enum XCombine {}

// MARK: - Operator methods
extension XCombineNamespace {
    /// Synchronously combine elements from another publisher and deliver pairs of elements as tuples.
    ///
    /// This is an alternative implementation of the zip operator, which has some advantages over the Combine's original one. It was designed to have the same documented functionality of the original one, but is different at how it handles back pressure, in that the original zip operator just forwards the downstream's received demand up to its upstreams, while this one requests elements by 1. By acting so it prevents some problematic usage scenarios, like those with the infinite upstream sequences.
    ///
    /// - Parameter other: Another publisher.
    /// - Returns: A publisher that emits pairs of elements from the upstream publishers as tuples.
    public func zip<Other: Publisher>(_ other: Other)
        -> XCombine.Zip<Upstream, Other>
    {
        return .init(upstream: self.upstream, other: other)
    }

    /// Returns a publisher that **shares a single subscription to the upstream**, and immediately upon subscription replays values in buffer.
    ///
    /// - Parameter replay: Maximum element count of the replay buffer.
    /// - Returns: A publisher that emits the elements produced by multicasting the upstream publisher.
    public func share(replay: Int = 0)
        -> XCombine.ShareReplay<Upstream>
    {
        return .init(upstream: self.upstream, capacity: replay)
    }

    internal func upstreamCompletionObserver(
        _ completer: XCombine.UpstreamGroupCompleter,
        policy: XCombine.UpstreamCompletionPolicy
    ) -> XCombine.UpstreamCompletionObserver<Upstream>
    {
        return .init(upstream: self.upstream,
                     completer: completer,
                     policy: policy)
    }

    /// Merges two publishers into one publisher by combining each element from self with the latest element from the second source, if any.
    /// - Parameter other: Another publisher.
    /// - Returns: A publisher that emits pairs of elements from the upstream publishers as tuples.
    public func withLatestFrom<Other: Publisher>(_ other: Other)
        -> XCombine.WithLatestFrom<Upstream, Other>
    {
        return .init(upstream: self.upstream, other: other)
    }
}
