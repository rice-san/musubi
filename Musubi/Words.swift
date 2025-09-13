//
//  Words.swift
//  Musubi
//
//  Created by Royston Martha on 9/12/25.
//

import Foundation

class Kanji {
    
    init(key: Character) {
        self._kanji = key
        self.on = []
        self.kun = []
    }
    
    // Date-Time Metadata
    let created = Date.now
    var edited = Date.now
    
    fileprivate var _kanji: Character // Literal for itself
    var on: Array<String> // onyomi
    var kun: Array<String> // kunyomi
    var meaning = "" // general meaning of kanji
    var relatedWords: Set<Words> = []
    
    var literal: Character {
        return _kanji
    }
}


class KanjiBank {
    private var hasLoaded: Bool = false
    static let bank: KanjiBank = KanjiBank()
    var lastSync: Date = Date.now
    fileprivate var kanjis: [String: Kanji] = [:] // Dictionary storing kanji
    
    func getKanji(_ kanji: String) -> Kanji? {
        return self.kanjis[kanji] // pull the kanji from the bank
    }
    
    func newKanji(_ kanji: String) -> Kanji {
        if let preexistingKanji = KanjiBank.bank.kanjis[kanji] {
            return preexistingKanji // If a kanji already exists, return the reference to it
        }
        let newKanji = Kanji(key: kanji.first!)
        self.kanjis[kanji] = newKanji
        return newKanji // return new kanji
    }
    
    private init() { }
    
    func initializeFromFile() {
        // TODO: Load from disk function
    }
    
    func sync() {
        // TODO: Sync function
    }
}

class WordBank {
    static var bank: WordBank = WordBank()
    var lastSync: Date = Date.now
    fileprivate var words = [String: Words]()
    func getWord(_ word: String) -> Words? {
        return self.words[word]
    }
    func newWord(_ word: String) -> Words {
        let newWord = Words(name: word)
        self.words[word] = newWord
        return newWord
    }
    func sync() {
        // TODO: Sync function
    }
}

class Words: Hashable {
    static func == (lhs: Words, rhs: Words) -> Bool {
        return lhs._word == rhs._word
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self._word)
    }
    
    // Date-Time Metadata
    let created = Date.now
    var edited = Date.now
    
    init(name: String) {
        self._word = name
    }
    
    // Internal Word Representations
    private var _word: String  // Internal String Representation of Word
    private var _readings: Array<String> = [] // Array of Kanji Readings
    private var __readingComplete: Bool = false // An internal value for tracking if a reading is complete
    private var _mora: Array<String> = [] // An internal array to represent mora
    

    // Alternate writings
    private var _alternates: Array<String> = []
    
    var meaning = ""
    
    // Reading and mora information
    var specialReading = false
    var moraCount: Int {
        get{
            return __readingComplete ? _mora.count : 0
        }
    }
    
    // Pitch Information
    var pitch: Int = 0 // Use dictionary style for pitch accent - 0 = heiban, 1 = atamadaka, 2-end-1 = nakadaka, end = odaka
    var pitchCategory: PitchCategory {
        get {
            if pitch == 0 {
                return .heiban
            }else if pitch == moraCount {
                return .odaka
            }else if pitch == 1 {
                return .atamadaka
            }else{
                return .nakadaka
            }
        }
    }
    
    // If they try to update the string
    var literal: String {
        get {
            return self._word
        }
        set(text) {
            if text.isJapanese { // If the text is Japanese actually update the word
                // Update location in WordBank
                let oldWord = self._word
                WordBank.bank.words[self._word] = nil
                self._word = text
                WordBank.bank.words[text] = self
                edited = Date.now
                let oldReading = self._readings
                self._readings = [] // Clear the readings
                for i in 0..<self._word.count { // This is set by character count. So - ちゅ is rendered as two characters - and the readings should be such too.
                    // If a given kanji hasn't changed, keep the reading too.
                    if Array(oldWord)[i] == Array(self._word)[i] {
                        self._readings[i] = oldReading[i]
                        // Don't interact with kanji bank, no new kanji has been introduced or removed.
                    }else{
                        if Array(self._word)[i].isKana { // If this charcter is not kanji
                            self._readings[i] = String(Array(arrayLiteral: self._word)[i]) // If the character is hiragana or kana - the reading is itself
                        }else{
                            if self._readings[i].isKanji {
                                self.kanjis[i] = KanjiBank.bank.newKanji(self._readings[i]) // Add kanji into the self array of kanji
                                updateKanji()
                            }
                            self._readings[i] = "" // Add an empty string.
                        }
                    }
                }
            }
        }
    }
    
    // Working with the reading as a string
    var reading: String {
        get {
            var str: String = ""
            for i in 0..<self._readings.count {
                if self._readings[i] == "" {
                    return "" // Return an empty string if the reading is not complete.
                }
                str += self._readings[i]
            }
            return str
        }
        set(str) {
            if specialReading {  // Special reading means we can't pull from kanji readings. Set manually
                self._readings = []
                self._readings.append(str)
                self.__readingComplete = true
                self.updateMora()
                self.edited = Date.now
            }else{ // All readings should be pulled from the kanji. Can't.
                // Theoretically possible to use .splitIntoMorae to assign these readings to Kanji
            }
        }
    }
    
    var readings: Array<String> {
        get {
            return self._readings
        }
        set {
            self._readings = newValue
            self.__readingComplete = !_readings.contains("") // If any of the readings are an empty string, the reading is not complete. Otherwise they are.
            self.updateMora()
        }
    }
    
    func setReading(_ str: String, at: Int) {
        if self._word[_word.index(_word.startIndex, offsetBy: at)].isKanji {
            self._readings[at] = str // There's no check needed because this reading is not a free text field. This is fed in through the kanji character.
        }
    }
    
    // Return kanji as an array
    var kanjis: Array<Kanji?> {
        get {
            var ret: Array<Kanji?> = []
            for i in 0..<self._word.count {
                ret[i] = (KanjiBank.bank.kanjis[Array(arrayLiteral: self._word)[i]]) // Return Kanji pulled or nil if no Kanji
            }
            return ret
        }
            
        set {
            // Do nothing. Not how kanji in a word are set.
        }
    }
    
    // Return reading as an array
    
    
    
    // Helper functions
    private func updateKanji() {
        for i in 0..<self._word.count {
            if Array(literal)[i].isKanji {
                if let kanji = KanjiBank.bank.kanjis[Array(arrayLiteral: literal)[i]] {
                    kanji.relatedWords.insert(self)
                }
            }
        }
    }
    
    private func updateMora() {
        if __readingComplete{
            self._mora = self.reading.splitIntoMorae
        }
    }
}

enum PitchCategory {
    case heiban
    case atamadaka
    case nakadaka
    case odaka
}
