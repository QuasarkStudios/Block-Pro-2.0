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
    
    @IBOutlet weak var cellBackgroundTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var cellBackgroundBottomAnchor: NSLayoutConstraint!
    
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    let shadowLayer: CAShapeLayer = CAShapeLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        //original height is 420
        
        cellBackgroundBottomAnchor.constant = 75
        
        
        cellBackground.drawShadow()
        
        //drawShadow()
    }
    
//    func drawShadow () {
//
//        let shadowRect: CGRect = CGRect(x: 0, y: 0, width: cellBackground.frame.width, height: 350)
//        shadowLayer.path = UIBezierPath(roundedRect: shadowRect, cornerRadius: 20).cgPath
//        shadowLayer.fillColor = UIColor.white.cgColor
//
//        shadowLayer.shadowColor = UIColor(hexString: "39434A")?.cgColor
//        shadowLayer.shadowPath = shadowLayer.path
//        shadowLayer.shadowOffset = CGSize(width: 0, height: 2)
//        shadowLayer.shadowOpacity = 0.35
//        shadowLayer.shadowRadius = 2.5
//
//        cellBackground.layer.masksToBounds = false
//        cellBackground.layer.insertSublayer(shadowLayer, at: 0)
//
//
//    }

}

extension UIView {
    
    func drawShadow () {
        
        layer.shadowRadius = 2.5
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.35
        
        layer.cornerRadius = 20
        layer.masksToBounds = false
        clipsToBounds = false
    }
}
