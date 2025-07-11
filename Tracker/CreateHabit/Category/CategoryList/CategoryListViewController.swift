//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/25.
//

import UIKit

final class CategoryListViewController: UIViewController {
    
    // MARK: - Public Properties
    var selectedCategory: TrackerCategory?
    
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    // MARK: - Private Properties
    private var viewModel: CategoryListViewModel?
    
    private lazy var label: UILabel = UILabel()
    
    private lazy var createNewCategoryButton: UIButton = UIButton()
    
    private lazy var addCategoryButton: UIButton = UIButton()
    
    private lazy var categoryListTableView: UITableView = UITableView()
    
    private var emptyStateView: EmptyStateView?
    
    private var cellHeight = 75.0
    
    private var categoryListTableViewHeight: NSLayoutConstraint?
    
    private let emptyStateImage: UIImage? = UIImage(named: "TrackersEmpty")
    private let emptyStateMessage: String = "Привычки и события можно объединить по смыслу"
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
                
        viewModel = CategoryListViewModel()

        view.backgroundColor = UIColor(named: "White")
        navigationItem.hidesBackButton = true
        
        setupCategoryListLabel()
        setupCategoryButton(for: createNewCategoryButton,
                            buttonText: "Добавить категорию",
                            using: #selector(createNewCategoryButtonTapped))
        setupCategoryButton(for: addCategoryButton,
                            buttonText: "Готово",
                            using: #selector(addCategoryButtonTapped))

        guard let viewModel else { return }
        
        viewModel.categoryListBinding = { [weak self] categories in
            guard let self else { return }

            if categories.isEmpty {
                self.categoryListTableView.removeFromSuperview()
                if self.emptyStateView == nil {
                    self.setupEmptyStateView()
                }
            } else {
                self.emptyStateView?.removeFromSuperview()
                if self.categoryListTableView.superview == nil {
                    self.setupCategoryListView()
                }
                self.categoryListTableView.reloadData()
                updateCategoryListTableViewHeight()
            }
        }
        
        viewModel.categoryListBinding?(viewModel.categories)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toggleButtonsVisibility()
    }
    
    // MARK: - Private Methods
    private func setupCategoryListLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "Black")
        label.text = "Категория"
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
        ])
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
    
    private func setupCategoryListView() {
        categoryListTableView.translatesAutoresizingMaskIntoConstraints = false
        categoryListTableView.clipsToBounds = true
        categoryListTableView.backgroundColor = UIColor(named: "InputBackground")
        categoryListTableView.layer.cornerRadius = 16
        categoryListTableView.separatorStyle = .none
        categoryListTableView.delegate = self
        categoryListTableView.dataSource = self
        categoryListTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        
        view.addSubview(categoryListTableView)
        
        NSLayoutConstraint.activate([
            categoryListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryListTableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
        ])
        
        categoryListTableViewHeight = categoryListTableView.heightAnchor.constraint(equalToConstant: 0)
        categoryListTableViewHeight?.isActive = true
        
        updateCategoryListTableViewHeight()
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
        guard let viewModel = viewModel else { return }
        
        let fullHeight: CGFloat = cellHeight * CGFloat(viewModel.categories.count)
        let maxHeight: CGFloat = addCategoryButton.frame.minY - categoryListTableView.frame.minY - 16
        let finalHeight: CGFloat = min(fullHeight, maxHeight)
        categoryListTableViewHeight?.constant = finalHeight
        
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
        
        createNewCategoryViewController.onCategoryCreated = { [ weak self ] category in
            guard let self else { return }
            self.viewModel?.addCategory(category)
            self.selectedCategory = category
            self.toggleButtonsVisibility()
            self.categoryListTableView.reloadData()
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

// MARK: - extension UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        
        viewModel.selectCategory(at: indexPath.row)
        selectedCategory = viewModel.selectedCategory
        
        toggleButtonsVisibility()
        categoryListTableView.reloadData()
    }
}

// MARK: - extension UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel else { return 0 }
        
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = categoryListTableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier, for: indexPath) as? CategoryTableViewCell,
            let viewModel
        else {
            return UITableViewCell()
        }
        
        cell.configure(with: viewModel.categories[indexPath.item])
        
        cell.contentView.subviews.forEach { subview in
            if subview.tag == 999 {
                subview.removeFromSuperview()
            }
        }
        
        if indexPath.row < viewModel.categories.count - 1 {
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
        
        if viewModel.categories[indexPath.row].categoryName == selectedCategory?.name {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

