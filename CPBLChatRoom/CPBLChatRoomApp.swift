//
//  CPBLChatRoomApp.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/8.
//

import SwiftUI

@main
struct CPBLChatRoomApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var auth = MainViewViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: MainViewViewModel())
                .environmentObject(auth)
        }
    }
}
