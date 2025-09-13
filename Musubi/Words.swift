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
    
    // Interesting metadata if in the future outside databases can be referenced
    var jlptLevel = JLPTLevel.none
    var jouyou = 0 // Zero means unknown/not jouyou
    
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
    
    func dumpToConsole() {
        print("Kanji Bank Dump:")
        for kanji in kanjis.keys {
            print(kanji)
        }
    }
}

class WordBank {
    static let bank: WordBank = WordBank()
    var lastSync: Date = Date.now
    fileprivate var words = [String: Words]()
    func getWord(_ word: String) -> Words? {
        return self.words[word]
    }
    func newWord(_ word: String) -> Words {
        let newWord = Words(word: word)
        self.words[word] = newWord
        return newWord
    }
    func sync() {
        // TODO: Sync function
    }
    
    func dumpToConsole() {
        print("Word Bank Dump:")
        for word in words.keys {
            print(word)
        }
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
    
    init(word: String) {
        self._word = word
        self._readings = Array.init(word.map { _ in "" })
        self.updateKanji()
    }
    
    // Raw Init
    init(word: String, readings: [String], meaning: String, shouldRunUpdates: Bool = true){
        self._word = word
        self._readings = readings
        self.meaning = meaning
        if shouldRunUpdates {
            self.updateKanji()
            self.updateMora()
            WordBank.bank.words[word] = self
        }
    }
    
    // Internal Word Representations
    private var _word: String  // Internal String Representation of Word
    private var _readings: [String] = [] // Array of Kanji Readings
    private var _mora: [String] = [] // An internal array to represent mora
    
    private var __readingComplete: Bool { // If any of the readings are an empty string, the reading is not complete. Otherwise they are.
        get {
            return !_readings.contains("") || ((_readings.first != "") && specialReading)
        }
    } // An internal value for tracking if a reading is complete
    

    // Alternate writings
    private var _alternates: [String] = []
    
    // All user defined fields - with no special checking done on these
    var meaning = ""
    var partOfSpeech = PartOfSpeech.unknown
    var examples: [String] = []
    var tags: [String] = []
    
    // Interesting metadata if in the future outside databases can be referenced
    var jlptLevel = JLPTLevel.none
    
    // Reading and mora information
    var specialReading = false
    var moraCount: Int {
        get{
            return __readingComplete ? _mora.count : 0
        }
    }
    
    // Pitch Information
    var pitch: Int = -1 // Use dictionary style for pitch accent - 0 = heiban, 1 = atamadaka, 2-end-1 = nakadaka, end = odaka
    var pitchCategory: PitchCategory {
        get {
            if pitch < 0 {
                return .unknown
            }else if pitch == 0 {
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
    
    // SRS Needed Stubs - see computed values and helper functions in SRS.swift
    var lastReviewed = Date.now
    var srsLevel: Int = 0
    var correctCount: Int = 0
    
    
    // COMPUTED VALUES/SETTERS
    // If they try to update the string
    var literal: String { // TODO: Improve readability
        get {
            return self._word
        }
        set(text) {
            guard text.isJapanese else{ return }
            // If the text is Japanese actually update the word
            // Update location in WordBank
            let oldWord = self._word
            let oldReading = self._readings
            
            if oldWord == text {
                return
            }
            
            self.clearKanji()
            WordBank.bank.words.removeValue(forKey: _word) // Remove word from bank
            self._word = text
            WordBank.bank.words[text] = self
            edited = Date.now
            
            let chars = Array(_word)
            let oldChars = Array(oldWord)
            
            let minCount = min(chars.count, oldWord.count)
            
            if specialReading {
                self._readings = Array.init(_word.map { _ in ""})
            }else{
                self._readings = Array.init(_word.map { _ in ""}) // Clear the readings
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
            }
            updateKanji() // This iterates all kanji, this can be excluded from the loop
            updateMora()
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
            self.updateMora()
        }
    }
    
    // When rendering reading - no reading character is generated for non kanji characters
    var renderedReading: [String] {
        if specialReading {
            return [self._readings.joined()]
        }
        var ret : [String] = []
        let text = Array(self._word)
        for i in 0..<text.count {
            let char = text[i]
            if char.isKanji {
                ret.append(readings[i])
            }else{
                ret.append("")
            }
        }
        return ret
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
        print("Update kanji called")
        for char in Array(self._word) {
            if char.isKanji {
                print("Kanji \(String(char)) inserted into KanjiBank")
                let kanji = KanjiBank.bank.newKanji(String(char)) // This will either add a kanji, or return the preexisting one
                kanji.relatedWords.insert(self)
            }
        }
    }
    
    private func clearKanji() {
        for char in Array(self._word) {
            if char.isKanji {
                KanjiBank.bank.kanjis[String(char)]?.relatedWords.remove(self) // Remove self
            }
        }
    }
    
    private func updateMora() {
        if __readingComplete{
            self._mora = self.reading.splitIntoMorae
        }else{
            self._mora = []
        }
    }
    
    init(word: String, readings: [String], meaning: String, partOfSpeech: PartOfSpeech, JLPTLevel: JLPTLevel) {
        self._word = word
        self._readings = readings
        self.meaning = meaning
    }
}

enum PitchCategory {
    case unknown
    case heiban
    case atamadaka
    case nakadaka
    case odaka
}

enum PartOfSpeech {
    case unknown
    case noun
    case verb
    case iadjective
    case nadjective
}

enum JLPTLevel: String {
    case unknown = ""
    case n1 = "N1"
    case n2 = "N2"
    case n3 = "N3"
    case n4 = "N4"
    case n5 = "N5"
    case none = "N/A"
}
