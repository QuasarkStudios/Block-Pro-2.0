//
//  TwentyMinCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/24/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation

class CollabTwentyMinCell: UITableViewCell {
    
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var initialOutline: UIView!
    @IBOutlet weak var initialLabel: UILabel!
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
            
            initialOutline.backgroundColor = blockColor
            initialOutline.layer.cornerRadius = 0.5 * 28
            initialOutline.clipsToBounds = true
            
            initialLabel.backgroundColor = UIColor.lightGray.lighten(byPercentage: 0.1)
            initialLabel.layer.cornerRadius = 0.5 * 24
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
            nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 15.0)
            nameLabel.adjustsFontSizeToFitWidth = true
            
            alphaView.layer.cornerRadius = 0.08 * alphaView.bounds.size.width
            alphaView.clipsToBounds = true
            
            startLabel.text = collabBlockViewObject.convertTo12Hour(block.startHour, block.startMinute)
            startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 12.5)

            toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 22)
            
            endLabel.text = collabBlockViewObject.convertTo12Hour(block.endHour, block.endMinute)
            endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 12.5)
        }
    }
}
