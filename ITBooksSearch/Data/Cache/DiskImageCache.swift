//
//  DiskImageCache.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import Foundation
import UIKit

final class DiskImageCache {
    private let directoryURL: URL
    
    init(folderName: String = "book_image_cache") {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.directoryURL = caches.appendingPathComponent(folderName, isDirectory: true)
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
    
    func load(forKey key: String) -> UIImage? {
        let url = directoryURL.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    func save(_ image: UIImage, forKey key: String) {
        let url = directoryURL.appendingPathComponent(key)
        guard let data = image.pngData() else { return }
        try? data.write(to: url, options: [.atomic])
    }
}
