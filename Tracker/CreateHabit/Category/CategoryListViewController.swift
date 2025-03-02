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
    
    // MARK: - Private Properties
    private lazy var label: UILabel = UILabel()
    
    private lazy var logoImage: UIImageView = UIImageView()
    
    private lazy var messageLabel: UILabel = UILabel()
    
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
        setupAddCategoryButton()
        
        if categoryList.isEmpty {
            setupLogo()
            setupMessageLabel()
        } else {
            setupCategoryListView()
            updateCategoryListTableViewHeight()
        }
    }
    
    // MARK: - IB Actions
    @objc private func addCategoryButtonTapped() {
        let createCategoryViewController = CreateCategoryViewController()
        
//        createCategoryViewController.onNewCategoryAdded = { [ weak self ] newCategory in
//            self?.categoryList.append(newCategory)
//            self?.categoryListView.reloadData()
//        }
        
        createCategoryViewController.modalPresentationStyle = .pageSheet
        createCategoryViewController.view.layer.cornerRadius = 10
        present(createCategoryViewController, animated: true, completion: nil)
    }
    
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
    
    private func setupAddCategoryButton() {
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.clipsToBounds = true
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.backgroundColor = UIColor(named: "Black")
        addCategoryButton.setTitleColor(.white, for: .normal)
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.addTarget(self, action: #selector (addCategoryButtonTapped), for: .touchUpInside)
        
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func updateCategoryListTableViewHeight() {
        let tableViewHeight: CGFloat = cellHeight * CGFloat(categoryList.count)
        categoryListTableViewHeight?.constant = tableViewHeight
        view.layoutIfNeeded()
    }
}

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
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

        if indexPath.row < categoryList.count - 1 {
            let separatorLineView = UIView()
            separatorLineView.translatesAutoresizingMaskIntoConstraints = false
            separatorLineView.clipsToBounds = true
            separatorLineView.backgroundColor = UIColor(named: "Gray")

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
        
        return cell
    }
}
