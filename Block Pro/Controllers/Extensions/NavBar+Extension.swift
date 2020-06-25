//
//  NavBar+Extension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

extension UINavigationBar {
    
    func configureNavBar (barBackgroundColor: UIColor = .white, barTintColor: UIColor = .black) {
        
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        backgroundColor = barBackgroundColor//.white
        
        tintColor = barTintColor//.black
        
        //frame = CGRect(x: frame.minX, y: frame.minY, width: UIScreen.main.bounds.width, height: 200)
    }
}
