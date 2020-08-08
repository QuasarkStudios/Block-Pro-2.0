//
//  ConvoPhotoHeaderInfoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/9/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ConvoPhotosHeaderInfoCell: UITableViewCell {

    @IBOutlet weak var seeAllLabel: UILabel!
    @IBOutlet weak var seeAllArrow: UIImageView!
    
    var photoMessageCount: Int? {
        didSet {
            
            if let count = photoMessageCount, count > 6 {
                
                seeAllLabel.isHidden = false
                seeAllArrow.isHidden = false
            }
            
            else {
                
                seeAllLabel.isHidden = true
                seeAllArrow.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
