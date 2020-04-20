//
//  MembersCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/13/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class MembersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profilePicContainer: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var memberNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowRadius = 2
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.35
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        layer.cornerRadius = 8
        layer.masksToBounds = false
        
        profilePicContainer.configureProfilePicContainer()
    }
}
