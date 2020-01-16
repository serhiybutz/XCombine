//
//  XCombine+ZipDemandTracker.swift
//  XCombine
//
//  Created by Serge Bouts on 12/3/2019.
//  Copyright © 2019 Serge Bouts. All rights reserved.
//

import Combine
import Foundation

protocol XCombineZipDemandTracker {
    func config(with gate: XCombineZipGate)
    func run(with demand: Subscribers.Demand, finalizingWith finalization: (() -> Void)?)
    func addDemand(_ additionalDemand: Subscribers.Demand)
    func issueNextDemandSequenceNumber() -> Int?
    func consumeDemandSequenceNumber(_ demandSequenceNumber: Int)
}

extension XCombine {
    final class ZipDemandTracker: XCombineZipDemandTracker {
        // MARK: - Constants

        static let initialDemandSequenceNumber = 0

        // MARK: - Types

        enum DemandHandlingState {
            case pending(demandSequenceNumber: Int)
            case completed(demandSequenceNumber: Int)
        }

        // MARK: - Properties

        private unowned var gate: XCombineZipGate!
        private var collector: XCombineZipCollector { gate.collector }
        private var processor: XCombineZipProcessor { gate.processor }

        private var totalDemand: Subscribers.Demand = .none
        private var state: DemandHandlingState?

        // MARK: - API

        func config(with gate: XCombineZipGate) {
            self.gate = gate
        }

        func run(with additionalDemand: Subscribers.Demand, finalizingWith finalization: (() -> Void)?) {
            var isFinalizationRun = false

            addDemand(additionalDemand)

            while let demandSequenceNumber = issueNextDemandSequenceNumber() {
                collector.runOnBehalfOfDownstream(for: demandSequenceNumber) {
                    finalization?()
                    isFinalizationRun = true
                }
            }

            if !isFinalizationRun {
                finalization?()
            }
        }

        func addDemand(_ additionalDemand: Subscribers.Demand) {
            self.totalDemand += additionalDemand
        }

        func issueNextDemandSequenceNumber() -> Int? {
            guard let demandSequenceNumber = nextDemandSequenceNumber else { return nil }
            totalDemand -= .max(1)
            state = .pending(demandSequenceNumber: demandSequenceNumber)
            return demandSequenceNumber
        }

        private var nextDemandSequenceNumber: Int? {
            guard totalDemand > .none else { return nil }
            guard let state = state else {
                precondition(processor.latestConsumedDemandSequenceNumber == nil)
                return ZipDemandTracker.initialDemandSequenceNumber
            }
            switch state {
            case .completed(let completedDemandSequenceNumber):
                precondition(processor.latestConsumedDemandSequenceNumber == completedDemandSequenceNumber)
                return completedDemandSequenceNumber + 1
            default:
                return nil
            }
        }

        func consumeDemandSequenceNumber(_ demandSequenceNumber: Int) {
            guard case .pending(demandSequenceNumber) = state
            else { preconditionFailure() }
            state = .completed(demandSequenceNumber: demandSequenceNumber)
        }
    }
}
