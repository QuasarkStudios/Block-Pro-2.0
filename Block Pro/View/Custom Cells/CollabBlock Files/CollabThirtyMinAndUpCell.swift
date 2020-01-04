//
//  ThirtyMinCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/25/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation

class CollabThirtyMinAndUpCell: UITableViewCell {
    
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var superContainerView: UIView!
    @IBOutlet weak var subContainerView: UIView!
    @IBOutlet weak var initialOutline: UIView!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var alphaViewLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var alphaViewTrailingAnchor: NSLayoutConstraint!
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
            
            superContainerView.layer.cornerRadius = 0.035 * superContainerView.bounds.size.width
            superContainerView.clipsToBounds = true
            
            subContainerView.backgroundColor = .none
            
            initialOutline.backgroundColor = blockColor
            initialOutline.layer.cornerRadius = 0.5 * 40
            initialOutline.clipsToBounds = true
            
            initialLabel.font = UIFont(name: "HelveticaNeue", size: 17)
    
            initialLabel.backgroundColor = UIColor.lightGray.lighten(byPercentage: 0.1)
            initialLabel.layer.cornerRadius = 0.5 * 36
            initialLabel.clipsToBounds = true
            
            if block.creator["userID"] == collabBlockViewObject.currentUser.userID {
                
                initialLabel.text = "Me"
                
            }
            else {
                
                let firstNameArray = Array(block.creator["firstName"]!)
                let lastNameArray = Array(block.creator["lastName"]!)
                
                initialLabel.text = "\(firstNameArray[0])" + "\(lastNameArray[0])"
            }
            
            nameLabel.text = block.name
            nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18.0)
            nameLabel.adjustsFontSizeToFitWidth = true
            
            //iPhone SE
            if UIScreen.main.bounds.width == 320.0 && UIScreen.main.bounds.height == 568 {
            
                alphaViewLeadingAnchor.constant -= 15
                alphaViewTrailingAnchor.constant -= 15
                
            }
            
            alphaView.layer.cornerRadius = 0.04 * alphaView.bounds.size.width
            alphaView.clipsToBounds = true
            
            startLabel.text = collabBlockViewObject.convertTo12Hour(block.startHour, block.startMinute)
            startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 13)
            
            toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
            
            endLabel.text = collabBlockViewObject.convertTo12Hour(block.endHour, block.endMinute)
            endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 13)
        }
    }
}
