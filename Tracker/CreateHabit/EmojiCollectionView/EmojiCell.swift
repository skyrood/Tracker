//
//  EmojiCell.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/30.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    let emoji: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .medium)
        
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emoji)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emoji.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
