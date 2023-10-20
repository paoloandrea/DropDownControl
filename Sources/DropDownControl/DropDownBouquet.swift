//
//  DropdownBouquet.swift
//
//
//  Created by Paolo Rossignoli on 19/10/23.
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
        layout.estimatedItemSize = CGSize(width: 1, height: 29) // stima dell'altezza
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DropDownCell.self, forCellWithReuseIdentifier: "DropDownCell")
        collectionView.register(DropDownHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DropDownHeaderView")
        
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private var closeButton: UIButton? = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private var controllerName:String?
    internal weak var delegate: DropDownBouquetDelegate?
    
    private var backgroundView: UIView? = { //UIVisualEffectView? = {
        //let blurEffect = UIBlurEffect(style: .dark)
        //let backgroundView = UIVisualEffectView(effect: blurEffect)
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }()
    
    private var titleHeight: CGFloat = 40
    private var cellHeight: CGFloat = 29
    
    private var textColor:UIColor?
    private var backgroundColor:UIColor?
    
    /// Initializes a new instance of the dropdown control.
    ///
    /// - Parameters:
    ///   - controllerName: The name of the controller.
    ///   - menuItems: The items to display in the dropdown.
    ///   - textColor: The text color for the dropdown items. Defaults to white.
    ///   - backgroundColor: The background color for the dropdown. Defaults to black.
    ///   - presentingViewController: The view controller from which the dropdown will be presented.
    init(controllerName: String, menuItems: [DropDownItems], textColor:UIColor? = .white, backgroundColor:UIColor? = .black, presentingViewController: UIViewController) {
        
        self.controllerName = controllerName
        self.menuItems = menuItems
        self.presentingViewController = presentingViewController
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        
        if let flowLayout = dropdownCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.headerReferenceSize = CGSize(width: dropdownCollectionView?.bounds.width ?? 0, height: titleHeight) // Scegli l'altezza appropriata
            flowLayout.sectionHeadersPinToVisibleBounds = true
        }
    }
    
    /// Displays the dropdown from the specified source view and source rectangle.
    ///
    /// This function will display the dropdown menu in a window with the specified source view and source rect.
    /// The menu will be presented with the specified text and background colors, and will be positioned relative to the specified view and rectangle.
    /// A close button is provided to dismiss the menu.
    ///
    /// - Parameters:
    ///   - sourceView: The view from which the dropdown should be displayed.
    ///   - sourceRect: The rectangle (in the coordinate space of the source view) at which the dropdown should be anchored.
    internal func show(from sourceView: UIView, sourceRect: CGRect) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        backgroundView?.backgroundColor = backgroundColor ?? .black
        backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        
        if let backgroundView = backgroundView {
            window.addSubview(backgroundView)
            NSLayoutConstraint.activate([
                backgroundView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                backgroundView.topAnchor.constraint(equalTo: window.topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])
        }
        
        dropdownCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        dropdownCollectionView?.delegate = self
        dropdownCollectionView?.dataSource = self
        
        window.addSubview(dropdownCollectionView!)
        
        NSLayoutConstraint.activate([
            dropdownCollectionView!.topAnchor.constraint(equalTo: window.topAnchor, constant:sourceRect.origin.y - titleHeight), //sourceRect.origin.y + titleHeight
            dropdownCollectionView!.leadingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leadingAnchor, constant: 0), //sourceRect.origin.x,
            dropdownCollectionView!.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: 0),
            //dropdownCollectionView!.widthAnchor.constraint(equalToConstant: window.widthAnchor),
            dropdownCollectionView!.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor) //CGFloat(menuItems.count) * (dropdownCollectionView?.bounds.height ?? 0) + titleHeight
            //dropdownCollectionView!.heightAnchor.constraint(equalToConstant: 400 ) //CGFloat(menuItems.count) * (dropdownCollectionView?.bounds.height ?? 0) + titleHeight
        ])
        
        // Close Menu
        if let closeButton = closeButton {
            window.addSubview(closeButton)
            closeButton.topAnchor.constraint(equalTo: dropdownCollectionView!.topAnchor, constant: -16).isActive = true
            closeButton.trailingAnchor.constraint(equalTo: dropdownCollectionView!.trailingAnchor, constant: -16).isActive = true
            closeButton.widthAnchor.constraint(equalToConstant: 29).isActive = true
            closeButton.heightAnchor.constraint(equalToConstant: 29).isActive = true
            closeButton.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.dropdownCollectionView?.alpha = 1.0
            self.backgroundView?.alpha = 1.0
            self.closeButton?.alpha = 1.0
            self.dropdownCollectionView?.layoutIfNeeded()
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let dropdownCollectionView = dropdownCollectionView else {
            return
        }
        
        let tapLocation = sender.location(in: dropdownCollectionView)
        if dropdownCollectionView.bounds.contains(tapLocation) {
            // Il tocco è all'interno del menu, non fare nulla
        } else {
            // Il tocco è al di fuori del menu, nascondi il menu
            dismissMenu()
        }
    }
    @objc internal func dismissMenu() {
        guard let dropdownCollectionView = dropdownCollectionView else {
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            dropdownCollectionView.alpha = 0.0
            self.backgroundView?.alpha = 0
            self.closeButton?.alpha = 0
            dropdownCollectionView.frame = CGRect(
                x: dropdownCollectionView.frame.origin.x,
                y: dropdownCollectionView.frame.origin.y + self.titleHeight,
                width: dropdownCollectionView.frame.width,
                height: 0
            )
        }) { (_) in
            dropdownCollectionView.removeFromSuperview()
            self.dropdownCollectionView = nil
            self.backgroundView?.removeFromSuperview()
            self.backgroundView = nil
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
        // Configura le label (supponendo che la tua UICollectionViewCell personalizzata abbia le stesse proprietà della UITableViewCell originale)
        cell.nameLabel.textColor = textColor?.withAlphaComponent(0.8) ?? .white.withAlphaComponent(0.8)
        cell.nameLabel.text = menuItems[indexPath.row].name
        cell.numberChannelsLabel.text = "\(menuItems[indexPath.row].totaleChannels ?? 0)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DropDownHeaderView", for: indexPath) as! DropDownHeaderView
            headerView.backgroundColor = backgroundColor ?? .black
            headerView.dropdownTitleView.textColor = textColor ?? .white
            headerView.dropdownTitleView.text = self.controllerName// Sostituisci con il tuo titolo effettivo
            return headerView
            
        default:
            assert(false, "Invalid element type")
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
        // Supponendo che tu voglia che ogni elemento abbia una larghezza che corrisponda a quella della collezione e una stima dell'altezza:
        return CGSize(width: collectionView.bounds.width, height: cellHeight) // Puoi personalizzare l'altezza come preferisci
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

