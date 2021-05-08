//
//  UITextField+Extension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/12/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

extension UITextField {
    
    func setOnboardingTextFieldConstraints () {
        
        if let superview = self.superview {
            
            self.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 20),
                self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -10),
                self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0),
                self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0)
            
            ].forEach({ $0.isActive = true })
        }
    }
    
    func setCustomPlaceholder (text: String, alignment: NSTextAlignment) {
        
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = alignment
        
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "AAAAAA") as Any, NSAttributedString.Key.paragraphStyle : centeredParagraphStyle])
    }
}
