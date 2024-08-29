//
//  MainViewViewModel.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/9.
//

import Foundation
import FirebaseAuth

class MainViewViewModel: ObservableObject {
    
    @Published var currentUserId: String = ""
    private var handler: AuthStateDidChangeListenerHandle?
    
    init(){
        //建立時啟動監聽登入登出壯態
        self.handler = Auth.auth().addStateDidChangeListener({ [weak self] auth, user in
            DispatchQueue.main.async{
                //切換到main queue，避免race condition，確保UI更新的順序性和一致性
                self?.currentUserId = user?.uid ?? ""
            }
        })
    }
    
    public var isSignIn: Bool{
        return Auth.auth().currentUser != nil
    }
    
    
}
