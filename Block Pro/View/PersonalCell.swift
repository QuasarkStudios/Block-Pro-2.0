//
//  PersonalCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class PersonalCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gradientLayer: CAGradientLayer!
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView.frame
        gradientLayer.colors = [UIColor(hexString: "F22613")?.cgColor as Any, UIColor(hexString: "DC281E")?.cgColor as Any]
        gradientLayer.locations = [0.5, 1]

        contentView.layer.addSublayer(gradientLayer)
        
        contentView.bringSubviewToFront(dayLabel)
        contentView.bringSubviewToFront(dateLabel)
        
        dayLabel.backgroundColor = .none
        dayLabel.textColor = .white
        
        dateLabel.backgroundColor = UIColor(hexString: "000000", withAlpha: 0.25)
        dateLabel.textColor = .white
    }

}
