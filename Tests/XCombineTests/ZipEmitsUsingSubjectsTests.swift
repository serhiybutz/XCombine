//
//  ZipEmitsUsingSubjectsTests.swift
//
//
//  Created by Serge Bouts.
//


import XCTest
@testable import XCombine
import Combine

final class ZipEmitsUsingSubjectsTests: XCTestCase {
    var sut: AnyCancellable?

    override func tearDown() {
        sut = nil
    }

    func test_emits_usingPassthroughSubjects1() {
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

        up1.send(2)

        // - Then
        let expected4: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )

        // (5)

        // - When

        up2.send("b")

        // - Then
        let expected5: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected5,
            "Results expected to be \(expected5) but were \(results)"
        )

        // (6)

        // - When

        up1.send(3)

        // - Then
        let expected6: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected6,
            "Results expected to be \(expected6) but were \(results)"
        )

        // (7)

        // - When

        up2.send("c")

        // - Then
        let expected7: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c"))]
        XCTAssert(
            results == expected7,
            "Results expected to be \(expected7) but were \(results)"
        )

        // (8)

        // - When

        up1.send(completion: .finished)

        // - Then
        let expected8: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .value(.init(3, "c")), .completion(.finished)]
        XCTAssert(
            results == expected8,
            "Results expected to be \(expected8) but were \(results)"
        )
    }

    func test_emits_usingPassthroughSubjects2() {
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

        up1.send(1)
        up2.send("a")

        // - Then
        let expected1: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        up1.send(2)

        // - Then
        let expected2: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        up1.send(3)

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

        up1.send(completion: .finished)
//        up2.send(completion: .finished)

        // - Then
        let expected5: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .completion(.finished)]
        XCTAssert(
            results == expected5,
            "Results expected to be \(expected5) but were \(results)"
        )
    }

    func test_emits_usingCurrentValueSubjects() {
        // Given
        typealias EventType = Event<Pair<Int, String>, Never>

        let up1 = CurrentValueSubject<Int, Never>(1)
        let up2 = CurrentValueSubject<String, Never>("a")

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
        let expected1: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected1,
            "Results expected to be \(expected1) but were \(results)"
        )

        // (2)

        // - When

        up1.send(2)

        // - Then
        let expected2: [EventType] = [.value(.init(1, "a"))]
        XCTAssert(
            results == expected2,
            "Results expected to be \(expected2) but were \(results)"
        )

        // (3)

        // - When

        up2.send("b")

        // - Then
        let expected3: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b"))]
        XCTAssert(
            results == expected3,
            "Results expected to be \(expected3) but were \(results)"
        )

        // (4)

        // - When

        up1.send(completion: .finished)

        // Then
        let expected4: [EventType] = [.value(.init(1, "a")), .value(.init(2, "b")), .completion(.finished)]
        XCTAssert(
            results == expected4,
            "Results expected to be \(expected4) but were \(results)"
        )
    }
}
