//
//  RegisterView.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/8.
//

import SwiftUI

enum RegisterField: Int {
    case name, email, password
}


struct RegisterView: View {
    
    @StateObject var viewModel = RegisterViewViewModel()
    @FocusState private var field: RegisterField?
    var body: some View {
        
        ZStack{
            Color.yellow.ignoresSafeArea()
            
            VStack {
              
                TitleView()

                Form(content: {
                    InputField(title: "名字", placeholder: "請輸入名字", text: $viewModel.name, foucusField: $field, field: .name, isSecure: false)
                    InputField(title: "電子信箱", placeholder: "請輸入電子信箱", text: $viewModel.email, foucusField: $field, field: .email, isSecure: false)
                    InputField(title: "密碼", placeholder: "請設定密碼", text: $viewModel.password, foucusField: $field, field: .password, isSecure: true)
                    
                    Section {
                        CTButton(title: "Register",
                                 backgroundColor: .black,
                                 textColor: .white,
                                 radius: 5) {
                            //action
                            viewModel.register()
                            
                        }
                        
                    }
                    .listRowBackground(Color.clear)
                   
                    
                    
                    })
                    .scrollContentBackground(.hidden)
                    .font(.title3.weight(.bold))
                    .scrollDismissesKeyboard(.interactively)
                    
                    
                }
                     
                     
                }
        }
        
    }


#Preview {
    RegisterView()
}


//MARK: subviews

private struct TitleView: View {
    
    var body: some View{
        VStack{
            Text("CPBL ChatRoom")
            Text("/ Register /")
        }
        .font(.custom("NatsuzemiMaruGothic-Black", size: 30))
        .bold()
        .multilineTextAlignment(.center)
        .foregroundStyle(Color.black)
        .padding()
    }
}


private struct InputField: View {
    
    let title: String
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var foucusField: RegisterField?
    let field: RegisterField
    let isSecure: Bool
    
    var body: some View {
        HStack(content: {
            Text(title)
                .standardFieldTextTitle(textColor: .black)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .registerSecureFieldFocus($foucusField, equals: field)
                    .standardTextField()
            } else{
                TextField(placeholder, text: $text)
                    .registerFieldFocus($foucusField, equals: field)
                    .standardTextField()
            }
                
        })
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
