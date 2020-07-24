//
//  File.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

extension String {
    
    func leniantValidationOfTextEntered () -> Bool {
        
        let textArray = Array(self)
        var textEntered: Bool = false
        
        for char in textArray {
            
            if char != " " {
                textEntered = true
                break
            }
        }
        
        return textEntered
    }
    
    func estimateFrameForMessageCell () -> CGRect {
        
        let size = CGSize(width: 200, height: 100000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: self).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 14) as Any], context: nil)
    }
}
