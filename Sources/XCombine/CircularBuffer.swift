//
//  CircularBuffer.swift
//  XCombine
//
//  Created by Serhiy Butz on 10/12/19.
//  Copyright © 2019 Serhiy Butz. All rights reserved.
//

import Foundation

/// Circular buffer errors.
enum CircularBufferError: Error, Equatable {
    case invalidCapacity
    case overflow
    case isEmpty
    case outOfRange
}

/// A circular buffer implementation.
///
/// See also: [Circular buffer](https://en.wikipedia.org/wiki/Circular_buffer)
struct CircularBuffer<Element> {
    // MARK: - Properties

    private var data: [Element]

    private var head: Int = 0

    private let lock = NSLock()

    // MARK: - Initialization

    /// Creates an instance with the buffer of `capacity` elements size.
    ///
    /// - Parameter capacity: The buffer's capacity.
    /// - Throws: `CircularBufferError.invalidCapacity` if the capacity value is wrong.
    public init(capacity: Int) throws {
        guard capacity > 0 else { throw CircularBufferError.invalidCapacity }

        self.capacity = capacity
        self.data = []
        // `Int.max` capacity value is a special case, for which we don't reserve capacity at all.
        if capacity < Int.max {
            data.reserveCapacity(capacity)
        }
    }

    // MARK: - API

    /// The buffer's capacity.
    private(set) var capacity: Int

    /// The buffer's current size.
    private(set) var count = 0

    /// Returns the index'th element if the index is not out of range;
    /// returns `nil` otherwise.
    subscript(safe index: Int) -> Element? {
        lock.lock()
        defer { lock.unlock() }

        guard index >= 0 && index < count else { return nil }

        let index = (head + index) % capacity

        return data[index]
    }

    /// Returns the index'th element if the index is correct;
    /// throws otherwise.
    ///
    /// - Parameter index: The element's index.
    /// - Throws: `CircularBufferError.outOfRange` if the index is out of range.
    /// - Returns: An element if the index is correct.
    func get(at index: Int) throws -> Element {
        guard let result = self[safe: index] else { throw CircularBufferError.outOfRange }
        return result
    }

    /// Appends an element at the end of the buffer if the buffer is not full;
    /// throws otherwise.
    ///
    /// - Parameter element: The element to append.
    /// - Throws: `CircularBufferError.overflow` if the buffer if full.
    mutating func append(_ element: Element) throws {
        lock.lock()
        defer { lock.unlock() }

        guard !isFull else { throw CircularBufferError.overflow }

        if data.count < capacity {
            data.append(element)
        } else {
            data[(head + count) % capacity] = element
        }

        count += 1
    }

    /// Removes the first element from the buffer if the buffer is not empty;
    /// throws otherwise.
    ///
    /// - Throws: `CircularBufferError.isEmpty` if the buffer is empty.
    mutating func removeFirst() throws {
        lock.lock()
        defer { lock.unlock() }

        guard count > 0 else { throw CircularBufferError.isEmpty }

        head = (head + 1) % capacity
        count -= 1
    }

    /// Returns `true` if the buffer if empty;
    /// `false` otherwise.
    var isEmpty: Bool {
        count == 0
    }

    /// Returns `true` if the buffer if full;
    /// `false` otherwise.
    var isFull: Bool {
        assert(count <= capacity)
        return count == capacity
    }

    /// Returns the number of elements, that can yet be appended.
    var freeSpace: Int {
        return capacity - count
    }
}
