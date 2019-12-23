//
//  RadialGradient.swift
//  Block Pro
//
//  Created by Nimat Azeez on 11/26/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class RadialGradients: UIView {
    
    override func draw(_ rect: CGRect) {
        
        let innerGradientInsideColor: UIColor = UIColor.flatMint().lighten(byPercentage: 0.25)!
        let innerGradientOutsideColor: UIColor = .white
        
        let innerGradientColors = [innerGradientInsideColor.cgColor, innerGradientOutsideColor.cgColor] as CFArray
        let innerGradient = CGGradient(colorsSpace: nil, colors: innerGradientColors, locations: nil)
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        let outerGradientInsideColor: UIColor = .white
        let outerGradientOusideColor: UIColor = UIColor.flatMint().lighten(byPercentage: 0.25)!
        
        let outerGradientColors = [outerGradientInsideColor.cgColor, outerGradientOusideColor.cgColor] as CFArray
        let outerGradient = CGGradient(colorsSpace: nil, colors: outerGradientColors, locations: [0.0, 0.5])
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        let center: CGPoint!
        let startRadius: CGFloat!
        let endRadius: CGFloat!
    
        
        //Setting the center of the gradients
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 { //iPhone XS Max & iPhone XR
            
            center = CGPoint(x: bounds.size.width / 2, y: (bounds.size.height / 2) - 7.5)
        }
            
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 { //iPhone XS
            
            center = CGPoint(x: bounds.size.width / 2, y: (bounds.size.height / 2) - 30)
        }
            
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 { //iPhone 8 Plus
            
            center = CGPoint(x: bounds.size.width / 2, y: (bounds.size.height / 2) - 60)
        }
        
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 { //iPhone 8
            
            center = CGPoint(x: bounds.size.width / 2, y: (bounds.size.height / 2) - 95)
        }
            
        else { //iPhone SE
            
            center = CGPoint(x: bounds.size.width / 2, y: (bounds.size.height / 2) - 120)
        }
            
        
        //Setting the startRadius of the gradient
        if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 { //iPhone 8
            
            startRadius = 120
        }
        
        else if UIScreen.main.bounds.width == 320.0  { //iPhone SE
            
            startRadius = 104
        }
        
        else { //Every other iPhone
            
            startRadius = 125
        }
        
        
        //Setting the endRadius of the gradients
        if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 { //iPhone 8
            
            endRadius = 122.5
        }
        
        else if UIScreen.main.bounds.width == 320.0  { //iPhone SE
            
            endRadius = 106.5
        }
        
        else { //Every other iPhone
            endRadius = 127.5
        }
        
        //Drawing the radial gradients onto the view
        UIGraphicsGetCurrentContext()!.drawRadialGradient(innerGradient!, startCenter: center , startRadius: 5, endCenter: center, endRadius: endRadius, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        
        UIGraphicsGetCurrentContext()!.drawRadialGradient(outerGradient!, startCenter: center, startRadius: startRadius, endCenter: center, endRadius: 400, options: CGGradientDrawingOptions.drawsAfterEndLocation)
        
    }

}
