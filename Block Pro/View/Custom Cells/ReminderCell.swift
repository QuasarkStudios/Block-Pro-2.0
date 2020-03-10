//
//  ReminderCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/6/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ReminderCell: UICollectionViewCell {

    @IBOutlet weak var reminderLabel: UILabel!
    
    var item: Int? {
        didSet {
            
            configureLabel(item!)
        }
    }
    
    var cellSelected: Bool? {
        didSet {
            
            if cellSelected! == true {
                
                reminderLabel.backgroundColor = UIColor.flatRed()
            }
            
            else {
                
                reminderLabel.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.5)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    private func configureLabel (_ item: Int) {
        
        
        
//        if cellSelected == true {
//            
//            reminderLabel.backgroundColor = UIColor.flatRed()
//        }
//        
//        else {
//            
//            reminderLabel.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.5)
//        }
        
        reminderLabel.layer.cornerRadius = 5
        reminderLabel.clipsToBounds = true
        
        //reminderLabel.adjustsFontSizeToFitWidth = true
        
        switch item {
            
        case 0:
            
            reminderLabel.text = "5  minutes \n before"
        
        case 1:
            
            reminderLabel.text = "10  minutes \n before"
       
        case 2:
            
            reminderLabel.text = "15  minutes \n before"
        
        case 3:
            
            reminderLabel.text = "30  minutes \n before"
        
        case 4:
            
            reminderLabel.text = "45  minutes \n before"
        
        case 5:
            
            reminderLabel.text = "1  hour \n before"
        
        case 6:
            
            reminderLabel.text = "2  hours \n before"
            
        default:
            break
        }
    }
    
}
