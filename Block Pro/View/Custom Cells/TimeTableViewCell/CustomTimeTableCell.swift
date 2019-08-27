//
//  CustomTimeTableCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/18/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class CustomTimeTableCell: UITableViewCell {

    
    @IBOutlet weak var timeLabelContainer: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cellSeperator: UIView!
    @IBOutlet weak var cellContentView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeLabelContainer.layer.cornerRadius = 0.135 * timeLabelContainer.bounds.size.width
        timeLabelContainer.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
