//
//  VibrateMethods.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/23/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class VibrateMethods {
    
    func quickVibrate () {
        
        let generator: UIImpactFeedbackGenerator?
        
        if #available(iOS 13.0, *) {

            generator = UIImpactFeedbackGenerator(style: .rigid)
        
        } else {
            
            generator = UIImpactFeedbackGenerator(style: .medium)
        }
        
        generator?.impactOccurred()
    }
}
