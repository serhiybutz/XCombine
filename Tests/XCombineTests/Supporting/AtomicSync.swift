//
//  AtomicSync.swift
//
//
//  Created by Serge Bouts.
//

import Foundation

@propertyWrapper
final class AtomicSync<Value> {
    let queue = DispatchQueue(label: "AtomicProperty")

    var value: Value

    var wrappedValue: Value {
        get {
            queue.sync { value }
        }
        set(newValue) {
            queue.sync {
                self.value = newValue
            }
        }
    }

    var projectedValue: AtomicSync {
        return self
    }

    func mutate(_ mutation: @escaping (inout Value) -> Void) {
        queue.sync {
            mutation(&self.value)
        }
    }

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}
