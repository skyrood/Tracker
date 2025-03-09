//
//  SplashScreenViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/04.
//

import UIKit

final class SplashScreenViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.image = UIImage(named: "Logo")
        
        return view
    }()
    
    private var onboardingScreenShown: Bool = true
    
    // MARK: - Overrides Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.backgroundColor = UIColor(named: "Blue")
        
        self.view.addSubview(logoImageView)
        setConstraints(for: logoImageView)
        
        if onboardingScreenShown {
            navigateToTabBarController()
        } else {
            navigateToOnboardingScreen()
        }
    }
    
    // MARK: - Private Methods
    private func setConstraints(for view: UIView) {
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            view.widthAnchor.constraint(equalToConstant: 91)
        ])
    }
    
    private func navigateToTabBarController() {
        let tabViewBarController = TabBarViewController()
        tabViewBarController.modalPresentationStyle = .fullScreen
        present(tabViewBarController, animated: true, completion: nil)
        print("navigated to tab bar controller!")
    }
    
    private func navigateToOnboardingScreen() {
        let onboardingScreenViewController = OnboardingScreenViewController()
        onboardingScreenViewController.modalPresentationStyle = .fullScreen
        present(onboardingScreenViewController, animated: true)
        print("navigated to Onboarding screen controller!")
    }
}
