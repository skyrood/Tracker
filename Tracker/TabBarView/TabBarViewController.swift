//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/04.
//

import UIKit

final class TabBarViewController: UITabBarController {

    // MARK: - Private Properties
    private lazy var borderLine: UIView = {
        let borderLine = UIView()
        borderLine.backgroundColor = Colors.shadow
        borderLine.translatesAutoresizingMaskIntoConstraints = false
        return borderLine
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersNavController = UINavigationController(rootViewController: TrackersViewController())
        let statisticsViewController = StatisticsViewController()
        
        trackersNavController.tabBarItem = UITabBarItem(title: L10n.trackersTitle, image: UIImage(named: "TrackersTabBarLogo"), tag: 0)
        statisticsViewController.tabBarItem = UITabBarItem(title: L10n.statisticsTab, image: UIImage(named: "StatisticsTabBarLogo"), tag: 0)
                
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.white
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        viewControllers = [trackersNavController, statisticsViewController]
        
        view.addSubview(borderLine)
        setConstraints(for: borderLine)
    }

    // MARK: - Private Methods
    private func setConstraints(for borderView: UIView) {
        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
