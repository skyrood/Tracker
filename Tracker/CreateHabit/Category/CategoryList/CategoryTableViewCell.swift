//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/07/09.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryListTableViewCell"
    
    let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor(named: "Black")
        
        return label
    }()
    
    var viewModel: CategoryViewModel?

    func configure(with viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        viewModel.categoryNameBinding = { [ weak self ] categoryName in
            self?.categoryNameLabel.text = categoryName
        }
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(categoryNameLabel)
        
        NSLayoutConstraint.activate([
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.categoryNameBinding = nil
    }
}
