//
//  UpcomingCollabTableCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/7/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class UpcomingCollabTableCell: UITableViewCell {
    
    @IBOutlet weak var collabNameContainer: UIView!
    @IBOutlet weak var collabNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collabNameContainer.layer.cornerRadius = 0.06 * collabNameContainer.bounds.size.width
        collabNameContainer.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
