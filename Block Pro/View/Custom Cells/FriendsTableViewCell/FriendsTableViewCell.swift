//
//  FriendsTableViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/8/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var friendsName: UILabel!
    @IBOutlet weak var collabNumberContainer: UIView!
    @IBOutlet weak var collabNumber: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collabNumberContainer.layer.cornerRadius = 0.5 * collabNumberContainer.bounds.size.width
        collabNumberContainer.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
