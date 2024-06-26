//
//  DropdownBouquet.swift
//
//
//  Created by Paolo Rossignoli on 19/10/23.
//  Updated by Paolo on 3/06/24
//  Copyright © 2024 IP Television. All rights reserved.
//

import UIKit

protocol DropDownBouquetDelegate: AnyObject {
    func dropdownMenu(_ dropdownMenu: DropDownBouquet, didSelectItemAtIndex index: Int)
}

class DropDownBouquet: NSObject {
    
    internal var menuItems: [DropDownItems] {
        didSet {
            self.dropdownCollectionView?.reloadData()
        }
    }
    
    private weak var presentingViewController: UIViewController?
    internal var dropdownCollectionView: UICollectionView? = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 1, height: 29)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DropDownCell.self, forCellWithReuseIdentifier: "DropDownCell")
        collectionView.register(DropDownHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DropDownHeaderView")
        collectionView.backgroundColor = .clear // Assicurarsi che lo sfondo della collection view sia trasparente
        collectionView.alpha = 0
        return collectionView
    }()
    
    private var closeButton: UIButton? = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.alpha = 0
        return button
    }()
    
    private var controllerName: String?
    internal weak var delegate: DropDownBouquetDelegate?
    private var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private let titleHeight: CGFloat = 40
    private let cellHeight: CGFloat = 29
    private var config: DropDownConfig?
    
    init(controllerName: String, menuItems: [DropDownItems], presentingViewController: UIViewController, config: DropDownConfig? = nil) {
        self.controllerName = controllerName
        self.menuItems = menuItems
        self.presentingViewController = presentingViewController
        self.config = config
        super.init()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        guard let collectionView = dropdownCollectionView,
              let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: titleHeight)
        flowLayout.sectionHeadersPinToVisibleBounds = true
    }
    
    internal func show(from sourceView: UIView, sourceRect: CGRect, buttonFrame: CGRect) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        setupBackgroundView(in: window)
        setupCollectionView(in: window, sourceRect: sourceRect)
        setupCloseButton(in: window, alignedWith: buttonFrame)
        animateDropdownAppearance()
    }
    
    private func setupBackgroundView(in window: UIWindow) {
        backgroundView.backgroundColor = config?.backgroundColor ?? .black
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        window.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: window.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])
    }
    
    private func setupCollectionView(in window: UIWindow, sourceRect: CGRect) {
        guard let collectionView = dropdownCollectionView else { return }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        window.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: window.topAnchor, constant: sourceRect.origin.y),
            collectionView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])
    }
    
    private func setupCloseButton(in window: UIWindow, alignedWith buttonFrame: CGRect) {
        guard let closeButton = closeButton else { return }
        window.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: window.topAnchor, constant: buttonFrame.origin.y),
            closeButton.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: buttonFrame.origin.x),
            closeButton.widthAnchor.constraint(equalToConstant: 29),
            closeButton.heightAnchor.constraint(equalToConstant: 29)
        ])
        closeButton.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
    }
    
    private func animateDropdownAppearance() {
        guard let collectionView = dropdownCollectionView else { return }
        dropdownCollectionView?.reloadData()
        dropdownCollectionView?.layoutIfNeeded()
        let headerView = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first as? DropDownHeaderView
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dropdownCollectionView?.alpha = 1.0
            self.backgroundView.alpha = 1.0
            self.closeButton?.alpha = 1.0
        }) { _ in
            headerView?.alpha = 1
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let collectionView = dropdownCollectionView else { return }
        let tapLocation = sender.location(in: collectionView)
        if !collectionView.bounds.contains(tapLocation) {
            dismissMenu()
        }
    }
    
    @objc internal func dismissMenu() {
        guard let collectionView = dropdownCollectionView, let closeButton = closeButton else { return }
        
        let headerView = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first as? DropDownHeaderView
        
        UIView.animate(withDuration: 0.3, animations: {
            collectionView.alpha = 0.0
            self.backgroundView.alpha = 0
            closeButton.alpha = 0
            headerView?.alpha = 0
        }) { _ in
            collectionView.removeFromSuperview()
            self.dropdownCollectionView = nil
            self.backgroundView.removeFromSuperview()
            self.closeButton?.removeFromSuperview()
            self.closeButton = nil
        }
    }
}

// MARK: - UICollectionViewDataSource

extension DropDownBouquet: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DropDownCell", for: indexPath) as? DropDownCell else {
            return UICollectionViewCell()
        }
        if let config = config {
            cell.nameLabel.textColor = config.cellTextColor.withAlphaComponent(0.8)
            cell.nameLabel.font = config.cellFont
            cell.numberChannelsLabel.font = config.cellFont
        } else {
            cell.nameLabel.textColor = .white.withAlphaComponent(0.8)
            cell.nameLabel.font = UIFont.systemFont(ofSize: 17)
            cell.numberChannelsLabel.font = UIFont.systemFont(ofSize: 17)
        }
        cell.nameLabel.text = menuItems[indexPath.row].name
        cell.numberChannelsLabel.text = "\(menuItems[indexPath.row].totalChannels)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DropDownHeaderView", for: indexPath) as! DropDownHeaderView
            if let config = config {
                headerView.backgroundColor = config.headerBackgroundColor
                headerView.dropdownTitleView.textColor = config.textColor
                headerView.dropdownTitleView.font = config.headerFont
            } else {
                headerView.backgroundColor = .black
                headerView.dropdownTitleView.textColor = .white
                headerView.dropdownTitleView.font = UIFont.boldSystemFont(ofSize: 18)
            }
            headerView.alpha = 0
            headerView.dropdownTitleView.text = self.controllerName
            return headerView
        default:
            fatalError("Invalid element type")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension DropDownBouquet: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.dropdownMenu(self, didSelectItemAtIndex: indexPath.row)
        dismissMenu()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DropDownBouquet: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
