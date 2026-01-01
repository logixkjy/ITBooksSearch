//
//  BookListViewController.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import UIKit

final class BookListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let vm = BookListViewModel()
    private let imageLoader = ImageLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Books"
        view.backgroundColor = .systemBackground
        
        searchBar.delegate = self
        searchBar.placeholder = "Search books (e.g. Swift, JavaScript, MySQL)"
        navigationItem.titleView = searchBar
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookCell.self, forCellReuseIdentifier: "BookCell")
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        Task {
            await vm.search(query: searchBar.text ?? "")
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookCell
        let book = vm.books[indexPath.row]
        cell.configure(title: book.title, subTitle: book.subtitle, price: book.price)
        
        cell.setThumbnail(nil)
        if let url = book.imageURL {
            let imageToken = cell.setImageToken(url.absoluteString)
            Task {
                if let img = try? await imageLoader.load(url),
                   cell.isImageTokenValid(imageToken) {
                    cell.setThumbnail(img)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        Task { [weak self] in
            guard let self else { return }
            if let range = await vm.loadNextPageIfNeeded(currentIndex: indexPath.row) {
                let indexPath = range.map { IndexPath(row: $0, section: 0) }
                self.tableView.insertRows(at: indexPath, with: .none)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = vm.books[indexPath.row]
        navigationController?.pushViewController(BookDetailViewController(isbn13: book.isbn13, imageLoader: imageLoader), animated: true)
    }
}

