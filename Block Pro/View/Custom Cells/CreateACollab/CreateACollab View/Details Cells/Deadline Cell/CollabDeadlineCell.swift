//
//  CollabDeadlineCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import BEMCheckBox

protocol DeadlineCell: AnyObject {
    
    func moveToCalendarView ()
}

class CollabDeadlineCell: UITableViewCell {
    
    @IBOutlet weak var deadlineContainer: UIView!
    
    @IBOutlet weak var calendarButtonContainer: UIView!
    @IBOutlet weak var calendarContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarButton: UIButton!
    
    @IBOutlet weak var checkBoxContainer: UIView!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var noDeadlineButton: UIButton!
    
    var cellInitiallyLoaded: Bool = false
    
    weak var deadlineCellDelegate: DeadlineCell?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCheckBox()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutSubviews()
        
        if !cellInitiallyLoaded {
            
            configureCalendarContainer()
            cellInitiallyLoaded = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureCalendarContainer () {
        
        deadlineContainer.backgroundColor = .white
        
        calendarContainerWidthConstraint.constant = deadlineContainer.frame.width / 2
        
        calendarButtonContainer.backgroundColor = .white
        calendarButtonContainer.layer.borderWidth = 1
        calendarButtonContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        calendarButtonContainer.layer.cornerRadius = 10
        calendarButtonContainer.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            calendarButtonContainer.layer.cornerCurve = .continuous
        }
        
        checkBoxContainer.backgroundColor = .white
    }
    
    private func configureCheckBox () {
        
        checkBox.onAnimationType = .fill
        checkBox.offAnimationType = .fill
    }
    
    private func animateContainers () {
        
        if checkBox.on {

            calendarContainerWidthConstraint.constant = 0
            
            UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseInOut, animations: {
                
                self.contentView.layoutIfNeeded()
            })
        }

        else {

            calendarContainerWidthConstraint.constant = deadlineContainer.frame.width / 2

            UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseInOut, animations: {
                
                self.contentView.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func calendarButton(_ sender: Any) {
        
        deadlineCellDelegate?.moveToCalendarView()
    }
    
    @IBAction func checkBox(_ sender: Any) {
        
        animateContainers()
    }
    
    @IBAction func noDeadlineButton(_ sender: Any) {
        
        checkBox.setOn(!checkBox.on, animated: true)
        
        animateContainers()
    }
    
}
