//
//  TimeBlockCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol MoveToEditBlockView {
    
    func moveToEditView (selectedBlock: PersonalRealmDatabase.blockTuple)
}

class TimeBlockCell: UITableViewCell {
    
    let personalDatabase = PersonalRealmDatabase.sharedInstance
    
    let formatter = DateFormatter()
    
    let cellTimes: [String] = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]
    

    var blockButtons: [UIButton] = []
    var coorespondingBlocks: [PersonalRealmDatabase.blockTuple] = []
    
    var editBlockDelegate: MoveToEditBlockView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCellBackground()
        configureBlocks()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellBackground () {
        
        var count: Double = 0
        
        for time in cellTimes {
            
            let textYPosition = 40 + (90 * count)

            let timeLabel = UILabel()
            timeLabel.frame = CGRect(x: 0, y: textYPosition, width: 50, height: 20)
            timeLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
            timeLabel.textAlignment = .right
            //timeLabel.textColor = UIColor(hexString: "9D9D9D")
            timeLabel.text = time

            let seperatorCenter = timeLabel.center.y - 0.5
            let seperatorWidth = contentView.frame.width

            let seperatorView = UIView()
            seperatorView.frame = CGRect(x: 70, y: seperatorCenter, width: seperatorWidth, height: 1)
            seperatorView.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.70)

            contentView.addSubview(timeLabel)
            contentView.addSubview(seperatorView)
            
            count += 1

        }
    }
    
    func configureBlocks () {
        
        if personalDatabase.blockArray != nil {
            
            var conflictingBlocks: [[PersonalRealmDatabase.blockTuple]] = []
            var count: Int = 0
            
            for pendingBlock in personalDatabase.blockArray! {
                
                conflictingBlocks.append([])
                
                for conflictingBlock in personalDatabase.blockArray! {
                    
                    if pendingBlock.blockID != conflictingBlock.blockID {

                        var currentBlockDate: Date = conflictingBlock.begins
                        
                        while currentBlockDate <= conflictingBlock.ends {
                            
                            if currentBlockDate.isBetween(startDate: pendingBlock.begins, endDate: pendingBlock.ends) {
                                
                                conflictingBlocks[count].append(conflictingBlock)
                                break
                            }
                            
                            else {
                                
                                currentBlockDate = currentBlockDate.addingTimeInterval(150)
                            }
                        }
                    }
                }
                
                count += 1
            }
            
            var blockConfigurationDict: [String : Any] = ["block": "", "typeOfBlock" : "", "conflictingBlocks" : "", "blockFrame" : "", "position" : ""]
            var blockConfigurationArray: [[String : Any]] = []
            
            
            count = 0
            
            for block in personalDatabase.blockArray! {
                
                if conflictingBlocks[count].count == 0 {
                    
                    blockConfigurationDict["block"] = block
                    blockConfigurationDict["typeOfBlock"] = "fullBlock"
                    blockConfigurationDict["conflictingBlocks"] = nil
                    blockConfigurationDict["position"] = "centered"
                    
                    blockConfigurationArray.append(blockConfigurationDict)
                }
                
                else if conflictingBlocks[count].count == 1 {
                    
                    blockConfigurationDict["block"] = block
                    blockConfigurationDict["typeOfBlock"] = "halfBlock"
                    blockConfigurationDict["conflictingBlocks"] = conflictingBlocks[count]
                    blockConfigurationDict["position"] = ""
                    
                    blockConfigurationArray.append(blockConfigurationDict)
                }
                
                else if conflictingBlocks[count].count >= 2 {
                    
                    blockConfigurationDict["block"] = block
                    blockConfigurationDict["typeOfBlock"] = "unknown"
                    blockConfigurationDict["conflictingBlocks"] = conflictingBlocks[count]
                    blockConfigurationDict["position"] = ""
                    
                    blockConfigurationArray.append(blockConfigurationDict)
                }
                
                count += 1
            }
            
            count = 0

            
            for configuration in blockConfigurationArray {
                
                if configuration["typeOfBlock"] as? String == "fullBlock" {
                    
                    count += 1
                    continue
                }

                else if configuration["typeOfBlock"] as? String == "halfBlock" {
                    
                    blockConfigurationArray[count]["position"] = determineHalfBlockPosition(configuration, blockConfigurationArray, count)
                }
                
                else if configuration["typeOfBlock"] as? String == "unknown" {
                    
                    let block = configuration["block"] as! PersonalRealmDatabase.blockTuple
                    let blockHasTwoConflicting: Bool = confirmOneThirdBlock(block, conflictingBlocks[count], conflictingBlocks)
                    
                    if blockHasTwoConflicting == true {
                        
                        blockConfigurationArray[count]["typeOfBlock"] = "oneThirdBlock"
                        blockConfigurationArray[count]["position"] = determineOneThirdBlockPosition(configuration, blockConfigurationArray, count)
                    }
                    
                    else {
                        
                        blockConfigurationArray[count]["typeOfBlock"] = "halfBlock"
                        blockConfigurationArray[count]["position"] = determineHalfBlockPosition(configuration, blockConfigurationArray, count)
                    }
                }
                
                
                
                count += 1
            }
            
            count = 0
            
            for configuration in blockConfigurationArray {
                
                if configuration["typeOfBlock"] as? String == "halfBlock" {
                    
                    let conflictingBlocks = configuration["conflictingBlocks"] as? [PersonalRealmDatabase.blockTuple]
                    var firstConflictingBlock: Int?
                    var secondConflictingBlock: Int?
                    
                    if conflictingBlocks!.count > 1 {
                        
                        firstConflictingBlock = (personalDatabase.blockArray?.firstIndex(where: { $0.blockID == conflictingBlocks![0].blockID}))!
                        secondConflictingBlock = (personalDatabase.blockArray?.firstIndex(where: { $0.blockID == conflictingBlocks![1].blockID}))!
                    }
                    
                    else {
                        
                        firstConflictingBlock = (personalDatabase.blockArray?.firstIndex(where: { $0.blockID == conflictingBlocks![0].blockID}))!
                    }
                    
                    if blockConfigurationArray[firstConflictingBlock!]["typeOfBlock"] as? String == "oneThirdBlock" {
                        
                        blockConfigurationArray[count]["typeOfBlock"] = "oneThirdBlock"
                    }
                    
                    else if secondConflictingBlock != nil {
                        
                        if blockConfigurationArray[secondConflictingBlock!]["typeOfBlock"] as? String == "oneThirdBlock" {
                            
                            blockConfigurationArray[count]["typeOfBlock"] = "oneThirdBlock"
                        }
                    }
                }
                
                count += 1
            }
            
            count = 0
            
            for configuration in blockConfigurationArray {
                
                let block = configuration["block"] as! PersonalRealmDatabase.blockTuple
                let typeOfBlock = configuration["typeOfBlock"] as! String
                let position = configuration["position"] as! String
                
                formatter.dateFormat = "HH"
                let startHour: Double = Double(formatter.string(from: block.begins))!
                let totalHours: Double = Double(formatter.string(from: block.ends))! - Double(formatter.string(from: block.begins))!

                formatter.dateFormat = "mm"
                let startMinutes: Double = Double(formatter.string(from: block.begins))!
                let totalMinutes: Double = Double(formatter.string(from: block.ends))! - Double(formatter.string(from: block.begins))!

                let blockYCoord: CGFloat = CGFloat(((startHour * 90) + (startMinutes * 1.5)) + 50)
                let blockHeight: CGFloat = CGFloat(((totalHours * 90) + (totalMinutes * 1.5)))
                let blockWidth = (UIScreen.main.bounds.width - 75) - 7.5
                
                switch typeOfBlock {
                    
                case "fullBlock":
                    
                    let fullBlock = FullBlock()
                    fullBlock.frame = CGRect(x: 77.5, y: blockYCoord, width: blockWidth, height: blockHeight)
                    fullBlock.block = block

                    contentView.addSubview(fullBlock)
                    contentView.addSubview(createButton(buttonFrame: fullBlock.frame, count: count))
                 
                case "halfBlock":
                    
                    let halfBlock = HalfBlock()
                    
                    if position == "left" {

                        halfBlock.frame = CGRect(x: 77.5, y: blockYCoord, width: (blockWidth / 2) - 10, height: blockHeight)
                    }

                    else if position == "right" {

                        halfBlock.frame = CGRect(x: (blockWidth / 2) + (77.5 + 10), y: blockYCoord, width: (blockWidth / 2) - 10, height: blockHeight)
                    }
                    
                    halfBlock.block = block
                    
                    contentView.addSubview(halfBlock)
                    contentView.addSubview(createButton(buttonFrame: halfBlock.frame, count: count))
                    
                case "oneThirdBlock":
                    
                    let oneThirdBlock = OneThirdBlock()
                    
                    if position == "left" {
                        
                        oneThirdBlock.frame = CGRect(x: 77.5, y: blockYCoord, width: (blockWidth / 3) - 10, height: blockHeight)
                    }
                    
                    else if position == "middle" {
                        
                        oneThirdBlock.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - 18.75, y: blockYCoord, width: (blockWidth / 3), height: blockHeight)
                    }
                    
                    else if position == "right" {
                        
                        oneThirdBlock.frame = CGRect(x: (UIScreen.main.bounds.width - (blockWidth / 3)) - 7.5, y: blockYCoord, width: (blockWidth / 3), height: blockHeight)
                    }
                    
                    oneThirdBlock.block = block
                    
                    contentView.addSubview(oneThirdBlock)
                    contentView.addSubview(createButton(buttonFrame: oneThirdBlock.frame, count: count))
                    
                default:
                    break
                }
                
                coorespondingBlocks.append(block)
                count += 1
            }
            
        }
    
    }
    
    private func determineHalfBlockPosition (_ configuration: [String : Any], _ blockConfigurationArray: [[String : Any]], _ count: Int) -> String {
        
        let conflictingBlock = configuration["conflictingBlocks"] as? [PersonalRealmDatabase.blockTuple] //The block that conflicts with this current block
        let conflictingBlockIndex: Int = (personalDatabase.blockArray?.firstIndex(where: { $0.blockID == conflictingBlock![0].blockID}))!
        
        if count < conflictingBlockIndex {
            
            return "left"
        }
        
        else {
            
            if blockConfigurationArray[conflictingBlockIndex]["position"] as? String == "left" {
                
                return "right"
            }
            
            else {
                
                return "left"
            }
            
            
        }
    }
    
    private func confirmOneThirdBlock (_ block: PersonalRealmDatabase.blockTuple, _ blocksConflictingBlocks: [PersonalRealmDatabase.blockTuple], _ allConflictingBlocks: [[PersonalRealmDatabase.blockTuple]]) -> Bool {
        
            var blockHasTwoConflicting: Bool = false
            
            for conflictingBlock in blocksConflictingBlocks {

                let conflictingBlockIndex: Int = (personalDatabase.blockArray?.firstIndex(where: { $0.blockID == conflictingBlock.blockID}))!

                let secondConflictingBlocks = allConflictingBlocks[conflictingBlockIndex]

                for secondConflictingBlock in secondConflictingBlocks {

                    if secondConflictingBlock.blockID != block.blockID {

                        var currentBlockDate: Date = secondConflictingBlock.begins

                        while currentBlockDate <= secondConflictingBlock.ends {

                            if currentBlockDate.isBetween(startDate: block.begins, endDate: block.ends) {

                                blockHasTwoConflicting = true
                                break
                            }

                            else {

                                currentBlockDate = currentBlockDate.addingTimeInterval(150)
                            }
                        }
                    }
                    
                    if blockHasTwoConflicting == true {
                        break
                    }
                }
                
                if blockHasTwoConflicting == true {
                    break
                }
            }
            
        return blockHasTwoConflicting
        
    }
    
    private func determineOneThirdBlockPosition ( _ configuration: [String : Any], _ blockConfigurationArray: [[String : Any]], _ count: Int) -> String {
        
        let conflictingBlocks = configuration["conflictingBlocks"] as? [PersonalRealmDatabase.blockTuple]
        let firstConflictingBlockIndex: Int = (personalDatabase.blockArray?.firstIndex(where: { $0.blockID == conflictingBlocks![0].blockID}))!
        let secondConflictingBlockIndex: Int = (personalDatabase.blockArray?.firstIndex(where: { $0.blockID == conflictingBlocks![1].blockID}))!

        let currentBlock = configuration["block"] as! PersonalRealmDatabase.blockTuple
        let firstConflictingBlock = conflictingBlocks![0]
        let secondConflictingBlock = conflictingBlocks![1]
        
        if (currentBlock.begins < firstConflictingBlock.begins) && (currentBlock.begins < secondConflictingBlock.begins) {
            
            return "left"
        }
        
        else if currentBlock.begins > firstConflictingBlock.begins && currentBlock.begins < secondConflictingBlock.begins {
            
            //return "middle"
            
            let firstConflictingPositon = blockConfigurationArray[firstConflictingBlockIndex]["position"] as? String
            let secondConflictingPosition = blockConfigurationArray[secondConflictingBlockIndex]["position"] as? String
            
            if firstConflictingPositon != "left" && secondConflictingPosition != "left" {
                
                return "left"
            }
            
            else if firstConflictingPositon != "middle" && secondConflictingPosition != "middle" {
                
                return "middle"
            }
            
            else {
                
                return "right"
            }
        }
        
        else if currentBlock.begins > firstConflictingBlock.begins && currentBlock.begins > secondConflictingBlock.begins {
            
            let firstConflictingPositon = blockConfigurationArray[firstConflictingBlockIndex]["position"] as? String
            let secondConflictingPosition = blockConfigurationArray[secondConflictingBlockIndex]["position"] as? String
            
            if firstConflictingPositon != "left" && secondConflictingPosition != "left" {
                
                return "left"
            }
            
            else if firstConflictingPositon != "middle" && secondConflictingPosition != "middle" {
                
                return "middle"
            }
            
            else {
                
                return "right"
            }
        }
        
        else {
            
            if currentBlock.begins == firstConflictingBlock.begins && currentBlock.begins != secondConflictingBlock.begins {
                
                if count < firstConflictingBlockIndex {
                    
                    return "left"
                }
                
                else {
                    
                    return "middle"
                }
            }
            
            else if currentBlock.begins != firstConflictingBlock.begins && currentBlock.begins == secondConflictingBlock.begins {
                
                let firstConflictingPositon = blockConfigurationArray[firstConflictingBlockIndex]["position"] as? String
                let secondConflictingPosition = blockConfigurationArray[secondConflictingBlockIndex]["position"] as? String
                
                if count < secondConflictingBlockIndex {
                    
                    return "middle"
                }
                
                else {
                    
                    if firstConflictingPositon != "left" && secondConflictingPosition != "left" {
                        
                        return "left"
                    }
                    
                    else if firstConflictingPositon != "middle" && secondConflictingPosition != "middle" {
                        
                        return "middle"
                    }
                    
                    else {
                        
                        return "right"
                    }
                }
                
            }
            
            else {
                
                if count < firstConflictingBlockIndex && count < secondConflictingBlockIndex {
                    
                    return "left"
                }
                
                else if count > firstConflictingBlockIndex && count < secondConflictingBlockIndex {
                    
                    return "middle"
                }
                
                else {
                    
                    let firstConflictingPositon = blockConfigurationArray[firstConflictingBlockIndex]["position"] as? String
                    let secondConflictingPosition = blockConfigurationArray[secondConflictingBlockIndex]["position"] as? String
                    
                    if firstConflictingPositon != "left" && secondConflictingPosition != "left" {
                        
                        return "left"
                    }
                    
                    else if firstConflictingPositon != "middle" && secondConflictingPosition != "middle" {
                        
                        return "middle"
                    }
                    
                    else {
                        
                        return "right"
                    }
                }
            }
        }
    }
    
    private func createButton (buttonFrame: CGRect, count: Int) -> UIButton {
        
        let blockButton = UIButton()
        blockButton.frame = buttonFrame
        blockButton.backgroundColor = .clear
        blockButton.tag = count
        blockButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        blockButtons.append(blockButton)
        return blockButton
    }
    
    @objc func buttonPressed (sender: UIButton) {
        
        editBlockDelegate?.moveToEditView(selectedBlock: coorespondingBlocks[sender.tag])


    }
}
