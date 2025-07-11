//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/04.
//

import UIKit

final class NewTrackerViewController: UIViewController {
   
    // MARK: - Public Properties
  
    var passHabitToTrackersList: ((Tracker, TrackerCategory) -> Void)?
    
    // MARK: - Private Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "Black")
        return label
    }()
    
    private lazy var habitButton: UIButton = {
        let button = createButton(title: "Привычка")
        button.addTarget(self, action: #selector(habitButtonTappedWrapper), for: .touchUpInside)
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = createButton(title: "Нерегулярное событие")
        button.addTarget(self, action: #selector(eventButtonTappedWrapper), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "White")
        navigationItem.hidesBackButton = true

        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(eventButton)
        
        setConstraints(for: titleLabel)
        setConstraints(for: habitButton)
        setTopConstraint(for: habitButton, relativeTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height * 0.435)
        setConstraints(for: eventButton)
        setTopConstraint(for: eventButton, relativeTo: habitButton.bottomAnchor, constant: 16)
    }
    
    // MARK: - Private Methods
    private func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "Black")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }
    
    private func setConstraints(for label: UILabel) {
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
        ])
    }
    
    private func setConstraints(for button: UIButton) {
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func setTopConstraint(for button: UIButton, relativeTo viewAnchor: NSLayoutYAxisAnchor, constant: CGFloat) {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: viewAnchor, constant: constant)
        ])
    }
    
    @objc private func newTrackerButtonTapped(showScheduleOption: Bool) {
        let createTrackerViewController = CreateTrackerViewController(showScheduleOption: showScheduleOption)
        
        createTrackerViewController.onHabitCreated = { [weak self] newTracker, category in
            self?.passHabitToTrackersList?(newTracker, category)
            self?.dismiss(animated: true)
        }
        createTrackerViewController.modalPresentationStyle = .pageSheet
        createTrackerViewController.view.layer.cornerRadius = 10
        present(createTrackerViewController, animated: true, completion: nil)
    }
    
    @objc private func habitButtonTappedWrapper() {
        newTrackerButtonTapped(showScheduleOption: true)
    }

    @objc private func eventButtonTappedWrapper() {
        newTrackerButtonTapped(showScheduleOption: false)
    }
}
