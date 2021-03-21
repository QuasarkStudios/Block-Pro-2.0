//
//  ScheduleCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/8/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import BEMCheckBox

class ScheduleCollectionViewCell: UICollectionViewCell {
    
    let scheduleContainer = UIView()
    let dateLabel = UILabel()
    
    let shareButton = UIButton(type: .system)
    
    var progressCircle: ProgressCircles?//
    let progressLabel = UILabel()
    let checkBox = BEMCheckBox()
    
    let scheduleStatusLabel = UILabel()
    let noStatusImageView = UIImageView()
    
    var formatter: DateFormatter?
    
    var dateForCell: Date? {
        didSet {
            
            setDateLabelText()
        }
    }
    
    var blocksForDate: [Block]? {
        didSet {
            
            setScheduleStatusLabel()
            setNoStatusImageView()
            
            configureProgressCircle()
            configureProgressLabel()
            configureCheckBox()
        }
    }
    
    var scheduleLabelTopAnchor: NSLayoutConstraint?
    var scheduleLabelHeightConstraint: NSLayoutConstraint?
    
    var imageViewLeadingAnchor: NSLayoutConstraint?
    var imageViewBottomAnchor: NSLayoutConstraint?
    var imageViewWidthConstraint: NSLayoutConstraint?
    var imageViewHeightConstraint: NSLayoutConstraint?
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureScheduleContainer()
        configureDateLabel()
        
        configureShareButton()
        
