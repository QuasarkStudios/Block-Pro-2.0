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
    
    @IBOutlet weak var dateLabel: UILabel! //Date label for the day cell in the UICollectionView
    
    @IBOutlet weak var selectedView: UIView!
}
