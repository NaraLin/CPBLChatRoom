//
//  LoginViewViewModel.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/9.
//

import Foundation
import FirebaseAuth

class LoginViewViewModel: ObservableObject{
    @Published var email:String = ""
    @Published var password:String = ""
    @Published var errorMessage = ""
   
    
    init() {}
    
    func login() {
        guard validate() else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password)
        
        
       
    }
    
    func validate() -> Bool {
        errorMessage = ""
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "--- 電子信箱 / 密碼未輸入 ---"
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "--- 電子信箱格式錯誤 ---"
            return false
        }
        
        return true
    }
}
