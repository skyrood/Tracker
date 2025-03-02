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
    //    private var categories: [TrackerCategory] = []
    
    private var selectedDate: Date = Date()
    
    private var categories: [TrackerCategory] = [
        TrackerCategory(
            name: "Fitness",
            trackers: [
                Tracker(id: 1, title: "Morning Run", emoji: "🤮", color: .selection1, schedule: Weekday.monday | Weekday.tuesday | Weekday.thursday)
            ]
        ),
        TrackerCategory(
            name: "Productivity",
            trackers: [
                Tracker(id: 2, title: "Read a Book", emoji: "💩", color: .selection6, schedule: Weekday.monday),
                Tracker(id: 3, title: "Code for an Hour and complete the sprint", emoji: "☠️", color: .selection11, schedule: Weekday.sunday)
            ]
        )
    ]
    
    private var filteredCategories: [TrackerCategory] {
        let weekdayBit = getWeekdayBit(from: selectedDate)
        
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { $0.schedule & weekdayBit != 0 }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(name: category.name, trackers: filteredTrackers)
        }
    }
    
    private var completedTrackers: Set<TrackerRecord> = []
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "Black")
        label.text = "Kрекеры"
        
        return label
    }()
    
    private lazy var startMessageContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .clear
        
        return view
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
        label.numberOfLines = 2
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: label.font ?? .systemFont(ofSize: 12),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        let labelText = categories.isEmpty ? "Что будем отслеживать?" : "Привычки и события можно\nобъединить по смыслу"
        label.attributedText = NSAttributedString(string: labelText, attributes: attributes)
        
        return label
    }()
    
    private lazy var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCollectionViewCell")
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderView.identifier)
        
        return collectionView
    }()
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "White")
        
        setUpNavigationBar()
        
        showStartMessage()
        showTrackersCollectionView()
        
        updateUI()
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
        datePicker.addTarget(self, action: #selector (dateChanged(_:)), for: .valueChanged)
        
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
        addTrackerViewController.categoryList = categories.map { $0.name }
        addTrackerViewController.modalPresentationStyle = .pageSheet
        addTrackerViewController.view.layer.cornerRadius = 10
        present(addTrackerViewController, animated: true, completion: nil)
    }
    
    private func updateUI() {
        let hasTrackers = !filteredCategories.isEmpty
        
        print("update triggered. hasTrackers: \(hasTrackers)")
        startMessageContainerView.isHidden = hasTrackers
        trackersCollectionView.isHidden = !hasTrackers
    }
    
    private func showStartMessage() {
        print("showing start message")
        view.addSubview(startMessageContainerView)
        
        startMessageContainerView.addSubview(image)
        startMessageContainerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            startMessageContainerView.heightAnchor.constraint(equalToConstant: 140),
            startMessageContainerView.widthAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.width),
            startMessageContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            startMessageContainerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            image.heightAnchor.constraint(equalToConstant: 80),
            image.widthAnchor.constraint(equalToConstant: 80),
            image.centerXAnchor.constraint(equalTo: startMessageContainerView.centerXAnchor),
            image.topAnchor.constraint(equalTo: startMessageContainerView.topAnchor),
            
            messageLabel.centerXAnchor.constraint(equalTo: startMessageContainerView.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 16)
        ])
    }
    
    private func showTrackersCollectionView() {
        view.addSubview(trackersCollectionView)
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func getWeekdayBit(from date: Date) -> Int {
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        return 1 << ((weekdayIndex + 5) % 7)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        trackersCollectionView.reloadData()
        
        updateUI()
    }
    
    @objc private func toggleCompletion(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? TrackerCollectionViewCell,
              let indexPath = trackersCollectionView.indexPath(for: cell) else { return }

        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let record = TrackerRecord(trackerId: tracker.id, date: selectedDate)
        
        if completedTrackers.contains(record) {
            completedTrackers.remove(record)
        } else {
            completedTrackers.insert(record)
        }
        
        cell.configureButton(for: tracker, selectedDate: selectedDate, completedTrackers: completedTrackers)
        
        let completedCount = completedDaysCount(for: tracker)
        cell.daysCountLabel.text = "\(completedCount) дней"
    }
    
    func completedDaysCount(for tracker: Tracker) -> Int {
        return completedTrackers.filter{ $0.trackerId == tracker.id }.count
    }
}

// MARK: - extension UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    
}

// MARK: - extension UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCollectionViewCell", for: indexPath) as? TrackerCollectionViewCell
        
        guard let cell = cell else { return UICollectionViewCell() }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        
        cell.emojiLabel.text = filteredCategories[indexPath.section].trackers[indexPath.row].emoji
        cell.title = filteredCategories[indexPath.section].trackers[indexPath.row].title
        let completedCount = completedDaysCount(for: tracker)
        cell.daysCountLabel.text = "\(completedCount) дней"
        
        cell.configureButton(for: tracker, selectedDate: selectedDate, completedTrackers: completedTrackers)

        cell.completeTrackerButton.addTarget(self, action: #selector(toggleCompletion(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.identifier,
            for: indexPath
        ) as? CategoryHeaderView else {
            return UICollectionReusableView()
        }
        
        let category = filteredCategories[indexPath.section]
        header.configure(with: category.name)
        
        return header
    }
}

// MARK: - extension UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 9) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 46)
    }
}

// MARK: - extension UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
