//
//  ShareReplayWithSequencesWithCapacityOf1.swift
//
//
//  Created by Serge Bouts.
//

import XCTest
@testable import XCombine
import Combine

final class ShareReplayLogicWithSequencesWithCapacityOf1: XCTestCase {
    let capacity = 1

    var subscriber1: AnyCancellable?
    var subscriber2: AnyCancellable?
    var subscriber3: AnyCancellable?

    override func tearDown()  {
        subscriber1 = nil
        subscriber2 = nil
        subscriber3 = nil
    }

    func test_empty() {
        // Given
        let publisher = Array<Int>().publisher.x.share(replay: capacity)

        var results = [Event<Int, Never>]()
        subscriber1 = publisher
            .sink(
                receiveCompletion: { completion in
                    results.append(.completion(completion))
            },
                receiveValue: { input in
                    results.append(.value(input))
            })

        // When
        // Then
        let expected: [Event<Int, Never>] = [.completion(.finished)]
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }

    func test_oneElement() {
        // Given

        let publisher = [1].publisher.x.share(replay: capacity)

        var results1: [Event<Int, Never>] = []
        var expected1: [Event<Int, Never>] = []
        var results2: [Event<Int, Never>] = []
        var expected2: [Event<Int, Never>] = []

        // (1)

        // - When

        subscriber1 = publisher
            .sink(
                receiveCompletion: { completion in
                    results1.append(.completion(completion))
            },
                receiveValue: { input in
                    results1.append(.value(input))
            })

        // - Then

        expected1 = [.value(1), .completion(.finished)]
        XCTAssert(
            results1 == expected1,
            "Results expected to be \(expected1) but were \(results1)"
        )

        // (2)

        // - When

        subscriber2 = publisher
            .sink(
                receiveCompletion: { completion in
                    results2.append(.completion(completion))
            },
                receiveValue: { input in
                    results2.append(.value(input))
            })

        // - Then
        expected2 = [.value(1), .completion(.finished)]
        XCTAssert(
            results2 == expected2,
            "Results expected to be \(expected2) but were \(results2)"
        )
    }

    func test_twoElementsWith2Subscribers() {
        // Given

        let publisher = [1, 2].publisher.x.share(replay: capacity)

        var results1: [Event<Int, Never>] = []
        var expected1: [Event<Int, Never>] = []
        var results2: [Event<Int, Never>] = []
        var expected2: [Event<Int, Never>] = []

        // (1)

        // - When

        subscriber1 = publisher
            .sink(
                receiveCompletion: { completion in
                    results1.append(.completion(completion))
            },
                receiveValue: { input in
                    results1.append(.value(input))
            })

        // - Then

        expected1 = [.value(1), .value(2), .completion(.finished)]
        XCTAssert(
            results1 == expected1,
            "Results expected to be \(expected1) but were \(results1)"
        )

        // (2)

        // - When

        subscriber2 = publisher
            .sink(
                receiveCompletion: { completion in
                    results2.append(.completion(completion))
            },
                receiveValue: { input in
                    results2.append(.value(input))
            })

        // - Then
        expected2 = [.value(2), .completion(.finished)]
        XCTAssert(
            results2 == expected2,
            "Results expected to be \(expected2) but were \(results2)"
        )
    }

    func test_twoElementsWith3Subscribers() {
        // Given

        let publisher = [1, 2].publisher.x.share(replay: capacity)

        var results1: [Event<Int, Never>] = []
        var expected1: [Event<Int, Never>] = []
        var results2: [Event<Int, Never>] = []
        var expected2: [Event<Int, Never>] = []
        var results3: [Event<Int, Never>] = []
        var expected3: [Event<Int, Never>] = []

        // (1)

        // - When

        subscriber1 = publisher
            .sink(
                receiveCompletion: { completion in
                    results1.append(.completion(completion))
            },
                receiveValue: { input in
                    results1.append(.value(input))
            })

        // - Then

        expected1 = [.value(1), .value(2), .completion(.finished)]
        XCTAssert(
            results1 == expected1,
            "Results expected to be \(expected1) but were \(results1)"
        )

        // (2)

        // - When

        subscriber2 = publisher
            .sink(
                receiveCompletion: { completion in
                    results2.append(.completion(completion))
            },
                receiveValue: { input in
                    results2.append(.value(input))
            })

        // - Then
        expected2 = [.value(2), .completion(.finished)]
        XCTAssert(
            results2 == expected2,
            "Results expected to be \(expected2) but were \(results2)"
        )

        // (3)

        // - When

        subscriber3 = publisher
            .sink(
                receiveCompletion: { completion in
                    results3.append(.completion(completion))
            },
                receiveValue: { input in
                    results3.append(.value(input))
            })

        // - Then
        expected3 = [.value(2), .completion(.finished)]
        XCTAssert(
            results3 == expected3,
            "Results expected to be \(expected3) but were \(results3)"
        )
    }

