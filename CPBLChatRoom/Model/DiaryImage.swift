//
//  DiaryImage.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/9/5.
//
import Foundation
import UIKit

struct ImageWithID: Identifiable, Equatable {
    var id: String
    var image: UIImage
}
struct ImageData: Codable, Identifiable {
    let id: String
    let data: Data
}
