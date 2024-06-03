/// A control that contains a button that triggers a drop down table.
//
//  DropDownCell.swift
//
//
//  Created by Paolo Rossignoli on 19/10/23.
//

import UIKit

class DropDownCell: UICollectionViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    let numberChannelsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupViews() {
        self.alpha = 0
        contentView.addSubview(nameLabel)
        contentView.addSubview(numberChannelsLabel)
        
        // Constraints for nameLabel
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        // Constraints for numberChannelsLabel
        NSLayoutConstraint.activate([
            numberChannelsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            numberChannelsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? self.nameLabel.textColor.withAlphaComponent(0.15) : .clear
        }
    }

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? self.nameLabel.textColor.withAlphaComponent(0.15) : .clear
        }
    }
}

class DropDownHeaderView: UICollectionReusableView {
    
    let dropdownTitleView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        label.textColor = .white
        label.backgroundColor = .clear
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        self.backgroundColor = .clear
        addSubview(dropdownTitleView)
        
        // Constraints for dropdownTitleView
        NSLayoutConstraint.activate([
            dropdownTitleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dropdownTitleView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            dropdownTitleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dropdownTitleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
