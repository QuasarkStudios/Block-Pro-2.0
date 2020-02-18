//
//  TimeBlockCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class TimeBlockCell: UITableViewCell {

    var personalDatabase: PersonalRealmDatabase? {
        didSet {
            configureBlocks()
        }
    }
    
    let formatter = DateFormatter()
    
    let cellTimes: [String] = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]
    

    var blockRects: [CGRect] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        configureCellBackground()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        
        //print(personalDatabase)
        
    }
    
    func configureBlocks() {
        
        var blockConfiguration: [String : Any] = [:]
        
        if personalDatabase?.blockArray != nil {
            
            for block1 in personalDatabase!.blockArray! {
                
                var timeConflicts: Int = 0
                
                for block2 in personalDatabase!.blockArray! {
                    
                    if block1 != block2 {
                        
                        var count: Double = 0
                        var currentBlockDate: Date = block2.begins
                        
                        while currentBlockDate <= block2.ends {
                            
                            if currentBlockDate.isBetween(startDate: block1.begins, endDate: block1.ends) {
                                
                                timeConflicts += 1
                                break
                            }
                            
                            else {
                                
                                currentBlockDate = currentBlockDate.addingTimeInterval(300 * count)
                                count += 1
                            }
                        }
                        
                    }
                    
                }
                
                print(timeConflicts)
                
                formatter.dateFormat = "HH"
                let startHour: Double = Double(formatter.string(from: block1.begins))!
                let totalHours: Double = Double(formatter.string(from: block1.ends))! - Double(formatter.string(from: block1.begins))!
                
                formatter.dateFormat = "mm"
                let startMinutes: Double = Double(formatter.string(from: block1.begins))!
                let totalMinutes: Double = Double(formatter.string(from: block1.ends))! - Double(formatter.string(from: block1.begins))!
                
                let blockYCoordinate: CGFloat = CGFloat(((startHour * 90) + (startMinutes * 1.5)) + 50)
                let blockHeight: CGFloat = CGFloat(((totalHours * 90) + (totalMinutes * 1.5)))
                let blockWidth = (UIScreen.main.bounds.width - 75) - 7.5
                
                
                //print(hour, minute)
                
                //blockRects[count] = CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
                
                let testView = FullBlock()
                testView.frame = CGRect(x: 77.5, y: blockYCoordinate, width: blockWidth, height: blockHeight)
                print("frame: ", testView.frame)
                
                testView.block = block1
                
                //testView.backgroundColor = UIColor(hexString: "5065A0", withAlpha: 0.80)
                
//                testView.font = UIFont(name: "Poppins-SemiBold", size: 17)
//                testView.text = block1.name
//                testView.textColor = .white
                
//                testView.layer.cornerRadius = 12
//                testView.clipsToBounds = true
                
                contentView.addSubview(testView)
                

            }
            
        }

    }
    
}

extension Date {
    
    func isBetween (startDate: Date, endDate: Date) -> Bool {
        
        return (min(startDate, endDate) ... max(startDate, endDate)).contains(self)
    }
}
