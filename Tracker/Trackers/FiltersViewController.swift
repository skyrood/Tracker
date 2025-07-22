//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/07/19.
//

import UIKit

enum TrackerFilter {
    case all
    case today
    case completed
    case uncompleted
}

final class FiltersViewController: UIViewController {
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    var selectedFilter: TrackerFilter?
    
    var onFilterSelected: ((TrackerFilter) -> Void)?
    
    // MARK: - Private Properties
    private var titleLabel: UILabel = UILabel()
    
    private var filtersTableView = UITableView()
    
    private let filters: [(String, TrackerFilter)] = [
        (L10n.allTrackers, .all),
        (L10n.trackersForToday, .today),
        (L10n.completedTrackers, .completed),
        (L10n.uncompletedTrackers, .uncompleted),
    ]
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.secondary
        
        setupTitleLabel()
        setupFiltersTableView()
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.clipsToBounds = true
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = Colors.primary
        titleLabel.text = L10n.filters
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
        ])
    }
    
    private func setupFiltersTableView() {
        view.addSubview(filtersTableView)
        
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
        
        filtersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        filtersTableView.translatesAutoresizingMaskIntoConstraints = false
        filtersTableView.clipsToBounds = true
        filtersTableView.separatorStyle = .none
        filtersTableView.backgroundColor = Colors.inputBackground
        filtersTableView.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            filtersTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            filtersTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            filtersTableView.heightAnchor.constraint(equalToConstant: 75 * 4)
        ])
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .clear
        
        if indexPath.row < filters.count - 1 {
            let separatorLineView = UIView()
            separatorLineView.translatesAutoresizingMaskIntoConstraints = false
            separatorLineView.clipsToBounds = true
            separatorLineView.backgroundColor = Colors.gray
            separatorLineView.tag = 999
            
            cell.contentView.addSubview(separatorLineView)
            
            NSLayoutConstraint.activate([
                separatorLineView.heightAnchor.constraint(equalToConstant: 0.5),
                separatorLineView.topAnchor.constraint(
                    equalTo: cell.contentView.topAnchor, constant: 74.5),
                separatorLineView.leadingAnchor.constraint(
                    equalTo: cell.leadingAnchor, constant: 16),
                separatorLineView.trailingAnchor.constraint(
                    equalTo: cell.trailingAnchor, constant: -16),
            ])
        }
        
        let filter = filters[indexPath.row].1
        
        if filter == .completed || filter == .uncompleted {
            cell.accessoryType = (filter == selectedFilter) ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.text = filters[indexPath.row].0
        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.row].1
        onFilterSelected?(selectedFilter)
        dismiss(animated: true)
    }
}
