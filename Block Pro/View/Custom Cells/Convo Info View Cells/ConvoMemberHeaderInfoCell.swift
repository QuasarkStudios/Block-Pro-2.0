//
//  ConvoMemberHeaderInfoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/17/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ConvoMemberHeaderInfoCell: UITableViewCell {

    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var seeAllLabel: UILabel!
    @IBOutlet weak var arrowIndicator: UIImageView!
    
    var membersExpanded: Bool? {
        didSet {
             
            if (membersExpanded ?? false) {
            
                seeAllLabel.text = "See less"
                arrowIndicator.transform = CGAffineTransform(rotationAngle: (-90 * CGFloat.pi) / 180)
            }
            
            else {
                
                seeAllLabel.text = "See all"
                arrowIndicator.transform = CGAffineTransform(rotationAngle: (90 * CGFloat.pi) / 180)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
