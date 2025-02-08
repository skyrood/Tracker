//
//  EmojiCollectionTableViewCell.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/02/01.
//

import UIKit

final class EmojiCollectionTableViewCell: UITableViewCell {
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    let cellReuseIdentifier = "EmojiCollectionTableViewCell"
    
    // MARK: - Private Properties
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        return collectionView
    }()
    
    private var emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪",
    ]
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: cellReuseIdentifier)
        setupEmojiCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func setupEmojiCollectionView() {
        contentView.addSubview(emojiCollectionView)
        
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

extension EmojiCollectionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
            cell.isSelected = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
            cell.isSelected = false
        }
    }
}

extension EmojiCollectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = emojiCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? EmojiCell
        
        guard let cell else { return UICollectionViewCell() }
        
        cell.emojiView.text = emojis[indexPath.row]
        
        return cell
    }
}

extension EmojiCollectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let emojiSize = (emojiCollectionView.bounds.width - 25) / 6
        return CGSize(width: emojiSize, height: emojiSize )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
