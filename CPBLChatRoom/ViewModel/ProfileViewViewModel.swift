//
//  ProfileViewViewModel.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/9.
//

import Foundation
import FirebaseAuth

class ProfileViewViewModel: ObservableObject {
    
    init(){}
    
    func logout(){
        try? Auth.auth().signOut()
    }
}
