//
//  ChatDetailViewViewModel.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/12.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ChatDetailViewViewModel: ObservableObject {
   
    @Published var selectedImage: UIImage?
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private var listener: ListenerRegistration?
    private var name: String = ""
    let team: Team
    
 
    
    init(team: Team){
        self.team = team
        startListening()
    }
    
    func startListening(){
        listener = db.collection("chatrooms")
            .document(team.name)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener({ [weak self] querySnapshot, error in
                
                guard let documents = querySnapshot?.documents else {
                    print("error fetching documents: \(error?.localizedDescription ?? "unknownError")")
                    return
                }
                self?.messages = documents.compactMap({ document in
                    let data = document.data()
                    let id = document.documentID
                    let senderID = data["senderID"] as? String ?? ""
                    let senderName = data["senderName"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                       
                    let content: MessageContent
                    if data["type"] as? String == "image",
                       let urlString = data["content"] as? String,
                       let url = URL(string: urlString) {
                        content = .image(url)
                    } else if let text = data["content"] as? String {
                        content = .text(text)
                    } else {
                        return nil
                    }
                    
                    return Message(id: id, senderID: senderID, senderName: senderName, content: content, timestamp: timestamp)
                })
                
            })
    }
    
    
    
    private func fetchUser(completion: @escaping () -> Void) {
        let userID = Auth.auth().currentUser?.uid
        guard let userID else {
            return
        }
        
        db.collection("users")
            .document(userID)
            .getDocument { [weak self] document, error in
                if let document = document, document.exists {
                    let user = document.data()
                    if let user {
                        self?.name = user["name"] as? String ?? ""
                        completion()
                    }
                }
            }
    }
    
    //uploadImage
    //path: images/xxx.png
    func uploadImage(image: UIImage) {
        guard let imageData = image.pngData() else { return }
        let imageName = UUID().uuidString
        let storageRef = storage.reference().child("images/\(imageName).png")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            storageRef.downloadURL { url, error in
                guard let url else {
                    print("error getting download URL: \(error?.localizedDescription ?? "unknown Error")")
                    return
                }
                print(url)
                self.createMessageData(content: .image(url))
            }
        }
    }
    
    //createMessageToFirestore
    func createMessageData(content: MessageContent) {
        
        let messageData: [String: Any]
        let currentUser = Auth.auth().currentUser
        
        switch content {
            case .image(let url):
                messageData = [
                    "content": url.absoluteString,
                    "type": "image",
                    "senderID": currentUser?.uid ?? "",
                    "timestamp": FieldValue.serverTimestamp()
                ]
            case .text(let text):
                messageData = [
                    "content": text,
                    "type": "text",
                    "senderID": currentUser?.uid ?? "",
                    "timestamp": FieldValue.serverTimestamp()
                ]
        }
        
        db.collection("chatrooms")
            .document(team.name)
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error {
                    print(error.localizedDescription)
                }
            }
    }
    
    func sendTextMessage() {
        fetchUser {
            guard !self.newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            self.createMessageData(content: .text(self.newMessage))
            self.newMessage = ""
            
        }
    }

    func send(){
        
        if let image = selectedImage {
            uploadImage(image: image)
            selectedImage = nil
        }
        
        if !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            sendTextMessage()
        }
        
    }
    
    deinit {
        listener?.remove()
    }
    
}

