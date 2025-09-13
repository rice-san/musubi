//
//  Core.swift
//  Musubi
//
//  Created by Royston Martha on 10/3/23.
//

import Foundation
import SwiftData

// Fragment System

// Represent fragments or parts of words/kanji.
@Model class Fragment : Identifiable, Comparable {
    
    let id = UUID()
    let date = Date.now // All fragments have a date.
    
    static func <(lhs: Fragment, rhs: Fragment) -> Bool {
        return lhs.date < rhs.date
    }
    static func ==(lhs: Fragment, rhs: Fragment) -> Bool {
        return false
    }
    init() {
        id = UUID()
        date = Date.now
    }
}

// The fragment is a pronunciation of a word.
class HatsuonFragment : Fragment {
    var hatsuon: String
    init(hatsuon: String) {
        self.hatsuon = hatsuon
        super.init()
    }
    
    required init(backingData: any SwiftData.BackingData<Fragment>) {
        fatalError("init(backingData:) has not been implemented")
    }
}

// This fragment is a kanji character, with no pronunciation
class KanjiFragment : Fragment {
    let kanji: String
    init(kanji: String) {
        self.kanji = kanji
        super.init()
    }
    
    required init(backingData: any SwiftData.BackingData<Fragment>) {
        fatalError("init(backingData:) has not been implemented")
    }
}

// This fragment is a word, with no pronunciation
class WordFragment : Fragment {
    let word: String
    init(word: String) {
        self.word = word
        super.init()
    }
    
    required init(backingData: any SwiftData.BackingData<Fragment>) {
        fatalError("init(backingData:) has not been implemented")
    }
}


// Kanji - the class that will represent every Kanji entry


