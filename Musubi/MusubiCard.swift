//
//  MusubiCard.swift
//  Musubi
//
//  Created by Royston Martha on 12/11/22.
//

import Foundation

class Musubi: ObservableObject {
    @Published var key: String
    {
        didSet{
            self.safe = false
        }
    }
    @Published var safe = false
    var musubi: Dictionary<String, Musubi>
    
    init(key: String) {
        self.key = key
        self.musubi = [:]
    }
    
    func link(musubi: Musubi) {
        if (self.musubi[musubi.key] != nil) {
            self.musubi[musubi.key] = musubi
        }
    }
}


class Word: Musubi {
    
    
    var yomiOnly = false
    var special = false
    
    @Published var yomi: Array<String> {
        didSet {
            self.safe = true
        }
    } // Yomi should be stored one string per Kanji
    var yomikata: String {  // "Yomikata" can be used to get the reading as one string.
        get {
            var result = ""
            for string in yomi {
                result = result + string
            }
            return result
        }
        set(kata) {
            if yomi.count > 1 {
                // If there is already a formatted yomikata, this setter should not be used.
                return
            }
            yomi[0] = kata // There are no kanji, so put all the kanji into one word. If it's a one-kanji word, this will have the same effect so no issue.
        }
    }
    @Published var meaning: String     // Store the meaning of the word
    override init(key: String) {
        //TODO: check string is actually kanji characters
        self.yomi = []
        self.meaning = ""
        super.init(key: key)
    }
    init(key: String, yomi: Array<String> = [], meaning: String = "") {
        self.yomi = yomi
        self.meaning = meaning
        super.init(key: key)
    }
}
