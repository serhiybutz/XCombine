//
//  Misc.swift
//
//
//  Created by Serhiy Butz.
//

func twoCharacterString(by index: Int) -> String {
    let c1index: Int = index / Configuration.alphabet.count
    let c2index: Int = index % Configuration.alphabet.count
    return String(Configuration.alphabet[c1index]) + String(Configuration.alphabet[c2index])
}
