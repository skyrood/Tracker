//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/02/18.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    var onCompleteButtonTapped: (() -> Void)?
    
    private var tracker: Tracker?
    
    let titleView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        
        return view
    }()
    
    let emojiBackgroundView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        
        return view
    }()
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.text = "🤮"
        
        return label
    }()
    
    var title: String? {
        get {
            titleLabel.text
        }
        set {
            guard let newValue = newValue else {
                return
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: titleLabel.font ?? .systemFont(ofSize: 12),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            titleLabel.attributedText = NSAttributedString(string: newValue, attributes: attributes)
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.baselineAdjustment = .alignBaselines
        
        return label
    }()
    
    let daysCountLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        
        return label
    }()
    
    var completeTrackerButtonColor: UIColor? {
        get { completeTrackerButton.backgroundColor }
        set {
            completeTrackerButton.backgroundColor = newValue
        }
    }
    
    let completeTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 17
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = .zero
        button.tintColor = .white
        
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleView)
        contentView.addSubview(emojiBackgroundView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(completeTrackerButton)
        contentView.addSubview(daysCountLabel)
        
        NSLayoutConstraint.activate([
            titleView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 90),
            titleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 12),
            emojiBackgroundView.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 12),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -12),
            
            completeTrackerButton.widthAnchor.constraint(equalToConstant: 34),
            completeTrackerButton.heightAnchor.constraint(equalToConstant: 34),
            completeTrackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeTrackerButton.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.trailingAnchor.constraint(equalTo: completeTrackerButton.leadingAnchor, constant: -8),
            daysCountLabel.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 16),
            daysCountLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        tracker = nil
//        titleLabel.text = nil
//        emojiLabel.text = nil
//        titleView.backgroundColor = nil
//        completeTrackerButton.setImage(nil, for: .normal)
//        completeTrackerButton.isEnabled = false
//    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureButton(for tracker: Tracker, selectedDate: Date, completedTrackers: Set<TrackerRecord>) {
        let isCompleted = completedTrackers.contains{
            $0.trackerId == tracker.id &&
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }

        titleView.backgroundColor = tracker.color
        
        completeTrackerButtonColor = isCompleted ? tracker.color.withAlphaComponent(0.3) : tracker.color.withAlphaComponent(1.0)
        let image = isCompleted ?
                    UIImage(systemName: "checkmark")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)) :
                    UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        
        completeTrackerButton.setImage(image, for: .normal)
        
        if Calendar.current.isDateInToday(selectedDate) || selectedDate < Date() {
            completeTrackerButton.isEnabled = true
        } else {
            completeTrackerButton.isEnabled = false
        }
    }
    
    @objc private func didTapCompleteTrackerButton(_ sender: UIButton) {
        onCompleteButtonTapped?()
    }
}
