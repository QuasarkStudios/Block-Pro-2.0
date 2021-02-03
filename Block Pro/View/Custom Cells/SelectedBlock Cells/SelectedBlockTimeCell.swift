//
//  SelectedBlockTimeCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/22/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class SelectedBlockTimeCell: UITableViewCell {

    let timeLabel = UILabel()
    
    var formatter: DateFormatter?
    
    var starts: Date?
    var ends: Date? {
        didSet {
            
            setTimeLabel()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "selectedBlockNameCell")
        
        configureTimeLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTimeLabel () {
        
        self.contentView.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            timeLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            timeLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
            timeLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            timeLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        timeLabel.numberOfLines = 0
    }
    
    private func setTimeLabel () {
        
        if starts != nil, ends != nil, formatter != nil {
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left

            let dateText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 20) as Any, NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.paragraphStyle : paragraphStyle]
            let timeText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray, NSAttributedString.Key.paragraphStyle : paragraphStyle]
            let attributedString = NSMutableAttributedString(string: "")

            formatter!.dateFormat = "EEEE, MMMM d"
            attributedString.append(NSAttributedString(string: formatter!.string(from: starts!), attributes: dateText))
            attributedString.append(NSAttributedString(string: starts!.daySuffix(), attributes: dateText))
            
            attributedString.append(NSAttributedString(string: "\n"))

            formatter!.dateFormat = "h:mm a"
            attributedString.append(NSAttributedString(string: formatter!.string(from: starts!), attributes: timeText))
            attributedString.append(NSAttributedString(string: " - ", attributes: timeText))
            attributedString.append(NSAttributedString(string: formatter!.string(from: ends!), attributes: timeText))
            
            timeLabel.attributedText = attributedString
        }
    }
}
