//
//  XCombine+ZipCollector.swift
//  XCombine
//
//  Created by Serge Bouts on 12/11/2019.
//  Copyright © 2019 Serge Bouts. All rights reserved.
//

import Foundation
import Combine

protocol XCombineZipCollector {
    var currentInitiator: XCombine.ZipCollector.CurrentInitiator? { get }
    func config(with gate: XCombineZipGate)
    func runOnBehalfOfDownstream(for demandSequenceNumber: Int, finalizingWith finalization: (() -> Void)?)
    func runOnBehalfOfUpstream(with upstreamId: CombineIdentifier, for demandSequenceNumber: Int, finalizingWith finalization: (() -> Void)?) -> Int?
}

extension XCombine {
    /// A sub-component responsible for *demand sequence number*-driven coordination of the upstreams' provided data.
    final class ZipCollector: XCombineZipCollector {
        // MARK: - Types

        enum CurrentInitiator {
            case upstream(id: CombineIdentifier)
            case downstream
        }

        // MARK: - Properties

        private(set) var currentInitiator: CurrentInitiator?
        private unowned var gate: XCombineZipGate!
        private var upstreams: [XCombineZipUpstreamSubscriber] { gate.upstreams }
        private var demandTracker: XCombineZipDemandTracker { gate.demandTracker }
        private var processor: XCombineZipProcessor { gate.processor }

        // MARK: - API

        func config(with gate: XCombineZipGate) {
            self.gate = gate
        }

        func runOnBehalfOfDownstream(for demandSequenceNumber: Int, finalizingWith finalization: (() -> Void)?) {
            currentInitiator = .downstream
            defer { currentInitiator = nil }

            batchRequestElement(for: upstreams, for: demandSequenceNumber)

            processor.consumeIfAppropriate(for: demandSequenceNumber)
            gate.handleCompletionWithFinishedIfAppropriate(finalizingWith: finalization)
        }

        func runOnBehalfOfUpstream(with upstreamId: CombineIdentifier, for demandSequenceNumber: Int, finalizingWith finalization: (() -> Void)?) -> Int? {
            currentInitiator = .upstream(id: upstreamId)
            defer { currentInitiator = nil }

            var upstreamsHash = upstreams.combineIdentifierKeyed

            if case .upstream(let id) = currentInitiator {
                upstreamsHash.removeValue(forKey: id)  // TODO: Consider using the array rather than the hash.
            }

            batchRequestElement(for: Array(upstreamsHash.values), for: demandSequenceNumber)

            processor.consumeIfAppropriate(for: demandSequenceNumber)
            gate.handleCompletionWithFinishedIfAppropriate(finalizingWith: finalization)
            guard !gate.isCancelledOrCompleted else { return nil }

            if let nextDemandSequenceNumber = demandTracker.issueNextDemandSequenceNumber() {
                batchRequestElement(for: Array(upstreamsHash.values), for: nextDemandSequenceNumber)
                return nextDemandSequenceNumber
            } else {
                return nil
            }
        }
    }
}

// MARK: - Helpers
extension XCombine.ZipCollector {
    private func batchRequestElement(
        for upstreams: [XCombineZipUpstreamSubscriber],
        for demandSequenceNumber: Int
    ) {
        for upstream in upstreams {
            guard !gate.isCancelledOrCompleted else { break }
            upstream.requestElementIfAppropriate(for: demandSequenceNumber)
        }
    }
}
