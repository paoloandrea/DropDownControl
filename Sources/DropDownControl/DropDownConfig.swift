//
//  DropDownConfig.swift
//  DropDownControl
//
//  Created by Paolo Rossignoli on 03/06/24.
//

import UIKit

public struct DropDownConfig {
    var headerBackgroundColor: UIColor
    var headerFont: UIFont
    var cellFont: UIFont
    var cellTextColor: UIColor
    var backgroundColor: UIColor
    var textColor: UIColor
    
    public init(headerBackgroundColor: UIColor = .black,
                headerFont: UIFont = UIFont.boldSystemFont(ofSize: 18),
                cellFont: UIFont = UIFont.systemFont(ofSize: 17),
                cellTextColor: UIColor = .white,
                backgroundColor: UIColor = .black,
                textColor: UIColor = .white) {
        self.headerBackgroundColor = headerBackgroundColor
        self.headerFont = headerFont
        self.cellFont = cellFont
        self.cellTextColor = cellTextColor
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
}
