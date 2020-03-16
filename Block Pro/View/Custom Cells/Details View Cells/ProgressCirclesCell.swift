//
//  ProgressCirclesCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ProgressCirclesCell: UITableViewCell {

    @IBOutlet weak var selectedCircleLabel: UILabel!
    
    let personalDatabase = PersonalRealmDatabase.sharedInstance
    
    let blockTimeTrackLayer = CAShapeLayer()
    let blockTimeShapeLayer = CAShapeLayer()
    let blockTimeAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    let freeTimeTrackLayer = CAShapeLayer()
    let freeTimeShapeLayer = CAShapeLayer()
    let freeTimeAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    let conflictingTimeTrackLayer = CAShapeLayer()
    let conflictingTimeShapeLayer = CAShapeLayer()
    let conflictingTimeAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    var blockedTime: [String : Int] = [:]
    
    var blockTimePercentage: Double? {
        didSet {
            
            configureBlockTimeAnimation(blockTimePercentage!)
            
            if personalDatabase.blockArray != nil {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    
                    self.progressLayerTapped(layer: self.blockTimeShapeLayer)
                    
                    self.conflictingTimeTrackLayer.fillColor = UIColor.clear.cgColor
                    
                    self.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    var freeTime: [String : Int] = [:]
    
    var freeTimePercentage: Double? {
        didSet {
            
            configureFreeTimeAnimation(freeTimePercentage!)
            
            if personalDatabase.blockArray == nil {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    
                    self.progressLayerTapped(layer: self.freeTimeShapeLayer)
                    
                    self.conflictingTimeTrackLayer.fillColor = UIColor.clear.cgColor
                    
                    self.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    var conflictingTime: [String : Int] = [:]
    
    var conflictingTimePercentage: Double? {
        didSet {
            
            configureConflictingTimeAnimation(conflictingTimePercentage!)
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isUserInteractionEnabled = false
        
        selectedCircleLabel.text = ""
        
        configureBlockTimeCircle()
        configureFreeTimeCircle()
        configureConflictingTimeCircle()
        
        calcBlockedAndFreeTime()
        calcConflictingTime()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Configuring Progress Circles
    
    private func configureBlockTimeCircle () {
        
        let circularPath: UIBezierPath
        
        circularPath = UIBezierPath(arcCenter: contentView.center, radius: 160, startAngle: (-CGFloat.pi) / 2, endAngle: -(2.5 * CGFloat.pi), clockwise: false)
        
        blockTimeTrackLayer.lineWidth = 15
        blockTimeTrackLayer.path = circularPath.cgPath
        blockTimeTrackLayer.fillColor = UIColor.clear.cgColor
        blockTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.cgColor
        
        contentView.layer.addSublayer(blockTimeTrackLayer)
        
        blockTimeShapeLayer.lineWidth = 12
        blockTimeShapeLayer.path = circularPath.cgPath
        blockTimeShapeLayer.fillColor = UIColor.clear.cgColor
        blockTimeShapeLayer.strokeColor = UIColor(hexString: "2ECC70")?.cgColor
        blockTimeShapeLayer.strokeEnd = 0
        
        blockTimeShapeLayer.lineCap = CAShapeLayerLineCap.round
        
        contentView.layer.addSublayer(blockTimeShapeLayer)
    }
    
    private func configureFreeTimeCircle () {
        
        let circularPath: UIBezierPath
        
        circularPath = UIBezierPath(arcCenter: contentView.center, radius: 130, startAngle: (-CGFloat.pi) / 2, endAngle: -(2.5 * CGFloat.pi), clockwise: false)
        
        freeTimeTrackLayer.lineWidth = 15
        freeTimeTrackLayer.path = circularPath.cgPath
        freeTimeTrackLayer.fillColor = UIColor.clear.cgColor
        freeTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.cgColor
        
        contentView.layer.addSublayer(freeTimeTrackLayer)
        
        freeTimeShapeLayer.lineWidth = 12
        freeTimeShapeLayer.path = circularPath.cgPath
        freeTimeShapeLayer.fillColor = UIColor.clear.cgColor
        freeTimeShapeLayer.strokeColor = UIColor(hexString: "FFCC02")?.cgColor
        freeTimeShapeLayer.strokeEnd = 0
        
        freeTimeShapeLayer.lineCap = .round
        
        contentView.layer.addSublayer(freeTimeShapeLayer)
    }
    
    private func configureConflictingTimeCircle () {
        
        let circularPath: UIBezierPath
        
        circularPath = UIBezierPath(arcCenter: contentView.center, radius: 100, startAngle: (-CGFloat.pi) / 2, endAngle: -(2.5 * CGFloat.pi), clockwise: false)
        
        conflictingTimeTrackLayer.lineWidth = 15
        conflictingTimeTrackLayer.path = circularPath.cgPath
        conflictingTimeTrackLayer.fillColor = UIColor.white.cgColor
        conflictingTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.cgColor
        
        contentView.layer.addSublayer(conflictingTimeTrackLayer)
        
        conflictingTimeShapeLayer.lineWidth = 12
        conflictingTimeShapeLayer.path = circularPath.cgPath
        conflictingTimeShapeLayer.fillColor = UIColor.clear.cgColor
        conflictingTimeShapeLayer.strokeColor = UIColor(hexString: "745EC4")?.cgColor
        conflictingTimeShapeLayer.strokeEnd = 0
        
        conflictingTimeShapeLayer.lineCap = .round
        
        contentView.layer.addSublayer(conflictingTimeShapeLayer)
    }
    
    
    //MARK: - Configuring Progress Animations
    
    private func configureBlockTimeAnimation (_ toValue: Double) {
        
        blockTimeAnimation.fromValue = 0
        blockTimeAnimation.toValue = toValue
        blockTimeAnimation.duration = 2//0.8 * 2.5
        blockTimeAnimation.fillMode = CAMediaTimingFillMode.forwards
        blockTimeAnimation.isRemovedOnCompletion = false
        
        blockTimeAnimation.speed = 1
        
        blockTimeShapeLayer.add(blockTimeAnimation, forKey: nil)
    }

    private func configureFreeTimeAnimation (_ toValue: Double) {
        
        freeTimeAnimation.fromValue = 0
        freeTimeAnimation.toValue = toValue
        freeTimeAnimation.duration = 2//0.65 * 2.5
        freeTimeAnimation.fillMode = CAMediaTimingFillMode.forwards
        freeTimeAnimation.isRemovedOnCompletion = false
        
        freeTimeAnimation.speed = 1
        
        freeTimeShapeLayer.add(freeTimeAnimation, forKey: nil)
    }
    
    private func configureConflictingTimeAnimation (_ toValue: Double) {
        
        conflictingTimeAnimation.fromValue = 0
        conflictingTimeAnimation.toValue = toValue
        conflictingTimeAnimation.duration = 2//0.4 * 2.5
        conflictingTimeAnimation.fillMode = CAMediaTimingFillMode.forwards
        conflictingTimeAnimation.isRemovedOnCompletion = false
        
        conflictingTimeAnimation.speed = 1
        
        conflictingTimeShapeLayer.add(conflictingTimeAnimation, forKey: nil)
    }
    
    //MARK: - Calc
    
    private func calcBlockedAndFreeTime () {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        var date: Date = formatter.date(from: "00:00")!
        var dateArray: [Date] = []
        
        while date <= formatter.date(from: "23:55")! {
            
            dateArray.append(date)
            
            date = date.addingTimeInterval(300)
        }
        
        if let blockArray = personalDatabase.blockArray {
            
            for block in blockArray {
                
                var currentBlockDate = block.begins
                
                while currentBlockDate <= block.ends {
                    
                    if let index = dateArray.firstIndex(of: formatter.date(from: formatter.string(from: currentBlockDate))!) {
                        
                        dateArray.remove(at: index)
                        
                        currentBlockDate = currentBlockDate.addingTimeInterval(300)
                    }
                    
                    else {
                        
                        currentBlockDate = currentBlockDate.addingTimeInterval(300)
                    }
                }
            }
        }
        
        blockTimePercentage = (Double(288 - dateArray.count) / Double(288))
        blockedTime["hours"] = (288 - dateArray.count) / 12
        blockedTime["minutes"] = (((288 - dateArray.count) % 12) * 5) - 5
        
        if blockedTime["minutes"]! < 0 && blockedTime["hours"]! > 0 {

            if blockedTime["hours"]! == 24 {

                blockedTime["hours"]! = 24
                blockedTime["minutes"] = 0
            }
                
            else {

                blockedTime["hours"]! -= 1
                blockedTime["minutes"] = 55
            }
        }

        else if blockedTime["minutes"]! < 0 && blockedTime["hours"]! == 0 {

            blockedTime["minutes"] = 0
        }
        
        
        freeTimePercentage = Double(dateArray.count) / Double(288)
        freeTime["hours"] = dateArray.count / 12
        freeTime["minutes"] = ((dateArray.count % 12) * 5) + 5
        
        if blockedTime["hours"] == 24 {

            freeTime["hours"] = 0
            freeTime["minutes"] = 0
        }
        
        else if freeTime["minutes"]! > 55 && freeTime["hours"]! < 24 {
            
            freeTime["hours"]! += 1
            freeTime["minutes"] = 0
        }
        
        else if freeTime["hours"]! == 24 {
            
            freeTime["minutes"] = 0
        }
    }
    
    private func calcConflictingTime () {
        
        if personalDatabase.blockArray != nil {
            
            var conflictingTimes: [Date] = []
            
            for pendingBlock in personalDatabase.blockArray! {
                
                for conflictingBlock in personalDatabase.blockArray! {
                    
                    if pendingBlock.blockID != conflictingBlock.blockID {
                        
                        var currentBlockDate: Date = conflictingBlock.begins
                        
                        while currentBlockDate <= conflictingBlock.ends {
                            
                            if currentBlockDate.isBetween(startDate: pendingBlock.begins, endDate: pendingBlock.ends) && conflictingTimes.firstIndex(of: currentBlockDate) == nil {
                                
                                conflictingTimes.append(currentBlockDate)
                                
                                currentBlockDate = currentBlockDate.addingTimeInterval(300)
                            }
                            
                            else {
                                
                                if currentBlockDate == pendingBlock.ends && conflictingTimes.firstIndex(of: currentBlockDate) == nil {
                                    
                                    conflictingTimes.append(currentBlockDate)
                                }
                                
                                else if currentBlockDate > pendingBlock.ends {
                                    
                                    break
                                }
                                
                                else {
                                    
                                    currentBlockDate = currentBlockDate.addingTimeInterval(300)
                                }
                            }
                        }
                    }
                }
            }
            
            conflictingTimePercentage = Double(conflictingTimes.count) / Double(287)
            conflictingTime["hours"] = conflictingTimes.count / 12
            conflictingTime["minutes"] = ((conflictingTimes.count % 12) * 5)
            
            if conflictingTimes.count == 287 {

                conflictingTime["hours"] = 24
                conflictingTime["minutes"] = 0
            }
            
            else if conflictingTime["minutes"]! > 55 && conflictingTime["hours"]! < 24 {
                
                conflictingTime["hours"]! += 1
                conflictingTime["minutes"] = 0
            }
            
            else if conflictingTime["hours"]! == 24 {
                
                conflictingTime["minutes"] = 0
            }
        }
    }
    
    private func progressLayerTapped (layer: CAShapeLayer) {
        
        let semiBoldAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17.5) as Any]
        let standardAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins", size: 13.5) as Any]
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "", attributes: nil)
        
        var selectedCircleText: NSAttributedString!
        var descriptionText: NSAttributedString!
        
        if layer == conflictingTimeShapeLayer {
            
            selectedCircleText = NSAttributedString(string: "Conflicting Time \n", attributes: semiBoldAttributes)
            attributedString.append(selectedCircleText)
            
            if conflictingTime["hours"] == 0 {
                
                if conflictingTime["minutes"] == 0 {
                    
                    descriptionText = NSAttributedString(string: "No Conflicting Time", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
                
                else {
                    
                    descriptionText = NSAttributedString(string: "\(conflictingTime["minutes"]!) Minutes", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
            }
            
            else if conflictingTime["minutes"] == 0 {
                
                if conflictingTime["hours"] == 1 {
                    
                    descriptionText = NSAttributedString(string: "\(conflictingTime["hours"]!) Hour", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
                
                else {
                    
                    descriptionText = NSAttributedString(string: "\(conflictingTime["hours"]!) Hours", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
            }
            
            else {
                
                if conflictingTime["hours"] == 1 {
                    
                    descriptionText = NSAttributedString(string: "\(conflictingTime["hours"]!) Hour and \(conflictingTime["minutes"]!) Minutes", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
                
                else {
                    
                    descriptionText = NSAttributedString(string: "\(conflictingTime["hours"]!) Hours and \(conflictingTime["minutes"]!) Minutes", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
            }
            
            selectedCircleLabel.attributedText = attributedString
            
            UIView.animate(withDuration: 0.5) {
                
                self.conflictingTimeTrackLayer.lineWidth = 18
                self.conflictingTimeShapeLayer.lineWidth = 17
                self.conflictingTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.darken(byPercentage: 0.05)?.cgColor
                
                self.freeTimeTrackLayer.lineWidth = 15
                self.freeTimeShapeLayer.lineWidth = 12
                self.freeTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.cgColor
                
                self.blockTimeTrackLayer.lineWidth = 15
                self.blockTimeShapeLayer.lineWidth = 12
                self.blockTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.cgColor
            }
        }
        
        else if layer == freeTimeShapeLayer {
            
            selectedCircleText = NSAttributedString(string: "Free Time \n", attributes: semiBoldAttributes)
            attributedString.append(selectedCircleText)
            
            if freeTime["hours"] == 0 {
                
                if freeTime["minutes"] == 0 {
                    
                    descriptionText = NSAttributedString(string: "No Free Time", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
                
                else {
                    
                    descriptionText = NSAttributedString(string: "\(freeTime["minutes"]!) Minutes", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
            }
            
            else if freeTime["minutes"] == 0 {
                    
                if freeTime["hours"] == 1 {
                    
                    descriptionText = NSAttributedString(string: "\(freeTime["hours"]!) Hour", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
                
                else {
                    
                    descriptionText = NSAttributedString(string: "\(freeTime["hours"]!) Hours", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
            }
            
            else {
                
                if freeTime["hours"] == 1 {
                    
                    descriptionText = NSAttributedString(string: "\(freeTime["hours"]!) Hour and \(freeTime["minutes"]!) Minutes", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
                
                else {
                    
                    descriptionText = NSAttributedString(string: "\(freeTime["hours"]!) Hours and \(freeTime["minutes"]!) Minutes", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
            }
            
            selectedCircleLabel.attributedText = attributedString
        
            UIView.animate(withDuration: 0.5) {
                
                self.freeTimeTrackLayer.lineWidth = 18
                self.freeTimeShapeLayer.lineWidth = 17
                self.freeTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.darken(byPercentage: 0.05)?.cgColor
                
                self.blockTimeTrackLayer.lineWidth = 15
                self.blockTimeShapeLayer.lineWidth = 12
                self.blockTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.cgColor
                
                self.conflictingTimeTrackLayer.lineWidth = 15
                self.conflictingTimeShapeLayer.lineWidth = 12
                self.conflictingTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.cgColor
            }
        }
        
        else if layer == blockTimeShapeLayer {
            
            selectedCircleText = NSAttributedString(string: "Blocked Time \n", attributes: semiBoldAttributes)
            attributedString.append(selectedCircleText)
            
            if blockedTime["hours"] == 0 {
                
                if blockedTime["minutes"] == 0 {
                    
                    descriptionText = NSAttributedString(string: "No Time Blocked", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
                
                else {
                    
                    descriptionText = NSAttributedString(string: "\(blockedTime["minutes"]!) Minutes", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
            }
            
            else if blockedTime["minutes"] == 0 {
                
                if blockedTime["hours"] == 1 {
                    
                    descriptionText = NSAttributedString(string: "\(blockedTime["hours"]!) Hour", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
                
                else {
                    
                    descriptionText = NSAttributedString(string: "\(blockedTime["hours"]!) Hours", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
            }
            
            else {
                
                if blockedTime["hours"] == 1 {
                    
                    descriptionText = NSAttributedString(string: "\(blockedTime["hours"]!) Hour and \(blockedTime["minutes"]!) Minutes", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
                
                else {
                    
                    descriptionText = NSAttributedString(string: "\(blockedTime["hours"]!) Hours and \(blockedTime["minutes"]!) Minutes", attributes: standardAttributes)
                    attributedString.append(descriptionText)
                }
            }
            
            selectedCircleLabel.attributedText = attributedString
            
            UIView.animate(withDuration: 0.5) {
                
                self.blockTimeTrackLayer.lineWidth = 18
                self.blockTimeShapeLayer.lineWidth = 17
                self.blockTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.darken(byPercentage: 0.05)?.cgColor
                
                self.conflictingTimeTrackLayer.lineWidth = 15
                self.conflictingTimeShapeLayer.lineWidth = 12
                self.conflictingTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.cgColor
                
                self.freeTimeTrackLayer.lineWidth = 15
                self.freeTimeShapeLayer.lineWidth = 12
                self.freeTimeTrackLayer.strokeColor = UIColor(hexString: "F1F1F1")?.cgColor
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        guard let point = touch?.location(in: contentView) else { return }
        
        if conflictingTimeShapeLayer.path!.contains(point) {
            
            progressLayerTapped(layer: conflictingTimeShapeLayer)
            
        }
        
        else if freeTimeShapeLayer.path!.contains(point) {
            
            progressLayerTapped(layer: freeTimeShapeLayer)
        }
        
        else if blockTimeShapeLayer.path!.contains(point) {
            
            progressLayerTapped(layer: blockTimeShapeLayer)
        }
    }
}
