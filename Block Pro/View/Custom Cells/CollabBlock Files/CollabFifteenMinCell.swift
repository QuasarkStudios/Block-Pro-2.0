//
//  FifteenMinCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/24/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation

class CollabFifteenMinCell: UITableViewCell {
    
    @IBOutlet weak var outlineView: UIView!
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
            
            outlineView.backgroundColor = blockColor
            outlineView.layer.cornerRadius = 0.035 * outlineView.bounds.size.width
            outlineView.clipsToBounds = true
            
            containerView.layer.cornerRadius = 0.035 * containerView.bounds.size.width
            containerView.clipsToBounds = true
            
            nameLabel.text = block.name
            nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 15.0)
            nameLabel.adjustsFontSizeToFitWidth = true
            
            alphaView.layer.cornerRadius = 0.05 * alphaView.bounds.size.width
            alphaView.clipsToBounds = true
            
            startLabel.text = collabBlockViewObject.convertTo12Hour(block.startHour, block.startMinute)
            startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
            
            toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
            
            endLabel.text = collabBlockViewObject.convertTo12Hour(block.endHour, block.endMinute)
            endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
        }
    }
}
