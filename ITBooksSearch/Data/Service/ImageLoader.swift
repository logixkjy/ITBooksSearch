//
//  ImageLoader.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import Foundation
import CryptoKit
import UIKit

private func cacheKey(for url: URL) -> String {
    let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
    return digest.map { String(format: "%02x", $0) }.joined() + ".png"
}

actor ImageLoader {
    private let network: NetworkClientType
    private let memory: MemoryImageCache
    private let disk: DiskImageCache
    
    private var inFlight: [URL: Task<UIImage, Error>] = [:]
    
    init(network: NetworkClientType = NetworkClient(),
         memory: MemoryImageCache = MemoryImageCache(),
         disk: DiskImageCache = DiskImageCache()) {
        self.network = network
        self.memory = memory
        self.disk = disk
    }
    
    func load(_ url: URL) async throws -> UIImage {
        let key = await cacheKey(for: url)
        
        if let img = await memory.image(forKey: key) { return img }
        if let img = await disk.load(forKey: key) {
            await memory.set(img, forKey: key)
            return img
        }
        
        if let task = inFlight[url] {
            return try await task.value
        }
        
        let task = Task<UIImage, Error> {
            let data = try await self.network.data(from: url)
            guard let img = UIImage(data: data) else { throw URLError(.cannotDecodeContentData) }
            await memory.set(img, forKey: key)
            await disk.save(img, forKey: key)
            return img
        }
        
        inFlight[url] = task
        
        do {
            let img = try await task.value
            inFlight[url] = nil
            return img
        } catch {
            inFlight[url] = nil
            throw error
        }
    }
}
