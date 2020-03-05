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

    @IBOutlet weak var timePickerContainer: UIView!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    var timeSelectedDelegate: TimeSelected?
    
    let formatter = DateFormatter()
    var currentDate: Date?
    
    var selectedTime: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
//        timePicker.layer.shadowRadius = 2.5
//        timePicker.layer.shadowColor = UIColor.black.cgColor//UIColor(hexString: "39434A")?.cgColor
//        timePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
//        timePicker.layer.shadowOpacity = 0.35
//
//        timePicker.layer.cornerRadius = 3
//        timePicker.layer.masksToBounds = false
//        timePicker.clipsToBounds = false
        
        
        
//        timePickerContainer.layer.shadowRadius = 2.25
//        timePickerContainer.layer.shadowColor = UIColor(hexString: "D8D8D8")?.cgColor
//        timePickerContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
//        timePickerContainer.layer.shadowOpacity = 0.75
//
//        timePickerContainer.layer.cornerRadius = 12
//        timePickerContainer.layer.masksToBounds = false
//        timePickerContainer.clipsToBounds = false
        
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 5
        timePicker.addTarget(self, action: #selector(timeSelected(timePicker:)), for: .allEvents)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func timeSelected (timePicker: UIDatePicker) {


        if selectedTime == "begins" {

            var date: String = ""

            formatter.dateFormat = "MM-dd-yyyy "
            date = formatter.string(from: currentDate!)

            formatter.dateFormat = "HH:mm"
            date += formatter.string(from: timePicker.date)

            formatter.dateFormat = "MM-dd-yyyy HH:mm"

            timeSelectedDelegate?.startTimeSelected(formatter.date(from: date)!)

        }

        else if selectedTime == "ends" {

            var date: String = ""

            formatter.dateFormat = "MM-dd-yyyy "
            date = formatter.string(from: currentDate!)

            formatter.dateFormat = "HH:mm"
            date += formatter.string(from: timePicker.date)

            formatter.dateFormat = "MM-dd-yyyy HH:mm"

            timeSelectedDelegate?.endTimeSelected(formatter.date(from: date)!)
        }

    }
    
}
