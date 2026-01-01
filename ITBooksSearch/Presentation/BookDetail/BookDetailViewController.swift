//
//  BookDetailViewController.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import UIKit

final class BookDetailViewController: UIViewController {
    
    private let imgThumb = UIImageView()
    private let lblTitle = UILabel()
    private let lblSubTitle = UILabel()
    private let lblPrice = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        imgThumb.contentMode = .scaleAspectFit
        lblTitle.numberOfLines = 0
        lblTitle.font = .systemFont(ofSize: 18)
        
        lblSubTitle.numberOfLines = 0
        lblSubTitle.font = .systemFont(ofSize: 14)
        
        let stack = UIStackView(arrangedSubviews: [imgThumb, lblTitle, lblSubTitle])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        imgThumb.backgroundColor = .systemGray
        lblTitle.text = "Title"
        lblSubTitle.text = "SubTitle"
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imgThumb.heightAnchor.constraint(equalToConstant: 240)
        ])
    }
}
