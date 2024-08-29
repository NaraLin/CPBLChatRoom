//
//  MessageView.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/12.
//

import SwiftUI
import UIKit

struct MessageView: View {
    let message: Message
    @State private var calculatedSize: CGSize = .zero
    private let maxWidth: CGFloat = 250
    private let minHeight: CGFloat = 40
    @State private var isImageEnlarged = false
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var dragOffset: CGSize = .zero
    
 
    
    var body: some View {
        
        HStack {
            //自己發的訊息靠右
            if message.isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading, content: {

                Text(message.isCurrentUser ? "" : message.senderName)
                    .font(.caption)
                    .foregroundStyle(Color.black)
                
                
                switch message.content {
                    //傳送文字樣式
                    case .text(let text):
                        GeometryReader { geometry in
                            BubbleShape(isCurrentUser: message.isCurrentUser)
                                .fill(message.isCurrentUser ? .second : .white)
                            //訊息框框的邊線
                                .overlay(
                                    BubbleShape(isCurrentUser: message.isCurrentUser)
                                        .borderPath(in: geometry.frame(in: .local))
                                        .stroke(message.isCurrentUser ? .white : .main, lineWidth: 3)
                                )
                                .overlay(
                                    //訊息Text本人
                                    Text(text)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal,12)
                                        .foregroundColor(message.isCurrentUser ? .white : .black)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .textSelection(.enabled)
                                )
                        }
                        .frame(width: calculatedSize.width, height: calculatedSize.height)
                    
                    //傳送圖片樣式
                    case .image(let URL):
                        imageContent(url:URL)
                }

                Text(message.timestamp, style: .time)
                    .bold()
                    .font(.caption2)
                    .foregroundStyle(Color.white)
            })
            
            //別人發的訊息靠左
            if !message.isCurrentUser{
                Spacer()
            }
        }
        .onAppear {
            if case .text(let text) = message.content {
                calculateTextSize(for: text)
            }
        }
        .fullScreenCover(isPresented: $isImageEnlarged, onDismiss: {
            scale = 1
        } ,content: {
            if case .image(let URL) = message.content {
                ZStack(content: {
                    Color.black.opacity(0.6)
                    AsyncImage(url: URL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .offset(dragOffset)
                            .edgesIgnoringSafeArea(.all)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    VStack {
                        HStack{
                            Spacer()
                            Image(systemName: "x.circle.fill")
                                .font(.title2)
                                .padding()
                                .foregroundStyle(Color.main)
                                .onTapGesture {
                                    isImageEnlarged = false
                                }
                        }
                        Spacer()
                    }
                })
//                .onTapGesture {
//                    isImageEnlarged = false
//                }
                .gesture(
                    DragGesture()
                        //待修改
                        .onChanged({ value in
                            dragOffset = value.translation
                        })
                    
                        .onEnded({ value in
                            if abs(value.translation.height) > 100 {
                                isImageEnlarged = false
                            }
                            dragOffset = .zero
                        })
                
                )
                .gesture(
                    MagnifyGesture()
                        .onChanged({ value in
                            let delta = value.magnification / lastScale
                            lastScale = value.magnification
                            scale *= delta
                        })
                    
                        .onEnded({ value in
                            withAnimation {
                                scale = max(1, scale)
                            }
                            lastScale = 1
                        })
                )
               
            }
        })
        
        
    }
    //calculate text width/height
    private func calculateTextSize(for text: String) {
        switch message.content {
            case .text(let text):
                let size = text.boundingRect(
                    //with:最大尺寸，寬度預留左右各12/不限定高度，隨意換行
                    with: CGSize(width: maxWidth - 24, height: .greatestFiniteMagnitude),
                    //.usesLineFragmentOrigin：每行有自己的空間 ; .usesFontLeading：每行之間留一些空間
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: [.font: UIFont.systemFont(ofSize: 17)],
                    context: nil).size
                //取文字寬度+12，不超過maxWidth
                let width = min(size.width + 24, maxWidth)
                let height = max(size.height + 16, minHeight)
                
                calculatedSize = CGSize(width: width, height: height)
            default:
                break
        }
        
        
    }
    
   
    private func imageContent(url: URL) -> some View {
        CachedAsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 200, maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        isImageEnlarged = true
                    }
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .foregroundStyle(Color.gray)
                        
                case .empty:
                    ProgressView()
                        .frame(maxWidth: 200, maxHeight: 200)

                @unknown default:
                    EmptyView()
                        .frame(maxWidth: 200, maxHeight: 200)

            }
        }
    }
    
}



#Preview {
    MessageView(message: .init(id: "", senderID: "", senderName: "", content: .text(""), timestamp: .now))
}
