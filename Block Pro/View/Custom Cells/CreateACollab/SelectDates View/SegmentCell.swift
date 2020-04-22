//
//  SegmentCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/20/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol SegmentCellProtocol: AnyObject {
    
    func selectedSegment (start: Bool)
}

class SegmentCell: UITableViewCell {

    @IBOutlet weak var startsLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var deadlineLabelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var segmentBackground: UIView!
    @IBOutlet weak var selectedSegmentIndicator: UIView!
    @IBOutlet weak var segmentIndicatorLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var segmentIndicatorWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startsButton: UIButton!
    @IBOutlet weak var startsButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var deadlineButton: UIButton!
    @IBOutlet weak var deadlineButtonWidthConstraint: NSLayoutConstraint!
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    var currentDate: Date = Date()
    
    var selectedStart: [String : Date] = [:]
    var selectedDeadline: [String : Date] = [:]
    
    weak var segmentCellDelegate: SegmentCellProtocol?
    
    var cellInitiallyLoaded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutSubviews()
        
        if !cellInitiallyLoaded {
            
            configureSegmentedControl()
            cellInitiallyLoaded = true
        }
    }
    
    private func configureSegmentedControl() {
        
        startsLabelWidthConstraint.constant = segmentContainer.frame.width / 2
        deadlineLabelWidthConstraint.constant = segmentContainer.frame.width / 2
        
        segmentContainer.layer.cornerRadius = 10
        segmentContainer.clipsToBounds = true
        
        segmentBackground.layer.cornerRadius = 10
        segmentBackground.clipsToBounds = true
        
        segmentIndicatorWidthConstraint.constant = segmentContainer.frame.width / 2
        selectedSegmentIndicator.layer.cornerRadius = 10
        selectedSegmentIndicator.clipsToBounds = true
        
        startsButton.titleLabel?.textAlignment = .center
        
        startsButtonWidthConstraint.constant = segmentContainer.frame.width / 2
        startsButton.layer.cornerRadius = 10
        startsButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        startsButton.clipsToBounds = true
        
        deadlineButton.titleLabel?.textAlignment = .center
        
        deadlineButtonWidthConstraint.constant = segmentContainer.frame.width / 2
        deadlineButton.layer.cornerRadius = 10
        deadlineButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        deadlineButton.clipsToBounds = true
    }
    
    func setStartButtonText () {
        
        if let date = selectedStart["startDate"] {
            
            let suffix = date.daySuffix()
            var dateString: String = ""

            formatter.dateFormat = "MMM d"
            dateString = formatter.string(from: date)
            dateString += suffix

            formatter.dateFormat = ", yyyy"
            dateString += formatter.string(from: date)
            
            formatter.dateFormat = "h:mm a"
            dateString += " \n at \(formatter.string(from: selectedStart["startTime"]!))"

            startsButton.setTitle(dateString, for: .normal)
        }
        
        else {
            
            startsButton.setTitle("Starts", for: .normal)
        }
    }
    
    func setDeadlineButtonText () {
        
        if let date = selectedDeadline["deadlineDate"] {
            
            let suffix = date.daySuffix()
            var dateString: String = ""
            
            formatter.dateFormat = "MMM d"
            dateString = formatter.string(from: date)
            dateString += suffix

            formatter.dateFormat = ", yyyy"
            dateString += formatter.string(from: date)
            
            formatter.dateFormat = "h:mm a"
            dateString += " \n at \(formatter.string(from: selectedDeadline["deadlineTime"]!))"
            
            deadlineButton.setTitle(dateString, for: .normal)
        }
        
        else {
            
            deadlineButton.setTitle("Deadline", for: .normal)
        }
    }
    
    func animateSegmentedControl (starts: Bool) {
        
        if starts {
            
            segmentIndicatorLeadingAnchor.constant = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                self.contentView.layoutIfNeeded()
                
                self.deadlineButton.setTitleColor(.black, for: .normal)
                self.startsButton.setTitleColor(.white, for: .normal)
                
            })
        }
        
        else {
            
            segmentIndicatorLeadingAnchor.constant = segmentContainer.frame.width / 2
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                self.contentView.layoutIfNeeded()
                
                self.deadlineButton.setTitleColor(.white, for: .normal)
                self.startsButton.setTitleColor(.black, for: .normal)
                
            })
        }
    }
    
    @IBAction func startsButton(_ sender: Any) {
        
        animateSegmentedControl(starts: true)
        
        segmentCellDelegate?.selectedSegment(start: true)
    }
    
    
    @IBAction func deadlineButton(_ sender: Any) {
        
        animateSegmentedControl(starts: false)
        
        segmentCellDelegate?.selectedSegment(start: false)
    }
}
