//
//  ChatView.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/9.
//

import SwiftUI

struct ChatView: View {
    
    @StateObject var viewModel = ChatViewViewModel()
    
    
    var body: some View {
        NavigationStack {
            ZStack(content: {
                Color.main
                
                //Content
                ScrollView(.vertical) {
                    ForEach(viewModel.teams) { team in
                        
                        NavigationLink(value: team) {
                            
                            Image(team.logo, label: Text(team.name))
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        
                    }
                }
                .padding(.vertical, 12)
                .navigationDestination(for: Team.self) { team in
                    ChatDetailView(team: team)
                }
                
            })
            .navigationTitle("球隊")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView().previewDevice(.iPhoneSE)
        ChatView().previewDevice(.iPad)
    }
}
