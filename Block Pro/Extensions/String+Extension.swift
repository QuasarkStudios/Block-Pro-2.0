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
    
    func strictValidationOfTextEntered () -> Bool {
        
        let letters = CharacterSet.letters
        let numbers = CharacterSet.decimalDigits
        
        for char in self.unicodeScalars {
            
            if !letters.contains(char) || !numbers.contains(char) {
                
                return true
            }
        }
        
        return true
    }
    
    func estimateFrameForMessageCell () -> CGRect {
        
        let size = CGSize(width: 200, height: 100000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: self).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 14) as Any], context: nil)
    }
    
    func estimateHeightForObjectiveTextLabel () -> CGRect {
        
        let size = CGSize(width: UIScreen.main.bounds.size.width - 64, height: 500)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: self).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 14) as Any], context: nil)
    }
    
    func estimateHeightForLongestOnboardingMessage () -> CGRect {
        
        let size = CGSize(width: UIScreen.main.bounds.size.width - (UIScreen.main.bounds.width != 320 ? 80 : 40), height: 500)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: self).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: UIScreen.main.bounds.width != 320 ? 18 : 16) as Any], context: nil)
    }
}
