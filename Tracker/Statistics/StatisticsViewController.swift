//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/04.
//

import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "Black")
        label.text = "Статистика"
        
        return label
    }()
    
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.image = UIImage(named: "StatisticsEmpty")
        
        return image
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.textColor = UIColor(named: "Black")
        label.text = "Анализировать пока нечего"
        
        return label
    }()
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "White")
        self.view.addSubview(label)
        self.view.addSubview(image)
        self.view.addSubview(messageLabel)
        
        setConstraints(for: label, relativeTo: view, constant: 44)
        setConstraints(for: image)
        setConstraints(for: messageLabel, relativeTo: image, constant: 88)
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func setConstraints(for label: UILabel, relativeTo relativeView: UIView, constant: Int) {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: relativeView.safeAreaLayoutGuide.topAnchor, constant: CGFloat(constant))
        ])
    }
    
    private func setConstraints(for image: UIImageView) {
        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 80),
            image.widthAnchor.constraint(equalToConstant: 80),
            image.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
}
