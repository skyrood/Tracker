//
//  StatisticsTableViewCell.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/07/20.
//

import UIKit

final class StatisticsTableViewCell: UITableViewCell {
    
    // MARK: - Public Properties
    static let reuseIdentifier = "StatisticsTableViewCell"
    
    // MARK: - Private Properties
    private let gradientLayer = CAGradientLayer()
    private let borderMask = CAShapeLayer()
    
    private let statisticsCellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = Colors.black
        
        return label
    }()
    
    private let statisticLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = Colors.black
        
        return label
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Public Methods
    func configure(with counter: Int?, for statistics: String) {
        counterLabel.text = counter.map { "\($0)" } ?? "-"
        statisticLabel.text = statistics
    }
    
    // MARK: - Private Methods
    private func setup() {
        backgroundColor = .clear
        contentView.addSubview(statisticsCellView)
        
        statisticsCellView.addSubview(counterLabel)
        statisticsCellView.addSubview(statisticLabel)
        
        NSLayoutConstraint.activate([
            statisticsCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            statisticsCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statisticsCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            statisticsCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
                        
            counterLabel.topAnchor.constraint(equalTo: statisticsCellView.topAnchor, constant: 12),
            counterLabel.leadingAnchor.constraint(equalTo: statisticsCellView.leadingAnchor, constant: 12),
            
            statisticLabel.bottomAnchor.constraint(equalTo: statisticsCellView.bottomAnchor, constant: -12),
            statisticLabel.leadingAnchor.constraint(equalTo: statisticsCellView.leadingAnchor, constant: 12),
        ])
        
        setupGradientBorder()
    }
    
    private func setupGradientBorder() {
        gradientLayer.colors = [
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 102 - 12)
        
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(
            roundedRect: gradientLayer.bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: 16
        ).cgPath
        shape.lineWidth = 1
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = shape
        statisticsCellView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
