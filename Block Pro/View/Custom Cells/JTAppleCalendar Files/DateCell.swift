//
//  DateCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/22/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var singleSelectionView: UIView!
    
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var dotViewBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var rangeSelectionView: UIView!
    @IBOutlet weak var rangeViewLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var rangeViewTrailingAnchor: NSLayoutConstraint!
}
