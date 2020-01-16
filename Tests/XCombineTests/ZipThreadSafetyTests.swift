
//  ZipThreadSafetyTests.swift
//
//
//  Created by Serge Bouts.
//

import XCTest
@testable import XCombine
import Combine

// Actually Combine's publisher sends elements in a thread-safe manner, so what really this test does is asserting the operator's own logic (including backpressure handling's) in a concurrent environment.

final class ZipThreadSafetyTests: XCTestCase {
    @AtomicSync
    var isBusy = false

    @AtomicSync
    var collisions = 0

    @AtomicSync
    var runs = 0

    @AtomicSync
    var result: Set<String> = []

    var sut: AnyCancellable?

    override func setUp() {
        isBusy = false
        collisions = 0
        runs = 0
        result = []
        sut = nil
    }

    func test_receivesElementsConcurrently_usingOneAsyncSubject() {
        // Given

        let expectation = XCTestExpectation(description: "concurrent runs")

        let subject = BlockingSubject<String, Never>()
        let seq = (1...).lazy.publisher

        sut = subject
            .x.zip(seq)
            .sink(receiveValue: { element in
                self.$result.mutate { result in
                    let uniqueStr = element.0 + twoCharacterString(by: element.1)
                    result.insert(uniqueStr)
                }
                self.$runs.mutate { runs in
                    runs += 1
                    if runs == Configuration.concurrentRuns {
                        expectation.fulfill()
                    }
                }
                usleep(arc4random() % 1000)
            })

        // When

        let queue = DispatchQueue.global(qos: .userInitiated)

        for index in 0..<Configuration.concurrentRuns {
            queue.async {
                subject.send(twoCharacterString(by: index))
            }
        }

        wait(for: [expectation], timeout: Configuration.expectationWaitTimeout)

        // Then

        XCTAssertEqual(result.count, Configuration.concurrentRuns)
    }

    func test_receivesElementsConcurrently_usingTwoAsyncSubjects() {
        // Given

        let expectation = XCTestExpectation(description: "concurrent runs")

        // Here we need the basic functionality of a PassthroughSubject. But since it's a "hot" publisher ignoring backpressure, we'll have to use a custom publisher.
        let subject1 = BlockingSubject<String, Never>()
        let subject2 = BlockingSubject<String, Never>()

        sut = subject1
            .x.zip(subject2)
            .sink(receiveValue: { element in
                defer { self.isBusy = false }
                self.$isBusy.mutate { isBusy in
                    if isBusy {
                        self.collisions += 1
                    } else {
                        isBusy = true
                    }
                }
                self.$result.mutate { result in
                    let uniqueStr = element.0 + element.1
                    result.insert(uniqueStr)
                }
                self.$runs.mutate { runs in
                    runs += 1
                    if runs == Configuration.concurrentRuns {
                        expectation.fulfill()
                    }
                }
                usleep(arc4random() % 1000)
            })

        // When

        let queue = DispatchQueue.global(qos: .userInitiated)
        for index in 0..<Configuration.concurrentRuns {
            queue.async {
                subject1.send(twoCharacterString(by: index))
            }
            queue.async {
                subject2.send(twoCharacterString(by: index))
            }
        }

        // Then

        wait(for: [expectation], timeout: Configuration.expectationWaitTimeout)

        XCTAssertEqual(collisions, 0)
        XCTAssertEqual(result.count, Configuration.concurrentRuns)
    }
}
