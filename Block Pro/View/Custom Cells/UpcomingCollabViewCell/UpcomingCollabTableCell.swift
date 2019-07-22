//
//  UpcomingCollabTableCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/7/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class UpcomingCollabTableCell: UITableViewCell {
    
    @IBOutlet weak var collabContainer: UIView!
    @IBOutlet weak var collabWithLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var collabNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collabContainer.layer.cornerRadius = 0.06 * collabContainer.bounds.size.width
        collabContainer.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
