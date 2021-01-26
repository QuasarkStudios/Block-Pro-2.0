//
//  UILabel+Extension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/21/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

extension UILabel {
    
    func addCharacterSpacing(kernValue: Double = 1.15) {

        if let labelText = text, labelText.count > 0 {

            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
