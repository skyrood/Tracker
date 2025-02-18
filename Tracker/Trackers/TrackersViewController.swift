//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/04.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private var categories: [TrackerCategory] = []
    
    private var completedTrackers: [TrackerRecord] = []
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "Black")
        label.text = "Kрекеры"
        
        return label
    }()
    
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.image = UIImage(named: "TrackersEmpty")
        
        return image
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.textColor = UIColor(named: "Black")
        label.text = "Что будем отслеживать?"
        
        return label
    }()
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "White")
        
        if categories.isEmpty {
            showStartMessage()
        } else {
            showTrackers()
        }
        
        setUpNavigationBar()
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
    
    private func setConstraints(for searchBar: UISearchBar) {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: label.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setUpNavigationBar() {
        title = "Крекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addTrackerButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTrackerButtonTapped)
        )
        addTrackerButton.tintColor = UIColor(named: "Black")

        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        
        let searchBar = UISearchController(searchResultsController: nil)
        searchBar.searchResultsUpdater = self
        searchBar.obscuresBackgroundDuringPresentation = false
        searchBar.searchBar.placeholder = "Поиск"
        
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchBar
    }
    
    @objc private func addTrackerButtonTapped() {
        let addTrackerViewController = AddTrackerViewController()
        addTrackerViewController.modalPresentationStyle = .pageSheet
        addTrackerViewController.view.layer.cornerRadius = 10
        present(addTrackerViewController, animated: true, completion: nil)
    }
    
    private func showStartMessage() {
        print("hello dude!")

        view.addSubview(image)
        view.addSubview(messageLabel)
        
        setConstraints(for: image)
        setConstraints(for: messageLabel, relativeTo: image, constant: 88)
    }
    
    private func showTrackers() {
//        view.addSubview(collectionView)
//
//        setConstraints(for: collectionView)
        print("show collection of my beautiful trackers")
    }
}

// MARK: - extension UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {}

// MARK: - extension UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = .red
        cell.contentView.layer.cornerRadius = 10
        
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 30) / 2
        return CGSize(width: width, height: width)
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    
    }
}
