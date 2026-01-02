//
//  MockNetworkClient.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/2/26.
//

import Foundation
@testable import ITBooksSearch

final class MockNetworkClient: NetworkClientType {
    private(set) var callCount = 0
    var delayNanos: UInt64 = 0
    var dataToReturn: Data
    
    init(dataToReturn: Data) {
        self.dataToReturn = dataToReturn
    }
    
    func data(from url: URL) async throws -> Data {
        callCount += 1
        if delayNanos > 0 {
            try await Task.sleep(nanoseconds: delayNanos)
        }
        return dataToReturn
    }
    
    func decode<T>(_ type: T.Type, from url: URL) async throws -> T where T : Decodable {
        fatalError("decode(_:from:) is not used in ImageLoader tests")
    }
}
