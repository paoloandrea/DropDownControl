//
//  DropDownControl.swift
//  IPTV
//
//  Created by Paolo Rossignoli on 18/05/23.
//  Updated by Paolo on 3/06/24
//  Copyright © 2024 IP Television. All rights reserved.
//

import UIKit

/// Structure that represents items for the drop down.
public struct DropDownItems: Hashable {
    let name: String
    let totalChannels: Int
    
    public init(name: String, totalChannels: Int) {
        self.name = name
        self.totalChannels = totalChannels
    }
    
    public static func ==(lhs: DropDownItems, rhs: DropDownItems) -> Bool {
        return lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

public final class DropDownControl: UIControl {
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()
    
    private var controllerName: String?
    private var controlTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 29).isActive = true
        button.heightAnchor.constraint(equalToConstant: 29).isActive = true
        button.setImage(UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private var dropdownMenu: DropDownBouquet?
    private var items: [DropDownItems] = []
    
    private var selectedText: String? {
        didSet {
            updateLabel()
        }
    }
    
    public var didSelectItem: ((String) -> Void)?
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: controlTitleLabel.intrinsicContentSize.height)
    }
    
    public init() {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        setupView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        configureLabel()
        configureButton()
        configureLayout()
    }
    
    private func configureLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        controlTitleLabel.isUserInteractionEnabled = true
        controlTitleLabel.addGestureRecognizer(tapGesture)
    }
    
    private func configureButton() {
        button.addTarget(self, action: #selector(showDropdownMenu), for: .touchUpInside)
    }
    
    private func configureLayout() {
        textStackView.addArrangedSubview(controlTitleLabel)
        addSubview(textStackView)
        addSubview(button)
        
        NSLayoutConstraint.activate([
            textStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textStackView.topAnchor.constraint(equalTo: topAnchor),
            textStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: textStackView.trailingAnchor, constant: 8),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func updateLabel() {
        controlTitleLabel.text = selectedText ?? controllerName
        let isEmpty = items.isEmpty
        button.isHidden = isEmpty
        button.isUserInteractionEnabled = !isEmpty
        textStackView.isUserInteractionEnabled = !isEmpty
    }
    
    @objc
    private func handleTap() {
        showDropdownMenu()
    }
    
    @objc
    public func showDropdownMenu() {
        guard let window = UIApplication.shared.keyWindow,
              let controllerName = controllerName else {
            return
        }
        
        // Calcola il frame del bottone relativo alla finestra
        let buttonFrame = self.convert(button.frame, to: window)
        
        // Posiziona il dropdown menu in modo che il bottone di chiusura (X) si allinei con il bottone di apertura (V)
        let sourceRect = CGRect(x: buttonFrame.origin.x, y: buttonFrame.maxY, width: window.frame.width, height: window.frame.height - buttonFrame.maxY)
        let config = DropDownConfig(headerBackgroundColor: .black,
                                    headerFont: UIFont.boldSystemFont(ofSize: 20),
                                    cellFont: UIFont.systemFont(ofSize: 18),
                                    cellTextColor: .lightGray,
                                    backgroundColor: .black,
                                    textColor: .white)
        dropdownMenu = DropDownBouquet(controllerName: controllerName, menuItems: items, presentingViewController: window.rootViewController!, config: config)
        
        dropdownMenu?.delegate = self
        dropdownMenu?.show(from: self, sourceRect: sourceRect, buttonFrame: buttonFrame)
    }
    
    public func withConfig(controllerName: String, items: [DropDownItems]) {
        self.items = Array(NSOrderedSet(array: items)) as! [DropDownItems]
        self.controllerName = controllerName
        self.controlTitleLabel.text = controllerName
        setupView()
        self.updateLabel()
    }
    
    public func updateItems(_ newItems: [DropDownItems]) {
        self.items = Array(NSOrderedSet(array: newItems)) as! [DropDownItems]
        if items.isEmpty {
            selectedText = nil
        }
        controlTitleLabel.text = controllerName
        button.isHidden = items.isEmpty
        button.isUserInteractionEnabled = !items.isEmpty
        textStackView.isUserInteractionEnabled = !items.isEmpty
    }
}

extension DropDownControl: DropDownBouquetDelegate {
    func dropdownMenu(_ dropdownMenu: DropDownBouquet, didSelectItemAtIndex index: Int) {
        selectedText = items[index].name
        didSelectItem?(selectedText!)
    }
}



@available(iOS 17.0, *)
#Preview {
    let dropdownControl = DropDownControl.init()
    dropdownControl.backgroundColor = .darkGray
    dropdownControl.frame = CGRect(x: 10, y: 10, width: 300, height: 20)
    let items = [DropDownItems.init(name: "Playlist 1", totalChannels: 2), DropDownItems.init(name: "Playlist 2", totalChannels: 523)]
    dropdownControl.withConfig(controllerName: "Bouquet", items: items)
    
    return dropdownControl
}
