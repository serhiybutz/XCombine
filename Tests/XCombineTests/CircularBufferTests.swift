//
//  CircularBufferTests.swift
//
//
//  Created by Serge Bouts.
//

import XCTest
@testable import XCombine

final class CircularBufferTests: XCTestCase {
    var sut: CircularBuffer<Int>!

    override func tearDown() {
        sut = nil
    }

    func test_throwsInvaliedCapacity01() {
        XCTAssertThrowsError(try CircularBuffer<Int>(capacity: 0)) { error in
            XCTAssertEqual(error as! CircularBufferError, .invalidCapacity)
        }
    }

    func test_throwsInvaliedCapacity02() {
        XCTAssertThrowsError(try CircularBuffer<Int>(capacity: -1)) { error in
            XCTAssertEqual(error as! CircularBufferError, .invalidCapacity)
        }
    }

    func test_noThrowIvalidCapacity03() {
        XCTAssertNoThrow(sut = try CircularBuffer<Int>(capacity: 1))
        XCTAssertEqual(sut.count, 0)
    }

    func test_setsCapacity1() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 1)
        // Then
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.capacity, 1)
    }

    func test_setsCapacity2() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 2)
        // Then
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.capacity, 2)
    }

    func test_throwsIsEmpty1() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 1)
        // Then
        XCTAssertEqual(sut.count, 0)
        XCTAssertThrowsError(try sut.removeFirst()) { error in
            XCTAssertEqual(error as! CircularBufferError, .isEmpty)
        }
    }

    func test_throwsIsEmpty2() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 1)

        // (1)
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (2)
        // - When
        try! sut.append(1)
        // - Then
        XCTAssertEqual(sut.count, 1)

        // (3)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (4)
        // - When
        // - Then
        XCTAssertThrowsError(try sut.removeFirst()) { error in
            XCTAssertEqual(error as! CircularBufferError, .isEmpty)
        }
    }

    func test_throwsIsEmpty3() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 1)

        // (1)
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (2)
        // - When
        try! sut.append(1)
        // - Then
        XCTAssertEqual(sut.count, 1)

        // (3)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (4)
        // - When
        try! sut.append(2)
        // - Then
        XCTAssertEqual(sut.count, 1)

        // (5)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (6)
        XCTAssertThrowsError(try sut.removeFirst()) { error in
            XCTAssertEqual(error as! CircularBufferError, .isEmpty)
        }
    }

    func test_throwsIsEmpty4() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 2)

        // (1)
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (2)
        // - When
        try! sut.append(1)
        // - Then
        XCTAssertEqual(sut.count, 1)

        // (3)
        // - When
        try! sut.append(2)
        // - Then
        XCTAssertEqual(sut.count, 2)

        // (4)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 1)

        // (5)
        // - When
        try! sut.append(3)
        // - Then
        XCTAssertEqual(sut.count, 2)

        // (6)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 1)

        // (7)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 0)

        // - Then
        XCTAssertThrowsError(try sut.removeFirst()) { error in
            XCTAssertEqual(error as! CircularBufferError, .isEmpty)
        }
    }

    func test_appendThrowsOverflow1() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 1)

        // (1)
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (2)
        // - When
        try! sut.append(1)
        // - Then
        XCTAssertEqual(sut.count, 1)

        // (3)
        // - Then
        XCTAssertThrowsError(try sut.append(2)) { error in
            XCTAssertEqual(error as! CircularBufferError, .overflow)
        }
    }

    func test_appendThrowsOverflow2() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 2)

        // (1)
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (2)
        // - When
        try! sut.append(1)
        try! sut.append(2)
        // - Then
        XCTAssertEqual(sut.count, 2)

        // (3)
        // - Then
        XCTAssertThrowsError(try sut.append(3)) { error in
            XCTAssertEqual(error as! CircularBufferError, .overflow)
        }
    }

    func test_appendThrowsOverflow3() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 1)

        // When
        try! sut.append(1)
        try! sut.removeFirst()
        try! sut.append(2)

        // Then
        XCTAssertThrowsError(try sut.append(3)) { error in
            XCTAssertEqual(error as! CircularBufferError, .overflow)
        }
    }

    func test_appendThrowsOverflow4() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 1)

        // (1)
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (2)
        // - When
        try! sut.append(1)
        // - Then
        XCTAssertEqual(sut.count, 1)

        // (3)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (4)
        // - Given
        try! sut.append(2)
        // - Then
        XCTAssertEqual(sut.count, 1)

        // (5)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (6)
        // - When
        try! sut.append(3)
        // - Then
        XCTAssertEqual(sut.count, 1)

        // (7)
        // - Then
        XCTAssertThrowsError(try sut.append(4)) { error in
            XCTAssertEqual(error as! CircularBufferError, .overflow)
        }
    }

    func test_appendThrowsOverflow5() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 2)

        // (1)
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (2)
        // - When
        try! sut.append(1)
        // - Then
        XCTAssertNoThrow(try sut.append(2))
        XCTAssertEqual(sut.count, 2)

        // (3)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertNoThrow(try sut.append(3))
        XCTAssertEqual(sut.count, 2)

        // (4)
        // - Then
        XCTAssertThrowsError(try sut.append(4)) { error in
            XCTAssertEqual(error as! CircularBufferError, .overflow)
        }
    }

    func test_correctValue_capacity1_1() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 1)

        // When
        try! sut.append(1)

        // Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[safe: 0], 1)
    }

    func test_correctValue_capacityOf2_1() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 2)

        // (1)
        // - Then
        XCTAssertEqual(sut.count, 0)

        // (2)
        // - When
        try! sut.append(1)
        try! sut.append(2)
        // - Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[safe: 0], 1)
        XCTAssertEqual(sut[safe: 1], 2)
    }

    func test_correctValue_capacityOf2_2() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 2)

        // (1)
        // - When
        try! sut.append(1)
        try! sut.append(2)
        // - Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[safe: 0], 1)
        XCTAssertEqual(sut[safe: 1], 2)

        // (2)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[safe: 0], 2)

        // (3)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 0)
    }

    func test_correctValue_capacityOf2_3() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 2)

        // (1)
        // - When
        try! sut.append(1)
        try! sut.append(2)
        // - Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[safe: 0], 1)
        XCTAssertEqual(sut[safe: 1], 2)

        // (2)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[safe: 0], 2)

        // (4)
        // - When
        try! sut.append(3)
        // - Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[safe: 0], 2)
        XCTAssertEqual(sut[safe: 1], 3)

        // (3)
        // - When
        try! sut.removeFirst()
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 0)
    }

    func test_correctValue_capacityOf3_1() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 3)

        // When
        try! sut.append(1)
        try! sut.append(2)
        try! sut.append(3)

        // Then
        XCTAssertEqual(sut.count, 3)
        XCTAssertEqual(sut[safe: 0], 1)
        XCTAssertEqual(sut[safe: 1], 2)
        XCTAssertEqual(sut[safe: 2], 3)
    }

    func test_correctValue_capacityOf3_2() {
        // Given
        sut = try! CircularBuffer<Int>(capacity: 3)

        // (1)
        // - When
        try! sut.append(1)
        try! sut.append(2)
        try! sut.append(3)
        // - Then
        XCTAssertEqual(sut.count, 3)
        XCTAssertEqual(sut[safe: 0], 1)
        XCTAssertEqual(sut[safe: 1], 2)
        XCTAssertEqual(sut[safe: 2], 3)

        // (2)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[safe: 0], 2)
        XCTAssertEqual(sut[safe: 1], 3)

        // (3)
        // - When
        try! sut.append(4)
        // - Then
        XCTAssertEqual(sut.count, 3)
        XCTAssertEqual(sut[safe: 0], 2)
        XCTAssertEqual(sut[safe: 1], 3)
        XCTAssertEqual(sut[safe: 2], 4)

        // (4)
        // - When
        try! sut.removeFirst()
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[safe: 0], 4)

        // (5)
        // - When
        try! sut.append(5)
        try! sut.append(6)
        // - Then
        XCTAssertEqual(sut.count, 3)
        XCTAssertEqual(sut[safe: 0], 4)
        XCTAssertEqual(sut[safe: 1], 5)
        XCTAssertEqual(sut[safe: 2], 6)

        // (6)
        // - When
        try! sut.removeFirst()
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[safe: 0], 6)

        // (7)
        // - When
        try! sut.removeFirst()
        // - Then
        XCTAssertEqual(sut.count, 0)
    }
}
