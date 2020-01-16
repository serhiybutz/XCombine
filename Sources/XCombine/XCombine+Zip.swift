//
//  XCombine+Zip.swift
//  XCombine
//
//  Created by Serge Bouts on 12/11/2019.
//  Copyright © 2019 Serge Bouts. All rights reserved.
//

import Combine
import Foundation

extension XCombine {
    /// A class that implements the underlying functionality of the zip operator, which is to synchronously combine elements from another publisher and deliver pairs of elements as tuples.
    ///
    /// It is a "cold" publisher, that creates a new identity for each downstream subscriber.
    public struct Zip<Upstream: Publisher, Other: Publisher>: Publisher
        where Upstream.Failure == Other.Failure
    {
        // MARK: - Types

        public typealias Output = (Upstream.Output, Other.Output)
        public typealias Failure = Upstream.Failure

        // MARK: - Properties

        private let upstream: Upstream
        private let other: Other

        // MARK: - Initialization

        init(upstream: Upstream,
             other: Other)
        {
            self.upstream = upstream
            self.other = other
        }

        // MARK: - Publisher

        public func receive<Downstream: Subscriber>(subscriber: Downstream)
            where Downstream.Input == Self.Output, Downstream.Failure == Self.Failure
        {
            let upstreams: [XCombineZipUpstreamSubscriber] = [
                ZipUpstreamSubscriber(publisher: upstream),
                ZipUpstreamSubscriber(publisher: other),
            ]

            let gate = ZipGate(
                upstreams: upstreams,
                onEmit: {
                    let tuple = Output(
                        (upstreams[0] as! ZipUpstreamSubscriber<Upstream>).element!,
                        (upstreams[1] as! ZipUpstreamSubscriber<Other>).element!)
                    return subscriber.receive(tuple)
                },
                onCompleteWithFinished: {
                    subscriber.receive(completion: .finished)
                },
                onCompleteWithFailure: {
                    if case .completedWithFailure = upstreams[0].completionState {
                        subscriber.receive(completion: .failure((upstreams[0] as! ZipUpstreamSubscriber<Upstream>).failure!))
                    } else if case .completedWithFailure = upstreams[1].completionState {
                        subscriber.receive(completion: .failure((upstreams[1] as! ZipUpstreamSubscriber<Other>).failure!))
                    } else {
                        preconditionFailure()
                    }
            })

            subscriber.receive(subscription: gate)
        }
    }
}
