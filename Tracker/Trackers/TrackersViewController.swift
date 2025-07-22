//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/04.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Private Properties
    private let categoryStore = TrackerCategoryStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
        
    private var selectedDate: Date = Date()
    private var selectedFilter: TrackerFilter = .all
    
    private var searchText: String = ""
    
    private var categories: [TrackerCategory] = []
        
    private var filteredCategories: [TrackerCategory] {
        let weekdayBit = getWeekday(from: selectedDate)
        
        return categories.compactMap { category in
            var trackers = category.trackers
            
            trackers = trackers.filter { $0.schedule?.contains(weekdayBit) ?? true }
            
            switch selectedFilter {
            case .completed:
                trackers = trackers.filter { isTrackerCompleted($0) }
            case .uncompleted:
                trackers = trackers.filter { !isTrackerCompleted($0) }
            case .today:
                break
            case .all:
                break
            }
            
            if !searchText.isEmpty {
                let lowered = searchText.lowercased()
                trackers = trackers.filter {
                    $0.name.lowercased().contains(lowered) ||
                    category.name.lowercased().contains(lowered)
                }
            }
            
            return trackers.isEmpty ? nil : TrackerCategory(name: category.name, trackers: trackers)
        }
    }
    
    private var completedTrackers: Set<TrackerRecord> = []

    private var emptyStateView: EmptyStateView?
    
    private let datePicker = UIDatePicker()

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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.setTitle(L10n.filters, for: .normal)
        button.backgroundColor = Colors.blue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        view.backgroundColor = Colors.secondary
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackerRecordsDidChange),
            name: .trackerRecordsDidChange,
            object: nil
        )
        
        categoryStore.delegate = self
        
        categories = categoryStore.categories
        
        completedTrackers = trackerRecordStore.records

        setupNavigationBar()
        
        setupEmptyStateView()
        showTrackersCollectionView()
        
        setupFiltersButton()
        
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsService.shared.reportEvent(
            event: "open",
            params: ["screen": "Main"]
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        AnalyticsService.shared.reportEvent(
            event: "close",
            params: ["screen": "Main"]
        )
    }
    
    // MARK: - Public Methods (testing)
    func setTestData() {
        let weekdays: Weekday = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        selectedDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 13))!
        categories = [
            TrackerCategory(name: "Work", trackers: [
                Tracker(id: UUID(), name: "Do Job", emoji: "🍻", colorName: "Selection 13", schedule: weekdays)
            ]),
        ]
        
        trackersCollectionView.reloadData()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        title = L10n.trackersTitle
        navigationController?.navigationBar.prefersLargeTitles = true

        let addButton = UIButton(type: .system)
        let plusImage = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))

        addButton.setImage(plusImage, for: .normal)
        addButton.tintColor = Colors.primary
        addButton.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)

        let addTrackerButton = UIBarButtonItem(customView: addButton)
        navigationItem.rightBarButtonItem = addTrackerButton
        
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
        let hasTrackersOnSelectedDate = hasTrackersOnSelectedDate()
        
        trackersCollectionView.isHidden = !hasTrackers
        filterButton.isHidden = !hasTrackersOnSelectedDate
        
        if hasTrackers {
            emptyStateView?.isHidden = true
            return
        }
        
        let image: UIImage?
        let message: String
        
        if !hasTrackersOnSelectedDate {
            image = UIImage(named: "TrackersEmpty")
            message = L10n.whatToTrack
        } else {
            image = UIImage(named: "NoSearchResults")
            message = L10n.nothingFound
        }
        
        emptyStateView?.update(image: image, message: message)
        emptyStateView?.isHidden = false
    }
    
    private func setupEmptyStateView() {
        emptyStateView = EmptyStateView(image: UIImage(named: "TrackersEmpty"), message: categories.isEmpty ? L10n.whatToTrack : L10n.categoryTipMultiline)
        guard let emptyStateView = emptyStateView else { return }
        
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    private func setupFiltersButton() {
        view.addSubview(filterButton)
        view.bringSubviewToFront(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
        ])
    }
    
    private func showTrackersCollectionView() {
        view.addSubview(trackersCollectionView)
        trackersCollectionView.contentInset.bottom = 58
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func showDeleteConfirmationAlert(for tracker: Tracker) {
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let title = NSAttributedString(
            string: L10n.deleteTrackerConfirmation,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]
        )
        alert.setValue(title, forKey: "attributedTitle")
        
        alert.addAction(UIAlertAction(title: L10n.deleteTrackerButton, style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            do {
                try categoryStore.deleteTracker(with: tracker.id)
            } catch {
                print("Error deleting tracker: \(error)")
            }
        }))
                                      
        alert.addAction(UIAlertAction(title: L10n.cancelButton, style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    private func getWeekday(from date: Date) -> Weekday {
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let weekdays: [Weekday] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        return weekdays[weekdayIndex - 1]
    }
    
    private func isTrackerCompleted(_ tracker: Tracker) -> Bool {
        completedTrackers.contains {
            $0.trackerId == tracker.id &&
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    private func completedDaysCount(for tracker: Tracker) -> Int {
        completedTrackers.filter{ $0.trackerId == tracker.id }.count
    }
    
    private func hasTrackersOnSelectedDate() -> Bool {
        let weekdayBit = getWeekday(from: selectedDate)
        return categories.contains { category in
            category.trackers.contains { $0.schedule?.contains(weekdayBit) ?? true }
        }
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        selectedFilter = filter
        
        if filter == .today {
            let today = Date()
            selectedDate = today
            datePicker.setDate(today, animated: false)
        }
        
        trackersCollectionView.reloadData()
        updateUI()
    }
    
    @objc private func addTrackerButtonTapped() {
        AnalyticsService.shared.reportEvent(
            event: "click",
            params: [
                "screen": "Main",
                "item": "add_track"
            ]
        )
        
        let newTrackerViewController = NewTrackerViewController(categoryStore: categoryStore)
        newTrackerViewController.passHabitToTrackersList = { [weak self] in
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
        AnalyticsService.shared.reportEvent(
            event: "click",
            params: [
                "screen": "Main",
                "item": "track"
            ]
        )
        
        guard let cell = sender.superview?.superview as? TrackerCollectionViewCell,
              let indexPath = trackersCollectionView.indexPath(for: cell) else { return }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let record = TrackerRecord(trackerId: tracker.id, date: Calendar.current.startOfDay(for: selectedDate))
        
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
    
    @objc private func showFilters() {
        AnalyticsService.shared.reportEvent(
            event: "click",
            params: [
                "screen": "Main",
                "item": "filter"
            ]
        )
        
        let filtersViewController = FiltersViewController()
        filtersViewController.selectedFilter = selectedFilter
        filtersViewController.onFilterSelected = { [weak self] filter in
            self?.applyFilter(filter)
        }
        
        present(filtersViewController, animated: true)
    }
    
    @objc private func handleTrackerRecordsDidChange() {
        completedTrackers = trackerRecordStore.records
        trackersCollectionView.reloadData()
        updateUI()
    }
    
    private func completedTrackersDaysCountString(for completedCount: Int) -> String {
        L10n.daysCompleted(completedCount)
    }
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
        
        let completedCount = completedDaysCount(for: tracker)
        cell.configure(for: tracker, with: completedCount, for: selectedDate)
        
        cell.configureButton(for: tracker, selectedDate: selectedDate, completedTrackers: completedTrackers)

        cell.completeTrackerButton.addTarget(self, action: #selector(toggleCompletion(_:)), for: .touchUpInside)
        
        cell.onEditButtonTapped = { [weak self] tracker in
            AnalyticsService.shared.reportEvent(
                event: "click",
                params: [
                    "screen": "Main",
                    "item": "edit"
                ]
            )
            
            guard let self else { return }
            let showScheduleOption = tracker.schedule != nil
            
            let selectedCategory = self.filteredCategories[indexPath.section]
                        
            let editTrackerViewController = CreateTrackerViewController(categoryStore: categoryStore, showScheduleOption: showScheduleOption, trackerToEdit: tracker, category: selectedCategory)
            
            editTrackerViewController.onHabitCreated = { [ weak self ] in
                self?.dismiss(animated: true)
                self?.trackersCollectionView.reloadData()
            }
            
            self.present(editTrackerViewController, animated: true)
        }
        
        cell.onDeleteButtonTapped = { [weak self] tracker in
            AnalyticsService.shared.reportEvent(
                event: "click",
                params: [
                    "screen": "Main",
                    "item": "delete"
                ]
            )
            
            self?.showDeleteConfirmationAlert(for: tracker)
        }
        
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

// MARK: - extension UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
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
        9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 46)
    }
}

// MARK: - extension UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        searchText = query
        
        trackersCollectionView.reloadData()
        updateUI()
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
