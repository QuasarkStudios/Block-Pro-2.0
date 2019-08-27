//
//  CollabBlockTableCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/29/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabBlockTableCell: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var initialOutline: UIView!
    @IBOutlet weak var initialContainer: UIView!
    @IBOutlet weak var initialLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    @IBOutlet weak var alphaView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        outlineView.layer.cornerRadius = 0.05 * outlineView.bounds.size.width
//        outlineView.clipsToBounds = true
        
        //cellContainerView.backgroundColor = UIColor.flatWhite
//        cellContainerView.layer.cornerRadius = 0.05 * cellContainerView.bounds.size.width
//        cellContainerView.clipsToBounds = true
        
//        initialOutline.layer.cornerRadius = 0.5 * initialOutline.bounds.size.width
//        initialOutline.clipsToBounds = true
        
//        initialContainer.layer.cornerRadius = 0.5 * initialContainer.bounds.size.width
//        initialContainer.clipsToBounds = true
        
        //nameLabel.adjustsFontSizeToFitWidth = true
        
//        alphaView.layer.cornerRadius = 0.05 * alphaView.bounds.size.width
//        alphaView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
    }
    
}
