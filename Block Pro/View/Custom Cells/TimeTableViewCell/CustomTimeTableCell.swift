//
//  CustomTimeTableCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/18/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class CustomTimeTableCell: UITableViewCell {

    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cellSeperator: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeLabel.frame.origin.y += 20.25
        cellSeperator.frame.origin.y += 89.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
