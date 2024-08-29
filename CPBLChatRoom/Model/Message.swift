//
//  Message.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/12.
//

import Foundation
import FirebaseAuth

struct Message: Codable, Identifiable, Equatable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    var senderID: String
    var senderName: String
    var content: MessageContent
    var timestamp: Date
    
    var isCurrentUser: Bool {
        return senderID == Auth.auth().currentUser?.uid
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: timestamp)
    }
    
    
}

enum MessageContent: Codable {
    case text(String)
    case image(URL)
}
