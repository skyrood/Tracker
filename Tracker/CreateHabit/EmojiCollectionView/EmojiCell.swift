//
//  EmojiCell.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/30.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    
    let emojiView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .medium)
        
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emojiView)
        contentView.layer.cornerRadius = 16

        NSLayoutConstraint.activate([
            emojiView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.backgroundColor = isSelected ? UIColor(named: "LightGray")?.cgColor : UIColor.clear.cgColor
        }
    }
}
