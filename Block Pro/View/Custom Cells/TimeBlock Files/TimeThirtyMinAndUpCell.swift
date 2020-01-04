//
//  TimeThirtyMinAndUpCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/14/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation

class TimeThirtyMinAndUpCell: UITableViewCell {
    
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var superContainerView: UIView!
    @IBOutlet weak var subContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var alphaViewLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var alphaViewTrailingAnchor: NSLayoutConstraint!
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
            
            outlineView.backgroundColor = blockColor
            outlineView.layer.cornerRadius = 0.035 * outlineView.bounds.size.width
            outlineView.clipsToBounds = true
            
            superContainerView.layer.cornerRadius = 0.035 * superContainerView.bounds.size.width
            superContainerView.clipsToBounds = true
            
            subContainerView.backgroundColor = .none
            
            nameLabel.text = block.name
            nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16.0)
            nameLabel.adjustsFontSizeToFitWidth = true
            
            if UIScreen.main.bounds.width == 320.0 {
                
                alphaViewLeadingAnchor.constant = 30
                alphaViewTrailingAnchor.constant = 30
            }
            
            alphaView.layer.cornerRadius = 0.035 * alphaView.bounds.size.width
            alphaView.clipsToBounds = true
            
            startLabel.text = timeBlockViewObject.convertTo12Hour(block.startHour, block.startMinute)
            startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 13)
            
            toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
            
            endLabel.text = timeBlockViewObject.convertTo12Hour(block.endHour, block.endMinute)
            endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 13)
        }
    }
}
