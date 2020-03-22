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
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var detailsButtonTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var detailsButtonCenterXAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonCenterXAnchor: NSLayoutConstraint!
    
    let personalDatabase = PersonalRealmDatabase.sharedInstance
    
    var currentDate: Date? {
        didSet {
            
            _ = personalDatabase.findTimeBlocks(currentDate!)
            
            configureBlocks()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        cellBackgroundTopAnchor.constant = 30
        cellBackgroundBottomAnchor.constant = 75
        cellBackgroundLeadingAnchor.constant = 15
        cellBackgroundTrailingAnchor.constant = 15
        
        cellBackground.drawCellShadow()

        detailsButton.alpha = 0
        shareButton.alpha = 0
        deleteButton.alpha = 0
        
        detailsButton.backgroundColor = .black//UIColor.white
        detailsButton.drawButtonShadow()
        
        shareButton.backgroundColor = UIColor(hexString: "A7BFE8")
        shareButton.drawButtonShadow()
        
        deleteButton.drawButtonShadow()
    }
    
    private func configureBlocks () {
        
        //print(currentDate)
        
        var count: Int = 0
        
        if let blockArray = personalDatabase.blockArray {
            
            for block in blockArray {
                
                //print(block.name)
                
                count += 1
            }
        }
        
        //print("\n")

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
    
    func configureBackgroundBlocks () {
        
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
