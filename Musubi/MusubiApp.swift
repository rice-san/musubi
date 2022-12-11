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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
