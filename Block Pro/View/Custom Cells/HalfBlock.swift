//
//  HalfBlock.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/17/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import ChameleonFramework

class HalfBlock: UIView {

    let nameLabel = UILabel()
    let timeLabel = UILabel()
    
    var block: Block? {
        didSet {
            
            configureBlock()
        }
    }
    
    override init (frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureBlock () {
        
//        self.setCollabBlockColor(block)
        
        self.backgroundColor = RandomFlatColor()
        
        nameLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: 22.5)
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 13.5)
        nameLabel.text = block?.name
        nameLabel.textColor = ContrastColorOf(backgroundColor!, returnFlat: false)
        
        self.addSubview(nameLabel)
        
        layer.cornerRadius = 5
        
        layer.cornerCurve = .continuous
        clipsToBounds = true
        
        switch frame.height {
        
        case 7.5:
            
            layer.cornerRadius = 3.75
            
        default:
            
            break
        }
    }
}
