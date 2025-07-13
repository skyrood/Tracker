//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/04.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Private Properties
    private let categoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private var selectedDate: Date = Date()
        
    private var categories: [TrackerCategory] = []
        
    private var filteredCategories: [TrackerCategory] {
        let weekdayBit = getWeekday(from: selectedDate)
        
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { $0.schedule?.contains(weekdayBit) ?? true }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(name: category.name, trackers: filteredTrackers)
        }
    }
    
    private var completedTrackers: Set<TrackerRecord> = []

    private var emptyStateView: EmptyStateView?
    
    private var emptyStateImage: UIImage? = UIImage(named: "TrackersEmpty")
    private lazy var emptyStateMessage: String = categories.isEmpty ? L10n.whatToTrack :
    L10n.categoryTipMultiline
    
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
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "White")
        
        categoryStore.delegate = self
        trackerRecordStore.delegate = self
        
        categories = categoryStore.categories
        
        completedTrackers = trackerRecordStore.records

        setUpNavigationBar()
        
        setupEmptyStateView()
        showTrackersCollectionView()
        
        updateUI()
    }
    
    // MARK: - Private Methods
    private func setUpNavigationBar() {
        title = L10n.trackersTitle
        navigationController?.navigationBar.prefersLargeTitles = true

        let addButton = UIButton(type: .system)
        let plusImage = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))

        addButton.setImage(plusImage, for: .normal)
        addButton.tintColor = .black
        addButton.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)

        let addTrackerButton = UIBarButtonItem(customView: addButton)
        navigationItem.rightBarButtonItem = addTrackerButton
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector (dateChanged(_:)), for: .valueChanged)
        
        let searchBar = UISearchController(searchResultsController: nil)
        searchBar.searchResultsUpdater = self
        searchBar.obscuresBackgroundDuringPresentation = false
        searchBar.searchBar.placeholder = L10n.search
        
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchBar
    }
    
    private func updateUI() {
        let hasTrackers = !filteredCategories.isEmpty
        
        emptyStateView?.isHidden = hasTrackers
        trackersCollectionView.isHidden = !hasTrackers
    }
    
    private func setupEmptyStateView() {
        emptyStateView = EmptyStateView(image: emptyStateImage, message: emptyStateMessage)
        guard let emptyStateView = emptyStateView else { return }
        
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
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
    
    private func getWeekday(from date: Date) -> Weekday {
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let weekdays: [Weekday] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        return weekdays[weekdayIndex - 1]
    }
    
    private func completedDaysCount(for tracker: Tracker) -> Int {
        return completedTrackers.filter{ $0.trackerId == tracker.id }.count
    }
    
    @objc private func addTrackerButtonTapped() {
        let newTrackerViewController = NewTrackerViewController()
        newTrackerViewController.passHabitToTrackersList = { [weak self] newHabit, category in
            self?.dismiss(animated: true)
        }
        newTrackerViewController.modalPresentationStyle = .pageSheet
        newTrackerViewController.view.layer.cornerRadius = 10
        present(newTrackerViewController, animated: true, completion: nil)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        trackersCollectionView.reloadData()
        
        updateUI()
    }
    
    @objc private func toggleCompletion(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? TrackerCollectionViewCell,
              let indexPath = trackersCollectionView.indexPath(for: cell) else { return }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let record = TrackerRecord(trackerId: tracker.id, date: selectedDate)
        
        if completedTrackers.contains(record) {
            completedTrackers.remove(record)
            trackerRecordStore.deleteRecord(record)
        } else {
            completedTrackers.insert(record)
            trackerRecordStore.addRecord(record)
        }
        
        cell.configureButton(for: tracker, selectedDate: selectedDate, completedTrackers: completedTrackers)
        
        let completedCount = completedDaysCount(for: tracker)
        cell.daysCountLabel.text = completedTrackersDaysCountString(for: completedCount)
    }
    
    private func completedTrackersDaysCountString(for completedCount: Int) -> String {
        return L10n.daysCompleted(completedCount)
    }
}

// MARK: - extension UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    
}

// MARK: - extension UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCollectionViewCell", for: indexPath) as? TrackerCollectionViewCell
        
        guard let cell = cell else { return UICollectionViewCell() }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        
        cell.emojiLabel.text = filteredCategories[indexPath.section].trackers[indexPath.row].emoji
        cell.title = filteredCategories[indexPath.section].trackers[indexPath.row].name
        let completedCount = completedDaysCount(for: tracker)
        cell.daysCountLabel.text  = completedTrackersDaysCountString(for: completedCount)
        
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

// MARK: - extention TrackerCategoryStoreDelegate
extension TrackersViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore) {
        categories = store.categories
        trackersCollectionView.reloadData()
        updateUI()
    }
}

// MARK: - extention TrackerRecordStoreDelegate
extension TrackersViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore) {

    }
}
