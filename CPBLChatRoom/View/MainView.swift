//
//  MainView.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/8.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
        
    var body: some View {
        if viewModel.isSignIn, !viewModel.currentUserId.isEmpty {
            //已登入，到主頁
            accountView
            .tint(Color.main)
            
          
        } else{
            //未登入，到登入頁面
           LoginView()
            
            
                
        }
    }
    
    @ViewBuilder
    var accountView: some View {
        TabView {
            ChatView(viewModel: ChatViewViewModel())
                .tabItem {
                    Label("Chat", systemImage: "text.bubble")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }

        }
    }
    
    
}

//#Preview {
//    MainView()
//}
