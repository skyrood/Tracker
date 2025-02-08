//
//  ColorCell.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/02/06.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorView)
        contentView.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 3 : 0
            contentView.layer.borderColor = isSelected ? colorView.backgroundColor?.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
        }
    }
}
