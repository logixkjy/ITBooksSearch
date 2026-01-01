//
//  BookAPIService.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import Foundation

protocol BookAPIServiceType {
    func search(query: String, page: Int) async throws -> BookSearchResponce
    func detail(isbn13: String) async throws -> BookDetail
}

final class BookAPIService: BookAPIServiceType {
    private let network: NetworkClientType
    
    init(network: NetworkClientType = NetworkClient()) {
        self.network = network
    }
    
    func search(query: String, page: Int) async throws -> BookSearchResponce {
        try await network.decode(BookSearchResponce.self, from: Endpoint.search(query: query, page: page).url)
    }
    
    func detail(isbn13: String) async throws -> BookDetail {
        try await network.decode(BookDetail.self, from: Endpoint.detail(isbn13: isbn13).url)
    }
}
