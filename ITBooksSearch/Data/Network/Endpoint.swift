//
//  Endpoint.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import Foundation

enum Endpoint {
    case search(query: String, page: Int)
    case detail(isbn13: String)
    
    var url: URL {
        switch self {
        case let .search(query, page):
            let encode = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? query
            return URL(string: "https://api.itbook.store/1.0/search/\(encode)/\(page)")!
        case let .detail(isbn13):
            return URL(string: "https://api.itbook.store/1.0/books/\(isbn13)")!
        }
    }
}
