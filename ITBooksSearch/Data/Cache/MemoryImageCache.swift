//
//  MemoryImageCache.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import UIKit

protocol ImageCacheType {
    func image(forKey key: String) -> UIImage?
    func set(_ image: UIImage, forKey key: String)
}

final class MemoryImageCache: ImageCacheType {
    private var cache = NSCache<NSString, UIImage>()
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
