//
//  BlocksTableViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class BlocksTableViewCell: UITableViewCell {

    var collab: Collab?
    var blocks: [Block]? {
        didSet {
            
            //Removing all the old blocks from the cell
            for subview in contentView.subviews {
                
                if subview as? FullBlock != nil || subview as? HalfBlock != nil || subview as? OneThirdBlock != nil {
                    
                    subview.removeFromSuperview()
                }
            }
            
            hiddenBlocks = []
            
            determineBlockIntersections()
            configureBlocks(blocks)
        }
    }
    
    let formatter = DateFormatter()
    
    var blockIntersections: [String : [[String : Any]]] = [:]
    
    let cellTimes: [String] = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]
    
    var hiddenBlocks: [Block] = []
    
    weak var blockSelectedDelegate: BlockSelectedProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "blocksTableViewCell")
        
        configureCellBackground()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCellBackground () {
        
        var count: Double = 0
        
        for time in cellTimes {
            
            let textYPosition = 40 + (90 * count)

            let timeLabel = UILabel()
            timeLabel.frame = CGRect(x: 0, y: textYPosition, width: 50, height: 20)
            timeLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
            timeLabel.textAlignment = .right
            timeLabel.text = time

            let seperatorCenter = timeLabel.center.y - 0.5
            let seperatorWidth = UIScreen.main.bounds.width

            let seperatorView = UIView(frame: CGRect(x: 70, y: seperatorCenter, width: seperatorWidth, height: 1))
            seperatorView.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.70)

            contentView.addSubview(timeLabel)
            contentView.addSubview(seperatorView)
            
            count += 1
        }
    }
    
    private func configureBlocks (_ blocks: [Block]?) {
        
        var blockArray = blocks
        
        var configuredBlocks: [UIView] = []
        
        let calendar = Calendar.current
        
        var count = 0
        
        while count < blockArray?.count ?? 0 {
            
            //height
            let height = CGFloat(calendar.dateComponents([.minute], from: blocks![count].starts!, to: blocks![count].ends!).minute!) * 1.5
            
            //ycoord
            let blockStartHour = calendar.dateComponents([.hour], from: blocks![count].starts!).hour!
            let blockStartMinute = calendar.dateComponents([.minute], from: blocks![count].starts!).minute!
            let yCoord = CGFloat((Double(blockStartHour) * 90) + (Double(blockStartMinute) * 1.5)) + 50
            
            //width
            let width = (UIScreen.main.bounds.width - 70) - 10
            
            let blockInterceptionCount: Int? = determineBlockType(blocks![count], blockArray!)
            
            //Configuring a full block
            if blockInterceptionCount == 0 {
                
                let fullBlock = FullBlock(frame: CGRect(x: 75, y: yCoord, width: width, height: height))
                fullBlock.formatter = formatter
                fullBlock.collab = collab
                fullBlock.block = blockArray?[count]
                fullBlock.blockSelectedDelegate = blockSelectedDelegate
                
                self.contentView.addSubview(fullBlock)
            }
            
            //Configuring a half block
            else if blockInterceptionCount == 1 {
                
                //Starting the block in it's left position configuration
                blockArray?[count].position = .left
                
                //Frames for each possible block configurations
                let leftFrame = CGRect(x: 75, y: yCoord, width: (width / 2) - 2.5, height: height)
                let rightFrame = CGRect(x: (width / 2) + (77.5), y: yCoord, width: (width / 2) - 2.5, height: height)
                
                //Checking to see if the current block positioned to the left would intercept with any previously added blocks
                for block in configuredBlocks {

                    if block.frame.intersects(leftFrame), block.frame.minY != leftFrame.maxY && block.frame.maxY != leftFrame.minY {

                        blockArray?[count].position = .right
                        break
                    }
                }
                
                let halfBlock = HalfBlock(frame: blockArray?[count].position == .left ? leftFrame : rightFrame)
                halfBlock.formatter = formatter
                halfBlock.block = blockArray?[count]
                halfBlock.blockSelectedDelegate = blockSelectedDelegate
                
                configuredBlocks.append(halfBlock)
                
                contentView.addSubview(halfBlock)
            }
            
            //Configuring a one third block
            else if blockInterceptionCount == 2 {
                    
                //Starting the block in it's left position configuration
                blockArray?[count].position = .left
                
                //Frames for each possible block configurations
                let leftFrame = CGRect(x: 75, y: yCoord, width: (width / 3) - 2.5, height: height)
                let centeredFrame = CGRect(x: (width / 3) + 77.5, y: yCoord, width: (width / 3) - 2.5, height: height)
                let rightFrame = CGRect(x: ((width / 3) * 2) + 80, y: yCoord, width: (width / 3) - 2.5, height: height)
                
                //Checking to see if the current block positioned to the left would intercept with any previously added blocks
                for block in configuredBlocks {

                    if block.frame.intersects(leftFrame), block.frame.minY != leftFrame.maxY && block.frame.maxY != leftFrame.minY {

                        blockArray?[count].position = .centered
                        break
                    }
                }
                
                //If the position has been changed to the center, this will check to see if the current block positioned in the center would intercept with any previously added blocks
                if blockArray?[count].position == .centered {
                    
                    for block in configuredBlocks {
                        
                        if block.frame.intersects(centeredFrame), block.frame.minY != centeredFrame.maxY && block.frame.maxY != centeredFrame.minY {
                            
                            blockArray?[count].position = .right
                            break
                        }
                    }
                }
                
                //If the position has been changed to the right, this will check to see if the current block positioned to the right would intercept with any previously added blocks
                if blockArray?[count].position == .right {
                    
                    for block in configuredBlocks {
                        
                        //If the block positioned to the right also wouldn't work, the block should be hidden
                        if block.frame.intersects(rightFrame), block.frame.minY != rightFrame.maxY && block.frame.maxY != rightFrame.minY {
                            
                            if let block = blockArray?[count] {
                                
                                hiddenBlocks.append(block)
                            }
                            
                            blockArray?[count].position = .hidden
                            break
                        }
                    }
                }
                
                if blockArray?[count].position != .hidden {
                    
                    let oneThirdBlock: OneThirdBlock?
                    
                    if blockArray?[count].position == .left {
                        
                        oneThirdBlock = OneThirdBlock(frame: CGRect(x: 75, y: yCoord, width: (width / 3) - 2.5, height: height))
                    }
                    
                    else if blockArray?[count].position == .centered {
                        
                        oneThirdBlock = OneThirdBlock(frame: CGRect(x: (width / 3) + 77.5, y: yCoord, width: (width / 3) - 2.5, height: height))
                    }
                    
                    else {
                        
                        oneThirdBlock = OneThirdBlock(frame: CGRect(x: ((width / 3) * 2) + 80, y: yCoord, width: (width / 3) - 2.5, height: height))
                    }
                    
                    oneThirdBlock?.block = blockArray?[count]
                    oneThirdBlock?.blockSelectedDelegate = blockSelectedDelegate
                    configuredBlocks.append(oneThirdBlock!)
                    
                    self.contentView.addSubview(oneThirdBlock!)
                }
            }
            
            count += 1
        }
    }
    
    private func determineBlockIntersections () {
        
        blockIntersections = [:]
        
        for firstBlock in blocks ?? [] {
            
            for secondBlock in blocks ?? [] {
                
                //If the two blocks aren't the same block
                if firstBlock.blockID != secondBlock.blockID {
                    
                    //If the blocks time intercept one another
                    if let intersection = DateInterval(start: firstBlock.starts!, end: firstBlock.ends!).intersection(with: DateInterval(start: secondBlock.starts!, end: secondBlock.ends!)) {
                        
                        //If true, these blocks interception is permitted
                        if firstBlock.starts! != secondBlock.ends! && firstBlock.ends! != secondBlock.starts! {
                            
                            if blockIntersections[firstBlock.blockID!] == nil {
                                
                                blockIntersections[firstBlock.blockID!] = []
                            }
                            
                            blockIntersections[firstBlock.blockID!]?.append(["intersectingBlock" : secondBlock, "intersectionStart" : intersection.start, "intersectionEnd" : intersection.end])
                        }
                    }
                }
            }
        }
    }
    
    private func determineBlockType (_ block: Block, _ blockArray: [Block]) -> Int? {
        
        //Full Block
        if blockIntersections[block.blockID!] == nil {
            
            return 0
        }
        
        //Half Block
        else if blockIntersections[block.blockID ?? ""]?.count == 1 {
            
            return 1
        }
        
        //Possible One Third Block
        else {
            
            //One Third Block
            if confirmTwoBlockIntersections(block) {
                
                return 2
            }

            //Half Block
            else {
                
                return 1
            }
        }
    }
    
    private func confirmTwoBlockIntersections (_ block: Block) -> Bool {
        
        let intersections = blockIntersections[block.blockID ?? ""]
        
        //Will check to see if a block has multiple interceptions
        for firstIntersection in intersections ?? [] {
            
            if let firstBlock = firstIntersection["intersectingBlock"] as? Block {
                
                for secondIntersection in intersections ?? [] {
                    
                    if let secondBlock = secondIntersection["intersectingBlock"] as? Block, firstBlock.blockID != secondBlock.blockID {
                              
                        //If true, these blocks interception is permitted
                        if firstBlock.starts! != secondBlock.ends! && firstBlock.ends! != secondBlock.starts! {
                            
                            //If the blocks time intercept one another
                            if DateInterval(start: firstBlock.starts!, end: firstBlock.ends!).intersects(DateInterval(start: secondBlock.starts!, end: secondBlock.ends!)) {
                                
                                return true
                            }
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    func blockSelected (_ block: Block) {
        
        blockSelectedDelegate?.blockSelected(block)
    }
}
