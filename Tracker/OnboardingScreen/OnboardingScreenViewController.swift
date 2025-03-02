//
//  OnboardingScreenViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/04.
//

import UIKit

final class OnboardingScreenViewController: UIPageViewController, UIPageViewControllerDelegate {
    
    // MARK: - Private Properties
    private lazy var pages: [UIViewController] = {
        return [
            OnboardingBlueViewController(),
            OnboardingRedViewController()
        ]
    }()
    
    private lazy var onboardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "Black")
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor(named: "White"), for: .normal)
        button.addTarget(self, action: #selector(onboardButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Initializers
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        self.view.addSubview(onboardButton)
        
        setConstraints(for: onboardButton)
    }
    
    // MARK: - Private Methods
    private func setConstraints(for imageView: UIImageView) {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        guard let imageHeight = imageView.image?.size.height else { return }
        if imageHeight < view.frame.height {
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
    }
    
    private func setConstraints(for label: UILabel) {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(view.bounds.height * 0.3525))
        ])
    }
    
    private func setConstraints(for button: UIButton) {
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
        ])
    }
    
    @objc private func onboardButtonTapped() {
        print("Onboarding screen shown. Never showing it again...") // TODO: save shown status to userdefaults?
        navigateToTabBarView()
    }
    
    private func navigateToTabBarView() {
        let tabBarViewController = TabBarViewController()
        tabBarViewController.modalPresentationStyle = .fullScreen
        present(tabBarViewController, animated: true, completion: nil)
    }
}

// MARK: - extension UIPageViewControllerDataSource
extension OnboardingScreenViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < (pages.count - 1) else {
            return nil
        }
        return pages[currentIndex + 1]
    }
}
