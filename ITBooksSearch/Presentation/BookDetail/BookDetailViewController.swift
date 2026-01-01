//
//  BookDetailViewController.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import UIKit
import SafariServices

final class BookDetailViewController: UIViewController {
    private let isbn13: String
    private let vm: BookDetailViewModel
    private let imageLoader: ImageLoader?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let imgCover = UIImageView()
    private let lblTitle = UILabel()
    private let lblSubTitle = UILabel()
    private let lblMetaInfo = UILabel()
    private let lblPrice = UILabel()
    private let lblRating = UILabel()
    private let lblDesc = UILabel()
    
    private let activity = UIActivityIndicatorView(style: .large)
    private let lblError = UILabel()
    private let btnOpen = UIButton(type: .system)
    
    private var currentImageURLString: String?
    
    init(isbn13: String, vm: BookDetailViewModel = .init(), imageLoader: ImageLoader) {
        self.isbn13 = isbn13
        self.vm = vm
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
        view.backgroundColor = .systemBackground
        
        setupUI()
        bindViewModel()
        
        Task { [weak self] in
            guard let self else { return }
            await self.vm.load(isbn13: isbn13)
        }
    }
    
    private func bindViewModel() {
        vm.onUpdate = { [weak self] in
            guard let self else { return }
            self.render()
        }
    }
    
    private func render() {
        if vm.isLoading {
            activity.startAnimating()
        } else {
            activity.stopAnimating()
        }
        
        if let msg = vm.errorMessage {
            lblError.text = msg
            lblError.isHidden = false
        } else {
            lblError.isHidden = true
        }
        
        guard let book = vm.bookDetail else { return }
            
        lblTitle.text = book.title
        lblSubTitle.text = book.subtitle.isEmpty ? nil : book.subtitle
        lblSubTitle.isHidden = (lblSubTitle.text == nil)
        
        lblMetaInfo.text = [
            book.authors.isEmpty ? nil : "By: \(book.authors)",
            book.publisher.isEmpty ? nil : "Published by: \(book.publisher)",
            book.year.isEmpty ? nil : "Published in: \(book.year)"
        ].compactMap { $0 }.joined(separator: "\n")
        
        lblPrice.text = book.price
        lblRating.text = "Rating: \(book.rating)/5"
        lblDesc.text = book.desc
        
        btnOpen.isHidden = book.url.isEmpty
        
        loadCoverIfNeeded(urlString: book.image)
    }
    
    private func loadCoverIfNeeded(urlString: String) {
        guard let loader = imageLoader else { return }
        guard let url = URL(string: urlString) else { return }
        
        if currentImageURLString == urlString { return }
        currentImageURLString = urlString
        
        imgCover.image = nil
        
        Task { [weak self] in
            guard let self else { return }
            let img = try? await loader.load(url)
            
            if self.currentImageURLString == urlString {
                self.imgCover.image = img
            }
        }
    }
    
    @objc private func tapOpen() {
        guard let url = URL(string: vm.bookDetail?.url ?? "") else { return }
        
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        imgCover.contentMode = .scaleAspectFit
        imgCover.clipsToBounds = true
        imgCover.backgroundColor = .secondarySystemBackground
        imgCover.layer.cornerRadius = 12
        imgCover.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imgCover.heightAnchor.constraint(equalToConstant: 240),
        ])
        
        lblTitle.numberOfLines = 0
        lblTitle.font = .systemFont(ofSize: 20)
        
        lblSubTitle.numberOfLines = 0
        lblSubTitle.font = .systemFont(ofSize: 15)
        lblSubTitle.textColor = .secondaryLabel
        
        lblMetaInfo.numberOfLines = 0
        lblMetaInfo.font = .systemFont(ofSize: 14)
        lblMetaInfo.textColor = .secondaryLabel
        
        lblPrice.font = .boldSystemFont(ofSize: 16)
        
        lblRating.font = .systemFont(ofSize: 14)
        lblRating.textColor = .secondaryLabel
        
        lblDesc.numberOfLines = 0
        lblDesc.font = .systemFont(ofSize: 15)
        lblDesc.textColor = .secondaryLabel
        
        btnOpen.setTitle("Open IT Bookstore", for: .normal)
        btnOpen.addTarget(self, action: #selector(tapOpen), for: .touchUpInside)
        btnOpen.isHidden = true
        
        lblError.numberOfLines = 0
        lblError.font = .systemFont(ofSize: 14)
        lblError.textColor = .systemRed
        lblError.isHidden = true
        
        activity.hidesWhenStopped = true
        activity.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activity)
        
        NSLayoutConstraint.activate([
            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let textStack = UIStackView(arrangedSubviews: [
            lblTitle,
            lblSubTitle,
            lblMetaInfo,
            lblPrice,
            lblRating,
            btnOpen,
            lblError,
            lblDesc
        ])
        textStack.axis = .vertical
        textStack.spacing = 10
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        let rootStack = UIStackView(arrangedSubviews: [
            imgCover,
            textStack
        ])
        rootStack.axis = .vertical
        rootStack.spacing = 16
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(rootStack)
        
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rootStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
}
