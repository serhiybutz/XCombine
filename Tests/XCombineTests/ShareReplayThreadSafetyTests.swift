//
//  ShareReplayThreadSafetyTests.swift
//
//
//  Created by Serge Bouts.
//

import XCTest
@testable import XCombine
import Combine

final class ShareReplayThreadSafetyTests: XCTestCase {
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

    // Skip this test deliberately, as at the time of writing Combine Publisher's `subscribe(_:)` is not thread-safe.
    func skip_test_publisherSubscribe() {
        // Given

        let upstreamPublisher = PublisherSubscribeMock<Int, Never>()

        let expectation = XCTestExpectation(description: "concurrent runs")

        upstreamPublisher.subscriptionHandler = { p in
            if p.runs == Configuration.concurrentRuns {
                expectation.fulfill()
            }
        }

        let shareOperator = upstreamPublisher.x.share(replay: 0)

        // When

        for _ in 1...Configuration.concurrentRuns {
            DispatchQueue.global(qos: .userInitiated).async {
                let subscriber = Subscribers.Sink<Int, Never>(
                    receiveCompletion: {_ in },
                    receiveValue: {_ in }
                )
                let _ = shareOperator.subscribe(subscriber)
                subscriber.cancel()
            }
        }

        // Then

        wait(for: [expectation], timeout: Configuration.expectationWaitTimeout)

        XCTAssertEqual(upstreamPublisher.collisions, 0)
    }

    func test_receivesElementsConcurently_withReplayCapacityOf0() {
        _test_receivesElementsConcurently(replayCapacity: 0)
    }

    func test_receivesElementsConcurently_withReplayCapacityOf1() {
        _test_receivesElementsConcurently(replayCapacity: 1)
    }

    func test_receivesElementsConcurently_withReplayCapacityOf5() {
        _test_receivesElementsConcurently(replayCapacity: 5)
    }

    func test_receivesElementsConcurently_withReplayCapacityOfConcurrentRuns() {
        _test_receivesElementsConcurently(replayCapacity: Configuration.concurrentRuns)
    }
}

extension ShareReplayThreadSafetyTests {
    // Actually Combine's publisher sends elements in a thread-safe manner, so what really this test does is asserting the operator's own logic (including backpressure handling's) in a concurrent environment.
    func _test_receivesElementsConcurently(replayCapacity: Int) {
        // Given

        let expectation = XCTestExpectation(description: "concurrent runs")

        // Here we need the basic functionality of a PassthroughSubject. But since it's a "hot" publisher ignoring backpressure, we'll have to use a custom publisher.
        let upstreamPublisher = BlockingSubject<Int, Never>()

        sut = upstreamPublisher
            .x.share(replay: replayCapacity)
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
                    result.insert(String(element))
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
                upstreamPublisher.send(index)
            }
        }

        // Then

        wait(for: [expectation], timeout: Configuration.expectationWaitTimeout)

        XCTAssertEqual(collisions, 0)
        XCTAssertEqual(result.count, Configuration.concurrentRuns)
    }
}
