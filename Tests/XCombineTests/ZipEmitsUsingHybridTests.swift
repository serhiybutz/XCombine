//
//  ZipEmitsUsingHybridTests.swift
//
//
//  Created by Serge Bouts.
//

import XCTest
@testable import XCombine
import Combine

final class ZipEmitsUsingHybridTests: XCTestCase {
    func test_emitsHybrid_usingSequenceAndPassthroughSubject1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = [1].publisher
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

        s.request(demand: .max(1))

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

        let expected3: [EventType] = [.value(.init(1, "a")), .completion(.finished)]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )
    }

    func test_emitsHybrid_usingSequenceAndPassthroughSubject2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = [1, 2].publisher
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

        s.request(demand: .max(1))

        // - Then

        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        up2.send("a")
        up2.send("b")  // should be discarded

        // - Then

        let expected2: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        s.request(demand: .max(1))

        // - Then

        let expected3: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up2.send("c")

        // - Then

        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "c")), .completion(.finished)]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )
    }

    func test_emitsHybrid_usingSequenceAndPassthroughSubject3() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = [1, 2, 3].publisher
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

        s.request(demand: .max(1))

        // - Then

        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        up2.send("a")

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

        let expected3: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up2.send("b")

        // - Then

        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )

        // (5)

        // - When

        up2.send("c")

        // - Then

        let expected5: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c")), .completion(.finished)]
        XCTAssert(
            results == expected5,
            "Results expected to be \(expected5) but were \(results)"
        )
    }

    func test_emitsHybrid_usingInfiniteSequenceAndPassthroughSubject() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = (1...).lazy.publisher
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

        s.request(demand: .max(1))

        // - Then

        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        up2.send("a")

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

        let expected3: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up2.send("b")

        // - Then

        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )

        // (5)

        // - When

        up2.send("c")

        // - Then

        let expected5: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c"))]
        XCTAssert(
            results == expected5,
            "Results expected to be \(expected5) but were \(results)"
        )

        // (6)

        // - When

        up2.send(completion: .finished) // should be discarded

        // - Then

        let expected6: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c"))]
        XCTAssert(
            results == expected6,
            "Results expected to be \(expected6) but were \(results)"
        )
    }

    func test_emitsHybrid_usingPassthroughSubjectAndSequence() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = PassthroughSubject<Int, Never>()
        let up2 = ["a", "b", "c"].publisher

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

        s.request(demand: .max(1))

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

        let expected2: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        s.request(demand: .unlimited)

        // - Then

        let expected3: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up1.send(2)

        // - Then

        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )

        // (5)

        // - When

        up1.send(3)

        // - Then

        let expected5: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c")), .completion(.finished)]
        XCTAssert(
            results == expected5,
            "Results expected to be \(expected5) but were \(results)"
        )
    }

    func test_emitsHybrid_usingPassthroughSubjectAndInfiniteSequence() {
        // Given
        typealias EventType = Event<Pair<String, Int>, Never>

        let up1 = PassthroughSubject<String, Never>()
        let up2 = (1...).lazy.publisher

        var results = [EventType]()

        let p = up1.x.zip(up2)
        let s = TestSubscriber<(String, Int), Never>(
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

        let expected1: [EventType] = []
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        up1.send("a")

        // - Then

        let expected2: [EventType] = [.value(.init("a", 1))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        s.request(demand: .unlimited)

        // - Then

        let expected3: [EventType] = [.value(.init("a", 1))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up1.send("b")

        // - Then

        let expected4: [EventType] = [.value(.init("a", 1)), .value(.init("b", 2))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )

        // (5)

        // - When

        up1.send("c")

        // - Then

        let expected5: [EventType] = [.value(.init("a", 1)), .value(.init("b", 2)), .value(.init("c", 3))]
        XCTAssert(
            results == expected5,
            "Results expected to be \(expected5) but were \(results)"
        )

        // (6)

        // - When

        up1.send(completion: .finished) // should be discarded

        // - Then

        let expected6: [EventType] = [.value(.init("a", 1)), .value(.init("b", 2)), .value(.init("c", 3))]
        XCTAssert(
            results == expected6,
            "Results expected to be \(expected6) but were \(results)"
        )
    }

    func test_emitsHybrid_usingSequenceAndCurrentValueSubject1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = [1].publisher
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

        let expected2: [EventType] = [.value(.init(1, "a")), .completion(.finished)]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )
    }

    func test_emitsHybrid_usingSequenceAndCurrentValueSubject2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = [1, 2].publisher
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

        s.request(demand: .max(1))

        // - Then

        let expected3: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up2.send("b")

        // - Then

        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .completion(.finished)]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )
    }

    func test_emitsHybrid_usingSequenceAndCurrentValueSubject3() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = [1, 2].publisher
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

        s.request(demand: .unlimited)

        // - Then

        let expected3: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up2.send("b")
        up2.send("c")  // should be discarded

        // - Then

        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .completion(.finished)]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )
    }

    func test_emitsHybrid_usingSequenceAndCurrentValueSubject4() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = [1, 2, 3].publisher
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

        s.request(demand: .max(1))

        // - Then

        let expected3: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up2.send("b")

        // - Then

        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )

        // (5)

        // - When

        up2.send("c")

        // - Then

        let expected5: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected5,
            "Results expected to be \(expected5) but were \(results)"
        )

        // (6)

        // - When

        s.request(demand: .max(1))

        // - Then

        let expected6: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c")), .completion(.finished)]
        XCTAssert(
            results == expected6,
            "Results expected to be \(expected6) but were \(results)"
        )
    }

    func test_emitsHybrid_usingSequenceAndCurrentValueSubject5() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = [1, 2, 3].publisher
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

        s.request(demand: .unlimited)

        // - Then

        let expected3: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up2.send("b")

        // - Then

        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )

        // (5)

        // - When

        up2.send("c")

        // - Then

        let expected5: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c")), .completion(.finished)]
        XCTAssert(
            results == expected5,
            "Results expected to be \(expected5) but were \(results)"
        )
    }

    func test_emitsHybrid_usingCurrentValueSubjectAndSequence() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = CurrentValueSubject<Int, Never>(1)
        let up2 = ["a", "b", "c"].publisher

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

        s.request(demand: .max(1))

        // - Then

        let expected3: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up1.send(2)

        // - Then

        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )

        // (5)

        // - When

        up1.send(3)

        // - Then

        let expected5: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected5,
            "Results expected to be \(expected5) but were \(results)"
        )

        // (6)

        // - When

        s.request(demand: .max(1))

        // - Then

        let expected6: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c")), .completion(.finished)]
        XCTAssert(
            results == expected6,
            "Results expected to be \(expected6) but were \(results)"
        )
    }
}
