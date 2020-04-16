//
//  AddMembersCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/12/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class MembersTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicContainer: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addedIndicator: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePicContainer.configureProfilePicContainer()
        
        addedIndicator.layer.cornerRadius = 0.21 * addedIndicator.frame.width
        addedIndicator.clipsToBounds = true
        addedIndicator.isHidden = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
