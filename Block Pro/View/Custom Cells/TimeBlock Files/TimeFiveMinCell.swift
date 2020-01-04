//
//  TimeFiveMinCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/14/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation
import ChameleonFramework

class TimeFiveMinCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
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
            containerView.layer.cornerRadius = 0.013 * containerView.bounds.size.width
            containerView.clipsToBounds = true
            
            nameLabel.text = block.name
            nameLabel.font = UIFont(name: "HelveticaNeue", size: 10.5)
            nameLabel.textColor = ContrastColorOf(blockColor, returnFlat: false)
            
        }
    }
}
