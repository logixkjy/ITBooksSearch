//
//  BookDetailViewModel.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import Foundation

final class BookDetailViewModel {
    private let api: BookAPIServiceType
    
    private(set) var bookDetail: BookDetail? = nil
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil
    
    var onUpdate: (() -> Void)?
    
    private var currentISBN13: String?
    
    init(api: BookAPIServiceType = BookAPIService()) {
        self.api = api
    }
    
    @MainActor
    func load(isbn13: String) async {
        if isLoading { return }
        if currentISBN13 == isbn13, bookDetail != nil { return }
        
        currentISBN13 = isbn13
        isLoading = true
        errorMessage = nil
        onUpdate?()
        
        defer {
            isLoading = false
            onUpdate?()
        }
        
        do {
            let res = try await api.detail(isbn13: isbn13)
            bookDetail = res
        } catch {
            bookDetail = nil
            errorMessage = "Failed to load deail for \(isbn13). Please try again later."
        }
    }
}
