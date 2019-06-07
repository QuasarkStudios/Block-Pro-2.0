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
    @IBOutlet weak var cellContentView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //timeLabel.frame.origin = cellContentView.center
        
        //timeLabel.frame.origin.x += 3
        //cellSeperator.frame.origin.y += 3.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
