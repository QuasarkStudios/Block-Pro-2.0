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
    
    weak var blockSelectedDelegate: BlockSelectedProtocol?
    
    var formatter: DateFormatter?
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(blockTapped))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureBlock () {
        
        self.setBlockColor(block)
        
        nameLabel.text = block?.name
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.addCharacterSpacing(kernValue: 1.69)
        
        if let formatter = formatter, let starts = block?.starts, let ends = block?.ends {
            
            formatter.dateFormat = "h:mm a"
            
            timeLabel.text = formatter.string(from: starts)
            timeLabel.text! += " - "
            timeLabel.text! += formatter.string(from: ends)
        }
        
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.addCharacterSpacing(kernValue: 1.06)
        
        layer.cornerCurve = .continuous
        clipsToBounds = true
        
        switch frame.height {
        
        //5 min block
        case 7.5:
            
            layer.cornerRadius = 3
        
        //10 min block
        case 15.0:
            
            layer.cornerRadius = 6
            
            nameLabel.frame = CGRect(x: 5, y: -0.5, width: frame.width - 10, height: 15)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 12)
            
            addSubview(nameLabel)
        
        //15 min block
        case 22.5:
            
            layer.cornerRadius = 9
            
            nameLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 10, height: 22.5)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 13.5)
            
            addSubview(nameLabel)
        
        //20 min block
        case 30:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 10, height: 30)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 13.5)

            addSubview(nameLabel)
           
        //25 min block
        case 37.5:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 10, height: 37.5)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)

            addSubview(nameLabel)
         
        //30 min block
        case 45:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 10, height: 45)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)

            addSubview(nameLabel)
        
        //35 min block
        case 52.5:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 10, height: 52.5)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
            
            addSubview(nameLabel)
        
        //40 min block
        case 60:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 5, y: 3.5, width: frame.width - 10, height: 30)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
            
            addSubview(nameLabel)
            
            timeLabel.frame = CGRect(x: 6.5, y: nameLabel.frame.maxY + 2, width: frame.width - 11.5, height: 15)
            timeLabel.font = UIFont(name: "Poppins-Medium", size: 12)

            addSubview(timeLabel)
        
        //45 min block
        case 67.5:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 5, y: 7.5, width: frame.width - 10, height: 30)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 16)
            
            addSubview(nameLabel)
            
            timeLabel.frame = CGRect(x: 6.5, y: nameLabel.frame.maxY + 2.5, width: frame.width - 11.5, height: 15)
            timeLabel.font = UIFont(name: "Poppins-Medium", size: 12)

            addSubview(timeLabel)
          
        //50 min block
        case 75:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: 30)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 16)
            
            addSubview(nameLabel)
            
            timeLabel.frame = CGRect(x: 6.5, y: nameLabel.frame.maxY + 2.5, width: frame.width - 11.5, height: 15)
            timeLabel.font = UIFont(name: "Poppins-Medium", size: 12)

            addSubview(timeLabel)
            
        //55 min block
        default:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: 35)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 16)
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.8
            
            addSubview(nameLabel)
            
            timeLabel.frame = CGRect(x: 6.5, y: nameLabel.frame.maxY + 2.5, width: frame.width - 11.5, height: 15)
            timeLabel.font = UIFont(name: "Poppins-Medium", size: 12)

            addSubview(timeLabel)
        }
    }
    
    @objc private func blockTapped () {
        
        if let block = block {
            
            blockSelectedDelegate?.blockSelected(block)
        }
    }
}
