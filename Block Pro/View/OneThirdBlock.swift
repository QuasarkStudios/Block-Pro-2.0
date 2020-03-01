//
//  OneThirdBlock.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/17/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class OneThirdBlock: UIView {

    let nameLabel = UILabel()
    
    let categoryColors: [String : String] = ["Work": "#5065A0", "Creativity" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#AAAAAA"]
    
    typealias blockTuple = (blockID: String, notificationID: String, name: String, begins: Date, ends: Date, category: String)
    
    var block: blockTuple? {
        didSet {
            
            configureBlock()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init () {
        self.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureBlock () {
        
        backgroundColor = UIColor(hexString: categoryColors[block!.category] ?? "#AAAAAA", withAlpha: 0.75)
        
        nameLabel.text = block?.name
        nameLabel.textColor = .white//ContrastColorOf(UIColor(hexString: categoryColors[block?.category ?? "Other"] ?? "#AAAAAA")!, returnFlat: false)
        nameLabel.addCharacterSpacing(kernValue: 1.69)
        nameLabel.textAlignment = .center
        
        //nameLabel.adjustsFontSizeToFitWidth = true
        
        switch frame.height {
        
        //5 mins
        case 7.5:
            
            layer.cornerRadius = 3
            clipsToBounds = true
        
        //10 mins
        case 15.0:
            
            layer.cornerRadius = 6
            clipsToBounds = true
            
            nameLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 10, height: 15)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
            
            addSubview(nameLabel)
        
        //15 mins
        case 22.5:
            
            layer.cornerRadius = 9
            clipsToBounds = true
            
            nameLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 10, height: 22.5)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
            
            addSubview(nameLabel)
        
        //20 mins
        case 30:
            
            layer.cornerRadius = 11
            clipsToBounds = true
            
            nameLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 10, height: 30)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)

            addSubview(nameLabel)
           
        //25 mins
        case 37.5:
            
            layer.cornerRadius = 12
            clipsToBounds = true
            
            nameLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 10, height: 37.5)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)

            addSubview(nameLabel)
         
        //30 mins
        case 45:
            
            layer.cornerRadius = 11
            clipsToBounds = true
            
            nameLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 10, height: 45)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)

            addSubview(nameLabel)
        
        //35 mins
        case 52.5:
            
            layer.cornerRadius = 11
            clipsToBounds = true
            
            nameLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 10, height: 45)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
            
            addSubview(nameLabel)
            
        default:
            
            layer.cornerRadius = 11
            clipsToBounds = true

            nameLabel.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: 37.5)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)

            addSubview(nameLabel)
            
            
            
//        //40 mins
//        case 60:
//
//            layer.cornerRadius = 11
//            clipsToBounds = true
//
//            nameLabel.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: 37.5)
//            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
//
//            addSubview(nameLabel)
//

//        //45 mins
//        case 67.5:
//
//            layer.cornerRadius = 11
//            clipsToBounds = true
//
//            nameLabel.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: 37.5)
//            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
//
//            addSubview(nameLabel)
//
//
//        //50 & 55 min block
//        case 75, 82.5:
//
//            layer.cornerRadius = 11
//            clipsToBounds = true
//
//            nameLabel.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: 37.5)
//            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
//
//            addSubview(nameLabel)
//
//
//        //1 hour block
//        default:
//
//            layer.cornerRadius = 11
//            clipsToBounds = true
//
//            nameLabel.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: 37.5)
//            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
//
//            addSubview(nameLabel)

        }
    }

}
