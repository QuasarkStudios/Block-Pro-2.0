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
        
        let gradientLayer: CAGradientLayer!
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView.frame
        gradientLayer.colors = [UIColor(hexString: "F22613")?.cgColor as Any, UIColor(hexString: "DC281E")?.cgColor as Any]
        gradientLayer.locations = [0.5, 1]

        //contentView.layer.addSublayer(gradientLayer)
        
        dayLabel.backgroundColor = .none
        //dayLabel.textColor = .white
        
//        dateLabel.backgroundColor = UIColor(hexString: "000000", withAlpha: 0.25)
        //dateLabel.textColor = .white
        
        contentView.bringSubviewToFront(dayLabel)
        contentView.bringSubviewToFront(dateLabel)
        
        drawShadow()
    }
    
    func drawShadow () {
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: 188, height: 420)
        
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
