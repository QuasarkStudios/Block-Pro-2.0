//
//  ScheduleCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/8/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class ScheduleCollectionViewCell: UICollectionViewCell {
    
    let scheduleContainer = UIView()
    let dateLabel = UILabel()
    
    let shareButton = UIButton(type: .system)
    
    let progressCircle = ProgressCircles(radius: 22.5, lineWidth: 6, strokeColor: UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor, strokeEnd: 0.37)
    let progressLabel = UILabel()
    
    let scheduleStatusLabel = UILabel()
    
    var formatter: DateFormatter?
    
    var dateForCell: Date? {
        didSet {
            
            setDateLabelText()
        }
    }
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureScheduleContainer()
        configureDateLabel()
        
        configureShareButton()
        
        configureProgressCircle()
        configureProgressLabel()
        
        configureScheduleStatusLabel()
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
    
    private func configureDateLabel () {
        
        scheduleContainer.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        [

            dateLabel.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -60),
            dateLabel.topAnchor.constraint(equalTo: scheduleContainer.topAnchor, constant: 12.5),
            dateLabel.heightAnchor.constraint(equalToConstant: 30)
            
        ].forEach({ $0.isActive = true })
        
        dateLabel.font = UIFont(name: "Poppins-SemiBold", size: 21)
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.textColor = .black
        dateLabel.textAlignment = .left
    }
    
    private func configureShareButton () {
        
        scheduleContainer.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            shareButton.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -12.5),
            shareButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor, constant: 0),
            shareButton.widthAnchor.constraint(equalToConstant: 35),
            shareButton.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        shareButton.backgroundColor = UIColor(hexString: "222222")
        
        shareButton.layer.cornerRadius = 17.5
        shareButton.layer.cornerCurve = .continuous
        
        shareButton.tintColor = .white
        shareButton.setImage(UIImage(named: "share"), for: .normal)
        
//        shareButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6.5, bottom: 7, right: 6.5)
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 6.25, left: 6.75, bottom: 7.5, right: 6.75)
    }
    
    private func configureScheduleStatusLabel () {
        
        scheduleContainer.addSubview(scheduleStatusLabel)
        scheduleStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            scheduleStatusLabel.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 20),
            scheduleStatusLabel.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -65),
            scheduleStatusLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 2.5),
            scheduleStatusLabel.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: -7.5),
        
        ].forEach({ $0.isActive = true })
        
        scheduleStatusLabel.numberOfLines = 0
        
        setScheduleStatusLabel()
    }
    
    private func configureProgressCircle () {
        
        scheduleContainer.addSubview(progressCircle)
        progressCircle.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressCircle.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -12.5),
            progressCircle.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: -12.5),
            progressCircle.widthAnchor.constraint(equalToConstant: 45),
            progressCircle.heightAnchor.constraint(equalToConstant: 45)
        
        ].forEach({ $0?.isActive = true })
    }
    
    
    //MARK: - Configure Progress Label
    
    private func configureProgressLabel () {
        
        scheduleContainer.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        [
        
            progressLabel.centerXAnchor.constraint(equalTo: progressCircle.centerXAnchor, constant: 0),
            progressLabel.centerYAnchor.constraint(equalTo: progressCircle.centerYAnchor, constant: 0),
            progressLabel.widthAnchor.constraint(equalToConstant: 27.5),
            progressLabel.heightAnchor.constraint(equalToConstant: 27.5)
        
        ].forEach({ $0.isActive = true })
        
        progressLabel.tag = 1
        progressLabel.font = UIFont(name: "Poppins-SemiBoldItalic", size: 15)
        progressLabel.textColor = .black
        progressLabel.textAlignment = .center
        
        progressLabel.text = "37%"
        
//        if let circle = progressCircle {
//
//            containerView.addSubview(progressLabel)
//            progressLabel.translatesAutoresizingMaskIntoConstraints = false
//
//
//
//            [
//
//                progressLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor, constant: 0),
//                progressLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 0),
//                progressLabel.widthAnchor.constraint(equalToConstant: 25),
//                progressLabel.heightAnchor.constraint(equalToConstant: 25)
//
//            ].forEach({ $0.isActive = true })
//
//            progressLabel.tag = 1
//            progressLabel.font = UIFont(name: "Poppins-Italic", size: 13.5)
//            progressLabel.textColor = .white
//            progressLabel.textAlignment = .center
//        }
    }
    
    private func setDateLabelText () {
        
        if let date = dateForCell, let formatter = formatter {
            
            formatter.dateFormat = "EEEE"
            dateLabel.text = formatter.string(from: date)
        }
    }
    
    private func setScheduleStatusLabel () {
        
        let semiBoldText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let mediumText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 15) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        let attributedString = NSMutableAttributedString(string: "")
        
        attributedString.append(NSAttributedString(string: "Up Next: \n", attributes: semiBoldText))
        
        attributedString.append(NSAttributedString(string: "Meeting with Alex \n", attributes: mediumText))
        
        attributedString.append(NSAttributedString(string: "7:00 PM", attributes: mediumText))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        scheduleStatusLabel.attributedText = attributedString
    }
}
