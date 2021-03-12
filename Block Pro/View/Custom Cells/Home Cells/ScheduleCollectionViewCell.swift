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
    
    let progressCircle = ProgressCircles(radius: 20, lineWidth: 6, strokeColor: UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor, strokeEnd: 0.37)
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
    
//    private func configureDateLabel () {
//
//        scheduleContainer.addSubview(dateLabel)
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        [
//
//            dateLabel.topAnchor.constraint(equalTo: scheduleContainer.topAnchor, constant: 12.5),
//            dateLabel.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: -8.5),
//            dateLabel.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 12.5),
//            dateLabel.widthAnchor.constraint(equalToConstant: 52.5)
//
//        ].forEach({ $0.isActive = true })
//
//        dateLabel.numberOfLines = 3
//    }
    
    private func configureDateLabel () {
        
        scheduleContainer.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        [

            dateLabel.topAnchor.constraint(equalTo: scheduleContainer.topAnchor, constant: 12.5),
            dateLabel.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 12.5),
            dateLabel.widthAnchor.constraint(equalToConstant: 38),
            dateLabel.heightAnchor.constraint(equalToConstant: 38)
            
        ].forEach({ $0.isActive = true })
        
        dateLabel.backgroundColor = UIColor(hexString: "222222")
        dateLabel.layer.cornerRadius = 19
        dateLabel.clipsToBounds = true
        
        dateLabel.font = UIFont(name: "Poppins-Medium", size: 18)
        dateLabel.textColor = .white
        dateLabel.textAlignment = .center
    }
    
    private func configureShareButton () {
        
        scheduleContainer.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            shareButton.topAnchor.constraint(equalTo: scheduleContainer.topAnchor, constant: 11),
            shareButton.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -10),
//            shareButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor, constant: -4),
            shareButton.widthAnchor.constraint(equalToConstant: 32),
            shareButton.heightAnchor.constraint(equalToConstant: 32)
        
        ].forEach({ $0.isActive = true })
        
        shareButton.tintColor = .black
        shareButton.setImage(UIImage(named: "share"), for: .normal)
    }
    
    private func configureProgressCircle () {
        
        scheduleContainer.addSubview(progressCircle)
        progressCircle.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressCircle.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -12.5),
            progressCircle.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: -12.5),
            progressCircle.widthAnchor.constraint(equalToConstant: 40),
            progressCircle.heightAnchor.constraint(equalToConstant: 40)
        
        ].forEach({ $0?.isActive = true })
    }
    
    
    //MARK: - Configure Progress Label
    
    private func configureProgressLabel () {
        
        scheduleContainer.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        [
        
            progressLabel.centerXAnchor.constraint(equalTo: progressCircle.centerXAnchor, constant: 0),
            progressLabel.centerYAnchor.constraint(equalTo: progressCircle.centerYAnchor, constant: 0),
            progressLabel.widthAnchor.constraint(equalToConstant: 25),
            progressLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        progressLabel.tag = 1
        progressLabel.font = UIFont(name: "Poppins-Italic", size: 13.5)
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
    
    private func configureScheduleStatusLabel () {
        
        scheduleContainer.addSubview(scheduleStatusLabel)
        scheduleStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            scheduleStatusLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 10),
            scheduleStatusLabel.trailingAnchor.constraint(equalTo: progressCircle.leadingAnchor, constant: -10),
            scheduleStatusLabel.topAnchor.constraint(equalTo: scheduleContainer.topAnchor, constant: 10),
            scheduleStatusLabel.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: -10),
//            scheduleStatusLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40 - 12.5 - 52.5 - 10 - 10 - 40 - 12.5),
//            scheduleStatusLabel.centerXAnchor.constraint(equalTo: scheduleContainer.centerXAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        scheduleStatusLabel.numberOfLines = 0
        
        setScheduleStatusLabel()
    }
    
    private func setDateLabelText () {
        
        if let date = dateForCell, let formatter = formatter {
            
            formatter.dateFormat = "EEEE"
            
            if formatter.string(from: date) == "Tuesday" {
                
                dateLabel.text = "Tu"
            }
            
            else if formatter.string(from: date) == "Thursday" {
                
                dateLabel.text = "Th"
            }
            
            else {
                
                formatter.dateFormat = "EEEEE"
                dateLabel.text = formatter.string(from: date)
            }
            
//            let largerText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 18) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
//            let regularText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 16) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
//            let attributedString = NSMutableAttributedString(string: "")
//
//            formatter.dateFormat = "E"
//            attributedString.append(NSAttributedString(string: formatter.string(from: date) + "\n", attributes: largerText))
//
//            formatter.dateFormat = "d"
//            attributedString.append(NSAttributedString(string: formatter.string(from: date) + "\n", attributes: largerText))
//
//            formatter.dateFormat = "MMMM"
//            let monthText = Array(formatter.string(from: date))
//
//            if monthText.count > 5 {
//
//                formatter.dateFormat = "MMM"
//                attributedString.append(NSAttributedString(string: formatter.string(from: date), attributes: regularText))
//            }
//
//            else {
//
//                attributedString.append(NSAttributedString(string: formatter.string(from: date), attributes: regularText))
//            }
//
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.alignment = .center
//            paragraphStyle.lineHeightMultiple = 0.85
//            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
//
//            dateLabel.attributedText = attributedString
        }
    }
    
    private func setScheduleStatusLabel () {
        
        let semiBoldText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let mediumText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 15) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let attributedString = NSMutableAttributedString(string: "")
        
        attributedString.append(NSAttributedString(string: "Up Next: \n", attributes: semiBoldText))
        
        attributedString.append(NSAttributedString(string: "Meeting with Alex \n", attributes: mediumText))
        
        attributedString.append(NSAttributedString(string: "7:00 PM", attributes: mediumText))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        scheduleStatusLabel.attributedText = attributedString
    }
}
