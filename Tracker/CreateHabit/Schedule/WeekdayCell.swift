//
//  WeekdayCell.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/03/02.
//

import UIKit

final class WeekdayCell: UITableViewCell {
    var toggleHandler: ((Weekday, Bool) -> Void)?
    
    let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = Colors.blue
        return toggle
    }()
    
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = Colors.black
        return label
    }()

    private var weekdayFlag: Weekday = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(weekdayLabel)
        contentView.addSubview(toggleSwitch)
        
        NSLayoutConstraint.activate([
            weekdayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            weekdayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        toggleSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with weekday: String, flag: Weekday, isSelected: Bool) {
        weekdayLabel.text = weekday
        weekdayFlag = flag
        toggleSwitch.isOn = isSelected
    }
    
    @objc private func switchToggled() {
        toggleHandler?(weekdayFlag, toggleSwitch.isOn)
    }
}
