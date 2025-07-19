//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/02/18.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {

    // MARK: - Public Properties
    var onCompleteButtonTapped: (() -> Void)?
    
    var onEditButtonTapped: ((Tracker) -> Void)?
    
    let daysCountLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = Colors.black
        
        return label
    }()
    
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
    
    // MARK: - Private Properties
    private var tracker: Tracker?
    
    private let titleView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        
        return view
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.text = "🤮"
        
        return label
    }()
    
    private var title: String? {
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.baselineAdjustment = .alignBaselines
        
        return label
    }()
    
    private var completeTrackerButtonColor: UIColor? {
        get { completeTrackerButton.backgroundColor }
        set {
            completeTrackerButton.backgroundColor = newValue
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleView)
        
        titleView.addSubview(emojiBackgroundView)
        titleView.addSubview(emojiLabel)
        titleView.addSubview(titleLabel)
        
        contentView.addSubview(completeTrackerButton)
        contentView.addSubview(daysCountLabel)
        
        completeTrackerButton.addTarget(self, action: #selector(didTapCompleteTrackerButton(_:)), for: .touchUpInside)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        titleView.addInteraction(interaction)
        
        NSLayoutConstraint.activate([
            titleView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 90),
            titleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func configure(for tracker: Tracker, with daysCompleted: Int, for selectedDate: Date) {
        self.tracker = tracker
        title = tracker.name
        emojiLabel.text = tracker.emoji
        daysCountLabel.text = L10n.daysCompleted(daysCompleted)
    }
    
    func configureButton(for tracker: Tracker, selectedDate: Date, completedTrackers: Set<TrackerRecord>) {
        let isCompleted = completedTrackers.contains{
            $0.trackerId == tracker.id &&
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }

        let trackerColor = Colors.selection[tracker.colorName]
        
        titleView.backgroundColor = trackerColor
        
        completeTrackerButtonColor = isCompleted ? trackerColor?.withAlphaComponent(0.3) : trackerColor?.withAlphaComponent(1.0)
        let image = isCompleted ?
                    UIImage(systemName: "checkmark")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)) :
        UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))
        
        completeTrackerButton.setImage(image, for: .normal)
        
        if Calendar.current.isDateInToday(selectedDate) || selectedDate < Date() {
            completeTrackerButton.isEnabled = true
        } else {
            completeTrackerButton.isEnabled = false
        }
    }
    
    // MARK: - Private Methods
    private func completedDaysCount(for tracker: Tracker, completedTrackers: [TrackerRecord]) -> Int {
        return completedTrackers.filter{ $0.trackerId == tracker.id }.count
    }
    
    @objc private func didTapCompleteTrackerButton(_ sender: UIButton) {
        onCompleteButtonTapped?()
    }
}

// MARK: - extension UIContextMenuInteractionDelegate
extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Edit", image: nil) { [ weak self ] _ in
                guard let tracker = self?.tracker else { return }
                self?.onEditButtonTapped?(tracker)
            }
            
            let deleteAction = UIAction(title: "Delete", image: nil) { _ in
                print("Удалить трекер: ")
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}
