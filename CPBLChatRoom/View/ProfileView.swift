//
//  ProfileView.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/9.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel = ProfileViewViewModel()
    
    
    var body: some View {
        
        NavigationStack {
            VStack {
                List {
                    Button("登出") {
                        viewModel.logout()
                    }
                    .listStyle(.sidebar)
                }
            }
            .navigationTitle("Profile")
        }
        
    }
}

#Preview {
    ProfileView()
}
