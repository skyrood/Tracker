//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/25.
//

import UIKit

final class CategoryListViewController: UIViewController {
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    
    var categoryList: [String] = [] {
        didSet {
            categoryListTableView.reloadData()
            updateCategoryListTableViewHeight()
        }
    }
    
    var selectedCategory: String?
    
    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - Private Properties
    private lazy var label: UILabel = UILabel()
    
    private lazy var logoImage: UIImageView = UIImageView()
    
    private lazy var messageLabel: UILabel = UILabel()
    
    private lazy var createNewCategoryButton: UIButton = UIButton()
    
    private lazy var addCategoryButton: UIButton = UIButton()
        
    private lazy var categoryListTableView: UITableView = UITableView()
    
    private var cellHeight = 75.0
    
    private var categoryListTableViewHeight: NSLayoutConstraint?
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White")
        navigationItem.hidesBackButton = true
        
        setupCategoryListLabel()
        setupCategoryButton(for: createNewCategoryButton,
                            buttonText: "Добавить категорию",
                            using: #selector(createNewCategoryButtonTapped))
        setupCategoryButton(for: addCategoryButton,
                            buttonText: "Готово",
                            using: #selector(addCategoryButtonTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if categoryList.isEmpty {
            setupLogo()
            setupMessageLabel()
        } else {
            setupCategoryListView()
            updateCategoryListTableViewHeight()
        }
        
        toggleButtonsVisibility()
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func setupCategoryListLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(named: "Black")
        label.text = "Категория"
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
        ])
    }
    
    private func setupLogo() {
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        logoImage.clipsToBounds = true
        logoImage.image = UIImage(named: "TrackersEmpty")
        
        view.addSubview(logoImage)
        
        NSLayoutConstraint.activate([
            logoImage.heightAnchor.constraint(equalToConstant: 80),
            logoImage.widthAnchor.constraint(equalToConstant: 80),
            logoImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -view.frame.height * 0.07),
        ])
    }
    
    private func setupMessageLabel() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.clipsToBounds = true
        messageLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        messageLabel.textColor = UIColor(named: "Black")
        messageLabel.numberOfLines = 2
        
        let attributedString = NSMutableAttributedString(string: "Привычки и события можно объединить по смыслу")

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center

        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )
        
        messageLabel.attributedText = attributedString
        
        view.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 1),
            messageLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            messageLabel.widthAnchor.constraint(equalToConstant: 230),
            messageLabel.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func setupCategoryListView() {
        categoryListTableView.translatesAutoresizingMaskIntoConstraints = false
        categoryListTableView.clipsToBounds = true
        categoryListTableView.backgroundColor = UIColor(named: "InputBackground")
        categoryListTableView.layer.cornerRadius = 16
        categoryListTableView.separatorStyle = .none
        categoryListTableView.delegate = self
        categoryListTableView.dataSource = self
        categoryListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryListTableViewCell")
        
        view.addSubview(categoryListTableView)
                        
        NSLayoutConstraint.activate([
            categoryListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryListTableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
        ])
        
        categoryListTableViewHeight = categoryListTableView.heightAnchor.constraint(equalToConstant: 0)
        categoryListTableViewHeight?.isActive = true
    }
    
    private func setupCategoryButton(for button: UIButton, buttonText: String, using action: Selector) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.setTitle(buttonText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "Black")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: action, for: .touchUpInside)
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func updateCategoryListTableViewHeight() {
        let tableViewHeight: CGFloat = cellHeight * CGFloat(categoryList.count)
        categoryListTableViewHeight?.constant = tableViewHeight
        view.layoutIfNeeded()
    }
    
    private func toggleButtonsVisibility() {
        if selectedCategory == nil {
            createNewCategoryButton.isHidden = false
            addCategoryButton.isHidden = true
        } else {
            createNewCategoryButton.isHidden = true
            addCategoryButton.isHidden = false
        }
    }
    
    @objc private func createNewCategoryButtonTapped() {
        let createNewCategoryViewController = CreateNewCategoryViewController()
        
        createNewCategoryViewController.onCategoryCreated = { [ weak self ] categoryName in
            self?.categoryList.append(categoryName)
            self?.selectedCategory = categoryName
            self?.categoryListTableView.reloadData()
            self?.toggleButtonsVisibility()
        }
        
        createNewCategoryViewController.modalPresentationStyle = .pageSheet
        createNewCategoryViewController.view.layer.cornerRadius = 10
        present(createNewCategoryViewController, animated: true, completion: nil)
    }
    
    @objc private func addCategoryButtonTapped() {
        guard let selectedCategoryName = selectedCategory else { return }
        
        onCategorySelected?(selectedCategoryName)
        dismiss(animated: true)
    }
}

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategoryName = categoryList[indexPath.row]
        
        if selectedCategory == selectedCategoryName {
            selectedCategory = nil
        } else {
            selectedCategory = selectedCategoryName
        }
        
        toggleButtonsVisibility()
        
        categoryListTableView.reloadData()
    }
}

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryListTableView.dequeueReusableCell(withIdentifier: "CategoryListTableViewCell", for: indexPath)
        cell.textLabel?.text = categoryList[indexPath.row]
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.contentView.subviews.forEach { subview in
            if subview.tag == 999 {
                subview.removeFromSuperview()
            }
        }

        if indexPath.row < categoryList.count - 1 {
            let separatorLineView = UIView()
            separatorLineView.translatesAutoresizingMaskIntoConstraints = false
            separatorLineView.clipsToBounds = true
            separatorLineView.backgroundColor = UIColor(named: "Gray")
            separatorLineView.tag = 999

            cell.contentView.addSubview(separatorLineView)
            
            NSLayoutConstraint.activate([
                separatorLineView.heightAnchor.constraint(equalToConstant: 0.5),
                separatorLineView.topAnchor.constraint(
                    equalTo: cell.contentView.topAnchor, constant: cellHeight - 0.5),
                separatorLineView.leadingAnchor.constraint(
                    equalTo: cell.leadingAnchor, constant: 16),
                separatorLineView.trailingAnchor.constraint(
                    equalTo: cell.trailingAnchor, constant: -16),
            ])
        }
        
        if categoryList[indexPath.row] == selectedCategory {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
