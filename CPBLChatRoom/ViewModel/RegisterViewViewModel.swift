//
//  RegisterViewViewModel.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/9.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
//import FirebaseFirestoreSwift(another way)

class RegisterViewViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var name: String = ""
   
    
    init(){}
    
    func register(){
        
        guard validate() else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userID = result?.user.uid else {
                print("no uid")
                return
            }
            self?.insertUserRecord(id: userID)
            
            
        }
    }
    
    private func insertUserRecord(id: String) {
        
        let newUser = User(id: id, name: name, email: email, joined: Date().timeIntervalSince1970)
        let db = Firestore.firestore()
        db.collection("users").document(id).setData(newUser.asDictionary())
        
    }
    
    private func validate() -> Bool{
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, !password.trimmingCharacters(in: .whitespaces).isEmpty, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        guard email.contains("@") && email.contains(".") else {
            return false
        }
        guard password.count >= 6 else {
            return false
        }
        return true
    }
}
