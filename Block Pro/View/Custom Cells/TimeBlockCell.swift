//
//  TimeBlockCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class TimeBlockCell: UITableViewCell {

    let cellTimes: [String] = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        configureCellLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellLayout () {
        
        var count: Double = 0
        
        for time in cellTimes {
            
            let textYPosition = 30 + (60 * count)

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

            //contentView.addSubview(timeLabel)


//                    let textCenter = ((120 * count) / 2) - 25
//
//                    let timeLabel = UILabel()
//                    timeLabel.frame = CGRect(x: 0, y: textCenter, width: 50, height: 20)
//                    timeLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
//                    timeLabel.textAlignment = .right
//                    //timeLabel.textColor = UIColor(hexString: "9D9D9D")
//                    timeLabel.text = time
//
//                    let seperatorCenter = timeLabel.center.y - 0.5
//                    let seperatorWidth = contentView.frame.width
//
//                    let seperatorView = UIView()
//                    seperatorView.frame = CGRect(x: 70, y: seperatorCenter, width: seperatorWidth, height: 1)
//                    seperatorView.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.70)
//
//                    contentView.addSubview(timeLabel)
//                    contentView.addSubview(seperatorView)
//
//                    count += 1
            
            
        }
        
//        let textCenter = ((120 * count) / 2) - 25
//
//        let timeLabel = UILabel()
//        timeLabel.frame = CGRect(x: 0, y: textCenter, width: 50, height: 20)
//        timeLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
//        timeLabel.textAlignment = .right
//        //timeLabel.textColor = UIColor(hexString: "9D9D9D")
//        timeLabel.text = time
//
//        let seperatorCenter = timeLabel.center.y - 0.5
//        let seperatorWidth = contentView.frame.width
//
//        let seperatorView = UIView()
//        seperatorView.frame = CGRect(x: 70, y: seperatorCenter, width: seperatorWidth, height: 1)
//        seperatorView.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.70)
//
//        contentView.addSubview(timeLabel)
//        contentView.addSubview(seperatorView)
//
//        count += 1
        
        
    }
    
}
