//
//  PersonalCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class PersonalCell: UICollectionViewCell {

    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        drawShadow()
    }
    
    func drawShadow () {
        
        let shadowLayer: CAShapeLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: cellBackground.bounds, cornerRadius: 20).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        
        shadowLayer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0, height: 2)
        shadowLayer.shadowOpacity = 0.35
        shadowLayer.shadowRadius = 2.5
        
        cellBackground.layer.masksToBounds = false
        cellBackground.layer.insertSublayer(shadowLayer, at: 0)
    }

}
