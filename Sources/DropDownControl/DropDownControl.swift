//
//  DropDownControl.swift
//  IPTV
//
//  Created by Paolo Rossignoli on 18/05/23.
//  Copyright © 2023 IP Television. All rights reserved.
//

import UIKit

/// Structure that represents items for the drop down.
public struct DropDownItems: Equatable {
    let name: String
    let totaleChannels: Int

    public init(name: String, totaleChannels: Int) {
        self.name = name
        self.totaleChannels = totaleChannels
    }
    
    public static func ==(lhs: DropDownItems, rhs: DropDownItems) -> Bool {
        return lhs.name == rhs.name && lhs.totaleChannels == rhs.totaleChannels
    }
}

/// A control that contains a button that triggers a drop down table.
public final class DropDownControl: UIControl {
    
    private let textStackView =  {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()
    
    private var controllerName:String?
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
    
    /// The default size of the control.
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: controlTitleLabel.intrinsicContentSize.height)
    }
    
    public init() {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
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
        //textStackView.addArrangedSubview(channelsNumber)
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
        if let selectedText = selectedText {
            controlTitleLabel.text = selectedText
        } else {
            controlTitleLabel.text = controllerName
        }
        
        button.isHidden = items.count == 0 ? true : false
        button.isUserInteractionEnabled = items.count == 0 ? false : true
        textStackView.isUserInteractionEnabled = items.count == 0 ? false : true
        
    }
    
    @objc
    private func handleTap() {
        showDropdownMenu()
    }
    
    @objc
    public func showDropdownMenu() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        let sourceRect = CGRect(x: 0, y: self.frame.maxY+26, width: window.frame.width, height:window.frame.height)//convert(bounds, to: window)
        
        guard let controllerName = controllerName else {
            return
        }
        dropdownMenu = DropDownBouquet(controllerName: controllerName, menuItems: items, presentingViewController: window.rootViewController!)
        dropdownMenu?.delegate = self
        
        dropdownMenu?.show(from: self, sourceRect: sourceRect)
    }
    
    /// Configure the dropdown control with given parameters.
    /// - Parameters:
    ///   - controllerName: The name of the controller.
    ///   - items: The items to display in the dropdown.
    public func withConfig(controllerName: String, items: [DropDownItems]) {
        self.items = items
        self.controllerName = controllerName
        self.controlTitleLabel.text = controllerName
        setupView()
        self.updateLabel()
    }
    public func updateItems(_ newItems: [DropDownItems]) {
        // 1. Aggiorna la variabile 'items' con i nuovi elementi
        self.items = newItems

        // 2. Aggiorna la `controlTitleLabel` se necessario.
        // (Questo dipende dalla tua logica. Ad esempio, potresti voler reimpostare il testo al valore predefinito del controller quando gli elementi vengono aggiornati. Ho supposto questa logica qui, ma potresti volerla modificare.)
        if newItems.isEmpty {
            selectedText = nil
        }
        controlTitleLabel.text = controllerName

        // Aggiorna la visibilità del pulsante e l'interazione dell'utente in base agli elementi
        button.isHidden = newItems.isEmpty
        button.isUserInteractionEnabled = !newItems.isEmpty
        textStackView.isUserInteractionEnabled = !newItems.isEmpty
    }
    
}

extension DropDownControl: DropDownBouquetDelegate {
    func dropdownMenu(_ dropdownMenu: DropDownBouquet, didSelectItemAtIndex index: Int) {
        selectedText = items[index].name
        didSelectItem?(selectedText!)
    }
}



#if compiler(>=5.9)
#Preview {
    let dropdownControl = DropDownControl.init()
    dropdownControl.backgroundColor = .darkGray
    dropdownControl.frame = CGRect(x: 10, y: 10, width: 300, height: 20)
    let items = [DropDownItems.init(name: "Playlist 1", totaleChannels: 2), DropDownItems.init(name: "Playlist 2", totaleChannels: 523)]
    dropdownControl.withConfig(controllerName: "Bouquet", items: items)
    
    return dropdownControl
}
#endif
