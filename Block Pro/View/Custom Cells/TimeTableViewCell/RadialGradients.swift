//
//  RadialGradient.swift
//  Block Pro
//
//  Created by Nimat Azeez on 11/26/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

//@IBDesignable
class RadialGradients: UIView {
    
    var innerGradientInsideColor: UIColor = UIColor.flatMint().lighten(byPercentage: 0.25)!
    var innerGradientOutsideColor: UIColor = .white
    
    var outerGradientInsideColor: UIColor = .white
    var outerGradientOusideColor: UIColor = UIColor.flatMint().lighten(byPercentage: 0.25)!
    
    override func draw(_ rect: CGRect) {
        
        var colors = [innerGradientInsideColor.cgColor, innerGradientOutsideColor.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil/*[0.0, 1/*0.93*/]*/)
        
        colors = [outerGradientInsideColor.cgColor, outerGradientOusideColor.cgColor] as CFArray
        
        let gradient2 = CGGradient(colorsSpace: nil, colors: colors, locations: [0.0, 0.5])
        
        let center: CGPoint?
        let endRadius: CGFloat? //min(frame.width, frame.height) / 2
    
        
        //Initializing the center of the gradient
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            center = CGPoint(x: bounds.size.width / 2, y: (bounds.size.height / 2) - 7.5)

        }
            
        //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            center = CGPoint(x: bounds.size.width / 2, y: (bounds.size.height / 2) - 30)
        }
            
        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {
            
            center = CGPoint(x: bounds.size.width / 2, y: (bounds.size.height / 2) - 65)

        }
            
        //iPhone 8
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {
            
            center = CGPoint(x: bounds.size.width / 2, y: (bounds.size.height / 2) - 30)

        }
            
        //iPhone SE
        else {
            
            center = CGPoint(x: bounds.size.width / 2, y: (bounds.size.height / 2) - 30)

        }
            
        
        
        
        //Initializing the endRadius of the gradient
        
        if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 { //iPhone 8
            
            endRadius = 122.5
        }
        
        else if UIScreen.main.bounds.width == 320.0  { //iPhone SE
            
            endRadius = 106.5
        }
        
        else {
            
            endRadius = 127.5
        }
        
        UIGraphicsGetCurrentContext()!.drawRadialGradient(gradient!, startCenter: center! , startRadius: 5, endCenter: center!, endRadius: endRadius!, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        
        UIGraphicsGetCurrentContext()!.drawRadialGradient(gradient2!, startCenter: center!, startRadius: 125, endCenter: center!, endRadius: 400, options: CGGradientDrawingOptions.drawsAfterEndLocation)
        
    }

}
