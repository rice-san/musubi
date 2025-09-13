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
    var on: [String] // onyomi
    var kun: [String] // kunyomi
    var meaning = "" // general meaning of kanji
    var relatedWords: Set<Words> = [] // FIXME: Can't store the actual words... in the JSON.
    
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
    
    private init() { } // prevent accidentaly extra banks from being created.
    
    func initializeFromFile() {
        // TODO: Load from disk function
    }
    
    func sync() {
        // TODO: Sync function
    }
    
    func collapseToJSON() -> String {
        return ""
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
        self._readings = Array.init(name.map { _ in "" })
    }
    
    // Internal Word Representations
    private var _word: String  // Internal String Representation of Word
    private var _readings: [String] = [] // Array of Kanji Readings
    private var __readingComplete: Bool = false // An internal value for tracking if a reading is complete
    private var _mora: [String] = [] // An internal array to represent mora
    

    // Alternate writings
    private var _alternates: [String] = []
    
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
            guard text.isJapanese else{ return }
            // If the text is Japanese actually update the word
            // Update location in WordBank
            let oldWord = self._word
            let oldReading = self._readings
            
            WordBank.bank.words.removeValue(forKey: _word) // Remove word from bank
            self._word = text
            WordBank.bank.words[text] = self
            edited = Date.now
            
            let chars = Array(_word)
            let oldChars = Array(oldWord)
            
            let minCount = min(chars.count, oldWord.count)
            
            self._readings = Array(repeating: "", count: self._word.count) // Clear the readings
            for i in 0..<minCount { // This is set by character count. So - ちゅ is rendered as one character - and the readings should be such too.
                let oldChar = oldChars[i]
                let newChar = chars[i]
                
                // If a given kanji hasn't changed, keep the reading too.
                if oldChar == newChar {
                    self._readings[i] = oldReading[i]
                    // Don't interact with kanji bank, no new kanji has been introduced or removed.
                }else{
                    if newChar.isKana { // If this charcter is not kanji
                        self._readings[i] = String(chars[i]) // If the character is hiragana or kana - the reading is itself
                    }else{
                        self._readings[i] = "" // Add an empty string. We don't know the reading yet.
                    }
                }
            }
            if chars.count > oldChars.count {
                for i in oldChars.count..<chars.count {
                    if chars[i].isKana {
                        _readings[i] = String(chars[i])
                    } else {
                        _readings[i] = ""
                    }
                }
            }
            updateKanji() // This iterates all kanji, this can be excluded from the loop
            
        }
    }
    
    // Working with the reading as a string
    var reading: String {
        get {
            for i in 0..<self._readings.count {
                if self._readings[i] == "" {
                    return "" // Return an empty string if the reading is not complete.
                }
            }
            return self._readings.joined()
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
    
    // Working with readings as an array
    var readings: [String] {
        get {
            return self._readings
        }
        set {
            self._readings = newValue
            self.__readingComplete = !_readings.contains("") // If any of the readings are an empty string, the reading is not complete. Otherwise they are.
            self.updateMora()
        }
    }
    
    // Set a reading. This is always called externally and operates only for kanji characters
    func setReading(_ str: String, at: Int) {
        let chars = Array(_word) // Grapheme clusters
        precondition(at >= 0 && at < chars.count, "Index out of bounds in setReading")

        let char = chars[at]
        precondition(char.isKanji, "setReading called on non-kanji character")

        _readings[at] = str
    }
    
    // Return kanji as an array
    var kanjis: [Kanji?] {
        get {
            var ret: [Kanji?] = []
            for char in Array(self._word) {
                ret.append(KanjiBank.bank.kanjis[String(char)]) // Return Kanji pulled or nil if no Kanji
            }
            return ret
        }
    }
    

    
    // Helper functions
    private func updateKanji() {
        for char in Array(self._word) {
            if char.isKanji {
                if let kanji = KanjiBank.bank.kanjis[String(char)] {
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
