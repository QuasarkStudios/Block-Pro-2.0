//
//  DeleteBlockCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/6/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class DeleteBlockCell: UITableViewCell {

    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var deleteLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackground.backgroundColor = UIColor.flatRed()
        
        cellBackground.layer.cornerRadius = 8
        cellBackground.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
