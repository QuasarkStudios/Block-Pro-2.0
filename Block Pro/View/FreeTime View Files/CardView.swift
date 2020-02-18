//
//  CardView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/6/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CardView: UIView {
    
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
    
    private func initializeView () {
        
        layer.cornerRadius = 0.075 * bounds.size.width
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
    }
}
