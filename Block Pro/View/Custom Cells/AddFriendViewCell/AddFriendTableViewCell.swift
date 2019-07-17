//
//  AddFriendTableViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/14/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class AddFriendTableViewCell: UITableViewCell {

    
    @IBOutlet weak var intialContainer: UIView!
    @IBOutlet weak var friendInitial: UILabel!
    @IBOutlet weak var searchedFriendName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        intialContainer.layer.cornerRadius = 0.5 * intialContainer.bounds.size.width
        intialContainer.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
