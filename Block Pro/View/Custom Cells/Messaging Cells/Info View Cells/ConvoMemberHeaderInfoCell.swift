//
//  ConvoMemberHeaderInfoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/17/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ConvoMemberHeaderInfoCell: UITableViewCell {

    @IBOutlet weak var seeAllLabel: UILabel!
    @IBOutlet weak var arrowIndicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        arrowIndicator.transform = CGAffineTransform(rotationAngle: (90 * CGFloat.pi) / 180)
    }
    
    func transformArrow (expand: Bool) {
        
        if expand {
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.arrowIndicator.transform = CGAffineTransform(rotationAngle: (-90 * CGFloat.pi) / 180)
                
            }, completion: nil)
        }
        
        else {
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.arrowIndicator.transform = CGAffineTransform(rotationAngle: (90 * CGFloat.pi) / 180)
                
            }, completion: nil)
        }
    }
}
