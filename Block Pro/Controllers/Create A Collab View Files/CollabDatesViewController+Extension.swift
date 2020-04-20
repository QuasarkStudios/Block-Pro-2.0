//
//  TimeSliderView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/15/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

extension CollabDatesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 119
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
        
        //cell.barView.backgroundColor = .blue
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if minMaxContentOffset(contentOffset: scrollView.contentOffset) == true && !viewInitiallyLoaded {
            return
        }
        
        let visibleItems: [IndexPath] = timeSelectorCollectionView.indexPathsForVisibleItems
        
        var count = 0
        
        for cell in self.timeSelectorCollectionView.visibleCells {
            
            let cellFrame: CGRect = CGRect(x: cell.frame.minX - timeSelectorCollectionView.contentOffset.x, y: cell.frame.minY, width: cell.frame.width, height: cell.frame.height)
          
            let selectedTimeIndicatorFrame: CGRect = CGRect(x: selectedTimeIndicator.frame.minX, y: 0, width: selectedTimeIndicator.frame.width, height: selectedTimeIndicator.frame.height)
            
            if cellFrame.intersects(selectedTimeIndicatorFrame) {
                
                setSelectedTime(centeredIndex: visibleItems[count].row - 18)
                
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
                
                setStartButtonText()
            }
            
            else if starts_deadlineLabel.text == "Deadline" {
                
                setDeadlineButtonText()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if starts_deadlineLabel.text == "Starts" {
            
            setStartButtonText()
        }
        
        else if starts_deadlineLabel.text == "Deadline" {
            
            setDeadlineButtonText()
        }
    }
    
    internal func configureCollectionView () {
        
        timeSelectorContainer.backgroundColor = .white
        
        timeSelectorCollectionView.dataSource = self
        timeSelectorCollectionView.delegate = self
        
        let layout = TimeSelectorCollectionViewFlowLayout()
        
        timeSelectorCollectionView.collectionViewLayout = layout
        
        timeSelectorCollectionView.showsHorizontalScrollIndicator = false
        
        selectedTimeIndicator.layer.cornerRadius = 2.5

        
        //Will probably never be nil thinking about it now// fix 
        if selectedStartTime["startDate"] == nil {

            timeSelectorCollectionView.scrollToItem(at: IndexPath(item: 12, section: 0), at: .centeredHorizontally, animated: false)

        }
        
        else {

            calcSelectedIndex(start: true)
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
    
    internal func calcSelectedIndex (start: Bool) {
        
        if start {
            
            formatter.dateFormat = "HH"
            var startHours = Int(formatter.string(from: selectedStartTime["startTime"]!))! * 60
            startHours /= 15
            
            formatter.dateFormat = "mm"
            let startMinutes = Int(formatter.string(from: selectedStartTime["startTime"]!))! / 15
            
            let startTime = startHours + startMinutes
            
            timeSelectorCollectionView.scrollToItem(at: IndexPath(item: startTime + 12, section: 0), at: .centeredHorizontally, animated: false)
            setSelectedTime(centeredIndex: startTime)
        }
        
        else {
            
            formatter.dateFormat = "HH"
            var deadlineHours = Int(formatter.string(from: selectedDeadline["deadlineTime"]!))! * 60
            deadlineHours /= 15
            
            formatter.dateFormat = "mm"
            let deadlineMinutes = Int(formatter.string(from: selectedDeadline["deadlineTime"]!))! / 15
            
            let deadlineTime = deadlineHours + deadlineMinutes
            
            timeSelectorCollectionView.scrollToItem(at: IndexPath(item: deadlineTime + 12, section: 0), at: .centeredHorizontally, animated: false)
            setSelectedTime(centeredIndex: deadlineTime)
        }
    }
    
    
    
    private func setSelectedTime (centeredIndex: Int) {
        
        let calendar = Calendar.current
        
        formatter.dateFormat = "hh:mm"
        let twelveAM: Date = formatter.date(from: "00:00")!
        var selectedTime: Date?
        
        selectedTime = calendar.date(byAdding: .minute, value: 15 * centeredIndex, to: twelveAM)
        
        guard let time = selectedTime else { return }
        
            formatter.dateFormat = "h:mm a"
            selectedTimeLabel.text = formatter.string(from: time)
        
            if starts_deadlineLabel.text == "Starts" {
                
                selectedStartTime["startTime"] = time
            }
        
            else if starts_deadlineLabel.text == "Deadline" {
                
                selectedDeadline["deadlineTime"] = time
            }
    }
}
