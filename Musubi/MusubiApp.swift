//
//  MusubiApp.swift
//  Musubi
//
//  Created by Royston Martha on 12/11/22.
//

import SwiftUI

@main
struct MusubiApp: App {
    let persistenceController = PersistenceController.shared
    var word = Words(word: "巡回監督", readings: ["たすまきてんぴゃっく", "かい", "かん", "とく"], meaning: "circuit overseer")
    
    var body: some Scene {
        WindowGroup {
            //WordCard(word: word, key: word.key, yomi: word.yomi, meaning: word.meaning)
            WordView(word: word)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
