//
//  CTButton.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/9.
//

import SwiftUI

struct CTButton: View {
    let title: String
    let backgroundColor: Color
    let textColor: Color
    let radius: CGFloat
    let action: ()->Void
    
    var body: some View {
        Button(action: action, label: {
            Text(title)
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .foregroundStyle(textColor).font(.title2.bold())
                .cornerRadius(radius)
        })
    }
}

#Preview {
    CTButton(title: "title", backgroundColor: .gray, textColor: .black, radius: 10) {
        //action
    }
}
