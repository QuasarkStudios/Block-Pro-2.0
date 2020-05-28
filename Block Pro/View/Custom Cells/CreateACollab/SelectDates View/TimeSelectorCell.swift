//
//  TimeSelectorCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/20/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

/*
 
 
 
 
 
OK
 
 
So this view has a good amount of problems that should be fixed. For right now, it's working well on the phones that share the width of the iPhone 11 Pro and getting along on phones that share the width of the iPhone 11 Pro Max. However, on any other phone (i.e. the iPhone SE), it's pretty buggy. I feel indifferent about leaving it in this state, but I'm pretty sure I'm going to need to rebuild this in future view so I'm hoping to figure out the issues in those future iterations.
 
 I had to do some funny things to adjust the content offset which where odd, the cell count is random, new views sizes through everythinf off (which they should, but you know), etc....
 
 A large part of me belives that if I build this more carefully in the future, I will be able to identify and fix all the bugs that plagued this version... well shit we'll see lol
 
 
 
 
 
 
*/
protocol TimeSelectorCellProtocol: AnyObject {
    
    func startTimeSelected (time: Date)
    func deadlineTimeSelected(time: Date)
}

class TimeSelectorCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var containerWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var starts_deadlineLabel: UILabel!
    @IBOutlet weak var selectedTimeLabel: UILabel!
    @IBOutlet weak var timeSelectorCollectionView: UICollectionView!
    
    @IBOutlet weak var selectedTimeIndicator: UIView!
    
    let formatter = DateFormatter()
    
    var selectedStartTime: Date?
    var selectedDeadlineTime: Date?
    
    weak var timeSelectorCellDelegate: TimeSelectorCellProtocol?
    
    var cellInitiallyLoaded: Bool = false
    
    var selectedSegment: String? {
        didSet {
            
            if selectedSegment! == "starts" {
                
                starts_deadlineLabel.text = "Starts"
                calcSelectedIndex(start: true)
            }
            
            else {
                
                starts_deadlineLabel.text = "Deadline"
                calcSelectedIndex(start: false)
            }
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCollectionView()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 119 //Random number; actually calc it out in future iterations
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "barCell", for: indexPath) as! BarCell
        
        if indexPath.row % 4 == 0 {
            
            cell.barViewTopAnchor.constant = 10
            cell.barViewBottomAnchor.constant = 10
            cell.barView.layer.cornerRadius = 2
        }
        
        else {
            
            cell.barViewTopAnchor.constant = 15
            cell.barViewBottomAnchor.constant = 15
            cell.barView.layer.cornerRadius = 2
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if minMaxContentOffset(contentOffset: scrollView.contentOffset) == true {
            return
        }
        
        let visibleItems: [IndexPath] = timeSelectorCollectionView.indexPathsForVisibleItems
        
        var count = 0
        
        //Loops through all the visible cells and sees which one intersects with the indicator
        for cell in self.timeSelectorCollectionView.visibleCells {
            
            let cellFrame: CGRect = CGRect(x: cell.frame.minX - timeSelectorCollectionView.contentOffset.x, y: cell.frame.minY, width: cell.frame.width, height: cell.frame.height)
          
            let selectedTimeIndicatorFrame: CGRect = CGRect(x: selectedTimeIndicator.frame.minX, y: 0, width: selectedTimeIndicator.frame.width, height: selectedTimeIndicator.frame.height)
            
            if cellFrame.intersects(selectedTimeIndicatorFrame) {
                
                setSelectedTime(centeredIndex: visibleItems[count].row - 18) // Honestly have no idea why I minused it by 18; literally forgot an hour I did it sooooo fix dat
                
                break
            }

            else {
                
                count += 1
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            
            if starts_deadlineLabel.text == "Starts" {
                
                guard let time = selectedStartTime else { return }
                 
                    timeSelectorCellDelegate?.startTimeSelected(time: time)
            }
            
            else if starts_deadlineLabel.text == "Deadline" {
                
                guard let time = selectedDeadlineTime else { return }
                
                    timeSelectorCellDelegate?.deadlineTimeSelected(time: time)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if starts_deadlineLabel.text == "Starts" {
            
            guard let time = selectedStartTime else { return }
             
                timeSelectorCellDelegate?.startTimeSelected(time: time)
        }
        
        else if starts_deadlineLabel.text == "Deadline" {
            
            guard let time = selectedDeadlineTime else { return }
            
                timeSelectorCellDelegate?.deadlineTimeSelected(time: time)
        }
    }
    
    private func minMaxContentOffset (contentOffset: CGPoint) -> Bool {
        
        //iPhone 11 Pro Max, iPhone 11, and iPhone 8 Plus
        if UIScreen.main.bounds.width == 414.0 {

            if contentOffset.x < 14 {
                
                timeSelectorCollectionView.contentOffset.x = 14
                return true
            }
            
            else if contentOffset.x > 1154 {
                
                timeSelectorCollectionView.contentOffset.x = 1154
                return true
            }
        }

        //iPhone 11 Pro and iPhone 8
        else if UIScreen.main.bounds.width == 375.0 {

            if contentOffset.x < 34 {
                
                timeSelectorCollectionView.contentOffset.x = 34
                return true
            }
            
            else if contentOffset.x > 1173 {
                
                timeSelectorCollectionView.contentOffset.x = 1173
                return true
            }
        }

        //iPhone SE
        else if UIScreen.main.bounds.width == 320.0 {

            if contentOffset.x < 61 {
                
                timeSelectorCollectionView.contentOffset.x = 61
                return true
            }
            
            else if contentOffset.x > 1201 {
                
                timeSelectorCollectionView.contentOffset.x = 1201
                return true
            }
        }

        return false
    }
    
    private func configureCollectionView () {
        
        containerWidthConstraint.constant = UIScreen.main.bounds.width
        
        self.backgroundColor = .white
        
        timeSelectorCollectionView.dataSource = self
        timeSelectorCollectionView.delegate = self
        
        let layout = TimeSelectorCollectionViewFlowLayout()
        
        timeSelectorCollectionView.collectionViewLayout = layout
        
        timeSelectorCollectionView.showsHorizontalScrollIndicator = false
        
        selectedTimeIndicator.layer.cornerRadius = 2.5

        timeSelectorCollectionView.register(UINib(nibName: "BarCell", bundle: nil), forCellWithReuseIdentifier: "barCell")
        
        timeSelectorCollectionView.scrollToItem(at: IndexPath(item: 12, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    private func vibrate (selectedTime: Date, newSelectedTime: Date) {
        
        if selectedTime != newSelectedTime {
            
            let generator: UIImpactFeedbackGenerator?
            
            if #available(iOS 13.0, *) {

                generator = UIImpactFeedbackGenerator(style: .light)
            
            } else {
                
                generator = UIImpactFeedbackGenerator(style: .medium)
            }
            
            
            generator?.impactOccurred()
        }
    }
    
    //Calcs which index to scroll to for a preselected time
    func calcSelectedIndex (start: Bool) {
        
        if start {
            
            formatter.dateFormat = "HH"
            var startHours = Int(formatter.string(from: selectedStartTime!))! * 60
            startHours /= 15

            formatter.dateFormat = "mm"
            let startMinutes = Int(formatter.string(from: selectedStartTime!))! / 15

            let startTime = startHours + startMinutes

            timeSelectorCollectionView.scrollToItem(at: IndexPath(item: startTime + 12, section: 0), at: .centeredHorizontally, animated: cellInitiallyLoaded ? false : true)
            setSelectedTime(centeredIndex: startTime)
        }
        
        else {
            
            formatter.dateFormat = "HH"
            var deadlineHours = Int(formatter.string(from: selectedDeadlineTime!))! * 60
            deadlineHours /= 15
            
            formatter.dateFormat = "mm"
            let deadlineMinutes = Int(formatter.string(from: selectedDeadlineTime!))! / 15
            
            let deadlineTime = deadlineHours + deadlineMinutes
            
            timeSelectorCollectionView.scrollToItem(at: IndexPath(item: deadlineTime + 12, section: 0), at: .centeredHorizontally, animated: cellInitiallyLoaded ? false : true)
            setSelectedTime(centeredIndex: deadlineTime)
        }

    }
    
    private func setSelectedTime (centeredIndex: Int) {
        
        let calendar = Calendar.current
        
        formatter.dateFormat = "hh:mm"
        let twelveAM: Date = formatter.date(from: "00:00")!
        var selectedTime: Date?
        
        selectedTime = calendar.date(byAdding: .minute, value: 15 * centeredIndex, to: twelveAM) //Times 15 cause every 15 mins
        
        guard let time = selectedTime else { return }
        
            formatter.dateFormat = "h:mm a"
            selectedTimeLabel.text = formatter.string(from: time)
        
            if starts_deadlineLabel.text == "Starts" {
                
                vibrate(selectedTime: selectedStartTime!, newSelectedTime: time)
                
                selectedStartTime = time
            }
        
            else if starts_deadlineLabel.text == "Deadline" {
                
                vibrate(selectedTime: selectedDeadlineTime!, newSelectedTime: time)
                
                selectedDeadlineTime = time
            }
    }
}
