//
//  ShareReplayCombinationTests.swift
//
//
//  Created by Serge Bouts.
//

import XCTest
@testable import XCombine
import Combine

final class ShareReplayCombinationTests: XCTestCase {

    // Capacity: 1

    //
    func test_doesntEmitInitially() {
        _testRunner(_test_doesntEmitInitially)
    }

    // - Events: 0
    func test_completesWithFinished() {
        _testRunner(_test_completesWithFinished)
    }

    func test_doesntEmitAfterCompletionWithFinished() {
        _testRunner(_test_doesntEmitAfterCompletionWithFinished)
    }

    func test_doesntCompleteAfterCompletionWithFinished() {
        _testRunner(_test_doesntCompleteAgainAfterCompletionWithFinished)
    }

    func test_doesntFailAfterCompletionWithFinished() {
        _testRunner(_test_doesntFailAfterCompletionWithFinished)
    }

    func test_completesWithError() {
        _testRunner(_test_completesWithError)
    }

    func test_doesntEmitAfterCompletionWithError() {
        _testRunner(_test_doesntEmitAfterCompletionWithError)
    }

    func test_doesntCompleteAfterCompletionWithError() {
        _testRunner(_test_doesntAgainAfterCompletionWithError)
    }

    func test_doesntFailAfterCompletionWithError() {
        _testRunner(_test_doesntFailAfterCompletionWithError)
    }

    //

    func test_autocancelOnDeallocation1() {
        _testRunner(_test_autocancelOnDeallocation1)
    }

    func test_autocancelOnDeallocation2() {
        _testRunner(_test_autocancelOnDeallocation2)
    }

    func test_autocancelOnDeallocation3() {
        _testRunner(_test_autocancelOnDeallocation3)
    }

    // - Events: 1

    func test_receivesOneEvent() {
        _testRunner(_test_receivesOneEvent)
    }

    func test_receivesOneEventAndCompletion() {
        _testRunner(_test_receivesOneEventAndCompletion)
    }

    func test_doesntReceivesAfterOneEventAndCompletion() {
        _testRunner(_test_doesntReceiveAfterOneEventAndCompletion)
    }

    func test_doesntCompleteAfterOneEventAndCompletion() {
        _testRunner(_test_doesntCompleteAfterOneEventAndCompletion)
    }

    func test_doesntFailAfterOneEventAndCompletion() {
        _testRunner(_test_doesntFailAfterOneEventAndCompletion)
    }

    func test_failsAfterOneEvent() {
        _testRunner(_test_failsAfterOneEvent)
    }

    func test_doesntEmitAfterOneEventAndFailure() {
        _testRunner(_test_doesntEmitAfterOneEventAndFailure)
    }

    func test_doesntCompleteAfterOneEventAndFailure() {
        _testRunner(_test_doesntCompleteAfterOneEventAndFailure)
    }

    func test_doesntFailAfterOneEventAndFailure() {
        _testRunner(_test_doesntFailAfterOneEventAndFailure)
    }

    // - Events: 2

    func test_receivesTwoEvents() {
        _testRunner(_test_receivesTwoEvents)
    }

    func test_receivesTwoEventsAndCompletion() {
        _testRunner(_test_receivesTwoEventsAndCompletion)
    }

    func test_receivesTwoEventsAndFailure() {
        _testRunner(_test_receivesTwoEventsAndFailure)
    }

    func test_doesntReceiveAfterTwoEventsAndCompletion() {
        _testRunner(_test_doesntReceiveAfterTwoEventsAndCompletion)
    }

    func test_doesntCompleteAfterTwoEventsAndCompletion() {
        _testRunner(_test_doesntCompleteAfterTwoEventsAndCompletion)
    }

    func test_doesntFailAfterTwoEventsAndCompletion() {
        _testRunner(_test_doesntFailAfterTwoEventsAndCompletion)
    }

    func test_doesntEmitAfterTwoEventsAndFailure() {
        _testRunner(_test_doesntEmitAfterTwoEventsAndFailure)
    }

    func test_doesntCompleteAfterTwoEventsAndFailure() {
        _testRunner(_test_doesntCompleteAfterTwoEventsAndFailure)
    }

    func test_doesntFailAfterTwoEventsAndFailure() {
        _testRunner(_test_doesntFailAfterTwoEventsAndFailure)
    }

    // - Events: 3

    func test_receivesThreeEvents() {
        _testRunner(_test_receivesThreeEvents)
    }

    func test_receivesThreeEventsAndCompletion() {
        _testRunner(_test_receivesThreeEventsAndCompletion)
    }

