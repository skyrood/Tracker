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
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor(named: "White")
        tableView.separatorStyle = .none
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
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
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
            if indexPath.row == 0 || indexPath.row == 1 {
                return 75
            }
        } else if indexPath.section == 2 || indexPath.section == 3 {
            return 180
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        if section == 2 {
            let emojiLabel = UILabel()
            emojiLabel.textColor = UIColor(named: "Black")
            emojiLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            emojiLabel.text = "Emoji"
            
            headerView.addSubview(emojiLabel)
            
            NSLayoutConstraint.activate([
                emojiLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
                emojiLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 14),
            ])
        }
        
        if section == 3 {
            let emojiLabel = UILabel()
            emojiLabel.textColor = UIColor(named: "Black")
            emojiLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            emojiLabel.text = "Цвет"
            
            headerView.addSubview(emojiLabel)
            
            NSLayoutConstraint.activate([
                emojiLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
                emojiLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 14),
            ])
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 3 {
            return 50
        }
        
        return 0.01
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
                return habitNameFieldCell()
            } else if indexPath.row == 1 {
                return charactersLimitWarningCell()
            }
        } else if indexPath.section == 1 {
            return categoryScheduleCells(indexPath)
        } else if indexPath.section == 2 {
            return EmojiCollectionTableViewCell()
        } else if indexPath.section == 3 {
            return ColorCollectionTableViewCell()
        }
        
        return UITableViewCell()
    }
    
    // MARK: - Private Methods For Setting Up Cells
    private func habitNameFieldCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.clipsToBounds = true
        backgroundView.backgroundColor = UIColor(named: "InputBackground")
        backgroundView.layer.cornerRadius = 16
        
        cell.contentView.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
        ])
        
        let habitNameField = UITextField()
        habitNameField.translatesAutoresizingMaskIntoConstraints = false
        habitNameField.clipsToBounds = true
        habitNameField.placeholder = "Введите название трекера"
        habitNameField.font = .systemFont(ofSize: 17)
        habitNameField.textColor = UIColor(named: "Black")
        habitNameField.backgroundColor = .clear
        habitNameField.layer.borderWidth = 0
        habitNameField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: habitNameField.frame.height))
        habitNameField.leftView = paddingView
        habitNameField.rightView = paddingView
        habitNameField.leftViewMode = .always
        habitNameField.rightViewMode = .always
        cell.contentView.addSubview(habitNameField)
        
        NSLayoutConstraint.activate([
            habitNameField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            habitNameField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            habitNameField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            habitNameField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            habitNameField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        return cell
    }
    
    private func charactersLimitWarningCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "warningCell")
        
        cell.contentView.addSubview(habitNameLimitWarning)
        NSLayoutConstraint.activate([
            habitNameLimitWarning.heightAnchor.constraint(equalToConstant: 30),
            habitNameLimitWarning.centerXAnchor.constraint(equalTo: cell.centerXAnchor)
        ])
        cell.selectionStyle = .none
        
        return cell
    }
    
    private func categoryScheduleCells(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ButtonCell")

        if indexPath.row == 0 {
            let backgroundView = UIView()
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.clipsToBounds = true
            backgroundView.backgroundColor = UIColor(named: "InputBackground")
            backgroundView.layer.cornerRadius = 16
            
            cell.contentView.addSubview(backgroundView)
            
            NSLayoutConstraint.activate([
                backgroundView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                backgroundView.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
                backgroundView.heightAnchor.constraint(equalToConstant: 150.5)
            ])
            
            let separatorLineView = UIView()
            separatorLineView.translatesAutoresizingMaskIntoConstraints = false
            separatorLineView.clipsToBounds = true
            separatorLineView.backgroundColor = UIColor(named: "Gray")
            
            cell.contentView.addSubview(separatorLineView)
            
            NSLayoutConstraint.activate([
                separatorLineView.heightAnchor.constraint(equalToConstant: 0.5),
                separatorLineView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 75),
                separatorLineView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
                separatorLineView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16)
            ])
            
        }
        
        cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = UIColor(named: "Black")
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return cell
    }
    
    private func colorCollectionCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "colorCell")
        cell.textLabel?.text = "Color grid placeholder"
        return cell
    }
}
