//
//  ZipCompletesWithFinishedTests.swift
//
//
//  Created by Serge Bouts.
//

import XCTest
@testable import XCombine
import Combine

final class ZipCompletesWithFinishedTests: XCTestCase {
    var sut: AnyCancellable?

    override func tearDown() {
        sut = nil
    }

    func test_completesWithFinished_usingSequences1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        // When
        let seq1 = Array<Int>().publisher
        let seq2 = Array<String>().publisher

        var results = [EventType]()

        sut = seq1.x.zip(seq2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        let expected: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_completesWithFinished_usingSequences2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        // When
        let seq1 = [1].publisher
        let seq2 = ["a"].publisher

        var results = [EventType]()

        sut = seq1.x.zip(seq2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        let expected: [EventType] = [.value(.init(1, "a")), .completion(.finished)]
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_completesWithFinished_usingSubjects1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // (1)

        // - When

        // - Then
        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2) -- normal completion conditions met

        // - When

        up1.send(completion: .finished)

        // - Then
        let expected2: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_completesWithFinished_usingSubjects2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // (1)

        // - When

        // - Then
        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        up1.send(1)
        up2.send("a")

        // - Then
        let expected2: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3) -- normal completion conditions met

        // - When

        up1.send(completion: .finished)

        // - Then
        let expected3: [EventType] = [.value(.init(1, "a")), .completion(.finished)]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )
    }

    func test_completesWithFinished_usingSubjects3() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // (1)

        // - When

        // - Then
        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2) -- normal completion conditions NOT met

        // - When

        up1.send(1)
        up1.send(completion: .finished)

        // - Then
        let expected2: [EventType] = []
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3) -- normal completion conditions met

        // - When

        up2.send(completion: .finished)

        // - Then
        let expected3: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )
    }

    func test_completesWithFinished_usingSubjects4() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // (1)

        // - When

        // - Then
        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2) -- normal completion conditions NOT met

        // - When

        up1.send(1)
        up1.send(completion: .finished)

        // - Then
        let expected2: [EventType] = []
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3) -- normal completion conditions met

        // - When

        up2.send("a")
//        up2.send(completion: .finished)

        // - Then
        let expected3: [EventType] = [.value(.init(1, "a")), .completion(.finished)]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )
    }

    func test_completesWithFinishedAsynchronously_usingPassthroghSubjects1() {
        let queue = DispatchQueue(label: "com.xyz", attributes: .concurrent)
        var completionExpectation: XCTestExpectation?

        // Given

        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        completionExpectation = self.expectation(description: "completion")

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
                    completionExpectation!.fulfill()
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // When

        queue.async {
            up1.send(completion: .finished)
        }

        queue.async {
            up2.send(completion: .finished)
        }

        // Then

        waitForExpectations(timeout: 2, handler: nil)

        let expected: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_completesWithFinishedAsynchronously_usingPassthroghSubjects2() {
        let queue = DispatchQueue(label: "com.xyz", attributes: .concurrent)
        var emissionExpectation: XCTestExpectation?
        var completionExpectation: XCTestExpectation?

        // Given

        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        completionExpectation = self.expectation(description: "completion")

        emissionExpectation = self.expectation(description: "emission 1")

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
                    completionExpectation!.fulfill()
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
                    emissionExpectation!.fulfill()
            })

        // (1)

        // - When

        queue.async {
            up1.send(1)
        }

        queue.async {
            up2.send("a")
        }

        // - Then

        wait(for: [emissionExpectation!], timeout: Configuration.expectationWaitTimeout)

        let expected1: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        queue.async {
            up1.send(completion: .finished)
        }

        queue.async {
            up2.send(completion: .finished)
        }

        // - Then

//        wait(for: [completionExpectation!], timeout: Configuration.expectationWaitTimeout)
        waitForExpectations(timeout: 2, handler: nil)

        let expected2: [EventType] = [.value(.init(1, "a")), .completion(.finished)]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_completesWithFinishedAsynchronously_usingCurrentValueSubjects() {
        let queue = DispatchQueue(label: "com.xyz", attributes: .concurrent)
        var emissionExpectation: XCTestExpectation?
        var completionExpectation: XCTestExpectation?

        // Given

        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = CurrentValueSubject<Int, Never>(1)
        let up2 = CurrentValueSubject<String, Never>("a")

        var results = [EventType]()

        // (1)

        // - When

        emissionExpectation = self.expectation(description: "emission 1")
        completionExpectation = self.expectation(description: "completion")

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
                    completionExpectation!.fulfill()
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
                    emissionExpectation!.fulfill()
            })

        // - Then

        wait(for: [emissionExpectation!], timeout: Configuration.expectationWaitTimeout)

        let expected1: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        queue.async {
            up1.send(completion: .finished)
        }

        queue.async {
            up2.send(completion: .finished)
        }

        // - Then

