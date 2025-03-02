//
//  ColorCollectionTableViewCell.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/02/06.
//

import UIKit

final class ColorCollectionTableViewCell: UITableViewCell {
    
    // MARK: - Public Properties
    let cellReuseIdentifier = "ColorCollectionTableViewCell"
    
    var selectedColor: String?
    
    var onColorSelected: ((String) -> Void)?
    
    // MARK: - Private Properties
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        return collectionView
    }()
    
    private var colors: [String] = [
        "Selection 1",
        "Selection 2",
        "Selection 3",
        "Selection 4",
        "Selection 5",
        "Selection 6",
        "Selection 7",
        "Selection 8",
        "Selection 9",
        "Selection 10",
        "Selection 11",
        "Selection 12",
        "Selection 13",
        "Selection 14",
        "Selection 15",
        "Selection 16",
        "Selection 17",
        "Selection 18",
    ]

    // MARK: - Overrides Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: cellReuseIdentifier)
        setupColorCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func setupColorCollectionView() {
        contentView.addSubview(colorCollectionView)
        
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        NSLayoutConstraint.activate([
            colorCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

// MARK: - extension UICollectionViewDelegate
extension ColorCollectionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
            cell.isSelected = true
            selectedColor = colors[indexPath.row]
            onColorSelected?(colors[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
            cell.isSelected = false
            selectedColor = nil
        }
    }
}

// MARK: - extension UICollectionViewDataSource
extension ColorCollectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? ColorCell
        
        guard let cell else { return UICollectionViewCell() }
        
        cell.colorView.backgroundColor = UIColor(named: colors[indexPath.row])
        
        return cell
    }
}

// MARK: - extension UICollectionViewDelegateFlowLayout
extension ColorCollectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let emojiSize = (colorCollectionView.bounds.width - 25) / 6
        return CGSize(width: emojiSize, height: emojiSize )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

