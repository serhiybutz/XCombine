//
//  ZipEmitsAsynchronouslyTests.swift
//
//
//  Created by Serge Bouts.
//

import XCTest
@testable import XCombine
import Combine

final class ZipEmitsAsynchronouslyTests: XCTestCase {
    var sut: AnyCancellable?

    override func tearDown() {
        sut = nil
    }

    func test_emitsAsynchronously_usingPassthroghSubjects() {
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

        emissionExpectation = self.expectation(description: "emission 2")

        queue.async {
            up1.send(2)
        }

        queue.async {
            up2.send("b")
        }

        // - Then

        wait(for: [emissionExpectation!], timeout: Configuration.expectationWaitTimeout)

        let expected2: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        emissionExpectation = self.expectation(description: "emission 3")

        queue.async {
            up1.send(3)
        }

        queue.async {
            up2.send("c")
        }

        // - Then

        wait(for: [emissionExpectation!], timeout: Configuration.expectationWaitTimeout)

        let expected3: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

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

        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c")), .completion(.finished)]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )
    }

    func test_emitsAsynchronously_usingCurrentValueSubjects() {
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

        emissionExpectation = self.expectation(description: "emission 2")

        queue.async {
            up1.send(2)
        }

        queue.async {
            up2.send("b")
        }

        // - Then

        wait(for: [emissionExpectation!], timeout: Configuration.expectationWaitTimeout)

        let expected2: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        queue.async {
            up1.send(completion: .finished)
        }

        queue.async {
            up2.send(completion: .finished)
        }

        // - Then

        waitForExpectations(timeout: 2, handler: nil)

        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .completion(.finished)]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )
    }

    func test_emitsAsynchronously_usingFutures() {
        let queue = DispatchQueue(label: "com.xyz", attributes: .concurrent)
        var emissionExpectation: XCTestExpectation?
        var completionExpectation: XCTestExpectation?

        // Given

        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = Future<Int, Never> { promise in
            queue.asyncAfter(deadline: .now() + 0.5) {
                promise(.success(1))
            }
        }

        let up2 = Future<String, Never> { promise in
            queue.asyncAfter(deadline: .now() + 1) {
                promise(.success("a"))
            }
        }

        var results = [EventType]()

        // When

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

        // Then

        waitForExpectations(timeout: 2, handler: nil)

        let expected: [EventType] = [.value(.init(1, "a")), .completion(.finished)]
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }
}
