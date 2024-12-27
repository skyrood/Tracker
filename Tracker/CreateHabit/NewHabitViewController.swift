//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/25.
//

import UIKit

final class NewHabitViewController: UIViewController {
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private var trackerName: String = "" {
        didSet {
            print("Tracker name updated to \(trackerName)")
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        tableView.backgroundColor = UIColor(named: "White")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor(named: "Black")
        return label
    }()
    
    private lazy var habitNameField: UITextField = {
        let inputField = UITextField()
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.clipsToBounds = true
        inputField.placeholder = "Введите название трекера"
        inputField.font = .systemFont(ofSize: 17)
        inputField.textColor = UIColor(named: "Black")
        inputField.backgroundColor = UIColor(named: "InputBackground")
        //        inputField.layer.cornerRadius = 16
        inputField.layer.borderWidth = 0
        inputField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: inputField.frame.height))
        inputField.leftView = paddingView
        inputField.leftViewMode = .always
        
        return inputField
    }()
    
    private lazy var habitNameLimitWarning: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor(named: "Red")
        return label
    }()
    
    private var shouldShowWarningCell = false
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)

        setConstraints(for: titleLabel, topConstraint: 26)
        setConstraints(for: tableView)
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func setConstraints(for titleLabel: UILabel, topConstraint: CGFloat) {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: topConstraint),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setConstraints(for tableView: UITableView) {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setConstraints(for inputField: UITextField, in cell: UITableViewCell) {
        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            inputField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            inputField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            inputField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            inputField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
}

// MARK: - UITextFieldDelegate
extension NewHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count <= 38 {
            trackerName = updatedText

            if shouldShowWarningCell {
                shouldShowWarningCell = false
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
                }
            }
            
            return true
        } else {
            if !shouldShowWarningCell {
                shouldShowWarningCell = true
                tableView.performBatchUpdates {
                    tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
                }
            }
            
            return false
        }
    }
}

// MARK: - UITableViewDelegate
extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 75
            } else if indexPath.row == 1 {
                return 30
            }
        } else if indexPath.section == 1 {
            return 75
        } else if indexPath.section == 2 {
            return 150
        } else if indexPath.section == 3 {
            return 150
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let categoryViewController = CategoryViewController()
                navigationController?.pushViewController(categoryViewController, animated: true)
            } else if indexPath.row == 1 {
                let ScheduleViewController = ScheduleViewController()
                navigationController?.pushViewController(ScheduleViewController, animated: true)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NewHabitViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return shouldShowWarningCell ? 2 : 1
        case 1:
            return 2
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                
                cell.contentView.addSubview(habitNameField)
                setConstraints(for: habitNameField, in: cell)

                return cell
            } else if indexPath.row == 1 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "warningCell")
                cell.contentView.addSubview(habitNameLimitWarning)
                NSLayoutConstraint.activate([
                    habitNameLimitWarning.heightAnchor.constraint(equalToConstant: 30),
                    habitNameLimitWarning.centerXAnchor.constraint(equalTo: cell.centerXAnchor)
                ])
                cell.selectionStyle = .none
                
                return cell
            }
            
        } else if indexPath.section == 1 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "ButtonCell")
            
            cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = UIColor(named: "Black")
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = UIColor(named: "InputBackground")
            cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            
            return cell
        } else if indexPath.section == 2 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "emojiCell")
            cell.textLabel?.text = "Emoji grid placeholder"
            return cell
        } else if indexPath.section == 3 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "colorCell")
            cell.textLabel?.text = "Color grid placeholder"
            return cell
        }
        
        return UITableViewCell()
    }
}
