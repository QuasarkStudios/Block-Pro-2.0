//
//  CollabReminderCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import BEMCheckBox

class CollabRemindersCell: UITableViewCell {
    
    @IBOutlet weak var reminderContainer: UIView!
    
    @IBOutlet weak var reminderButtonContainer: UIView!
    @IBOutlet weak var reminderContainerWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var checkBoxContainer: UIView!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var noReminderButton: UIButton!
    
    var cellInitiallyLoaded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCheckBox()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutSubviews()
        
        if !cellInitiallyLoaded {
            
            configureReminderContainer()
            cellInitiallyLoaded = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureReminderContainer () {
        
        reminderContainer.backgroundColor = .white
        
        reminderContainerWidthConstraint.constant = reminderContainer.frame.width / 2
        
        reminderButtonContainer.backgroundColor = .white
        reminderButtonContainer.layer.borderWidth = 1
        reminderButtonContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        reminderButtonContainer.layer.cornerRadius = 10
        reminderButtonContainer.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            reminderButtonContainer.layer.cornerCurve = .continuous
        }
        
        checkBoxContainer.backgroundColor = .white
    }
    
    private func configureCheckBox () {
        
        checkBox.onAnimationType = .fill
        checkBox.offAnimationType = .fill

    }
    
    private func animateContainers () {
        
        if checkBox.on {

            reminderContainerWidthConstraint.constant = 0
            
            UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseInOut, animations: {
                
                self.contentView.layoutIfNeeded()
            })
        }

        else {

           reminderContainerWidthConstraint.constant = reminderContainer.frame.width / 2

            UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseInOut, animations: {
                
                self.contentView.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func setReminderButton(_ sender: Any) {
        
        print("set reminder button")
    }
    
    
    @IBAction func checkBox(_ sender: Any) {
        
        animateContainers()
    }
    
    
    @IBAction func noRemindersButton(_ sender: Any) {
        
        checkBox.setOn(!checkBox.on, animated: true)
        
        animateContainers()
    }
}
