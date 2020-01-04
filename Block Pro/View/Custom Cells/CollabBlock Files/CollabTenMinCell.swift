//
//  TenMinCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/24/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation
import ChameleonFramework

class CollabTenMinCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    let collabBlockViewObject = CollabBlockViewController()
    
    typealias blockTuple = CollabBlockViewController.blockTuple
    
    lazy var blockCategoryColors: [String : String] = collabBlockViewObject.blockCategoryColors
    
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
            alphaView.layer.cornerRadius = 0.039 * alphaView.bounds.size.width
            alphaView.clipsToBounds = true
            
            startLabel.text = collabBlockViewObject.convertTo12Hour(block.startHour, block.startMinute)
            startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
            
            toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
            
            endLabel.text = collabBlockViewObject.convertTo12Hour(block.endHour, block.endMinute)
            endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
        }
    }
}
