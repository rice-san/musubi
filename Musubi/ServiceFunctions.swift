//
//  ServiceFunctions.swift
//  Musubi
//
//  Created by Royston Martha on 12/13/22.
//

import Foundation


extension String {
    // Determine if a string is Japanese characters
    var isJapanese : Bool {
        return self.range(of: #"^[\p{Han}\p{Hiragana}\p{Katakana}]+$"#, options: .regularExpression) != nil
    }
    // Determine if a string is only hiragana
    var isHiragana: Bool {
        return self.range(of: "^\\p{Hiragana}+$", options: .regularExpression) != nil
    }
    
    // Determine if a string is only hiragana or katakana
    var isKana: Bool {
        return self.range(of: #"^[\p{Hiragana}\p{Katakana}]+$"#, options: .regularExpression) != nil
    }
    
    var isKanji: Bool {
        return self.isJapanese && !self.isKana
    }
    
    var splitIntoMorae: [String] {
        get{
            if self.isKana {
                let smallKana: Set<Character> = ["ょ", "ゃ", "ゅ", "ョ", "ャ", "ュ", "ぁ", "ぉ", "ぃ", "ぇ", "ァ", "ィ", "ェ", "ォ"] // Set of small characters
                var result: [String] = []
                var current: String = ""
                for c in Array(self) {
                    if !current.isEmpty {
                        print("current is not empty")
                        if smallKana.contains(c) {
                            current.append(c)
                            print("contains small kana, current is now \(current)")
                            result.append(current)
                            current = ""
                        }else{
                            result.append(current)
                            print("contains no small kana, current is now \(current)")
                            current = String(c)
                        }
                    }else{
                        current = String(c)
                    }
                }
                
                result.append(current) // Add on the last lost mora
                return result
            }else{
                return []
            }
        }
    }
}
extension Character {
    // XCode AI generation might actually be scary intuitive...
    var isHiragana: Bool {
        return self.unicodeScalars.first!.value >= 0x3040 && self.unicodeScalars.first!.value <= 0x309F
    }
    
    var isKatakana: Bool {
        return self.unicodeScalars.first!.value >= 0x30A0 && self.unicodeScalars.first!.value <= 0x30FF
    }
    
    var isKana: Bool {
        return self.isHiragana || self.isKatakana
    }
    
    var isKanji: Bool {
        return self.unicodeScalars.first!.value >= 0x4E00 && self.unicodeScalars.first!.value <= 0x9FFF
    }
}
