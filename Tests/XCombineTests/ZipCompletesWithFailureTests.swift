//
//  ZipCompletesWithFailureTests.swift
//
//
//  Created by Serhiy Butz.
//

import XCTest
@testable import XCombine
import Combine

final class ZipCompletesWithFailureTests: XCTestCase {
    var sut: AnyCancellable?

    override func tearDown() {
        sut = nil
    }

    func test_completesWithFailure_usingSubjects1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, EventError>

        let up1 = PassthroughSubject<Int, EventError>()
        let up2 = PassthroughSubject<String, EventError>()

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

        up1.send(completion: .failure(EventError.ohNo))

        // - Then
        let expected2: [EventType] = [.completion(.failure(EventError.ohNo))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_completesWithFailure_usingSubjects2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, EventError>

        let up1 = PassthroughSubject<Int, EventError>()
        let up2 = PassthroughSubject<String, EventError>()

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

        // Then
        let expected2: [EventType] = []
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        up1.send(completion: .failure(EventError.ohNo))

        // - Then
        let expected3: [EventType] = [.completion(.failure(EventError.ohNo))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )
    }

    func test_completesWithFailure_usingSubjects3() {
        // Given
        typealias EventType = Event<Pair<Int, String>, EventError>

        let up1 = PassthroughSubject<Int, EventError>()
        let up2 = PassthroughSubject<String, EventError>()

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

        // - Then
        let expected2: [EventType] = []
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        up2.send("a")

        // - Then
        let expected3: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up1.send(completion: .failure(EventError.ohNo))

        // - Then
        let expected4: [EventType] = [.value(.init(1, "a")), .completion(.failure(EventError.ohNo))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )
    }

    func test_completesWithFailureAsynchronously_usingPassthroughSubjects1() {
        let queue = DispatchQueue(label: "com.xyz", attributes: .concurrent)
        var completionExpectation: XCTestExpectation?

        // Given

        typealias EventType = Event<Pair<Int, String>, EventError>

        let up1 = PassthroughSubject<Int, EventError>()
        let up2 = PassthroughSubject<String, EventError>()

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
            up1.send(completion: .failure(EventError.ohNo))
        }

        // Then

        waitForExpectations(timeout: 2, handler: nil)

        let expected1: [EventType] = [.completion(.failure(EventError.ohNo))]
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )
    }

    func test_completesWithFailureAsynchronously_usingPassthroughSubjects2() {
        let queue = DispatchQueue(label: "com.xyz", attributes: .concurrent)
        var emissionExpectation: XCTestExpectation?
        var completionExpectation: XCTestExpectation?

        // Given

        typealias EventType = Event<Pair<Int, String>, EventError>

        let up1 = PassthroughSubject<Int, EventError>()
        let up2 = PassthroughSubject<String, EventError>()

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
                    emissionExpectation!.fulfill()
            })

        // (1)

        // - When

        emissionExpectation = self.expectation(description: "emission 1")

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
            up1.send(completion: .failure(EventError.ohNo))
        }

        // - Then

        waitForExpectations(timeout: 2, handler: nil)

        let expected2: [EventType] = [.value(.init(1, "a")), .completion(.failure(EventError.ohNo))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_completesWithFailureAsynchronously_usingCurrentValueSubjects() {
        let queue = DispatchQueue(label: "com.xyz", attributes: .concurrent)
        var emissionExpectation: XCTestExpectation?
        var completionExpectation: XCTestExpectation?

        // Given

        typealias EventType = Event<Pair<Int, String>, EventError>

        let up1 = CurrentValueSubject<Int, EventError>(1)
        let up2 = CurrentValueSubject<String, EventError>("a")

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
            up1.send(completion: .failure(EventError.ohNo))
        }

        // - Then

        waitForExpectations(timeout: 2, handler: nil)

        let expected2: [EventType] = [.value(.init(1, "a")), .completion(.failure(EventError.ohNo))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_completesWithFailureAsynchronously_usingFutures() {
        let queue = DispatchQueue(label: "com.xyz", attributes: .concurrent)
        var completionExpectation: XCTestExpectation?

        // Given

        typealias EventType = Event<Pair<Int, String>, EventError>

        let up1 = Future<Int, EventError> { promise in
            queue.asyncAfter(deadline: .now() + 0.5) {
                promise(.failure(EventError.ohNo))
            }
        }

        let up2 = Future<String, EventError> { promise in
            queue.asyncAfter(deadline: .now() + 1) {
                promise(.success("a"))
            }
        }

        var results = [EventType]()

        // When

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

        // Then

        waitForExpectations(timeout: 5, handler: nil)

        let expected: [EventType] = [.completion(.failure(EventError.ohNo))]
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_completesWithFailure_disregardingBackpressure_winsFinished() {
        // Given
        typealias EventType = Event<Pair<Int, String>, EventError>

        let up1 = Array<Int>().publisher.setFailureType(to: EventError.self)
        let up2 = Fail<String, EventError>(error: EventError.ohNo)

        var results = [EventType]()

        let p = up1.x.zip(up2)
        let s = TestSubscriber<(Int, String), EventError>(
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

        let expected1: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )
    }

    func test_completesWithFailure_disregardingBackpressure_winsFailure() {
        // Given
        typealias EventType = Event<Pair<String, Int>, EventError>

        let up1 = Fail<String, EventError>(error: EventError.ohNo)
        let up2 = Array<Int>().publisher.setFailureType(to: EventError.self)

        var results = [EventType]()

        let p = up1.x.zip(up2)
        let s = TestSubscriber<(String, Int), EventError>(
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

        let expected1: [EventType] = [.completion(.failure(EventError.ohNo))]
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )
    }

    func test_completesWithFailureDisregardingBackpressure_usingCurrentValueSubjects() {
        // Given
        typealias EventType = Event<Pair<Int, String>, EventError>

        let up1 = CurrentValueSubject<Int, EventError>(1)
        let up2 = CurrentValueSubject<String, EventError>("a")

        var results = [EventType]()

        let p = up1.x.zip(up2)
        let s = TestSubscriber<(Int, String), EventError>(
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

        up1.send(completion: .failure(EventError.ohNo))

        // - Then
        let expected2: [EventType] = [.completion(.failure(EventError.ohNo))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }
}
