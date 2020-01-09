//
//  CardContainer.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/6/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CardContainer: UIView {
    
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
        
        self.backgroundColor = UIColor(hexString: "F2F2F2")?.darken(byPercentage: 0.1)
        
        layer.cornerRadius = 0.08 * bounds.size.width
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
    }
}
