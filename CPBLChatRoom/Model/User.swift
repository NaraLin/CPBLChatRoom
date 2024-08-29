//
//  User.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/9.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let joined: TimeInterval
}
