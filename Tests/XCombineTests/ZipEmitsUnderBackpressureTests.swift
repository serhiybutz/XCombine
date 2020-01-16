//
//  ZipEmitsUnderBackpressureTests.swift
//
//
//  Created by Serge Bouts.
//

import XCTest
@testable import XCombine
import Combine

final class ZipEmitsUnderBackpressureTests: XCTestCase {
    func test_emitsUnderBackpressure_usingSequences1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let seq1 = [1].publisher
        let seq2 = ["a"].publisher

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

    func test_emitsUnderBackpressure_usingSequences2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let seq1 = [1, 2].publisher
        let seq2 = ["a", "b", "c"].publisher

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

        let expected2: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        s.request(demand: .unlimited)

        // - Then

        let expected3: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .completion(.finished)]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )
    }

    func test_emitsUnderBackpressure_usingSequences3() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let seq1 = [1, 2, 3].publisher
        let seq2 = ["a", "b", "c"].publisher

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

        s.request(demand: .max(1))

        // - Then

        let expected1: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        s.request(demand: .max(1))

        // - Then

        let expected2: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        s.request(demand: .unlimited)

        // - Then

        let expected3: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c")), .completion(.finished)]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )
    }

    func test_emitsUnderBackpressure_usingSequences4() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let seq1 = [1, 2, 3].publisher
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

        s.request(demand: .max(1))

        // - Then

        let expected1: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        s.request(demand: .max(2))

        // - Then

        let expected2: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .completion(.finished)]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_emitsUnderBackpressure_usingInfiniteSequences() {
        // Given
        typealias EventType = Event<Pair<Int, Int>, Never>

        // When
        let seq1 = (0...).lazy.map { $0 * 2 }.publisher
        let seq2 = (0...).lazy.map { $0 * 2 + 1 }.publisher

        var results = [EventType]()

        let p = seq1.x.zip(seq2)

        let s = TestSubscriber<(Int, Int), Never>(
            receiveCompletion: { completion in
                results.append(.completion(completion))
        },
            receiveValue: { input in
                results.append(.value(Pair(input)))
                return .none
        }
        )
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

        let expected2: [EventType] = [.value(.init(0, 1))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        s.request(demand: .max(2))

        // - Then

        let expected3: [EventType] = [.value(.init(0, 1)), .value(.init(2, 3)), .value(.init(4, 5))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )
    }

    func test_emitsUnderBackpressure_usingCurrentValueSubjects1() {
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

        // should be discarded
        up1.send(2)
        up2.send("b")

        // should be tracked in step (4)
        up1.send(3)
        up2.send("c")

        // - Then
        let expected3: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        s.request(demand: .max(1))

        // - Then
        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(3, "c"))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )

        // (5)

        // - When

        s.request(demand: .unlimited)

        // - Then
        let expected5: [EventType] = [.value(.init(1, "a")), .value(.init(3, "c"))]
        XCTAssert(
            results == expected5,
            "Results expected to be \(expected5) but were \(results)"
        )
    }

    func test_emitsUnderBackpressure_usingCurrentValueSubjects2() {
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

        s.request(demand: .max(2))

        // - Then
        let expected2: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        up1.send(2)
        up2.send("b")

        // should be discarded
        up1.send(3)
        up2.send("c")

        // should be tracked in step (4)
        up1.send(4)
        up2.send("d")

        // - Then
        let expected3: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        s.request(demand: .unlimited)

        // - Then
        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(4, "d"))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )
    }
}
