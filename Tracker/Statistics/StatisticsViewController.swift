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
    private let statisticsService = StatisticsService()
    
    private var statistics: Statistics?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = Colors.primary
        label.text = L10n.statisticsTitle
        
        return label
    }()
    
    private lazy var statsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Colors.secondary
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    private var emptyStateView: EmptyStateView?
    
    private let emptyStateImage: UIImage? = UIImage(named: "StatisticsEmpty")
    private let emptyStateMessage: String = L10n.nothingToAnalyze
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        setupTitleLabel()
        
        view.backgroundColor = Colors.secondary
        
        statisticsService.onDidUpdate = { [weak self] in
            self?.updateStatistics()
        }
        
        if statisticsService.isEmpty {
            setupEmptyStateView()
        } else {
            statistics = statisticsService.calculate()
            setupStatsTableView()
        }
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
    
    private func setupStatsTableView() {
        view.addSubview(statsTableView)
        statsTableView.register(StatisticsTableViewCell.self, forCellReuseIdentifier: StatisticsTableViewCell.reuseIdentifier)
        statsTableView.allowsSelection = false
        statsTableView.isScrollEnabled = false
        
        NSLayoutConstraint.activate([
            statsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            statsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateStatistics() {
        if statisticsService.isEmpty {
            setupEmptyStateView()
            emptyStateView?.isHidden = false
            statsTableView.removeFromSuperview()
        } else {
            statistics = statisticsService.calculate()
            setupStatsTableView()
            emptyStateView?.removeFromSuperview()
            if statsTableView.superview == nil {
                setupStatsTableView()
            } else {
                statsTableView.reloadData()
            }
        }
    }
}

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.reuseIdentifier, for: indexPath) as? StatisticsTableViewCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            cell.configure(with: statistics?.bestPeriod, for: L10n.bestPeriod)
        case 1:
            cell.configure(with: statistics?.perfectDays, for: L10n.perfectDays)
        case 2:
            cell.configure(with: statistics?.trackersCompleted, for: L10n.trackersCompleted)
        case 3:
            cell.configure(with: statistics?.completedAverage, for: L10n.completedAverage)
        default:
            break
        }
        
        return cell
    }
}

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}
