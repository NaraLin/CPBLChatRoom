//
//  ChatViewViewModel.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/9.
//

import Foundation
import SwiftUI

class ChatViewViewModel: ObservableObject {
    
    
    @Published var teams: [Team] = []
    
    init(){
        loadTeams()
    }
    
    private func loadTeams(){
        teams = [
            Team(id: "1", name: "統一獅", logo: "lions", color: .orange),
            Team(id: "2", name: "中信兄弟", logo: "brothers", color: .yellow),
            Team(id: "3", name: "樂天桃猿", logo: "monkeys", color: .darkRed),
            Team(id: "4", name: "味全龍", logo: "dragons", color: .red),
            Team(id: "5", name: "台鋼雄鷹", logo: "HAWKS",color: .hawksGreen),
            Team(id: "6", name: "富邦悍將", logo: "guardians",color: .fubonBlue)
        ]
    }
}


