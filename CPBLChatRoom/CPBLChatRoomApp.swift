//
//  CPBLChatRoomApp.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/8.
//

import SwiftUI
import CoreData

@main
struct CPBLChatRoomApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var auth = MainViewViewModel()
    let persistenceContainer = PersistenceController()
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: MainViewViewModel())
                .environmentObject(auth)
                .environment(\.managedObjectContext, persistenceContainer.container.viewContext)
        }
    }
}


struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DiaryModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as? NSError {
                fatalError("未解析錯誤\(error), \(error.userInfo)")
            }
        }
       
    }
}