    func test_oneElement_respectsBackpressureWith2Subscribers() {
        // Given

        let publisher = [1].publisher.x.share(replay: capacity)

        var results1: [Event<Int, Never>] = []
        var expected1: [Event<Int, Never>] = []
        var results2: [Event<Int, Never>] = []
        var expected2: [Event<Int, Never>] = []

        // (1)

        // - When

        let subscriber1 = TestSubscriber<Int, Never>(
            receiveCompletion: { completion in
                results1.append(.completion(completion))
        },
            receiveValue: { input in
                results1.append(.value(input))
                return .none
        })
        publisher.subscribe(subscriber1)

        subscriber2 = publisher
            .sink(
                receiveCompletion: { completion in
                    results2.append(.completion(completion))
            },
                receiveValue: { input in
                    results2.append(.value(input))
            })

        // - Then

        expected1 = []
        XCTAssert(
            results1 == expected1,
            "Results expected to be \(expected1) but were \(results1)"
        )

        expected2 = []
        XCTAssert(
            results2 == expected2,
            "Results expected to be \(expected2) but were \(results2)"
        )

        // (3)

        // - When

        subscriber1.request(demand: .max(1))

        // - Then

        expected1 = [.value(1), .completion(.finished)]
        XCTAssert(
            results1 == expected1,
            "Results expected to be \(expected1) but were \(results1)"
        )

        expected2 = [.value(1), .completion(.finished)]
        XCTAssert(
            results2 == expected2,
            "Results expected to be \(expected2) but were \(results2)"
        )
    }

    func test_oneElement_respectsBackpressureWith3Subscribers() {
        // Given

        let publisher = [1].publisher.x.share(replay: capacity)
        var results1: [Event<Int, Never>] = []
        var expected1: [Event<Int, Never>] = []
        var results2: [Event<Int, Never>] = []
        var expected2: [Event<Int, Never>] = []
        var results3: [Event<Int, Never>] = []
        var expected3: [Event<Int, Never>] = []

        // (1)

        // - When

        let subscriber1 = TestSubscriber<Int, Never>(
            receiveCompletion: { completion in
                results1.append(.completion(completion))
        },
            receiveValue: { input in
                results1.append(.value(input))
                return .none
        })
        publisher.subscribe(subscriber1)

        let subscriber2 = TestSubscriber<Int, Never>(
            receiveCompletion: { completion in
                results2.append(.completion(completion))
        },
            receiveValue: { input in
                results2.append(.value(input))
                return .none
        })
        publisher.subscribe(subscriber2)

        subscriber3 = publisher
            .sink(
                receiveCompletion: { completion in
                    results3.append(.completion(completion))
            },
                receiveValue: { input in
                    results3.append(.value(input))
            })

        // - Then

        expected1 = []
        XCTAssert(
            results1 == expected1,
            "Results expected to be \(expected1) but were \(results1)"
        )

        expected2 = []
        XCTAssert(
            results2 == expected2,
            "Results expected to be \(expected2) but were \(results2)"
        )

        expected3 = []
        XCTAssert(
            results3 == expected3,
            "Results expected to be \(expected3) but were \(results3)"
        )

        // (3)

        // - When

        subscriber1.request(demand: .max(1))

        // - Then

        expected1 = []
        XCTAssert(
            results1 == expected1,
            "Results expected to be \(expected1) but were \(results1)"
        )

        expected2 = []
        XCTAssert(
            results2 == expected2,
            "Results expected to be \(expected2) but were \(results2)"
        )

        expected3 = []
        XCTAssert(
            results3 == expected3,
            "Results expected to be \(expected3) but were \(results3)"
        )

        // (4)

        // - When

        subscriber2.request(demand: .max(1))

        // - Then

        expected1 = [.value(1), .completion(.finished)]
        XCTAssert(
            results1 == expected1,
            "Results expected to be \(expected1) but were \(results1)"
        )

        expected2 = [.value(1), .completion(.finished)]
        XCTAssert(
            results2 == expected2,
            "Results expected to be \(expected2) but were \(results2)"
        )

        expected3 = [.value(1), .completion(.finished)]
        XCTAssert(
            results3 == expected3,
            "Results expected to be \(expected3) but were \(results3)"
        )
    }
}
