//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/25.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let trackerNameMaxLength: Int = 38
    }
    
    // MARK: - Public Properties
    var categoryStore: TrackerCategoryStore
    var trackerName: String?
    var showScheduleOption: Bool
    
    var onHabitCreated: (() -> Void)?
    
    // MARK: - Private Properties
    private var trackerToEdit: Tracker?
    
    private var selectedCategory: TrackerCategory?
    private var colorName: String?
    private var emoji: String?
    private var selectedWeekdays: Weekday?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = Colors.white
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.text = L10n.newTracker
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Colors.black
        return label
    }()
    
    private lazy var habitNameLimitWarning: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        
        label.text = L10n.trackerNameLimit(Constants.trackerNameMaxLength)
        label.font = .systemFont(ofSize: 17)
        label.textColor = Colors.red
        return label
    }()
    
    private var cancelButton: UIButton = UIButton()
    private var createButton: UIButton = UIButton()
    
    private var shouldShowWarningCell = false
    
    // MARK: - Initializers
    init(categoryStore: TrackerCategoryStore, showScheduleOption: Bool = true, trackerToEdit: Tracker? = nil, category: TrackerCategory? = nil) {
        self.categoryStore = categoryStore
        self.showScheduleOption = showScheduleOption
        self.trackerToEdit = trackerToEdit
        self.selectedCategory = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        navigationItem.hidesBackButton = true
        
        if let tracker = trackerToEdit {
            trackerName = tracker.name
            emoji = tracker.emoji
            colorName = tracker.colorName
            selectedWeekdays = tracker.schedule
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EmojiCollectionTableViewCell.self, forCellReuseIdentifier: "EmojiCollectionTableViewCell")
        tableView.register(ColorCollectionTableViewCell.self, forCellReuseIdentifier: "ColorCollectionTableViewCell")
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        setConstraints(for: titleLabel, topConstraint: 26)
        setConstraints(for: tableView)
        setupTableFooterButtons()
        updateCreateButtonState()
    }
    
    // MARK: - Private Methods
    private func setConstraints(for titleLabel: UILabel, topConstraint: CGFloat)
    {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: topConstraint),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setConstraints(for tableView: UITableView) {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 50),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupTableFooterButtons() {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let cancelButtonTitle = NSAttributedString(string: L10n.cancel, attributes: attributes)
        let createButtonTitle = (trackerToEdit != nil) ? NSAttributedString(string: L10n.save) : NSAttributedString(string: L10n.create, attributes: attributes)
        
        cancelButton.setAttributedTitle(cancelButtonTitle, for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(
            self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        createButton.setAttributedTitle(createButtonTitle, for: .normal)
        createButton.setTitleColor(Colors.white, for: .normal)
        createButton.backgroundColor = Colors.black
        createButton.layer.cornerRadius = 16
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.addTarget(
            self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        footerView.addSubview(cancelButton)
        footerView.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(
                equalTo: footerView.leadingAnchor),
            cancelButton.topAnchor.constraint(
                equalTo: footerView.topAnchor, constant: 16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(
                equalTo: footerView.trailingAnchor),
            createButton.topAnchor.constraint(
                equalTo: footerView.topAnchor, constant: 16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
        ])
        
        footerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80)
        tableView.tableFooterView = footerView
    }
    
    private func selectedReadableWeekdays() -> String? {
        guard let selectedWeekdays else { return nil }
        let days = [
            (Weekday.monday, L10n.monShort),
            (Weekday.tuesday, L10n.tueShort),
            (Weekday.wednesday, L10n.wedShort),
            (Weekday.thursday, L10n.thuShort),
            (Weekday.friday, L10n.friShort),
            (Weekday.saturday, L10n.satShort),
            (Weekday.sunday, L10n.sunShort)
        ]
        
        let selectedDays = days
            .filter { selectedWeekdays.contains($0.0) }
            .map { $0.1 }
        
        if selectedDays.count == days.count {
            return L10n.everyDay
        }
        
        return selectedDays.joined(separator: ", ")
    }
    
    private func updateCreateButtonState() {
        guard let trackerName = trackerName, !trackerName.isEmpty,
              selectedCategory != nil,
              emoji != nil,
              colorName != nil else {
            createButton.isEnabled = false
            createButton.backgroundColor = Colors.gray
            return
        }
        
        createButton.isEnabled = true
        createButton.backgroundColor = Colors.black
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func createButtonTapped() {
        guard let selectedCategory = selectedCategory,
              let emoji = emoji,
              let colorName = colorName,
              let trackerName = trackerName else {
            print("Error: Missing required fields")
            return
        }
        
        do {
            try categoryStore.addOrUpdateTracker(trackerID: trackerToEdit?.id, name: trackerName, emoji: emoji, color: colorName, schedule: selectedWeekdays, to: selectedCategory)
            onHabitCreated?()
        } catch {
            print("Saving new tracker failed: \(error)")
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - extension UITextFieldDelegate
extension CreateTrackerViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(
            in: stringRange, with: string)
        
        updateCreateButtonState()
        
        if updatedText.count <= Constants.trackerNameMaxLength {
            trackerName = updatedText
            
            if shouldShowWarningCell {
                shouldShowWarningCell = false
                tableView.performBatchUpdates {
                    tableView.deleteRows(
                        at: [IndexPath(row: 1, section: 0)], with: .fade)
                }
            }
            
            return true
        } else {
            if !shouldShowWarningCell {
                shouldShowWarningCell = true
                tableView.performBatchUpdates {
                    tableView.insertRows(
                        at: [IndexPath(row: 1, section: 0)], with: .fade)
                }
            }
            
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - extension UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 75
            } else if indexPath.row == 1 {
                return 30
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 || indexPath.row == 1 {
                return 75
            }
        } else if indexPath.section == 2 || indexPath.section == 3 {
            return 180
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(
        _ tableView: UITableView, viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        if section == 2 {
            let emojiLabel = UILabel()
            emojiLabel.textColor = Colors.black
            emojiLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            emojiLabel.text = "Emoji"
            
            headerView.addSubview(emojiLabel)
            
            NSLayoutConstraint.activate([
                emojiLabel.topAnchor.constraint(
                    equalTo: headerView.topAnchor, constant: 10),
                emojiLabel.leadingAnchor.constraint(
                    equalTo: headerView.leadingAnchor, constant: 14),
            ])
        }
        
        if section == 3 {
            let emojiLabel = UILabel()
            emojiLabel.textColor = Colors.black
            emojiLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            emojiLabel.text = L10n.color
            
            headerView.addSubview(emojiLabel)
            
            NSLayoutConstraint.activate([
                emojiLabel.topAnchor.constraint(
                    equalTo: headerView.topAnchor, constant: 10),
                emojiLabel.leadingAnchor.constraint(
                    equalTo: headerView.leadingAnchor, constant: 14),
            ])
        }
        
        return headerView
    }
    
    func tableView(
        _ tableView: UITableView, heightForHeaderInSection section: Int
    ) -> CGFloat {
        if section == 2 || section == 3 {
            return 50
        }
        
        return 0.01
    }
    
    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let categoryListViewController = CategoryListViewController()
                categoryListViewController.selectedCategory = selectedCategory
                
                if selectedCategory != nil {
                    categoryListViewController.selectedCategory = selectedCategory
                }
                
                categoryListViewController.onCategorySelected = { [weak self] category in
                    self?.selectedCategory = category
                    self?.updateCreateButtonState()
                    tableView.reloadData()
                }
                
                categoryListViewController.modalPresentationStyle = .pageSheet
                categoryListViewController.view.layer.cornerRadius = 10
                
                present(categoryListViewController, animated: true, completion: nil)
            } else if indexPath.row == 1 && showScheduleOption {
                let createScheduleViewController = CreatecreateScheduleViewController()
                createScheduleViewController.selectedWeekdays = selectedWeekdays ?? []
                createScheduleViewController.onScheduleCreated = { [weak self] selectedDays in
                    self?.selectedWeekdays = selectedDays
                    self?.updateCreateButtonState()
                    self?.tableView.reloadData()
                }
                createScheduleViewController.modalPresentationStyle = .pageSheet
                createScheduleViewController.view.layer.cornerRadius = 10
                present(createScheduleViewController, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - extension UITableViewDataSource
extension CreateTrackerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int
    {
        switch section {
        case 0:
            return shouldShowWarningCell ? 2 : 1
        case 1:
            return showScheduleOption ? 2 : 1
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
    {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return habitNameFieldCell()
            } else if indexPath.row == 1 {
                return charactersLimitWarningCell()
            }
        } else if indexPath.section == 1 {
            return categoryScheduleCells(indexPath)
        } else if indexPath.section == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiCollectionTableViewCell", for: indexPath) as? EmojiCollectionTableViewCell {
                cell.onEmojiSelected = { [weak self] emoji in
                    self?.emoji = emoji
                    self?.updateCreateButtonState()
                    self?.tableView.reloadData()
                }
                
                cell.configure(with: emoji)
                return cell
            }
        } else if indexPath.section == 3 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCollectionTableViewCell", for: indexPath) as? ColorCollectionTableViewCell {
                cell.onColorSelected = { [weak self] colorName in
                    self?.colorName = colorName
                    self?.updateCreateButtonState()
                    self?.tableView.reloadData()
                }
                
                cell.configure(with: colorName)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    // MARK: - Private Methods For Setting Up Cells
    private func habitNameFieldCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "HabitNameTextFieldCell")
        
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.clipsToBounds = true
        backgroundView.backgroundColor = Colors.inputBackground
        backgroundView.layer.cornerRadius = 16
        
        cell.contentView.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(
                equalTo: cell.contentView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(
                equalTo: cell.contentView.trailingAnchor),
            backgroundView.topAnchor.constraint(
                equalTo: cell.contentView.topAnchor),
            backgroundView.bottomAnchor.constraint(
                equalTo: cell.contentView.bottomAnchor),
        ])
        
        let habitNameField = UITextField()
        habitNameField.translatesAutoresizingMaskIntoConstraints = false
        habitNameField.clipsToBounds = true
        habitNameField.placeholder = L10n.enterTrackerName
        habitNameField.font = .systemFont(ofSize: 17)
        habitNameField.textColor = Colors.black
        habitNameField.backgroundColor = .clear
        habitNameField.layer.borderWidth = 0
        habitNameField.delegate = self
        
        habitNameField.text = trackerName
        
        let paddingView = UIView(
            frame: CGRect(
                x: 0, y: 0, width: 16, height: habitNameField.frame.height))
        habitNameField.leftView = paddingView
        habitNameField.rightView = paddingView
        habitNameField.leftViewMode = .always
        habitNameField.rightViewMode = .always
        cell.contentView.addSubview(habitNameField)
        
        NSLayoutConstraint.activate([
            habitNameField.leadingAnchor.constraint(
                equalTo: cell.contentView.leadingAnchor),
            habitNameField.trailingAnchor.constraint(
                equalTo: cell.contentView.trailingAnchor),
            habitNameField.topAnchor.constraint(
                equalTo: cell.contentView.topAnchor),
            habitNameField.bottomAnchor.constraint(
                equalTo: cell.contentView.bottomAnchor),
            habitNameField.heightAnchor.constraint(equalToConstant: 75),
        ])
        
        return cell
    }
    
    private func charactersLimitWarningCell() -> UITableViewCell {
        let cell = UITableViewCell(
            style: .default, reuseIdentifier: "warningCell")
        
        cell.contentView.addSubview(habitNameLimitWarning)
        NSLayoutConstraint.activate([
            habitNameLimitWarning.heightAnchor.constraint(equalToConstant: 30),
            habitNameLimitWarning.centerXAnchor.constraint(
                equalTo: cell.centerXAnchor),
        ])
        cell.selectionStyle = .none
        
        return cell
    }
    
    private func categoryScheduleCells(_ indexPath: IndexPath)
    -> UITableViewCell
    {
        let cell = UITableViewCell(
            style: .subtitle, reuseIdentifier: "ButtonCell")
        
        if indexPath.row == 0 {
            let backgroundView = UIView()
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.clipsToBounds = true
            backgroundView.backgroundColor = Colors.inputBackground
            backgroundView.layer.cornerRadius = 16
            
            cell.contentView.addSubview(backgroundView)
            
            NSLayoutConstraint.activate([
                backgroundView.topAnchor.constraint(
                    equalTo: cell.contentView.topAnchor),
                backgroundView.leadingAnchor.constraint(
                    equalTo: cell.leadingAnchor),
                backgroundView.trailingAnchor.constraint(
                    equalTo: cell.trailingAnchor),
            ])
            
            if showScheduleOption {
                NSLayoutConstraint.activate([
                    backgroundView.heightAnchor.constraint(equalToConstant: 150),
                ])
                
                let separatorLineView = UIView()
                separatorLineView.translatesAutoresizingMaskIntoConstraints = false
                separatorLineView.clipsToBounds = true
                separatorLineView.backgroundColor = Colors.gray
                
                cell.contentView.addSubview(separatorLineView)
                
                NSLayoutConstraint.activate([
                    separatorLineView.heightAnchor.constraint(equalToConstant: 0.5),
                    separatorLineView.topAnchor.constraint(
                        equalTo: cell.contentView.topAnchor, constant: 75),
                    separatorLineView.leadingAnchor.constraint(
                        equalTo: cell.leadingAnchor, constant: 16),
                    separatorLineView.trailingAnchor.constraint(
                        equalTo: cell.trailingAnchor, constant: -16),
                ])
            } else {
                NSLayoutConstraint.activate([
                    backgroundView.heightAnchor.constraint(equalToConstant: 75),
                ])
            }
        }
        
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = Colors.black
        
        if indexPath.row == 0 {
            cell.textLabel?.text = L10n.category
            
            if selectedCategory != nil {
                cell.detailTextLabel?.text = selectedCategory?.name
                cell.detailTextLabel?.font = .systemFont(ofSize: 17)
                cell.detailTextLabel?.textColor = .gray
            }
        }
        
        if indexPath.row == 1 {
            cell.textLabel?.text = L10n.scheduleTitle
            
            if selectedWeekdays != nil {
                cell.detailTextLabel?.text = selectedReadableWeekdays()
                cell.detailTextLabel?.font = .systemFont(ofSize: 17)
                cell.detailTextLabel?.textColor = .gray
            }
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear
        cell.layoutMargins = UIEdgeInsets(
            top: 0, left: 16, bottom: 0, right: 16)
        
        return cell
    }
    
//    private func colorCollectionCell() -> UITableViewCell {
//        let cell = UITableViewCell(
//            style: .default, reuseIdentifier: "colorCell")
//        
//        return cell
//    }
}
