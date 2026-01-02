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
        title = "IT Book Store"
        view.backgroundColor = .systemBackground
        
        searchBar.delegate = self
        searchBar.searchTextField.inputAccessoryView = makekeyboardToolbar()
        searchBar.placeholder = "Search books (e.g. Swift, clean+code)"
        navigationItem.titleView = searchBar
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookCell.self, forCellReuseIdentifier: "BookCell")
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        updateEmptyState()
    }
    
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "Search for IT Books"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()
    
    private func updateEmptyState() {
        if vm.books.isEmpty {
            tableView.backgroundView = emptyLabel
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        Task { [weak self] in
            guard let self else { return }
            await vm.search(query: searchBar.text ?? "")
            await MainActor.run {
                self.tableView.reloadData()
                self.updateEmptyState()
                self.tableView.layoutIfNeeded()
                if self.vm.books.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            Task { [weak self] in
                guard let self else { return }
                await self.vm.resetSearch()
                self.tableView.reloadData()
                self.updateEmptyState()
                let top = CGPoint(x: 0, y: -self.tableView.adjustedContentInset.top)
                self.tableView.setContentOffset(top, animated: false)
            }
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
    
    private func makekeyboardToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let fiexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        toolbar.items = [fiexible, doneButton]
        return toolbar
    }
    
    @objc private func doneTapped() {
        searchBar.resignFirstResponder()
    }
}

