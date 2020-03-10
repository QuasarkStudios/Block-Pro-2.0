//
//  BlockTimePickerCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/4/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol TimeSelected {
    
    func startTimeSelected (_ selectedTime: Date)
    
    func endTimeSelected (_ selectedTime: Date)
}

class BlockTimePickerCell: UITableViewCell {

    @IBOutlet weak var timePicker: UIDatePicker!
    
    var timeSelectedDelegate: TimeSelected?
    
    let formatter = DateFormatter()
    
    var currentDate: Date? {
        didSet {
            
            formatter.dateFormat = "yyyy-MM-dd"

            var minimumDate: String = formatter.string(from: currentDate!)
            let minimumTime: String = " 00:00:00"
            minimumDate += minimumTime

            var maximumDate: String = formatter.string(from: currentDate!)
            let maximumTime: String = " 23:55:00"
            maximumDate += maximumTime
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
//            timePicker.minimumDate = formatter.date(from: minimumDate)
//            timePicker.maximumDate = formatter.date(from: maximumDate)
            
            
            
            //print(formatter.date(from: formatter.string(from: currentDate!) + " " + "\(timePicker.date)")!)
            
            formatter.dateFormat = "yyyy-MM-dd"
            var timePickerCurrentDate = formatter.string(from: currentDate!)
            
            timePickerCurrentDate += " "
            
            formatter.dateFormat = "HH:mm"
            timePickerCurrentDate += formatter.string(from: timePicker.date)
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            timePicker.date = formatter.date(from: timePickerCurrentDate)!

        }
    }
    
    var selectedTime: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        timePicker.layer.shadowRadius = 2
        timePicker.layer.shadowColor = /*UIColor.black.cgColor*/UIColor(hexString: "39434A")?.cgColor
        timePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        timePicker.layer.shadowOpacity = 0.35

        timePicker.layer.cornerRadius = 3
        timePicker.layer.masksToBounds = false
        timePicker.clipsToBounds = false

        
        
//        timePicker.datePickerMode = .time
//        timePicker.minuteInterval = 5
        
        
        timePicker.addTarget(self, action: #selector(timeSelected(timePicker:)), for: .allEvents)
        timePicker.date = Date()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func timeSelected (timePicker: UIDatePicker) {
        
        let minimumTime: String = "00:00"
        let maximumTime: String = "23:55"
        
        formatter.dateFormat = "HH:mm"
        
        if selectedTime == "begins" {
            
            if formatter.string(from: timePicker.date) == maximumTime {

                //timePicker.date = (formatter.date(from: maximumDate)?.addingTimeInterval(-300))!
                
                timePicker.date = formatter.date(from: "23:50")!
            }
        
            //timeSelectedDelegate?.startTimeSelected(formatter.date(from: formatter.string(from: timePicker.date))!)
            
            timeSelectedDelegate?.startTimeSelected(timePicker.date)

        }

        else if selectedTime == "ends" {
            
            if formatter.string(from: timePicker.date) == minimumTime {
                
                //timePicker.date = (formatter.date(from: minimumDate)?.addingTimeInterval(300))!
                
                timePicker.date = formatter.date(from: "00:05")!
            }
            
            timeSelectedDelegate?.endTimeSelected(timePicker.date)

        }

    }
    
}
