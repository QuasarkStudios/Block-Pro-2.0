//
//  CategoryTrackBar.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/16/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class CategoryTrackBar: UIView {
    
    override init (frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init () {
        self.init(frame: .zero)
        
        configureBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureBar()
    }
    
    private func configureBar () {
        
        backgroundColor = UIColor(hexString: "F1F1F1")
        
        layer.cornerRadius = 7.5
        clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
    }
}