    func test_failsAfterThreeEvents() {
        _testRunner(_test_failsAfterThreeEvents)
    }

    func test_doesntReceiveAfterThreeEventsAndCompletion() {
        _testRunner(_test_doesntReceiveAfterThreeEventsAndCompletion)
    }

    func test_doesntCompleteAfterThreeEventsAndCompletion() {
        _testRunner(_test_doesntCompleteAfterThreeEventsAndCompletion)
    }

    func test_doesntFailAfterThreeEventsAndCompletion() {
        _testRunner(_test_doesntFailAfterThreeEventsAndCompletion)
    }

    func test_doesntReceiveAfterThreeEventsAndFailure() {
        _testRunner(_test_doesntReceiveAfterThreeEventsAndFailure)
    }

    func test_doesntCompleteAfterThreeEventsAndFailure() {
        _testRunner(_test_doesntCompleteAfterThreeEventsAndFailure)
    }

    func test_doesntFailAfterThreeEventsAndFailure() {
        _testRunner(_test_doesntFailAfterThreeEventsAndFailure)
    }
}

/////////////////////////////////////////////////////////////////////

extension ShareReplayCombinationTests {
    class SubscriberTesting {
        var subscriber: AnyCancellable?
        var results = [Event<String, EventError>]()
    }

    func _testRunner(_ testFunc: (Int, [SubscriberTesting]) -> Void) {
        let subscriberTestings11 = Array(repeating: SubscriberTesting.init(), count: 1)
        testFunc(1, subscriberTestings11)

        let subscriberTestings12 = Array(repeating: SubscriberTesting.init(), count: 1)
        testFunc(2, subscriberTestings12)

        let subscriberTestings13 = Array(repeating: SubscriberTesting.init(), count: 1)
        testFunc(3, subscriberTestings13)

        let subscriberTestings21 = Array(repeating: SubscriberTesting.init(), count: 2)
        testFunc(1, subscriberTestings21)

        let subscriberTestings22 = Array(repeating: SubscriberTesting.init(), count: 2)
        testFunc(2, subscriberTestings22)

        let subscriberTestings23 = Array(repeating: SubscriberTesting.init(), count: 2)
        testFunc(3, subscriberTestings23)
    }

    func _test_doesntEmitInitially(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber = publisher
                .sink(
                    receiveCompletion: { completion in
                        ctx.results.append(.completion(completion))
                },
                    receiveValue: {value in
                        ctx.results.append(.value(value))
                })
        }

        // When

        // Then
        let expected: [Event<String, EventError>] = []
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    // - Events: 0
    func _test_completesWithFinished(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber = publisher
                .sink(
                    receiveCompletion: { completion in
                        ctx.results.append(.completion(completion))
                },
                    receiveValue: {value in
                        ctx.results.append(.value(value))
                })
        }

        // When
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntEmitAfterCompletionWithFinished(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber = publisher
                .sink(
                    receiveCompletion: { completion in
                        ctx.results.append(.completion(completion))
                },
                    receiveValue: {value in
                        ctx.results.append(.value(value))
                })
        }

        // When
        subject.send(completion: .finished)
        subject.send("foo")

