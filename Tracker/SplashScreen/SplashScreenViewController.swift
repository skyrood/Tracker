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
        
    // MARK: - Overrides Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        self.view.backgroundColor = Colors.blue
        
        self.view.addSubview(logoImageView)
        setConstraints(for: logoImageView)
        
        if UserDefaults.standard.bool(forKey: "onboardingScreenShown") {
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
    }
    
    private func navigateToOnboardingScreen() {
        let onboardingScreenViewController = OnboardingScreenViewController()
        onboardingScreenViewController.modalPresentationStyle = .fullScreen
        present(onboardingScreenViewController, animated: true)
    }
}
