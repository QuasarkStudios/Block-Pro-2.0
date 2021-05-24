//
//  ConvoScheduleCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/22/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class ConvoScheduleCollectionViewCell: UICollectionViewCell {
    
    let scheduleImageView = UIImageView(image: UIImage(named: "schedule-1"))
    let dateLabel = UILabel()
    let initialContainer = UIView()
    let initialLabel = UILabel()
    
    var formatter: DateFormatter?
    
    var members: [Member]?
    
    var message: Message? {
        didSet {
            
            if let formatter = formatter, let date = message?.dateForBlocks {
                
                formatter.dateFormat = "M/d/yyyy"
                dateLabel.text = formatter.string(from: date)
                
                setInitialLabel()
            }
        }
    }
    
    weak var scheduleDelegate: ScheduleProtocol?
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureCell()
        configureInitialContainer()
        configureIntialLabel()
        configureScheduleImageView()
        configureDateLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Cell
    
    private func configureCell () {
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
    }
    
    
    //MARK: - Configure Initial Container
    
    private func configureInitialContainer () {
        
        self.contentView.addSubview(initialContainer)
        initialContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            initialContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            initialContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            initialContainer.widthAnchor.constraint(equalToConstant: 25),
            initialContainer.heightAnchor.constraint(equalToConstant: 25)
            
        ].forEach({ $0.isActive = true })
        
        initialContainer.backgroundColor = UIColor(hexString: "222222")
        
        initialContainer.layer.cornerRadius = 12.5
        initialContainer.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        initialContainer.layer.shadowRadius = 1
        initialContainer.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        initialContainer.layer.shadowOpacity = 0.65
    }
    
    
    //MARK: - Configure Initial Label
    
    private func configureIntialLabel () {
        
        initialContainer.addSubview(initialLabel)
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            initialLabel.centerXAnchor.constraint(equalTo: initialContainer.centerXAnchor, constant: 0),
            initialLabel.centerYAnchor.constraint(equalTo: initialContainer.centerYAnchor, constant: 0),
            initialLabel.widthAnchor.constraint(equalToConstant: 15),
            initialLabel.heightAnchor.constraint(equalToConstant: 15)
        
        ].forEach({ $0.isActive = true })
        
        initialLabel.adjustsFontSizeToFitWidth = true
        initialLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
        initialLabel.textAlignment = .center
        initialLabel.textColor = .white
    }
    
    
    //MARK: - Configure Schedule Image View
    
    private func configureScheduleImageView () {
        
        self.contentView.addSubview(scheduleImageView)
        scheduleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            scheduleImageView.widthAnchor.constraint(equalToConstant: itemSize - 50),
            scheduleImageView.heightAnchor.constraint(equalToConstant: itemSize - 50),
            scheduleImageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            scheduleImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -6)
        
        ].forEach({ $0.isActive = true })
        
        scheduleImageView.contentMode = .scaleAspectFill
    }
    
    
    //MARK: - Configure Date Label
    
    private func configureDateLabel () {
        
        self.contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            dateLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            dateLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            dateLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),
            dateLabel.heightAnchor.constraint(equalToConstant: 17)
        
        ].forEach({ $0.isActive = true })
        
        dateLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
        dateLabel.textAlignment = .center
    }

    
    //MARK: - Set Initial Label
    
    private func setInitialLabel () {
        
        if let sender = message?.sender, let member = members?.first(where: { $0.userID == sender }) {
            
            let firstName = Array(member.firstName)
            let lastName = Array(member.lastName)
            
            initialLabel.text = "\(firstName[0])\(lastName[0])"
        }
    }
}
