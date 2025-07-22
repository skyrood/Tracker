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
    
    private var colorNames: [String] {
        Colors.sortedKeys
    }
    
    // MARK: - Overrides Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: cellReuseIdentifier)
        setupColorCollectionView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with selectedColor: String?) {
        self.selectedColor = selectedColor
        
        if let colorKey = selectedColor,
           let index = Colors.sortedKeys.firstIndex(of: colorKey) {
            let indexPath = IndexPath(item: index, section: 0)
            colorCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            
            DispatchQueue.main.async {
                if let cell = self.colorCollectionView.cellForItem(at: indexPath) as? ColorCell {
                    cell.isSelected = true
                }
            }
        }
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
            selectedColor = colorNames[indexPath.row]
            onColorSelected?(colorNames[indexPath.row])
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
        colorNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? ColorCell
        guard let cell else { return UICollectionViewCell() }
        
        let key = colorNames[indexPath.row]
        cell.colorView.backgroundColor = Colors.selection[key]
        
        return cell
    }
}

// MARK: - extension UICollectionViewDelegateFlowLayout
extension ColorCollectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let colorCellSize = (colorCollectionView.bounds.width - 25) / 6
        return CGSize(width: colorCellSize, height: colorCellSize )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

