//
//  BookCell.swift
//  ITBooksSearch
//
//  Created by JooYoung Kim on 1/1/26.
//

import UIKit

final class BookCell: UITableViewCell {
    private let imgThumb = UIImageView()
    private let lblTitle = UILabel()
    private let lblSubtitle = UILabel()
    private let lblPrice = UILabel()
    
    private var imageToken: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgThumb.contentMode = .scaleAspectFit
        imgThumb.translatesAutoresizingMaskIntoConstraints = false
        imgThumb.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imgThumb.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        lblTitle.numberOfLines = 2
        lblSubtitle.numberOfLines = 2
        lblSubtitle.font = .systemFont(ofSize: 13)
        lblPrice.font = .systemFont(ofSize: 13)
        
        imgThumb.backgroundColor = .blue
        lblTitle.text = "Title"
        lblSubtitle.text = "SubTitle"
        lblPrice.text = "$1.0"
        
        let textStack = UIStackView(arrangedSubviews: [lblTitle, lblSubtitle, lblPrice])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let root = UIStackView(arrangedSubviews: [imgThumb, textStack])
        root.axis = .horizontal
        root.spacing = 12
        root.alignment = .center
        root.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            root.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            root.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            root.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgThumb.image = nil
        imageToken = nil
    }
    
    func configure(title: String, subTitle: String, price: String) {
        lblTitle.text = title
        lblSubtitle.text = subTitle
        lblPrice.text = price
    }
    
    func setThumbnail(_ image: UIImage?) {
        imgThumb.image = image
    }
    
    func setImageToken(_ token: String) -> String {
        imageToken = token
        return token
    }
    
    func isImageTokenValid(_ token: String) -> Bool {
        imageToken == token
    }
}
