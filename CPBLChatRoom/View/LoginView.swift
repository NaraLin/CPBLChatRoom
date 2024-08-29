

import SwiftUI

enum LoginField: Int {
    case email, password
}

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewViewModel()
    @FocusState private var field: LoginField?
    @State private var fieldHeight: CGFloat = 0
    
    var body: some View {
        
        NavigationStack {
            ZStack(content: {
                Color.second.ignoresSafeArea()
                VStack {
 
                    TitleView()
                    
                    Form(content: {
                        
                        HStack(content: {
                            Text("電子信箱")
                                .standardFieldTextTitle(textColor: .white)
                            
                            TextField("請輸入電子信箱", text: $viewModel.email)
                                .loginFieldFocus($field, equals: .email)
                                .standardTextField()
                        })
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    
                        
                        HStack(content: {
                            Text("密碼")
                                .standardFieldTextTitle(textColor: .white)
                            
                            SecureField("請輸入密碼", text: $viewModel.password)
                                .loginSecureFieldFocus($field, equals: .password)
                                .standardTextField()
                        })
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        
                        
                        Section {
                            CTButton(title: "Login", backgroundColor: .yellow, textColor: .black, radius: 5, action: {
                                viewModel.login()
                            })
                            
                            Group {
                                ErrorMessageView(message: viewModel.errorMessage)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        
                    })
                    
                    .scrollContentBackground(.hidden)
                    .font(.title3.weight(.bold))
                    .scrollDismissesKeyboard(.interactively)
                    
                }
            })
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    createAccountView(title: "沒有帳號嗎 ?", subTitle: "[ 註冊新帳號 ]")
                }
            }

        }
        
    }
}

//MARK: subviews

private struct TitleView: View {
    
    var body: some View {
        VStack{
            Text("Welcome")
            Text("CPBL ChatRoom")
        }
        .font(.custom("NatsuzemiMaruGothic-Black", size: 30))
        .bold()
        .multilineTextAlignment(.center)
        .foregroundStyle(Color.black)
        .padding()
    }
}
 
private struct ErrorMessageView: View {
    let message: String
    var body: some View {
        if !message.isEmpty {
            HStack{
                Spacer()
                Text(message)
                    .foregroundStyle(.red)
                    .padding()
                    .font(.callout.bold())
                Spacer()
            }
        }
    }
}



private struct createAccountView: View {
    let title: String
    let subTitle: String
   
    
    var body: some View {
        VStack(spacing: 4){
            Text(title)
                .font(.callout)
                .foregroundStyle(Color.white)
            
            NavigationLink {
                RegisterView()
                    
            } label: {
                Text(subTitle)
                    .font(.title3)
                    .foregroundStyle(.yellow)
                    .bold()
            }
        }.padding()
           
    }
}
    
//    #Preview {
//        LoginView()
//    }
