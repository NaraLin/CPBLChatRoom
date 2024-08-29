//
//  Team.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/13.
//

import Foundation
import SwiftUI

struct Team: Identifiable, Hashable {
    let id: String
    let name: String
    let logo: String
    let color: Color
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
  
}
