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
    // Determine if a string is only hiragana or katakana
    var isHiragana: Bool {
        return self.range(of: "^\\p{Hiragana}+$", options: .regularExpression) != nil
    }
    
    // Determine if a string is only hiragana or katakana
    var isKana: Bool {
        return self.range(of: #"^[\p{Hiragana}\p{Katakana}]+$"#, options: .regularExpression) != nil
    }
}

