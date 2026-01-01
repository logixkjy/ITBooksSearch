//
//  BookSummary.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import Foundation

struct BookSearchResponce: Decodable {
    let error: String
    let total: String
    let page: String
    let books: [BookSummary]
}

struct BookSummary: Decodable, Hashable {
    let title: String
    let subtitle: String
    let isbn13: String
    let price: String
    let image: String
    let url: String
    
    var imageURL: URL? {
        URL(string: image)
    }
}

