//
//  BigBlock.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class BigBlock: UIView {

    let nameLabel: UILabel = UILabel()
    let timeLabel: UILabel = UILabel()
    
    let categoryColors: [String : String] = ["Work": "#5065A0", "Creativity" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#AAAAAA"]
    
    var category: String? {
        didSet {
            
            backgroundColor = UIColor(hexString: categoryColors[category!] ?? "#AAAAAA", withAlpha: 0.85)
        }
    }
    
    override init (frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init () {
        self.init(frame: .zero)
        
        configureBlock()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureBlock()
    }
    
    private func configureBlock () {
        
        backgroundColor = UIColor(hexString: "#AAAAAA", withAlpha: 0.85)//flatBlue().withAlphaComponent(0.85)
        layer.cornerRadius = 10
        
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        nameLabel.text = "Block"
        nameLabel.textColor = .white
        nameLabel.textAlignment = .left
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
        
        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        timeLabel.text = "Starts - Ends"
        timeLabel.textColor = .white
        timeLabel.textAlignment = .left
        timeLabel.font = UIFont(name: "Poppins-Medium", size: 13)
    }

}
