//
//  CollabBlocksTableViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabBlocksTableViewCell: UITableViewCell {

    let cellTimes: [String] = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCellBackground()
    }

    func configureCellBackground () {
        
        var count: Double = 0
        
        for time in cellTimes {
            
            let textYPosition = 40 + (90 * count)

            let timeLabel = UILabel()
            timeLabel.frame = CGRect(x: 0, y: textYPosition, width: 50, height: 20)
            timeLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
            timeLabel.textAlignment = .right
            //timeLabel.textColor = UIColor(hexString: "9D9D9D")
            timeLabel.text = time

            let seperatorCenter = timeLabel.center.y - 0.5
            let seperatorWidth = contentView.frame.width

            let seperatorView = UIView()
            seperatorView.frame = CGRect(x: 70, y: seperatorCenter, width: seperatorWidth, height: 1)
            seperatorView.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.70)

            contentView.addSubview(timeLabel)
            contentView.addSubview(seperatorView)
            
            count += 1

        }
    }
    
}
