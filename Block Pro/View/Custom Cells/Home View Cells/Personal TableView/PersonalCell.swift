//
//  PersonalCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class PersonalCell: UICollectionViewCell {

    @IBOutlet weak var cellBackground: UIView!
    
    @IBOutlet weak var cellBackgroundTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var cellBackgroundBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var cellBackgroundLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var cellBackgroundTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var firstBlockBeginsLabel: UILabel!
    @IBOutlet weak var firstBlock: UIView!
    @IBOutlet weak var firstBlockName: UILabel!
    @IBOutlet weak var firstBlockTime: UILabel!
    
    @IBOutlet weak var secondBlockBeginsLabel: UILabel!
    @IBOutlet weak var secondBlock: UIView!
    @IBOutlet weak var secondBlockName: UILabel!
    @IBOutlet weak var secondBlockTime: UILabel!
    
    @IBOutlet weak var thirdBlockBeginsLabel: UILabel!
    @IBOutlet weak var thirdBlock: UIView!
    @IBOutlet weak var thirdBlockName: UILabel!
    @IBOutlet weak var thirdBlockTime: UILabel!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var detailsButtonTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var detailsButtonCenterXAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonCenterXAnchor: NSLayoutConstraint!
    
    let personalDatabase = PersonalRealmDatabase.sharedInstance
    
    let formatter = DateFormatter()
    
    var currentDate: Date? {
        didSet {
            
            _ = personalDatabase.findTimeBlocks(currentDate!)
            
            calcBlocks(date: currentDate!)
        }
    }
    
    let tempLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        cellBackgroundTopAnchor.constant = 30
        cellBackgroundBottomAnchor.constant = 75
        cellBackgroundLeadingAnchor.constant = 15
        cellBackgroundTrailingAnchor.constant = 15
        
        cellBackground.drawCellShadow()

        detailsButton.alpha = 0
        shareButton.alpha = 0
        deleteButton.alpha = 0
        
        detailsButton.backgroundColor = .black//UIColor.white
        detailsButton.drawButtonShadow()
        
        shareButton.backgroundColor = UIColor(hexString: "A7BFE8")
        shareButton.drawButtonShadow()
        
        deleteButton.drawButtonShadow()
        
        contentView.addSubview(tempLabel)
    }
    
    private func calcBlocks (date: Date) {
        
        formatter.dateFormat = "yyyy dd MM"
        
        if let blockArray = personalDatabase.blockArray {
            
            var cellBlocks: [PersonalRealmDatabase.blockTuple] = []
            
            if formatter.string(from: Date()) == formatter.string(from: blockArray[0].begins) {
                
                for block in blockArray {
                    
                    formatter.dateFormat = "HH:mm"
                    
                    let currentTime: Date! = formatter.date(from: formatter.string(from: Date()))
                    
                    if formatter.date(from: formatter.string(from: block.ends))! >= currentTime {
                        
                        cellBlocks.append(block)
                    }
                }
                
                if cellBlocks.count == 0 {
                    
                    setLabel(text: "No More TimeBlocks Today")
                }
            }
            
            else {
                
                for block in blockArray {
                        
                    cellBlocks.append(block)
                }
            }
            
            configureBlocks(cellBlocks)
        }
        
        else {
            
            firstBlockBeginsLabel.isHidden = true
            firstBlock.isHidden = true
            
            secondBlockBeginsLabel.isHidden = true
            secondBlock.isHidden = true
            
            thirdBlockBeginsLabel.isHidden = true
            thirdBlock.isHidden = true
            
            setLabel(text: "Open Schedule")
        }
    }
    
    private func configureBlocks (_ blocks: [PersonalRealmDatabase.blockTuple]) {
        
        var count: Int = 0
        
        for block in blocks {
            
            formatter.dateFormat = "h:mm a"
            
            if count == 0 {
                
                firstBlockBeginsLabel.isHidden = false
                firstBlock.isHidden = false
                
                firstBlockBeginsLabel.text = formatter.string(from: block.begins)
                
                firstBlock.layer.cornerRadius = 7
                firstBlock.clipsToBounds = true
                firstBlock.backgroundColor = UIColor(hexString: personalDatabase.categoryColors[block.category] ?? "#AAAAAA")
                
                firstBlockName.text = block.name
                
                firstBlockTime.text = formatter.string(from: block.begins)
                firstBlockTime.text! += "  -  "
                firstBlockTime.text! += formatter.string(from: block.ends)
            }
            
            else if count == 1 {
                
                secondBlockBeginsLabel.isHidden = false
                secondBlock.isHidden = false
                
                secondBlockBeginsLabel.text = formatter.string(from: block.begins)
                
                secondBlock.layer.cornerRadius = 7
                secondBlock.clipsToBounds = true
                secondBlock.backgroundColor = UIColor(hexString: personalDatabase.categoryColors[block.category] ?? "#AAAAAA")
                
                secondBlockName.text = block.name
                
                secondBlockTime.text = formatter.string(from: block.begins)
                secondBlockTime.text! += "  -  "
                secondBlockTime.text! += formatter.string(from: block.ends)
            }
            
            else if count == 2 {
               
                thirdBlockBeginsLabel.isHidden = false
                thirdBlock.isHidden = false
                
                thirdBlockBeginsLabel.text = formatter.string(from: block.begins)
                
                thirdBlock.layer.cornerRadius = 7
                thirdBlock.clipsToBounds = true
                thirdBlock.backgroundColor = UIColor(hexString: personalDatabase.categoryColors[block.category] ?? "#AAAAAA")
                
                thirdBlockName.text = block.name
                
                thirdBlockTime.text = formatter.string(from: block.begins)
                thirdBlockTime.text! += "  -  "
                thirdBlockTime.text! += formatter.string(from: block.ends)
            }
            
            count += 1
        }
        
        if count == 0 {
            
            firstBlockBeginsLabel.isHidden = true
            firstBlock.isHidden = true
            
            secondBlockBeginsLabel.isHidden = true
            secondBlock.isHidden = true
            
            thirdBlockBeginsLabel.isHidden = true
            thirdBlock.isHidden = true
        }
        
        else if count == 1 {
            
            tempLabel.isHidden = true
            
            secondBlockBeginsLabel.isHidden = true
            secondBlock.isHidden = true
            
            thirdBlockBeginsLabel.isHidden = true
            thirdBlock.isHidden = true
        }
        
        else if count == 2 {
            
            tempLabel.isHidden = true
            
            thirdBlockBeginsLabel.isHidden = true
            thirdBlock.isHidden = true
        }
        
        else {
            
            tempLabel.isHidden = true
        }
    }
    
    private func setLabel (text: String) {
        
        tempLabel.isHidden = false
        
        tempLabel.frame = CGRect(x: contentView.center.x - 75, y: contentView.center.y - 150, width: 150, height: 150)
        tempLabel.text = text
        tempLabel.font = UIFont(name: "Poppins-SemiBold", size: 20)
        tempLabel.textColor = .black
        tempLabel.adjustsFontSizeToFitWidth = true
    }
    
}

extension UIView {
    
    func drawCellShadow () {
        
        layer.shadowRadius = 2.5
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.35
        
        layer.cornerRadius = 20
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    func configureBackgroundBlocks () {
        
        if tag == 0 {
            
            layer.cornerRadius = 8
        }
        
        else if tag == 1 {
            
            layer.cornerRadius = 9
        }
    }
}

extension UIButton {
    
    func drawButtonShadow () {
        
        layer.shadowRadius = 2.5
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.35
        
        layer.cornerRadius = 0.5 * bounds.size.width
        layer.masksToBounds = false
        clipsToBounds = false
    }
}
