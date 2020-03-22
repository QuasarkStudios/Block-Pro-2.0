//
//  CategoryProgressBar.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/16/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class CategoryProgressBar: UIView {
    
    let categoryColors: [String : String] = ["Work": "#5065A0", "Creativity" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#AAAAAA"]
    
    var category: String? {
        didSet {
            
            backgroundColor = UIColor(hexString: categoryColors[category!] ?? "#AAAAAA")
        }
    }
    
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
        
        layer.cornerRadius = 5.5
        clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        } 
    }
}
