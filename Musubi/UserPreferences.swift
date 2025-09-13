//
//  UserPreferences.swift
//  Musubi
//
//  Created by Royston Martha on 9/12/25.
//

class UserPreferences {
    var useSRS: Bool = true
    var weightWordsOnPitch: Bool = true
    var allowSelfWeighing: Bool = false
    
    private init() {}
    
    static let shared = UserPreferences()
}
