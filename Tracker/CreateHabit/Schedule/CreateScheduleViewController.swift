//
//  CreatecreateScheduleViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/25.
//

import UIKit

final class CreatecreateScheduleViewController: UIViewController {

    // MARK: - Public Properties
    var onScheduleCreated: ((Weekday) -> Void)?
    
    var selectedWeekdays: Weekday = []
    
    // MARK: - Private Properties
    private var titleLabel: UILabel = UILabel()
    
    private var createScheduleButton: UIButton = UIButton(type: .system)
    
    private lazy var scheduleTableView: UITableView = UITableView()
    
    private var scheduleTableViewHeightConstraint: NSLayoutConstraint!

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTitleLabel()
        setupCreateScheduleButton()
        setupScheduleTableView()
    }

    // MARK: - Private Methods
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.clipsToBounds = true
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor(named: "Black")
        titleLabel.text = "Расписание"
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
        ])
    }
    
    private func setupCreateScheduleButton() {
        createScheduleButton.translatesAutoresizingMaskIntoConstraints = false
        createScheduleButton.setTitle("Готово", for: .normal)
        createScheduleButton.setTitleColor(.white, for: .normal)
        createScheduleButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createScheduleButton.backgroundColor = .black
        createScheduleButton.layer.cornerRadius = 16
        createScheduleButton.addTarget(self, action: #selector(createScheduleButtonTapped), for: .touchUpInside)
        
        view.addSubview(createScheduleButton)
        
        NSLayoutConstraint.activate([
            createScheduleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createScheduleButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            createScheduleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            createScheduleButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func setupScheduleTableView() {
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        scheduleTableView.clipsToBounds = true
        scheduleTableView.backgroundColor = UIColor(named: "InputBackground")
        scheduleTableView.layer.cornerRadius = 16
        scheduleTableView.separatorStyle = .none
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.register(WeekdayCell.self, forCellReuseIdentifier: "WeekdayCell")
        
        view.addSubview(scheduleTableView)
        
        NSLayoutConstraint.activate([
            scheduleTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scheduleTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            scheduleTableView.bottomAnchor.constraint(lessThanOrEqualTo: createScheduleButton.topAnchor, constant: -24)
        ])

        scheduleTableViewHeightConstraint = scheduleTableView.heightAnchor.constraint(equalToConstant: 525)
        scheduleTableViewHeightConstraint.isActive = true
    }
    
    private func toggleWeekday(_ weekday: Weekday, isOn: Bool) {
        if isOn {
            selectedWeekdays.insert(weekday)
        } else {
            selectedWeekdays.remove(weekday)
        }
    }
    
    private func updateScheduleTableViewHeight() {
        let contentHeight = scheduleTableView.contentSize.height
        let maxHeight: CGFloat = 525
        
        scheduleTableViewHeightConstraint.constant = min(contentHeight, maxHeight)
    }

    private func isWeekdaySelected(_ weekday: Weekday) -> Bool {
        selectedWeekdays.contains(weekday)
    }
    
    @objc private func createScheduleButtonTapped() {
        onScheduleCreated?(selectedWeekdays)
        dismiss(animated: true)
    }
}

// MARK: - extension UITableViewDelegate
extension CreatecreateScheduleViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - extension UITableViewDataSource
extension CreatecreateScheduleViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeekdayCell") as? WeekdayCell else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let weekdays = [
            ("Понедельник", Weekday.monday),
            ("Вторник", Weekday.tuesday),
            ("Среда", Weekday.wednesday),
            ("Четверг", Weekday.thursday),
            ("Пятница", Weekday.friday),
            ("Суббота", Weekday.saturday),
            ("Воскресенье", Weekday.sunday)
        ]
        
        let (dayName, flag) = weekdays[indexPath.row]
        let isSelected = isWeekdaySelected(flag)
                
        cell.configure(with: dayName, flag: flag, isSelected: isSelected)
        
        cell.toggleHandler = { [weak self] flag, isOn in
            self?.toggleWeekday(flag, isOn: isOn)
        }
        
        if indexPath.row < 6 {
            let separatorLineView = UIView()
            separatorLineView.translatesAutoresizingMaskIntoConstraints = false
            separatorLineView.clipsToBounds = true
            separatorLineView.backgroundColor = UIColor(named: "Gray")

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
        
        return cell
    }
}
