//
//  Configuration.swift
//
//
//  Created by Serge Bouts.
//

import Foundation

struct Configuration {
    static let concurrentRuns = 100  // Note: exceeding GCD's maximum threads limit increases same threads repetitions.
    static let alphabet = (UnicodeScalar("a").value...UnicodeScalar("z").value).compactMap(Unicode.Scalar.init).compactMap(Character.init)
    static let expectationWaitTimeout: TimeInterval = 10.0
}
