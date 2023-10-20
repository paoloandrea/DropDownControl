//
//  ViewController.swift
//  DropDownControl
//
//  Created by Paolo Rossignoli on 19/10/23.
//

import UIKit

class ViewController: UIViewController {
    
    let imageView:UIImageView = {
        let image = UIImage(named: "background")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let dropDownControl:DropDownControl = {
        let control = DropDownControl.init()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = .clear
        return control
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let items = [DropDownItems.init(name: "Curabitur pretium orci", totaleChannels: 2),
                                 DropDownItems.init(name: "Proin sollicitudin", totaleChannels: 523),
                                 DropDownItems.init(name: "Lorem ipsum", totaleChannels: 70),
                                 DropDownItems.init(name: "Aliquam sit amet lacinia", totaleChannels: 2),
                                 DropDownItems.init(name: "Pellentesque", totaleChannels: 14),
                                 DropDownItems.init(name: "Nulla iaculis leo nulla", totaleChannels: 22),
                                 DropDownItems.init(name: "Donec suscipit", totaleChannels: 132),
                                 DropDownItems.init(name: "Sed blandit arcu quis", totaleChannels: 223)
        ]
        
        dropDownControl.withConfig(controllerName: "DropDown name", items: items)
        
        setupConstraint()
    }
    
    func setupConstraint(){
        self.view.addSubview(imageView)
        self.view.addSubview(dropDownControl)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            dropDownControl.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dropDownControl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            dropDownControl.widthAnchor.constraint(equalToConstant: 200),
            dropDownControl.heightAnchor.constraint(equalToConstant: 20),
        ])
    }


}

