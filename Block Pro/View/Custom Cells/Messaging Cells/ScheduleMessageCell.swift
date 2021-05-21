//
//  ScheduleMessageCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/19/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class ScheduleMessageCell: UITableViewCell {
    
    let scheduleContainer = UIView()
    let scheduleImageView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "scheduleMessageCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureScheduleContainer () {
        
        self.contentView.addSubview(scheduleContainer)
        scheduleContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            scheduleContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            scheduleContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            scheduleContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            scheduleContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            
        ].forEach({ $0.isActive = true })
        
        scheduleContainer.backgroundColor = .white
        
        scheduleContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        scheduleContainer.layer.borderWidth = 1

        scheduleContainer.layer.cornerRadius = 10
        scheduleContainer.layer.cornerCurve = .continuous
        scheduleContainer.clipsToBounds = true
    }
    
    private func configureScheduleImageView () {
        
        
    }

}
