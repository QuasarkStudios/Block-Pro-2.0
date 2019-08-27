//
//  CustomBlockTableCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/19/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import ChameleonFramework

class CustomBlockTableCell: UITableViewCell {

    @IBOutlet weak var cellContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    
    @IBOutlet weak var alphaView: UIView!

    @IBOutlet weak var note1TextView: UITextView!
    @IBOutlet weak var note2TextView: UITextView!
    @IBOutlet weak var note3TextView: UITextView!
    
    
    @IBOutlet weak var note1Bullet: UIView!
    @IBOutlet weak var note2Bullet: UIView!
    @IBOutlet weak var note3Bullet: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellContainerView.backgroundColor = UIColor.flatMint
        cellContainerView.layer.cornerRadius = 0.05 * cellContainerView.bounds.size.width
        cellContainerView.clipsToBounds = true
        
//        self.cellContainerView.bringSubviewToFront(startLabel)
//        self.cellContainerView.bringSubviewToFront(toLabel)
//        self.cellContainerView.bringSubviewToFront(endLabel)
        
//        self.cellContainerView.bringSubviewToFront(note1TextView)
//        self.cellContainerView.bringSubviewToFront(note2TextView)
//        self.cellContainerView.bringSubviewToFront(note3TextView)
        
        //alphaView.layer.cornerRadius = 0.05 * alphaView.bounds.size.width
        alphaView.clipsToBounds = true
        
        note1TextView.backgroundColor = UIColor.flatWhite
        note1TextView.layer.cornerRadius = 0.05 * note1TextView.bounds.size.width
        note1TextView.clipsToBounds = true
        
        note2TextView.backgroundColor = UIColor.flatWhite
        note2TextView.layer.cornerRadius = 0.05 * note2TextView.bounds.size.width
        note2TextView.clipsToBounds = true
        
        note3TextView.backgroundColor = UIColor.flatWhite
        note3TextView.layer.cornerRadius = 0.05 * note3TextView.bounds.size.width
        note3TextView.clipsToBounds = true
        
        note1Bullet.layer.cornerRadius = 0.5 * note1Bullet.bounds.size.width
        note1Bullet.clipsToBounds = true
        
        note2Bullet.layer.cornerRadius = 0.5 * note2Bullet.bounds.size.width
        note2Bullet.clipsToBounds = true
        
        note3Bullet.layer.cornerRadius = 0.5 * note3Bullet.bounds.size.width
        note3Bullet.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
