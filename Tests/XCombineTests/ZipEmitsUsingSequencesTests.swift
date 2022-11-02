//
//  ZipEmitsUsingSequencesTests.swift
//
//
//  Created by Serhiy Butz.
//

import XCTest
@testable import XCombine
import Combine

final class ZipEmitsUsingSequencesTests: XCTestCase {
    var sut: AnyCancellable?

    override func tearDown() {
        sut = nil
    }

    func test_emits_usingSequences1() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>
        let expected: [EventType] = [.value(.init(1, "a")), .completion(.finished)]

        // When
        let up1 = [1].publisher
        let up2 = ["a"].publisher

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_emits_usingSequences2() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>
        let expected: [EventType] = [.value(.init(1, "a")), .completion(.finished)]

        // When
        let up1 = [1, 2].publisher
        let up2 = ["a"].publisher

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_emits_usingSequences3() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>
        let expected: [EventType] = [.value(.init(1, "a")), .completion(.finished)]

        // When
        let up1 = [1, 2, 3].publisher
        let up2 = ["a"].publisher

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_emits_usingSequences4() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>
        let expected: [EventType] = [.value(.init(1, "a")), .completion(.finished)]

        // When
        let up1 = [1].publisher
        let up2 = ["a", "b"].publisher

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_emits_usingSequences5() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>
        let expected: [EventType] = [.value(.init(1, "a")), .completion(.finished)]

        // When
        let up1 = [1].publisher
        let up2 = ["a", "b", "c"].publisher

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_emits_usingSequences6() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>
        let expected: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .completion(.finished)]

        // When
        let up1 = [1, 2].publisher
        let up2 = ["a", "b"].publisher

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_emits_usingSequences7() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>
        let expected: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .completion(.finished)]

        // When
        let up1 = [1, 2].publisher
        let up2 = ["a", "b", "c"].publisher

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_emits_usingSequences8() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>
        let expected: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .completion(.finished)]

        // When
        let up1 = [1, 2].publisher
        let up2 = ["a", "b", "c", "d"].publisher

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_emits_usingSequences9() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>
        let expected: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c")), .completion(.finished)]

        // When
        let up1 = [1, 2, 3].publisher
        let up2 = ["a", "b", "c"].publisher

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_emits_usingInfiniteSequenceCombinedWithFiniteSequence() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>
        let expected: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c")), .completion(.finished)]

        // When
        let up1 = (1...).lazy.publisher
        let up2 = ["a", "b", "c"].publisher

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_emits_usingFiniteSequenceCombinedWithInfiniteSequence() {
        // Given
        typealias EventType = Event<Pair<String, Int>, Never>
        let expected: [EventType] = [.value(.init("a", 1)), .value(.init("b", 2)), .value(.init("c", 3)), .completion(.finished)]

        // When
        let up1 = ["a", "b", "c"].publisher
        let up2 = (1...).lazy.publisher

        var results = [EventType]()

        sut = up1.x.zip(up2)
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(Pair(input)))
            })

        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }
}
