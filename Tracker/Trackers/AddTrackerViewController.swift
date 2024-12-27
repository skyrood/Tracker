//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/04.
//

import UIKit

final class AddTrackerViewController: UIViewController {
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor(named: "Black")
        return label
    }()
    
    private lazy var habitButton: UIButton = {
        let button = createButton(title: "Привычка")
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = createButton(title: "Нерегулярное событие")
        button.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "White")
        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(eventButton)
        
        setConstraints(for: titleLabel)
        setConstraints(for: habitButton)
        setTopConstraint(for: habitButton, relativeTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height * 0.435)
        setConstraints(for: eventButton)
        setTopConstraint(for: eventButton, relativeTo: habitButton.bottomAnchor, constant: 16)
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.setTitle(title, for: .normal)
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
    
    @objc private func habitButtonTapped() {
        print("Habit button tapped")
        let newHabitViewController = UINavigationController(rootViewController:         NewHabitViewController())
        newHabitViewController.modalPresentationStyle = .pageSheet
        newHabitViewController.view.layer.cornerRadius = 10
        present(newHabitViewController, animated: true, completion: nil)
    }
    
    @objc private func eventButtonTapped() {
        print("Event button tapped")
    }
}
