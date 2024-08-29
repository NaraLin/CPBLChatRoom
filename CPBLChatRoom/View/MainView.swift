//
//  MainView.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/8.
//

import SwiftUI

extension MainView {
    enum Tab: View, CaseIterable {
        case chat, profile
        
        var body: some View {
            content.tabItem{ tabLabel }
        }
        
        @ViewBuilder
        private var content: some View {
            switch self {
                case .chat:
                    ChatView()
                case .profile:
                    ProfileView()
            }
        }
        
        private var tabLabel: some View {
            switch self {
                case .chat:
                    Label("Chat", systemImage: "text.bubble")
                case .profile:
                    Label("Profile", systemImage: "person.circle")
            }
        }
        
    }
}


struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
        
    var body: some View {
        if viewModel.isSignIn, !viewModel.currentUserId.isEmpty {
            //已登入，到主頁
            TabView {
                ForEach(Tab.allCases, id: \.self) { $0 }
            }
            .tint(Color.main)
        } else{
            //未登入，到登入頁面
           LoginView()
        }
    }
}

//#Preview {
//    MainView()
//}
