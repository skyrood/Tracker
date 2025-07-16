//
//  EmptyStateView.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/03/03.
//

import UIKit

final class EmptyStateView: UIView {
    
    private let imageView: UIImageView = UIImageView()
    private let messageLabel: UILabel = UILabel()
    
    init(image: UIImage?, message: String) {
        super.init(frame: .zero)
        setupView(image: image, message: message)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(image: UIImage?, message: String) {
        imageView.image = image
        messageLabel.text = message
    }
    
    private func setupView(image: UIImage?, message: String) {
        translatesAutoresizingMaskIntoConstraints = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.image = image
        addSubview(imageView)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.clipsToBounds = true
        messageLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        messageLabel.textColor = UIColor(named: "Black")
        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .center
        messageLabel.text = message
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            
            messageLabel.firstBaselineAnchor.constraint(equalTo: imageView.lastBaselineAnchor, constant: 24),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 230),
            messageLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
        ])
    }
}
