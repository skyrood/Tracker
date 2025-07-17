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
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = Colors.black
        label.text = L10n.statisticsTitle
        
        return label
    }()
    
    private var emptyStateView: EmptyStateView?
    
    private let emptyStateImage: UIImage? = UIImage(named: "StatisticsEmpty")
    private let emptyStateMessage: String = L10n.nothingToAnalyze
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        view.backgroundColor = Colors.white
        
        setupTitleLabel()
        setupEmptyStateView()
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(44))
        ])
    }
    
    private func setupEmptyStateView() {
        emptyStateView = EmptyStateView(image: emptyStateImage, message: emptyStateMessage)
        guard let emptyStateView = emptyStateView else { return }
        
        view.addSubview(emptyStateView)
        
        let topAnchor = titleLabel.frame.maxY
        let bottomAnchor = view.safeAreaLayoutGuide.layoutFrame.maxY
        let availableHeight = bottomAnchor - topAnchor
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: topAnchor + (availableHeight / 2))
        ])
    }
}
