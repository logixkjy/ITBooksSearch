//
//  ImageLoaderTests.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/2/26.
//

import XCTest
@testable import ITBooksSearch
import UIKit

final class ImageLoaderTests: XCTestCase {
    private func makeIsolatedDiskCache() -> DiskImageCache {
        DiskImageCache(folderName: "test_book_image_cache_\(UUID().uuidString)")
    }
    
    func testLoadTwiceUsesCacheFatchOnce() async throws {
        let url = URL(string: "https://example.com/a.png")!
        let network = try await MockNetworkClient(dataToReturn: makeTestPNGImage())
        
        let loader = await ImageLoader(
            network: network,
            memory: MemoryImageCache(),
            disk: makeIsolatedDiskCache()
        )
        
        _ = try await loader.load(url)
        _ = try await loader.load(url)
        
        XCTAssertEqual(network.callCount, 1)
    }
    
    func testConcurrentLoadsDedupInflightFetchOnce() async throws {
        let url = URL(string: "https://example.com/a.png")!
        let network = try await MockNetworkClient(dataToReturn: makeTestPNGImage())
        network.delayNanos = 200_000_000
        
        let loader = await ImageLoader(
            network: network,
            memory: MemoryImageCache(),
            disk: makeIsolatedDiskCache()
        )
        
        async let a = loader.load(url)
        async let b = loader.load(url)
        _ = try await (a, b)

        XCTAssertEqual(network.callCount, 1)
    }
}
