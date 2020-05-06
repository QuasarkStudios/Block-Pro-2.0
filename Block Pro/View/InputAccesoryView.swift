//
//  InputAccesoryView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/4/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class InputAccesoryView: UIView {

    var size: CGSize? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        
        self.autoresizingMask = .flexibleHeight
        size = configureSize()
    }
    
    convenience init () {
        self.init(frame: .zero)
        
        configureView()
        
        size = configureSize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var intrinsicContentSize: CGSize {
        return size ?? CGSize(width: 0, height: 0)
    }
    
    private func configureView () {
        
        isHidden = true
        alpha = 0
        backgroundColor = UIColor(hexString: "ffffff", withAlpha: 0.95)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureSize () -> CGSize {
        
        //iPhone 11 Pro Max & iPhone 11
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {

            return CGSize(width: 0, height: 75)
        }
            
        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            return CGSize(width: 0, height: 75)
        }
            
        //Every other iPhone
        else  {
            
            return CGSize(width: 0, height: 50)
        }
    }
}
