//
//  WithLatestFromTests.swift
//
//
//  Created by Serge Bouts.
//

import XCTest
@testable import XCombine
import Combine

final class WithLatestFromTests: XCTestCase {
    var sut: AnyCancellable?

    override func tearDown() {
        sut = nil
    }

    func test_emitsAccordingToItsLogic1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        sut = up1.x.withLatestFrom(up2)
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

        up2.send("foo")

        // - Then
        let expected3: [EventType] = []
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up1.send(2)

        // - Then
        let expected4: [EventType] = [.value(.init(2, "foo"))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )

        // (5)

        // - When

        up2.send("bar")

        // - Then
        let expected5: [EventType] = [.value(.init(2, "foo"))]
        XCTAssert(
            results == expected5,
            "Results expected to be \(expected5) but were \(results)"
        )

        // (6)

        // - When

        up1.send(3)

        // - Then
        let expected6: [EventType] = [.value(.init(2, "foo")), .value(.init(3, "bar"))]
        XCTAssert(
            results == expected6,
            "Results expected to be \(expected6) but were \(results)"
        )

        // (7)

        // - When

        up1.send(4)

        // - Then
        let expected7: [EventType] = [.value(.init(2, "foo")), .value(.init(3, "bar")), .value(.init(4, "bar"))]
        XCTAssert(
            results == expected7,
            "Results expected to be \(expected7) but were \(results)"
        )

        // (8)

        // - When

        up2.send("baz")

        // - Then
        let expected8: [EventType] = [.value(.init(2, "foo")), .value(.init(3, "bar")), .value(.init(4, "bar"))]
        XCTAssert(
            results == expected8,
            "Results expected to be \(expected8) but were \(results)"
        )

        // (9)

        // - When

        up1.send(5)

        // - Then
        let expected9: [EventType] = [.value(.init(2, "foo")), .value(.init(3, "bar")), .value(.init(4, "bar")), .value(.init(5, "baz"))]
        XCTAssert(
            results == expected9,
            "Results expected to be \(expected9) but were \(results)"
        )

        // (10)

        // - When

        up2.send("bazz")
        up2.send("bazzz")

        // - Then
        let expected10: [EventType] = [.value(.init(2, "foo")), .value(.init(3, "bar")), .value(.init(4, "bar")), .value(.init(5, "baz"))]
        XCTAssert(
            results == expected10,
            "Results expected to be \(expected10) but were \(results)"
        )

        // (11)

        // - When

        up1.send(6)

        // - Then
        let expected11: [EventType] = [.value(.init(2, "foo")), .value(.init(3, "bar")), .value(.init(4, "bar")), .value(.init(5, "baz")), .value(.init(6, "bazzz"))]
        XCTAssert(
            results == expected11,
            "Results expected to be \(expected11) but were \(results)"
        )

        // (12)

        // - When

        up1.send(7)

        // - Then
        let expected12: [EventType] = [.value(.init(2, "foo")), .value(.init(3, "bar")), .value(.init(4, "bar")), .value(.init(5, "baz")), .value(.init(6, "bazzz")), .value(.init(7, "bazzz"))]
        XCTAssert(
            results == expected12,
            "Results expected to be \(expected12) but were \(results)"
        )
    }

    func test_emitsAccordingToItsLogic2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        sut = up1.x.withLatestFrom(up2)
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

        up2.send("foo")

        // - Then
        let expected2: [EventType] = []
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        up2.send("bar")

        // - Then
        let expected3: [EventType] = []
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up1.send(1)

        // - Then
        let expected4: [EventType] = [.value(.init(1, "bar"))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )
    }

    func test_competesWithFinished1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        sut = up1.x.withLatestFrom(up2)
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

        up1.send(completion: .finished)

        // - Then
        let expected2: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_competesWithFinished2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        sut = up1.x.withLatestFrom(up2)
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

        up2.send(completion: .finished)

        // - Then
        let expected2: [EventType] = []
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        up1.send(completion: .finished)

        // - Then
        let expected3: [EventType] = [.completion(.finished)]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )
    }

    func test_competesWithFinished3() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = PassthroughSubject<String, Never>()

        var results = [EventType]()

        sut = up1.x.withLatestFrom(up2)
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

        up2.send("foo")
        up1.send(1)
        up2.send(completion: .finished)

        // - Then
        let expected2: [EventType] = [.value(.init(1, "foo"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        up1.send(completion: .finished)

        // - Then
        let expected3: [EventType] = [.value(.init(1, "foo")), .completion(.finished)]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )
    }

    func test_competesWithError1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, EventError>

        let up1 = PassthroughSubject<Int, EventError>()
        let up2 = PassthroughSubject<String, EventError>()

        var results = [EventType]()

        sut = up1.x.withLatestFrom(up2)
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
            "Results expected to be \(expected1) but were \(results)"
        )
    }

    func test_competesWithError2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, EventError>

        let up1 = PassthroughSubject<Int, EventError>()
        let up2 = PassthroughSubject<String, EventError>()

        var results = [EventType]()

        sut = up1.x.withLatestFrom(up2)
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

        up2.send(completion: .failure(EventError.ohNo))

        // - Then
        let expected2: [EventType] = [.completion(.failure(EventError.ohNo))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected1) but were \(results)"
        )
    }
}
