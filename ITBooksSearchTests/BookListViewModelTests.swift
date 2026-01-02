//
//  BookListViewModelTests.swift
//  ITBooksSearchTests
//
//  Created by JooYoung Kim on 1/2/26.
//

import XCTest
@testable import ITBooksSearch

final class BookListViewModelTests: XCTestCase {

    enum TestError: Error {
        case dummy
    }
    
    final class MockBookAPIService: BookAPIServiceType {
        let result: Result<BookSearchResponse, Error>
        
        init(result: Result<BookSearchResponse, Error>
        ) {
            self.result = result
        }
        
        func search(query: String, page: Int) async throws -> BookSearchResponse {
            try result.get()
        }
        
        func detail(isbn13: String) async throws -> BookDetail {
            fatalError("detail is not used in BookListViewModelTests")
        }
    }
    
    @MainActor
    func testFetchBookList() async throws {
        let bookRes = BookSearchResponse(
            error: "0",
            total: "100",
            page: "1",
            books: [
                BookSummary(
                    title: "Test",
                    subtitle: "Sub",
                    isbn13: "978123",
                    price: "$10.99",
                    image: "https://example.com/image.png",
                    url: "https://example.com")
            ]
        )
        
        let api = MockBookAPIService(result: .success(bookRes))
        let vm = BookListViewModel(api: api)
        
        await vm.search(query: "Sub")
        
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(vm.books.count, 1)
        XCTAssertEqual(vm.books.first?.title, "Test")
        XCTAssertEqual(vm.books.first?.subtitle, "Sub")
        XCTAssertEqual(vm.books.first?.isbn13, "978123")
    }
    
    @MainActor
    func testFetchBookListError() async throws {
        let api = MockBookAPIService(result: .failure(TestError.dummy))
        let vm = BookListViewModel(api: api)
        
        await vm.search(query: "Sub")
        
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(vm.books.isEmpty)
    }
    
    @MainActor
    func testResetSearchClearBooks() async throws {
        let bookRes = BookSearchResponse(
            error: "0",
            total: "100",
            page: "1",
            books: [
                BookSummary(
                    title: "Test",
                    subtitle: "Sub",
                    isbn13: "978123",
                    price: "$10.99",
                    image: "https://example.com/image.png",
                    url: "https://example.com")
            ]
        )
        
        let api = MockBookAPIService(result: .success(bookRes))
        let vm = BookListViewModel(api: api)
        
        await vm.search(query: "Sub")
        XCTAssertFalse(vm.books.isEmpty)
        
        await vm.resetSearch()
        XCTAssertTrue(vm.books.isEmpty)
    }
}
