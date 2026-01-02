//
//  TestImageFactory.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/2/26.
//

import UIKit

func makeTestPNGImage() async throws -> Data {
    let img = UIImage(systemName: "book")!
    return img.pngData()!
}
