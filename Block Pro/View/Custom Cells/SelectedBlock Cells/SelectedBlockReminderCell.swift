//
//  SelectedBlockReminderCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/23/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class SelectedBlockReminderCell: UITableViewCell {

    let reminderLabel = UILabel()
    
    let calendar = Calendar.current
    var formatter: DateFormatter?
    
    var block: Block? {
        didSet {
            
            setReminderLabel(block?.reminders)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "selectedBlockReminderCell")
        
        configureReminderLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureReminderLabel () {
        
        self.contentView.addSubview(reminderLabel)
        reminderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            reminderLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            reminderLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
            reminderLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            reminderLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        reminderLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setReminderLabel (_ reminders: [Int]?) {
        
        if formatter != nil {
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            let semiBoldText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: reminders?.count ?? 0 > 0 ? 15.5 : 16.5) as Any, NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.paragraphStyle : paragraphStyle]
            let regularText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 15) as Any, NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.paragraphStyle : paragraphStyle]
            
            let attributedString = NSMutableAttributedString(string: "")
            
            formatter!.dateFormat = "h:mm a"

            if reminders?.count ?? 0 == 0 {

                attributedString.append(NSAttributedString(string: "No Reminders Yet", attributes: semiBoldText))
            }

            else if reminders?.count ?? 0 == 1 {

                attributedString.append(NSAttributedString(string: "Remind me at: ", attributes: semiBoldText))

                if let time = block?.starts, let reminderTime = calendar.date(byAdding: .minute, value: minutesToSubtractBy[reminders![0]], to: time) {

                    attributedString.append(NSAttributedString(string: formatter!.string(from: reminderTime), attributes: regularText))
                }
            }

            else if reminders?.count ?? 0 == 2 {

                attributedString.append(NSAttributedString(string: "Remind me at: ", attributes: semiBoldText))

                let sortedReminders = reminders!.sorted() //Sorting the reminders

                if let time = block?.starts, let firstReminder = calendar.date(byAdding: .minute, value: minutesToSubtractBy[sortedReminders[1]], to: time), let secondReminder = calendar.date(byAdding: .minute, value: minutesToSubtractBy[sortedReminders[0]], to: time) {

                    attributedString.append(NSAttributedString(string: formatter!.string(from: firstReminder) + " and " + formatter!.string(from: secondReminder), attributes: regularText))
                }
            }

            reminderLabel.attributedText = attributedString
        }
    }
}
