//
//  Pair.swift
//
//
//  Created by Serge Bouts.
//

struct Pair<F: Equatable, S: Equatable>: Equatable {
    let first: F
    let second: S
    init(_ f: F, _ s: S) {
        self.first = f
        self.second = s
    }
    init(_ tuple: (f: F, s: S)) {
        self.first = tuple.f
        self.second = tuple.s
    }
}
