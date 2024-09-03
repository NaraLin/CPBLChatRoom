//
//  MainView.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/8.
//

import SwiftUI
import CoreData

extension MainView {
    enum Tab: View, CaseIterable {
        case chat, diary, profile
        
        var body: some View {
            content.tabItem{ tabLabel }
        }
        
        @ViewBuilder
        private var content: some View {
            switch self {
                case .chat:
                    ChatView()
                case .diary:
                    DiaryView(context: PersistenceController.shared.container.viewContext)
                case .profile:
                    ProfileView()
            }
        }
        
        private var tabLabel: some View {
            switch self {
                case .chat:
                    Label("Chat", systemImage: "text.bubble")
                case .diary:
                    Label("Diary", systemImage: "square.and.pencil")
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

struct contentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().previewDevice(.iPhoneSE)
        MainView().previewDevice(.iPad)
    }
}