        configureScheduleStatusLabel()
        configureNoStatusImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Schedule Container
    
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
    
    
    //MARK: - Configure Date Label
    
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
    
    
    //MARK: - Configure Share Button
    
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
        
//        shareButton.imageEdgeInsets = UIEdgeInsets(top: 6.25, left: 6.75, bottom: 7.5, right: 6.75)
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 6.25, left: 7, bottom: 8, right: 7)
    }
    
    
    //MARK: - Configure Schedule Status Label
    
    private func configureScheduleStatusLabel () {
        
        scheduleContainer.addSubview(scheduleStatusLabel)
        scheduleStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            scheduleStatusLabel.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 20),
            scheduleStatusLabel.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -65),
        
        ].forEach({ $0.isActive = true })
        
        scheduleLabelTopAnchor = scheduleStatusLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 6)
        scheduleLabelTopAnchor?.isActive = true
        
        scheduleLabelHeightConstraint = scheduleStatusLabel.heightAnchor.constraint(equalToConstant: 77)
        scheduleLabelHeightConstraint?.isActive = true
        
        scheduleStatusLabel.numberOfLines = 0
    }
    
    
    //MARK: - Configure Image View
    
    private func configureNoStatusImageView () {
        
        scheduleContainer.addSubview(noStatusImageView)
        noStatusImageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageViewLeadingAnchor = noStatusImageView.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 28.5)
        imageViewBottomAnchor = noStatusImageView.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: 1)
        imageViewWidthConstraint = noStatusImageView.widthAnchor.constraint(equalToConstant: 70)
        imageViewHeightConstraint = noStatusImageView.heightAnchor.constraint(equalToConstant: 65)
        
        imageViewLeadingAnchor?.isActive = true
        imageViewBottomAnchor?.isActive = true
        imageViewWidthConstraint?.isActive = true
        imageViewHeightConstraint?.isActive = true
        
        noStatusImageView.contentMode = .scaleAspectFill
    }
    
    
    //MARK: Configure Progress Circle
    
    private func configureProgressCircle () {
        
        if progressCircle?.superview == nil {
            
            progressCircle = ProgressCircles(radius: 23, lineWidth: 6, strokeColor: calculateProgress() != 1 ? UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor : UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor, strokeEnd: calculateProgress())
            
            scheduleContainer.addSubview(progressCircle!)
            progressCircle!.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                progressCircle!.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -12.5),
                progressCircle!.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: -12.5),
                progressCircle!.widthAnchor.constraint(equalToConstant: 45),
                progressCircle!.heightAnchor.constraint(equalToConstant: 45)
            
            ].forEach({ $0?.isActive = true })
        }
        
        else {
            
            progressCircle?.shapeLayer.strokeEnd = calculateProgress()
            progressCircle?.shapeLayer.strokeColor = calculateProgress() != 1 ? UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor : UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor
        }
    }
    
    
    //MARK: - Configure Progress Label
    
    private func configureProgressLabel () {
        
        if let circle = progressCircle, progressLabel.superview == nil {

            scheduleContainer.addSubview(progressLabel)
            progressLabel.translatesAutoresizingMaskIntoConstraints = false



            [

                progressLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor, constant: 0),
                progressLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 0),
                progressLabel.widthAnchor.constraint(equalToConstant: 30),
                progressLabel.heightAnchor.constraint(equalToConstant: 30)

            ].forEach({ $0.isActive = true })

            progressLabel.font = UIFont(name: "Poppins-SemiBoldItalic", size: 15)
            progressLabel.textColor = .black
            progressLabel.textAlignment = .center
        }
        
        if calculateProgress() != 1 {
            
            progressLabel.isHidden = false
            
            let completedPercentage = round((Double(calculateProgress()) * 100))
            progressLabel.text = "\(Int(completedPercentage))%"
        }
        
        else {
            
            progressLabel.isHidden = true
        }
    }
    
    
    //MARK: - Configure Check Box
    
    private func configureCheckBox () {
        
        if let circle = progressCircle, checkBox.superview == nil {
            
            scheduleContainer.addSubview(checkBox)
            checkBox.translatesAutoresizingMaskIntoConstraints = false
            
            [

                checkBox.centerXAnchor.constraint(equalTo: circle.centerXAnchor, constant: 0),
                checkBox.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 0),
                checkBox.widthAnchor.constraint(equalToConstant: 30),
                checkBox.heightAnchor.constraint(equalToConstant: 30)

            ].forEach({ $0.isActive = true })
            
            checkBox.isUserInteractionEnabled = false
            checkBox.hideBox = true
            
            checkBox.lineWidth = 5.5
            checkBox.tintColor = .clear
            checkBox.onCheckColor = UIColor(hexString: "7BD293") ?? .green
        }
        
        checkBox.on = calculateProgress() == 1 ? true : false
    }
    
    
    //MARK: - Set Date Label Text
    
    private func setDateLabelText () {
        
        if let date = dateForCell, let formatter = formatter {
            
            formatter.dateFormat = "EEEE"
            dateLabel.text = formatter.string(from: date)
        }
    }
    
    
    //MARK: - Set Status Label
    
    private func setScheduleStatusLabel () {
        
        let semiBoldText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let mediumText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 15.5) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        let attributedString = NSMutableAttributedString(string: "")
        
        //If there have been blocks set for this date
        if let blocks = blocksForDate, blocks.count > 0 {
            
            //If there is a block that has yet to begun and has yet to be marked completed
            if let nextBlock = blocks.first(where: { $0.starts! > Date() && $0.status != .completed }), let name = nextBlock.name, let startTime = nextBlock.starts, let formatter = formatter {
                
                formatter.dateFormat = "h:mm a"
                
                attributedString.append(NSAttributedString(string: "Up Next: \n", attributes: semiBoldText))
                attributedString.append(NSAttributedString(string: "\(name) \n", attributes: mediumText))
                attributedString.append(NSAttributedString(string: formatter.string(from: startTime), attributes: mediumText))
                
                scheduleLabelTopAnchor?.constant = 6
                scheduleLabelHeightConstraint?.constant = 77
            }
            
            else {
                
                var allBlocksCompleted: Bool = true
                blocks.forEach({ if $0.status != .completed { allBlocksCompleted = false } }) //Finds any blocks that have not yet been completed
                
                if allBlocksCompleted {
                    
                    attributedString.append(NSAttributedString(string: "Done for the Day \n", attributes: semiBoldText))
                    
                    scheduleLabelTopAnchor?.constant = 0
                    scheduleLabelHeightConstraint?.constant = 30
                }
                
                else {
                    
                    //Finds the first block that has yet to be completed
                    if let remainingBlock = blocks.first(where: { $0.status != .completed }), let name = remainingBlock.name, let startTime = remainingBlock.starts, let formatter = formatter {
                        
                        formatter.dateFormat = "h:mm a"
                        
                        attributedString.append(NSAttributedString(string: "Blocks Remaining: \n", attributes: semiBoldText))
                        attributedString.append(NSAttributedString(string: "\(name) \n", attributes: mediumText))
                        attributedString.append(NSAttributedString(string: formatter.string(from: startTime), attributes: mediumText))
                        
                        scheduleLabelTopAnchor?.constant = 6
                        scheduleLabelHeightConstraint?.constant = 77
                    }
                }
            }
        }
        
        //If there have been no blocks set for this date
        else {
            
            attributedString.append(NSAttributedString(string: "Open Schedule \n \n", attributes: semiBoldText))
            
            scheduleLabelTopAnchor?.constant = 0
            scheduleLabelHeightConstraint?.constant = 30
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        scheduleStatusLabel.attributedText = attributedString
    }
    
    
    //MARK: - Set Image View
    
    private func setNoStatusImageView () {
        
        //If there have been blocks set for this date
        if let blocks = blocksForDate, blocks.count > 0 {
            
            //If there is a block that has yet to begun and has yet to be marked completed
            if blocks.first(where: { $0.starts! > Date() && $0.status != .completed }) != nil {
                
                noStatusImageView.image = nil
            }
            
            else {
                
                var allBlocksCompleted: Bool = true
                blocks.forEach({ if $0.status != .completed { allBlocksCompleted = false } }) //Finds any blocks that have not yet been completed
                
                if allBlocksCompleted {
                    
                    noStatusImageView.image = UIImage(named: "done-for-today")
                    
                    imageViewLeadingAnchor?.constant = 14
                    imageViewBottomAnchor?.constant = -5
                    imageViewWidthConstraint?.constant = 60
                    imageViewHeightConstraint?.constant = 55
                }
                
                else {
                    
                    noStatusImageView.image = nil
                }
            }
        }
        
        //If there have been no blocks set for this date
        else {
            
            noStatusImageView.image = UIImage(named: "falling")
            
            imageViewLeadingAnchor?.constant = 28.5
            imageViewBottomAnchor?.constant = 1
            imageViewWidthConstraint?.constant = 70
            imageViewHeightConstraint?.constant = 65
        }
    }
    
    
    //MARK: - Calculate Progress
    
    private func calculateProgress () -> CGFloat {
        
        var completedBlockCount: Int = 0
        
        for block in blocksForDate ?? [] {
            
            //If a block is completed
            if let status = block.status, status == .completed {
                
                completedBlockCount += 1
            }
        }
        
        //If there are blocks
        if let blockCount = blocksForDate?.count, blockCount > 0 {
            
            let completedPercentage = round((Double(completedBlockCount) / Double(blockCount)) * 100)
            
            //If no blocks have been completed
            if completedPercentage == 0 {
                
                return 0.0025
            }
            
            //If less than 100% of blocks have been completed
            else if completedPercentage < 100 {
                
                return CGFloat(completedBlockCount) / CGFloat(blockCount)
            }
            
            //If all the blocks have been completed
            else {
                
                return 1
            }
        }
        
        //If there are no blocks
        else {
            
            return 0.0025
        }
    }
}
