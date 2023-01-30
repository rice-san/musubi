//
//  MusubiCard.swift
//  Musubi
//
//  Created by Royston Martha on 12/11/22.
//

import Foundation

class Musubi: ObservableObject {
    var key: String
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
    
    var special = false
    
    var yomi: Array<String> // Yomi should be stored one string per Kanji
    var yomikata: String {  // "Yomikata" can be used to get the reading as one string.
        get {
            var result = ""
            for i in 0..<key.count {
                result = result + (yomi[i] != "" ? yomi[i] : String(Array(key)[i])) // If there is no yomi (e.g. okurigana) use the hiragana from the key word
            }
            if result.isHiragana {
                return result
            }else{
                return ""   // If the yomikata is not complete, don't send a partial one.
            }
        }
        set(kata) {
            if yomi.count > 1 {
                // If there is already a formatted yomikata, this setter should not be used.
                return
            }
            yomi[0] = kata // There are no kanji, so put all the kanji into one word. If it's a one-kanji word, this will have the same effect so no issue.
        }
    }
    var meaning: String     // Store the meaning of the word
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

class Kanji: Musubi {
    override init(key: String) {
        super.init(key: String(Character(key)))
    }
}
