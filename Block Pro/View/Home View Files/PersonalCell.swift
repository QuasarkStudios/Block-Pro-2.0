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
    @IBOutlet weak var cellBackgroundLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var cellBackgroundTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var block1: UIView!
    @IBOutlet weak var block2: UIView!
    @IBOutlet weak var block3: UIView!
    @IBOutlet weak var block4: UIView!
    @IBOutlet weak var block5: UIView!
    @IBOutlet weak var block6: UIView!
    
    @IBOutlet weak var buttonContainer: UIView!
    
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var detailsButtonTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareButtonTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonTopAnchor: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        cellBackgroundTopAnchor.constant = 15
        cellBackgroundBottomAnchor.constant = 75
        cellBackgroundLeadingAnchor.constant = 15
        cellBackgroundTrailingAnchor.constant = 15
        
        cellBackground.drawCellShadow()
        
        blurView.layer.cornerRadius = 20
        blurView.clipsToBounds = true
        
        block1.configureBlocks()
        block2.configureBlocks()
        block3.configureBlocks()
        block4.configureBlocks()
        block5.configureBlocks()
        block6.configureBlocks()
        
        //buttonContainer.backgroundColor = UIColor.white.withAlphaComponent(0)
        buttonContainer.clipsToBounds = true
        
        detailsButton.alpha = 0
        shareButton.alpha = 0
        deleteButton.alpha = 0
        
        detailsButtonTopAnchor.constant = -50
        shareButtonTopAnchor.constant = -50
        deleteButtonTopAnchor.constant = -50
        
        detailsButton.backgroundColor = UIColor.white
        detailsButton.drawButtonShadow()
        
        shareButton.backgroundColor = UIColor(hexString: "A7BFE8")
        shareButton.drawButtonShadow()
        
        deleteButton.drawButtonShadow()
        
        dateLabel.backgroundColor = UIColor.white.withAlphaComponent(0)
        
    }
    
}

extension UIView {
    
    func drawCellShadow () {
        
        layer.shadowRadius = 2.5
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.35
        
        layer.cornerRadius = 20
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    func configureBlocks () {
        
        if tag == 0 {
            
            layer.cornerRadius = 8
        }
        
        else if tag == 1 {
            
            layer.cornerRadius = 9
        }
    }
}

extension UIButton {
    
    func drawButtonShadow () {
        
        layer.shadowRadius = 2.5
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.35
        
        layer.cornerRadius = 0.5 * bounds.size.width
        layer.masksToBounds = false
        clipsToBounds = false
    }
}
