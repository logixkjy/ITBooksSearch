//
//  NetworkClient.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import Foundation

protocol NetworkClientType {
    func data(from url: URL) async throws -> Data
    func decode<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T
}

final class NetworkClient: NetworkClientType {
    private let sessin: URLSession
    
    init(sessin: URLSession = .shared) {
        self.sessin = sessin
    }
    
    func data(from url: URL) async throws -> Data {
        let (data, response) = try await sessin.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    func decode<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let data = try await data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
