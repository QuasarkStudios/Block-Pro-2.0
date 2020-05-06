//
//  MessageTextViewContainer.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/4/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class MessageTextViewContainer: UIView {
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    convenience init () {
        self.init(frame: .zero)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureView () {
        
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        layer.borderWidth = 1
    }
    
    func configureConstraints () {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        constraints.append(leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: 13))
        constraints.append(trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: -13))
        constraints.append(heightAnchor.constraint(equalToConstant: 35))
        
        //iPhone 11 Pro Max & iPhone 11
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            constraints.append(bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: -36))
        }
            
        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            constraints.append(bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: -36))
        }
            
        //Every other iPhone
        else {
            
            constraints.append(bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: -10))
        }
        
        constraints.forEach { $0.isActive = true }
    }
}
