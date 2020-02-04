//
//  SelectionIndicator.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/31/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class SelectionIndicator: UIView {
    
    override init (frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init () {
        self.init(frame: CGRect.zero)
        
        initializeView ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeView ()
    }
    
    func initializeView () {
        
        layer.cornerRadius = 15
        clipsToBounds = true
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor(hexString: "4E697B")?.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        
    }
    
}
