//
//  DateCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/19/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dotView: UIView!
    
    @IBOutlet weak var singleSelectionView: UIView!
    
    @IBOutlet weak var rangeSelectionView: UIView!
    @IBOutlet weak var rangeViewLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var rangeViewTrailingAnchor: NSLayoutConstraint!
    
    
    @IBOutlet weak var selectedViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedViewHeightConstraint: NSLayoutConstraint!
}
