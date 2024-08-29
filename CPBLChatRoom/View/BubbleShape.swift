//
//  BubbleShape.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/13.
//

import Foundation
import SwiftUI

struct BubbleShape:Shape {
    
    var isCurrentUser: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path(roundedRect: rect, cornerRadius: 10)
        let arrowSize: CGFloat = 10
        let controlPointOffset: CGFloat = 4
        
        if isCurrentUser {
            
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - arrowSize/2 - controlPointOffset))
            path.addQuadCurve(to: CGPoint(x: rect.maxX + arrowSize, y: rect.midY),
                              control: CGPoint(x: rect.maxX, y: rect.midY - arrowSize/2))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY + arrowSize/2 + controlPointOffset),
                              control: CGPoint(x: rect.maxX, y: rect.midY + arrowSize/2))
            
        } else {
            
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY + arrowSize/2 + controlPointOffset))
            path.addQuadCurve(to: CGPoint(x: rect.minX - arrowSize, y: rect.midY),
                              control: CGPoint(x: rect.minX, y: rect.midY + arrowSize/2))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY - arrowSize/2 - controlPointOffset),
                              control: CGPoint(x: rect.minX, y: rect.midY - arrowSize/2))
        }
        
        
        
        return Path(path.cgPath)
    }
    
    func borderPath(in rect: CGRect) -> Path {

        
        var path = Path()
        let cornerRadius: CGFloat = 10
        let arrowSize: CGFloat = 10
        let controlPointOffset: CGFloat = 4 // 控制點偏移量，用於調整曲線的彎曲程度

        // 開始於左上角
        let startPoint = CGPoint(x: rect.minX + cornerRadius, y: rect.minY)
        path.move(to: startPoint)

        // 上邊
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))

        // 右上角
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(270),
                    endAngle: .degrees(0),
                    clockwise: false)

        // 右邊（包括箭頭，如果是當前用戶）
        if isCurrentUser {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - arrowSize/2 - controlPointOffset))
            path.addQuadCurve(to: CGPoint(x: rect.maxX + arrowSize, y: rect.midY),
                              control: CGPoint(x: rect.maxX, y: rect.midY - arrowSize/2))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY + arrowSize/2 + controlPointOffset),
                              control: CGPoint(x: rect.maxX, y: rect.midY + arrowSize/2))
        }
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))

        // 右下角
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)

        // 下邊
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))

        // 左下角
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)

        // 左邊（包括箭頭，如果不是當前用戶）
        if !isCurrentUser {
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY + arrowSize/2 + controlPointOffset))
            path.addQuadCurve(to: CGPoint(x: rect.minX - arrowSize, y: rect.midY),
                              control: CGPoint(x: rect.minX, y: rect.midY + arrowSize/2))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY - arrowSize/2 - controlPointOffset),
                              control: CGPoint(x: rect.minX, y: rect.midY - arrowSize/2))
        }
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))

        // 左上角
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)
        return Path(path.cgPath)
    }
}


struct bubbleView: View {
    
    var body: some View{
        BubbleShape(isCurrentUser: false)
            .borderPath(in: CGRect(x: 10, y: 10, width: 100, height: 100))
            .fill(Color.clear)
            .stroke(.main)
            .frame(maxWidth: 100, minHeight: 100)
            
    }
}

struct bubbleView_Preview: PreviewProvider {
    static var previews: some View {
        bubbleView()
            
    }
}
