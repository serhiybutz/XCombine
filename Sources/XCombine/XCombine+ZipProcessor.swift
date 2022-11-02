//
//  XCombine+ZipProcessor.swift
//  XCombine
//
//  Created by Serhiy Butz on 12/3/2019.
//  Copyright © 2019 Serhiy Butz. All rights reserved.
//

import Combine
import Foundation

protocol XCombineZipProcessor {
    var latestConsumedDemandSequenceNumber: Int? { get }
    func config(with gate: XCombineZipGate)
    func consumeIfAppropriate(for demandSequenceNumber: Int)
}

extension XCombine {
    /// A sub-component responsible for finalizing the demand processing loop.
    final class ZipProcessor: XCombineZipProcessor {
        // MARK: - Properties

        private unowned var gate: XCombineZipGate!
        private var upstreams: [XCombineZipUpstreamSubscriber] { gate.upstreams }
        private var demandTracker: XCombineZipDemandTracker { gate.demandTracker }

        private(set) var latestConsumedDemandSequenceNumber: Int?

        // MARK: - API

        func config(with gate: XCombineZipGate) {
            self.gate = gate
        }

        func consumeIfAppropriate(for demandSequenceNumber: Int) {
            let elementsCount = upstreams.filter({ $0.isElementReceived }).count
            guard elementsCount == upstreams.count else { return; }
            upstreams.forEach { precondition($0.sequenceNumber! == demandSequenceNumber) }
            gate.emit()
            upstreams.forEach { $0.consume() }
            latestConsumedDemandSequenceNumber = demandSequenceNumber
            demandTracker.consumeDemandSequenceNumber(demandSequenceNumber)
        }
    }
}
