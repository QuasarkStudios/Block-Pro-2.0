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
    
    var gradientLayer: CAGradientLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collabContainer.layer.cornerRadius = 0.06 * collabContainer.bounds.size.width
        collabContainer.clipsToBounds = true
        
        collabWithLabel.adjustsFontSizeToFitWidth = true
        collabNameLabel.adjustsFontSizeToFitWidth = true
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = collabContainer.bounds
        gradientLayer.colors = [UIColor(hexString: "#e35d5b")?.cgColor as Any, UIColor(hexString: "#e53935")?.cgColor as Any]
        
        collabContainer.layer.addSublayer(gradientLayer)
        
        collabContainer.bringSubviewToFront(collabWithLabel)
        collabContainer.bringSubviewToFront(seperatorView)
        collabContainer.bringSubviewToFront(collabNameLabel)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
