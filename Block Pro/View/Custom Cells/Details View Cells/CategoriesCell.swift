//
//  CategoriesCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/16/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CategoriesCell: UITableViewCell {

    @IBOutlet weak var trackBar: CategoryTrackBar!
    
    @IBOutlet weak var workLabelTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var workProgressBar: CategoryProgressBar!
    @IBOutlet weak var workBarTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var workBarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var creativityLabelTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var creativityProgressBar: CategoryProgressBar!
    @IBOutlet weak var creativityBarTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var creativityBarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sleepLabelTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var sleepProgressBar: CategoryProgressBar!
    @IBOutlet weak var sleepBarTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var sleepBarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var foodLabelTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var foodProgressBar: CategoryProgressBar!
    @IBOutlet weak var foodBarTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var foodBarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leisureLabelTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var leisureProgressBar: CategoryProgressBar!
    @IBOutlet weak var leisureBarTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var leisureBarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var exerciseLabelTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var exerciseProgressBar: CategoryProgressBar!
    @IBOutlet weak var exerciseBarTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var exerciseBarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selfcareLabelTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var selfcareProgressBar: CategoryProgressBar!
    @IBOutlet weak var selfcareBarTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var selfcareBarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var otherLabelTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var otherProgressBar: CategoryProgressBar!
    @IBOutlet weak var otherBarTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var otherBarWidthConstraint: NSLayoutConstraint!
    
    let personalDatabase = PersonalRealmDatabase.sharedInstance
    
    var barArray: [[String : Any]] = []
    
    var categoryArray: [(key: String, value: Int)]?
    
    var barsAnimated: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureBar()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutSubviews()
        
        if barsAnimated == false {
            
            calcCategoryProgress()
            
            barsAnimated = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func configureBar () {
        
        workProgressBar.category = "Work"
        workBarWidthConstraint.constant = 0
        barArray.append(["labelTopAnchor" : workLabelTopAnchor!, "bar" : workProgressBar!, "barTopAnchor" : workBarTopAnchor!, "widthConstraint" : workBarWidthConstraint!])
        
        creativityProgressBar.category = "Creativity"
        creativityBarWidthConstraint.constant = 0
        barArray.append(["labelTopAnchor" : creativityLabelTopAnchor!, "bar" : creativityProgressBar!, "barTopAnchor" : creativityBarTopAnchor!, "widthConstraint" : creativityBarWidthConstraint!])
        
        sleepProgressBar.category = "Sleep"
        sleepBarWidthConstraint.constant = 0
        barArray.append(["labelTopAnchor" : sleepLabelTopAnchor!, "bar" : sleepProgressBar!, "barTopAnchor" : sleepBarTopAnchor!, "widthConstraint" : sleepBarWidthConstraint!])
        
        foodProgressBar.category = "Food/Eat"
        foodBarWidthConstraint.constant = 0
        barArray.append(["labelTopAnchor" : foodLabelTopAnchor!, "bar" : foodProgressBar!, "barTopAnchor" : foodBarTopAnchor!, "widthConstraint" : foodBarWidthConstraint!])
        
        leisureProgressBar.category = "Leisure"
        leisureBarWidthConstraint.constant = 0
        barArray.append(["labelTopAnchor" : leisureLabelTopAnchor!, "bar" : leisureProgressBar!, "barTopAnchor" : leisureBarTopAnchor!, "widthConstraint" : leisureBarWidthConstraint!])
        
        exerciseProgressBar.category = "Exercise"
        exerciseBarWidthConstraint.constant = 0
        barArray.append(["labelTopAnchor" : exerciseLabelTopAnchor!, "bar" : exerciseProgressBar!, "barTopAnchor" : exerciseBarTopAnchor!, "widthConstraint" : exerciseBarWidthConstraint!])
        
        selfcareProgressBar.category = "Self-Care"
        selfcareBarWidthConstraint.constant = 0
        barArray.append(["labelTopAnchor" : selfcareLabelTopAnchor!, "bar" : selfcareProgressBar!, "barTopAnchor" : selfcareBarTopAnchor!, "widthConstraint" : selfcareBarWidthConstraint!])
        
        otherProgressBar.category = "Other"
        otherBarWidthConstraint.constant = 0
        barArray.append(["labelTopAnchor" : otherLabelTopAnchor!, "bar" : otherProgressBar!, "barTopAnchor" : otherBarTopAnchor!, "widthConstraint" : otherBarWidthConstraint!])
    }
    
    private func calcCategoryProgress () {
        
        var blockCount: Int = 0
        var categoryCount: [String : Int] = ["Work" : 0, "Creativity" : 0, "Sleep" : 0, "Food/Eat" : 0, "Leisure" : 0, "Exercise" : 0, "Self-Care" : 0, "Other" : 0]
        
        if let blockArray = personalDatabase.blockArray {
            
            blockCount = blockArray.count
            
            for block in blockArray {
                
                categoryCount[block.category]! += 1
            }

            categoryArray = categoryCount.sorted(by: {$0.value > $1.value})
            
            animateBarTopAnchor(categoryArray, animateUp: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                self.animateBarWidth(blockCount, categoryCount)
            }
        }
    }
    
    func animateBarTopAnchor (_ categoryArray: [(key: String, value: Int)]?, animateUp: Bool, duration: Double = 0) {
        
        if animateUp == true {
            
            guard let array = categoryArray else { return }
            
            var count: Int = 0
            
            while count < array.count {
                
                for bars in barArray {
                    
                    let bar = bars["bar"] as! CategoryProgressBar
                    let barLabelTopAnchor = bars["labelTopAnchor"] as! NSLayoutConstraint
                    let barTopAnchor = bars["barTopAnchor"] as! NSLayoutConstraint
                    
                    if bar.category == array[count].key {
                        
                        barLabelTopAnchor.constant = CGFloat(30 + (50 * count))
                        barTopAnchor.constant = CGFloat(35 + (50 * count))
                        
                        UIView.animate(withDuration: duration) {
                             
                            self.layoutIfNeeded()
                         }
                    }
                }
                
                count += 1
            }
        }
        
        else {
            
            var count: Int = 0
            
            for bars in barArray {
                
                //let bar = bars["bar"] as! CategoryProgressBar
                let barLabelTopAnchor = bars["labelTopAnchor"] as! NSLayoutConstraint
                let barTopAnchor = bars["barTopAnchor"] as! NSLayoutConstraint
                
                barLabelTopAnchor.constant = CGFloat(30 + (50 * count))
                barTopAnchor.constant = CGFloat(35 + (50 * count))
                
                UIView.animate(withDuration: duration) {
                    
                    self.layoutIfNeeded()
                }
                
                count += 1
            }
        }
    }
    
    private func animateBarWidth (_ blockCount: Int, _ categoryCount: [String : Int]) {
        
        for bars in barArray {
            
            let bar = bars["bar"] as! CategoryProgressBar
            let barWidthConstraint = bars["widthConstraint"] as! NSLayoutConstraint
            let barWidth = (Double(categoryCount[bar.category!] ?? 0) / Double(blockCount)) * Double(trackBar.frame.width - 6)
            
            barWidthConstraint.constant = CGFloat(barWidth)
            
            UIView.animate(withDuration: 1.9) {
                 
                self.layoutIfNeeded()
             }
        }

    }
    
}
