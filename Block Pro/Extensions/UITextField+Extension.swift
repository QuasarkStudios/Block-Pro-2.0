//
//  UITextField+Extension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/12/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

extension UITextField {
    
    func setCustomPlaceholder (text: String, alignment: NSTextAlignment) {
        
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = alignment
        
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "AAAAAA") as Any, NSAttributedString.Key.paragraphStyle : centeredParagraphStyle])
    }
}
