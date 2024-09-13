
import SwiftUI

struct ChatDetailView: View {
    @StateObject var viewModel: ChatDetailViewViewModel
    @State private var isImagePickerPresented = false
    
    
    init(team: Team) {
        _viewModel = StateObject(wrappedValue: ChatDetailViewViewModel(team: team))
    }
    
    var body: some View {
            VStack {
                //已送出的訊息區
                MessageListView(messages: viewModel.messages)
                
                //圖片預覽小圖
                ImagePreviewView(image: viewModel.selectedImage){
                    viewModel.selectedImage = nil
                }
                
                //輸入訊息區
                InputBarView(
                    newMessage: $viewModel.newMessage,
                    onSendMessage: viewModel.send,
                    onSelectedImage: { isImagePickerPresented = true }
                )
                
            }
            .background(viewModel.team.color.ignoresSafeArea(edges: .top))
            .navigationTitle(viewModel.team.name)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isImagePickerPresented, content: {
                ImagePicker(image: $viewModel.selectedImage)
            })
        
    }
}


// MARK: SubViews

private func messageForDateView(_ messages: [Message]) -> some View {
    ForEach(messages) { message in
        MessageView(message: message)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .id(message.id)
    }
}
    
private struct MessageListView: View {
   
    //訊息by日期group&顯示
    let messages: [Message]
    
    @State var groupedMessages: [(String, [Message])] = []
    var body: some View {
        
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(groupedMessages, id: \.0){ date, messages in
                        Section {
                            messageForDateView(messages)
                        } header: {
                            //日期當header
                            Text(date)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                        
                    }
                }
                .padding(.horizontal)
                
            }
            .onAppear {
                updateGroupMessage()
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: messages) {
                updateGroupMessage()
                scrollToBottom(proxy: proxy)
            }

        }
        
    }
    
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastID = messages.last?.id else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            withAnimation(.easeInOut(duration: 0.3), {
                proxy.scrollTo(lastID, anchor: .bottom)
            })
        }
    }
    
    
   
    /*
     [
     ("2024-08-20", ["訊息1", "訊息2"]),
     ("2024-08-21", ["訊息3", "訊息4", "訊息5"]),
     ("2024-08-22", ["訊息6"])
     ]
     */
    
    
    private func updateGroupMessage() {
        //key: dateString
        //value: messages
        let groupMessages = Dictionary(grouping: messages) { $0.dateString
        }
        groupedMessages = groupMessages.sorted{ $0.key < $1.key }
    }
}

private struct ImagePreviewView: View {
    let image: UIImage?
    let onRemove: () -> Void
    var body: some View {
        HStack {
            if let image {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40,height: 40,alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay {
                            RoundedRectangle(cornerRadius: 5).stroke(Color.main, lineWidth: 2)
                    }
                    
                    Button(action: {
                        onRemove()
                    }, label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(Color.main)
                            .background(Color.white)
                            .clipShape(Circle())
                    })
                    .offset(x: 8, y: -8)
                }
                
               
            }
            Spacer()
        }
        .frame(height: image == nil ? 0 : 50)
        .padding(.horizontal)
    }
}

private struct InputBarView: View {
    
    @Binding var newMessage: String
    let onSendMessage: ()->Void
    let onSelectedImage: ()->Void
    
    var body: some View {
        HStack {
            //輸入訊息
            TextEditor(text: $newMessage)
                .frame(height: 24)
                .padding(8)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.main.opacity(0.3), lineWidth: 4)
                )
            
            //選擇圖片button
            Button(action: {
                onSelectedImage()
            }, label: {
                Image(systemName: "photo.circle.fill")
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.main)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            })
            
            
            //送出訊息button
            Button(action: {
                onSendMessage()
            }, label: {
                Image(systemName: "paperplane.circle")
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.main)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            })
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    ChatDetailView(team: Team(id: "1", name: "統一獅", logo: "lions", color: .orange))
}




