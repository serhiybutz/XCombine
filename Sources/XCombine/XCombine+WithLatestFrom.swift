//
//  XCombine+WithLatestFrom.swift
//  XCombine
//
//  Created by Serhiy Butz on 12/11/2019.
//  Copyright © 2019 Serhiy Butz. All rights reserved.
//

import Combine

extension XCombine {
    /// A "cold" publisher, that creates a new identity for each downstream subscriber.
    public struct WithLatestFrom<Upstream: Publisher, Other: Publisher>: Publisher where Upstream.Failure == Other.Failure {
        // MARK: - Types

        public typealias Output = (Upstream.Output, Other.Output)
        public typealias Failure = Upstream.Failure

        // MARK: - Properties

        private let upstream: Upstream
        private let other: Other

        private let completer = XCombine.UpstreamGroupCompleter()

        // MARK: - Initialization

        init(upstream: Upstream, other: Other) {
            self.upstream = upstream
            self.other = other
        }

        // MARK: - Publisher Lifecycle

        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let merged = mergedStream(upstream, other)
            let result = resultStream(from: merged)
            result.subscribe(subscriber)
        }
    }
}

// MARK: - Helpers
private extension XCombine.WithLatestFrom {
    // MARK: - Types

    enum MergedElement {
        case upstream1(Upstream.Output)
        case upstream2(Other.Output)
    }

    typealias ScanResult = (value1: Upstream.Output?, value2: Other.Output?, shouldEmit: Bool)

    // MARK: - Pipelines

    func mergedStream(_ upstream1: Upstream, _ upstream2: Other) -> AnyPublisher<MergedElement, Failure> {
        let mergedElementUpstream1 = upstream1
            .x.upstreamCompletionObserver(completer, policy: .completeAll)
            .map { MergedElement.upstream1($0) }
        let mergedElementUpstream2 = upstream2
            .x.upstreamCompletionObserver(completer, policy: .transparent)
            .map { MergedElement.upstream2($0) }
        return mergedElementUpstream1
            .merge(with: mergedElementUpstream2)
            .eraseToAnyPublisher()
    }

    func resultStream(from mergedStream: AnyPublisher<MergedElement, Failure>) -> AnyPublisher<Output, Failure> {
        mergedStream
            .scan(nil) { (prevResult: ScanResult?, mergedElement: MergedElement) -> ScanResult? in
                var newValue1: Upstream.Output?
                var newValue2: Other.Output?
                let shouldEmit: Bool

                switch mergedElement {
                case .upstream1(let v):
                    newValue1 = v
                    shouldEmit = prevResult?.value2 != nil
                case .upstream2(let v):
                    newValue2 = v
                    shouldEmit = false
                }

                return ScanResult(value1: newValue1 ?? prevResult?.value1,
                                  value2: newValue2 ?? prevResult?.value2,
                                  shouldEmit: shouldEmit)
            }
            .compactMap { $0 }
            .filter { $0.shouldEmit }
            .map { Output($0.value1!, $0.value2!) }
            .eraseToAnyPublisher()
    }
}
