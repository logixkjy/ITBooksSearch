//
//  BookDetailViewModelTests.swift
//  ITBooksSearchTests
//
//  Created by JooYoung Kim on 1/2/26.
//

import XCTest
@testable import ITBooksSearch

final class BookDetailViewModelTests: XCTestCase {
    enum TestError: Error {
        case dummy
    }
    
    final class MockBookAPIService: BookAPIServiceType {
        let result: Result<BookDetail, Error>
        
        init(result: Result<BookDetail, Error>
        ) {
            self.result = result
        }
        
        func search(query: String, page: Int) async throws -> BookSearchResponse {
            fatalError("search is not used in BookDetailViewModelTests")
        }
        
        func detail(isbn13: String) async throws -> BookDetail {
            try result.get()
        }
    }
    
    @MainActor
    func testFetchBookDetail() async throws {
        let book = BookDetail(
            error: "0",
            title: "Test",
            subtitle: "Sub",
            authors: "A",
            publisher: "P",
            language: "English",
            isbn10: "111",
            isbn13: "978123",
            pages: "100",
            year: "2026",
            rating: "3",
            desc: "Description",
            price: "$10.99",
            image: "https://example.com/image.png",
            url: "https://example.com",
            pdf: ["chapter1": "https://example.com/chapter1.pdf"]
        )
        
        let api = MockBookAPIService(result: .success(book))
        let vm = BookDetailViewModel(api: api)
        
        await vm.load(isbn13: "978123")
        
        XCTAssertEqual(vm.bookDetail?.isbn13 ?? "", "978123")
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }
    
    @MainActor
    func testFetchBookDetailError() async throws {
        let api = MockBookAPIService(result: .failure(TestError.dummy))
        let vm = BookDetailViewModel(api: api)
        
        await vm.load(isbn13: "978123")
        
        XCTAssertNil(vm.bookDetail)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNotNil(vm.errorMessage)
    }
}
