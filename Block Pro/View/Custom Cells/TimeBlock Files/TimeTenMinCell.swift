//
//  TimeTenMinCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/14/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation
import ChameleonFramework

class TimeTenMinCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    let timeBlockViewObject = TimeBlockViewController()
    
    typealias blockTuple = TimeBlockViewController.blockTuple
    
    lazy var blockCategoryColors: [String : String] = timeBlockViewObject.blockCategoryColors
    
    var block: blockTuple! {
        didSet {
            
            var blockColor: UIColor!
            
            if block.category != "" {
                
                blockColor = UIColor(hexString: blockCategoryColors[block.category] ?? "#AAAAAA")
            }
            else {
                
                blockColor = UIColor(hexString: "#AAAAAA")
            }
            
            containerView.backgroundColor = blockColor
            containerView.layer.cornerRadius = 0.03 * containerView.bounds.size.width
            containerView.clipsToBounds = true
            
            nameLabel.text = block.name
            nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 15.0)
            nameLabel.textColor = ContrastColorOf(blockColor, returnFlat: false)
            nameLabel.adjustsFontSizeToFitWidth = true
            
            alphaView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            alphaView.layer.cornerRadius = 0.045 * alphaView.bounds.size.width
            alphaView.clipsToBounds = true
            
            startLabel.text = timeBlockViewObject.convertTo12Hour(block.startHour, block.startMinute)
            startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
            startLabel.textColor = UIColor.black
            
            toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
            toLabel.textColor = UIColor.black
            
            endLabel.text = timeBlockViewObject.convertTo12Hour(block.endHour, block.endMinute)
            endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
            endLabel.textColor = UIColor.black
        }
    }
}
