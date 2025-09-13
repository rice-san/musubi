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
    var word = Word(key: "結び", yomi: ["むす", ""], meaning: "union")
    var body: some Scene {
        WindowGroup {
            //WordCard(word: word, key: word.key, yomi: word.yomi, meaning: word.meaning)
            FragmentManagerView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