//        wait(for: [completionExpectation!], timeout: Configuration.expectationWaitTimeout)
        waitForExpectations(timeout: 2, handler: nil)

        let expected2: [EventType] = [.value(.init(1, "a")), .completion(.finished)]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_completesWithFinished_disregardingBackpressure() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let seq1 = Array<Int>().publisher
        let seq2 = Array<String>().publisher

        var results = [EventType]()

        let p = seq1.x.zip(seq2)
        let s = TestSubscriber<(Int, String), Never>(
            receiveCompletion: { completion in
                results.append(.completion(completion))
        },
            receiveValue: { input in
                results.append(.value(Pair(input)))
                return .none
        })
        p.subscribe(s)

        // When

        // Then

        let expected: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_notCompletesWithFinishedUnderBackpressure_usingSequences1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let seq1 = [1].publisher
        let seq2 = Array<String>().publisher

        var results = [EventType]()

        let p = seq1.x.zip(seq2)
        let s = TestSubscriber<(Int, String), Never>(
            receiveCompletion: { completion in
                results.append(.completion(completion))
        },
            receiveValue: { input in
                results.append(.value(Pair(input)))
                return .none
        })
        p.subscribe(s)

        // - Then

        let expected1: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )
    }

    func test_notCompletesWithFinishedUnderBackpressure_usingSequences2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let seq1 = [1].publisher
        let seq2 = ["a", "b"].publisher

        var results = [EventType]()

        let p = seq1.x.zip(seq2)
        let s = TestSubscriber<(Int, String), Never>(
            receiveCompletion: { completion in
                results.append(.completion(completion))
        },
            receiveValue: { input in
                results.append(.value(Pair(input)))
                return .none
        })
        p.subscribe(s)

        // (1)

        // - When

        // - Then

        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        s.request(demand: .max(1))

        // - Then

        let expected2: [EventType] = [.value(.init(1, "a")), .completion(.finished)]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_completesWithFinishedDisregardingBackpressure_usingPassthroughSubjects1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        let p = up1.x.zip(up2)
        let s = TestSubscriber<(Int, String), Never>(
            receiveCompletion: { completion in
                results.append(.completion(completion))
        },
            receiveValue: { input in
                results.append(.value(Pair(input)))
                return .none
        })
        p.subscribe(s)

        // (1)

        // - When

        // - Then
        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        up1.send(completion: .finished)

        // - Then
        let expected2: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_completesWithFinishedDisregardingBackpressure_usingPassthroughSubjects2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        let p = up1.x.zip(up2)
        let s = TestSubscriber<(Int, String), Never>(
            receiveCompletion: { completion in
                results.append(.completion(completion))
        },
            receiveValue: { input in
                results.append(.value(Pair(input)))
                return .none
        })
        p.subscribe(s)

        // (1)

        // - When

        // - Then
        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        // should be discarded
        up1.send(1)
        up2.send("a")

        // - Then
        let expected2: [EventType] = []
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        s.request(demand: .unlimited)

        // - Then
        let expected3: [EventType] = []
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up2.send(completion: .finished)

        // - Then
        let expected4: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )
    }

    func test_completesWithFinishedDisregardingBackpressure_usingCurrentValueSubjects1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = CurrentValueSubject<Int, Never>(1)
        let up2 = CurrentValueSubject<String, Never>("a")

        var results = [EventType]()

        let p = up1.x.zip(up2)
        let s = TestSubscriber<(Int, String), Never>(
            receiveCompletion: { completion in
                results.append(.completion(completion))
        },
            receiveValue: { input in
                results.append(.value(Pair(input)))
                return .none
        })
        p.subscribe(s)

        // (1)

        // - When

        // - Then
        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        up1.send(completion: .finished)

        // - Then
        let expected2: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_completesWithFinishedDisregardingBackpressure_usingCurrentValueSubjects2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = CurrentValueSubject<Int, Never>(1)
        let up2 = CurrentValueSubject<String, Never>("a")

        var results = [EventType]()

        let p = up1.x.zip(up2)
        let s = TestSubscriber<(Int, String), Never>(
            receiveCompletion: { completion in
                results.append(.completion(completion))
        },
            receiveValue: { input in
                results.append(.value(Pair(input)))
                return .none
        })
        p.subscribe(s)

        // (1)

        // - When

        // - Then
        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        s.request(demand: .max(1))

        // - Then
        let expected2: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )


        // (3)

        // - When

        up1.send(completion: .finished)

        // - Then
        let expected3: [EventType] = [.value(.init(1, "a")), .completion(.finished)]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )
    }
}
