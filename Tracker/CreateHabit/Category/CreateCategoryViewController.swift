//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/02/08.
//

import UIKit

final class CreateCategoryViewController: UIViewController {
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    private lazy var label: UILabel = UILabel()
    
    // MARK: - Private Properties
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White")
        navigationItem.hidesBackButton = true
        
        setupCreateCategoryLabel()
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func setupCreateCategoryLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(named: "Black")
        label.text = "Новая категория"
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
        ])
    }
}