        // Then
        let expected: [Event<String, EventError>] = [.completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntCompleteAgainAfterCompletionWithFinished(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber = publisher
                .sink(
                    receiveCompletion: { completion in
                        ctx.results.append(.completion(completion))
                },
                    receiveValue: {value in
                        ctx.results.append(.value(value))
                })
        }

        // When
        subject.send(completion: .finished)
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntFailAfterCompletionWithFinished(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber = publisher
                .sink(
                    receiveCompletion: { completion in
                        ctx.results.append(.completion(completion))
                },
                    receiveValue: {value in
                        ctx.results.append(.value(value))
                })
        }

        // When
        subject.send(completion: .finished)
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_completesWithError(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber = publisher
                .sink(
                    receiveCompletion: { completion in
                        ctx.results.append(.completion(completion))
                },
                    receiveValue: {value in
                        ctx.results.append(.value(value))
                })
        }

        // When
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntEmitAfterCompletionWithError(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber = publisher
                .sink(
                    receiveCompletion: { completion in
                        ctx.results.append(.completion(completion))
                },
                    receiveValue: {value in
                        ctx.results.append(.value(value))
                })
        }

        // When
        subject.send(completion: .failure(EventError.ohNo))
        subject.send("foo")

        // Then
        let expected: [Event<String, EventError>] = [.completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntAgainAfterCompletionWithError(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber = publisher
                .sink(
                    receiveCompletion: { completion in
                        ctx.results.append(.completion(completion))
                },
                    receiveValue: {value in
                        ctx.results.append(.value(value))
                })
        }

        // When
        subject.send(completion: .failure(EventError.ohNo))
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntFailAfterCompletionWithError(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber = publisher
                .sink(
                    receiveCompletion: { completion in
                        ctx.results.append(.completion(completion))
                },
                    receiveValue: {value in
                        ctx.results.append(.value(value))
                })
        }

        // When
        subject.send(completion: .failure(EventError.ohNo))
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    //

    func _test_autocancelOnDeallocation1(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subscriberTestings.forEach { ctx in
            ctx.subscriber = nil
        }
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = []
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_autocancelOnDeallocation2(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        let expected: [Event<String, EventError>] = []
        subscriberTestings.forEach { ctx in
            ctx.subscriber = nil
        }
        subject.send("foo")

        // Then
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_autocancelOnDeallocation3(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subscriberTestings.forEach { ctx in
            ctx.subscriber = nil
        }
        subject.send("bar")

        // Then
        let expected: [Event<String, EventError>] = [.value("foo")]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    // - Events: 1

    func _test_receivesOneEvent(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")

        // Then
        let expected: [Event<String, EventError>] = [.value("foo")]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_receivesOneEventAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntReceiveAfterOneEventAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send(completion: .finished)
        subject.send("bar")

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntCompleteAfterOneEventAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send(completion: .finished)
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntFailAfterOneEventAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send(completion: .finished)
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_failsAfterOneEvent(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntEmitAfterOneEventAndFailure(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send(completion: .failure(EventError.ohNo))
        subject.send("bar")

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntCompleteAfterOneEventAndFailure(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send(completion: .failure(EventError.ohNo))
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntFailAfterOneEventAndFailure(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send(completion: .failure(EventError.ohNo))
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    // - Events: 2

    func _test_receivesTwoEvents(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar")]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_receivesTwoEventsAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_receivesTwoEventsAndFailure(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntReceiveAfterTwoEventsAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send(completion: .finished)
        subject.send("baz")

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntCompleteAfterTwoEventsAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send(completion: .finished)
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntFailAfterTwoEventsAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send(completion: .finished)
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntEmitAfterTwoEventsAndFailure(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send(completion: .failure(EventError.ohNo))
        subject.send("baz")

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntCompleteAfterTwoEventsAndFailure(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send(completion: .failure(EventError.ohNo))
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntFailAfterTwoEventsAndFailure(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send(completion: .failure(EventError.ohNo))
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    // Events: 3

    func _test_receivesThreeEvents(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send("baz")

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .value("baz")]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_receivesThreeEventsAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send("baz")
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .value("baz"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_failsAfterThreeEvents(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send("baz")
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .value("baz"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntReceiveAfterThreeEventsAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send("baz")
        subject.send(completion: .finished)
        subject.send("bazz")

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .value("baz"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntCompleteAfterThreeEventsAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send("baz")
        subject.send(completion: .finished)
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .value("baz"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntFailAfterThreeEventsAndCompletion(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send("baz")
        subject.send(completion: .finished)
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .value("baz"), .completion(.finished)]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntReceiveAfterThreeEventsAndFailure(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send("baz")
        subject.send(completion: .failure(EventError.ohNo))
        subject.send("bazz")

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .value("baz"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntCompleteAfterThreeEventsAndFailure(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send("baz")
        subject.send(completion: .failure(EventError.ohNo))
        subject.send(completion: .finished)

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .value("baz"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }

    func _test_doesntFailAfterThreeEventsAndFailure(capacity: Int, subscriberTestings: [SubscriberTesting]) {
        // Given
        let subject = PassthroughSubject<String, EventError>()
        let publisher = subject.x.share(replay: capacity)

        subscriberTestings.forEach { ctx in
            ctx.subscriber =
                publisher
                    .sink(
                        receiveCompletion: { completion in
                            ctx.results.append(.completion(completion))
                    },
                        receiveValue: {value in
                            ctx.results.append(.value(value))
                    })
        }

        // When
        subject.send("foo")
        subject.send("bar")
        subject.send("baz")
        subject.send(completion: .failure(EventError.ohNo))
        subject.send(completion: .failure(EventError.ohNo))

        // Then
        let expected: [Event<String, EventError>] = [.value("foo"), .value("bar"), .value("baz"), .completion(.failure(EventError.ohNo))]
        subscriberTestings.forEach { ctx in
            XCTAssert(
                ctx.results == expected,
                "Results expected to be \(expected) but were \(ctx.results)"
            )
        }
    }
}
