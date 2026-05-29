//
//  iLoveYouApp.swift
//  iLoveYou
//
//  Created by Christopher Huffaker on 5/28/26.
//

import SwiftUI
import CoreData

@main
struct iLoveYouApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
