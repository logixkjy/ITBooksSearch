//
//  BookListViewModel.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import Foundation

final class BookListViewModel {
    private let api: BookAPIServiceType
    
    private(set) var books: [BookSummary] = []
    private(set) var isLoading: Bool = false
    private(set) var isLoadingNextPage: Bool = false
    private(set) var hasNextPage: Bool = true
    
    private var currentQuery: String = ""
    private var nextPage: Int = 1
    
    init(api: BookAPIServiceType = BookAPIService()) {
        self.api = api
    }
    
    func search(query: String) async {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ").joined(separator: "+")
        guard !q.isEmpty else { return }
        
        isLoading = true
        currentQuery = q
        nextPage = 1
        hasNextPage = true
        
        defer { isLoading = false }
        
        do {
            let res = try await api.search(query: q, page: 1)
            books = res.books
            nextPage = (Int(res.page) ?? 1) + 1
            
            let total = Int(res.total) ?? books.count
            hasNextPage = total > books.count
        } catch {
            books = []
            hasNextPage = false
        }
    }
    
    func loadNextPageIfNeeded(currentIndex: Int) async -> Range<Int>? {
        guard hasNextPage, !isLoading, !isLoadingNextPage else { return nil }
        
        guard currentIndex >= books.count - 5 else { return nil }
        
        isLoadingNextPage = true
        defer { isLoadingNextPage = false }
        
        do {
            let oldCount = books.count
            let res = try await api.search(query: currentQuery, page: nextPage)
            let newBooks = res.books
            books.append(contentsOf: newBooks)
            let newCount = books.count
            
            nextPage = (Int(res.page) ?? nextPage) + 1
            
            let total = Int(res.total) ?? books.count
            hasNextPage = total > books.count
            return oldCount..<newCount
        } catch {
            return nil
        }
    }
    
    func resetSearch() async {
        books.removeAll()
        currentQuery = ""
        nextPage = 1
        hasNextPage = true
        isLoading = false
    }
}
