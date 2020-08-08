//
//  VibrateMethods.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/23/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class VibrateMethods {
    
    func quickVibration () {
        
//        let generator: UIImpactFeedbackGenerator?
//
//        if #available(iOS 13.0, *) {
//
//            generator = UIImpactFeedbackGenerator(style: .rigid)
//
//        } else {
//
//            generator = UIImpactFeedbackGenerator(style: .medium)
//        }
//
//        generator?.impactOccurred()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
    }
    
    func warningVibration () {
        
//        let generator = UINotificationFeedbackGenerator()
//        generator.notificationOccurred(.error)
        
                let generator: UIImpactFeedbackGenerator?
        
//                if #available(iOS 13.0, *) {
//
//                    generator = UIImpactFeedbackGenerator(style: .rigid)
//
//                } else {
//
//                    generator = UIImpactFeedbackGenerator(style: .medium)
                //}
        
        generator = UIImpactFeedbackGenerator(style: .heavy)
        
                generator?.impactOccurred()
        
    }
}
