//
//  NavBar+Extension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

extension UINavigationBar {
    
    func configureNavBar () {
        
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        backgroundColor = .clear
        
        tintColor = .black
    }
}
