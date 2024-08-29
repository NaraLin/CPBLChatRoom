//
//  ImageCache.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/20.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() {}
    
    //get cache image
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    //put image to cache
    func setImage(_ image: UIImage, url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}
