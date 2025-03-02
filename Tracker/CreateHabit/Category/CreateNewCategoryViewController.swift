//
//  CreateNewCategoryViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/02/08.
//

import UIKit

final class CreateNewCategoryViewController: UIViewController {
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    var categoryName: String = ""
    
    var onCategoryCreated: ((String) -> Void)?
    
    // MARK: - Private Properties
    private var label: UILabel = UILabel()
    
    private var categoryNameTextField: UITextField = UITextField()
    
    private var createCategorybutton: UIButton = UIButton(type: .system)
    
    private lazy var categoryNameFieldWarningMessage: UILabel = {
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
        navigationItem.hidesBackButton = true
        
        setupCreateCategoryLabel()
        setupCategoryNameTextField()
        setupCategoryNameFieldWarningMessage()
        setupCreateCagegoryButton()
        
        toggleWarningMessage()
        
        createCategorybutton.isEnabled = false
        createCategorybutton.alpha = 0.3
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func setupCreateCategoryLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(named: "Black")
        label.text = "Новая категория"
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
        ])
    }
    
    private func setupCategoryNameTextField() {
        categoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryNameTextField.clipsToBounds = true
        categoryNameTextField.placeholder = "Введите название категории"
        categoryNameTextField.font = .systemFont(ofSize: 17)
        categoryNameTextField.textColor = UIColor(named: "Black")
        categoryNameTextField.backgroundColor = UIColor(named: "InputBackground")
        categoryNameTextField.layer.cornerRadius = 16
        categoryNameTextField.layer.borderWidth = 0
        categoryNameTextField.delegate = self
        
        categoryNameTextField.addTarget(self, action: #selector(categoryNameTextFieldDidChange), for: .editingChanged)
        
        let paddingView = UIView(
            frame: CGRect(
                x: 0, y: 0, width: 16, height: categoryNameTextField.frame.height))
        categoryNameTextField.leftView = paddingView
        categoryNameTextField.rightView = paddingView
        categoryNameTextField.leftViewMode = .always
        categoryNameTextField.rightViewMode = .always
        
        view.addSubview(categoryNameTextField)
        
        NSLayoutConstraint.activate([
            categoryNameTextField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
        ])
    }
    
    private func setupCategoryNameFieldWarningMessage() {
        view.addSubview(categoryNameFieldWarningMessage)
        
        NSLayoutConstraint.activate([
            categoryNameFieldWarningMessage.topAnchor.constraint(equalTo: categoryNameTextField.bottomAnchor, constant: 8),
            categoryNameFieldWarningMessage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryNameFieldWarningMessage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryNameFieldWarningMessage.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupCreateCagegoryButton() {
        createCategorybutton.translatesAutoresizingMaskIntoConstraints = false
        createCategorybutton.setTitle("Готово", for: .normal)
        createCategorybutton.setTitleColor(.white, for: .normal)
        createCategorybutton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createCategorybutton.backgroundColor = .black
        createCategorybutton.layer.cornerRadius = 16
        createCategorybutton.addTarget(self, action: #selector(createCategoryButtonTapped), for: .touchUpInside)
        
        view.addSubview(createCategorybutton)
        
        NSLayoutConstraint.activate([
            createCategorybutton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategorybutton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            createCategorybutton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            createCategorybutton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func createCategoryButtonTapped() {
        guard let categoryName = categoryNameTextField.text, !categoryName.isEmpty else { return }
        
        onCategoryCreated?(categoryName)
        dismiss(animated: true)
    }
    
    @objc private func categoryNameTextFieldDidChange() {
        let hasText = !(categoryNameTextField.text?.isEmpty ?? true)
        createCategorybutton.isEnabled = hasText
        createCategorybutton.alpha = hasText ? 1 : 0.3
    }
    
    private func toggleWarningMessage() {
        categoryNameFieldWarningMessage.isHidden = !shouldShowWarningCell
    }
}

extension CreateNewCategoryViewController: UITextFieldDelegate {
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
        
        if updatedText.count <= 38 {
            categoryName = updatedText
            
            if shouldShowWarningCell {
                shouldShowWarningCell = false
                toggleWarningMessage()
            }
            
            return true
        } else {
            if !shouldShowWarningCell {
                shouldShowWarningCell = true
                toggleWarningMessage()
            }
            
            return false
        }
    }
}

