//
//  CollabView+TableViewExtension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/25/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation
import SVProgressHUD

extension CollabViewController: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Number of Rows
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == collabHomeTableView {
            
            return 12
        }
        
        else {
            
            if selectedTab == "Progress" {
                
                return blocksFiltered ? filteredBlocks.count : blocks?.count ?? 0
            }
            
            else if selectedTab == "Blocks" {
                
                if var startTime = collab?.dates["startTime"], var deadline = collab?.dates["deadline"] {

                    //Formatting the startTime and deadline so that the only the date and not the time is truly used
                    formatter.dateFormat = "yyyy MM dd"
                    startTime = formatter.date(from: formatter.string(from: startTime)) ?? Date()
                    deadline = formatter.date(from: formatter.string(from: deadline)) ?? Date()
                    
                    if let days = calendar.dateComponents([.day], from: startTime, to: deadline).day, days != 0 {

                        return days + 1
                    }

                    else {

                        //Collab that is less than one day long
                        return 1
                    }
                }

                else {

                    return 1
                }
            }
            
            else if selectedTab == "Messages" {
                
                return messagingMethods.numberOfRowsInSection(messages: messages)
            }
            
            else {
                
                return 1 //Will be used to during tab transitions
            }
        }
    }
    
    
    //MARK: - Cell for Row
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        if tableView == collabHomeTableView {
            
            if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeMembersCell", for: indexPath) as! CollabHomeMembersCell
                cell.selectionStyle = .none
                
                cell.collabMemberDelegate = self
                
                cell.collab = collab
                cell.blocks = blocks
                
                return cell
            }
            
            else if indexPath.row == 3 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationsPresentationCell", for: indexPath) as! LocationsPresentationCell
                cell.selectionStyle = .none
                
                cell.locations = collab?.locations
                
                cell.locationSelectedDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 5 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "photosPresentationCell", for: indexPath) as! PhotosPresentationCell
                cell.selectionStyle = .none
                
                cell.collab = collab
                cell.photoIDs = collab?.photoIDs
                
                cell.cachePhotoDelegate = self
                cell.zoomInDelegate = self
                cell.presentCopiedAnimationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 7 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "voiceMemosPresentationCell", for: indexPath) as! VoiceMemosPresentationCell
                cell.selectionStyle = .none
                
                cell.collab = collab
                
                cell.voiceMemos = collab?.voiceMemos
                
                return cell
            }
            
            else if indexPath.row == 9 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "linksPresentationCell", for: indexPath) as! LinksPresentationCell
                cell.selectionStyle = .none
                
                cell.links = collab?.links
                
                cell.cacheIconDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 11 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeEdit_LeaveCell", for: indexPath) as! CollabHomeEdit_LeaveCell
                cell.selectionStyle = .none
                
                cell.collab = collab
                
                cell.collabViewController = self
                
                return cell
            }
            
            else {
                
                let cell = UITableViewCell()
                cell.isUserInteractionEnabled = false
                return cell
            }
        }
        
        else {
            
            if selectedTab == "Progress" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! BlockCell
                cell.selectionStyle = .none
                
                cell.formatter = formatter
                cell.block = blocksFiltered ? filteredBlocks[indexPath.row] : blocks?[indexPath.row]
                
                return cell
            }
            
            else if selectedTab == "Blocks" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "blocksTableViewCell", for: indexPath) as! BlocksTableViewCell
                cell.selectionStyle = .none
                
                cell.collab = collab
                cell.blockSelectedDelegate = self
                
                if let startTime = collab?.dates["startTime"], let dateForCell = calendar.date(byAdding: .day, value: indexPath.row, to: startTime) {
                    
                    cell.blocks = blocks?.filter({ calendar.isDate($0.starts!, inSameDayAs: dateForCell) }).sorted(by: { $0.starts! < $1.starts! })
                }
                
                return cell
            }
            
            else if selectedTab == "Messages" {
                
                return messagingMethods.cellForRowAt(indexPath: indexPath, messages: messages, members: collab?.historicMembers)
            }
            
            else {
                
                //Will be used to during tab transitions
                let cell = UITableViewCell()
                cell.isUserInteractionEnabled = false
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == collabHomeTableView {
            
            switch indexPath.row {
            
                //Buffer cell
                case 0:
                    
                    return 10
                   
                //Members Presentation Cell
                case 1:
                    
                    if collab?.currentMembers.count ?? 0 > 1 {

                        return 160
                    }

                    else {

                        return 132.5
                    }
                 
                //Buffer Cell
                case 2:
                    
                    return collab?.currentMembers.count ?? 0 > 1 ? 10 : 25
                  
                //Locations Presentation Cell
                case 3:
                    
                    if collab?.locations?.count ?? 0 == 0 {
                        
                        return itemSize + 30 + 20
                    }
                    
                    else if collab?.locations?.count == 1 {
                        
                        return 210
                    }
                    
                    else {
                        
                        return 252.5
                    }
                  
                //Buffer Cell
                case 4:

                    return collab?.locations?.count ?? 0 > 1 ? 0 : 25
                   
                //Photos Presentation Cell
                case 5 :
                    
                    if collab?.photoIDs.count ?? 0 <= 3 {
                        
                        return itemSize + 30 + 20
                    }
                    
                    else {
                        
                        return (itemSize * 2) + 30 + 20 + 5
                    }
                  
                //Voice Presentation Memos Cell
                case 7:
                    
                    return itemSize + 30 + 20
                  
                //Links Presentation Cell
                case 9:
                    
                    if collab?.links?.count ?? 0 == 0 {
                        
                        return itemSize + 30 + 20
                    }
                    
                    else if collab?.links?.count ?? 0 < 3 {
                        
                        return 130
                    }
                    
                    else {
                        
                        return 157.5
                    }
                  
                //Buffer Cell
                case 10:
                    
                    return 30
                   
                //Edit-Leave Cell
                case 11:
                    
                    return 50
                
                default:
                    
                    return 25
                
            }
        }
        
        else {
            
            if selectedTab == "Progress" {
                
                if blocksFiltered {
                    
                    //If the block for the blockCell has members assigned to it
                    if filteredBlocks[indexPath.row].members?.count ?? 0 > 0 {
                        
                        return 210
                    }
                    
                    else {
                        
                        return 175
                    }
                }
                
                else {
                    
                    //If the block for the blockCell has members assigned to it
                    if blocks?[indexPath.row].members?.count ?? 0 > 0 {
                        
                        return 210
                    }
                    
                    else {
                        
                        return 175
                    }
                }
                
                
            }
            
            else if selectedTab == "Blocks" {
                
                return 2210
            }
            
            else if selectedTab == "Messages" {
                
                return messagingMethods.heightForRowAt(indexPath: indexPath, messages: messages)
            }
            
            else {
                
                return 500 //Will be used to during tab transitions
            }
        }
    }
    
    
    //MARK: - Will Display Cell
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //If it's the "collabHomeTableView", the Edit-Delete cell is being presented, and "enableTabBarVisibilityHandling" is true
        //"enableTabBarVisibilityHandling" being true signifies that the view has appeared
        if tableView == collabHomeTableView && indexPath.row == (tableView.numberOfRows(inSection: 0) - 1), enableTabBarVisibiltyHandling {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.presentCollabNavigationViewButton.alpha = 0
                self.tabBar.alpha = 0
            }
        }
    }
    
    
    //MARK: - Did End Displaying Cell
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == collabHomeTableView && indexPath.row == (tableView.numberOfRows(inSection: 0) - 1) {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.presentCollabNavigationViewButton.alpha = 1
                self.tabBar.alpha = 1
            }
        }
    }
    
    
    //MARK: - Did Select Row At
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == collabNavigationView.collabTableView, selectedTab == "Progress" {
            
            if let cell = tableView.cellForRow(at: indexPath) as? BlockCell {
                
                if let block = blocks?.first(where: { $0.blockID == cell.block?.blockID }) {
                    
                    selectedBlock = block
                    
                    performSegue(withIdentifier: "moveToSelectedBlockView", sender: self)
                }
                
                else {
                    
                    SVProgressHUD.showError(withStatus: "Sorry, this block may have been deleted")
                }
            }
        }
    }
    
    
    //MARK: - Scroll View Did Scroll
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == collabHomeTableView {
            
            if scrollView.contentOffset.y >= 0 {
                
                if ((collabHeaderViewHeightConstraint?.constant ?? 0) - scrollView.contentOffset.y) > topBarHeight {
                    
                    collabHeaderViewHeightConstraint?.constant -= scrollView.contentOffset.y
                    scrollView.contentOffset.y = 0
                    
                    let alphaPart = 1 / (collabHeaderView.configureViewHeight() - 70 - topBarHeight)
                    collabHeaderView.alpha = alphaPart * (collabHeaderViewHeightConstraint!.constant - topBarHeight)
                }
                
                else {
                    
                    collabHeaderViewHeightConstraint?.constant = topBarHeight
                    collabHeaderView.alpha = 0
                    
                    self.title = collab?.name
                    navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
                }
            }
            
            else {
                
                self.title = nil
                navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
                
                if (collabHeaderViewHeightConstraint?.constant ?? 0) < collabHeaderView.configureViewHeight() - 70 {
                    
                    collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight() - 70
                    
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                        self.view.layoutIfNeeded()
                    })
                }

                else {
                    
//                    collabHeaderViewHeightConstraint?.constant = (collabHeaderView.configureViewHeight() - 80) + abs(scrollView.contentOffset.y)
                }
            }
        }
        
        else {
            
            if selectedTab == "Progress" {
                
                if scrollView.contentOffset.y >= 0 {
                    
                    //If the progress view height minus the scrollView contentOffset is larger than 67, it's minimum allowable height
                    if (collabNavigationView.progressViewHeightConstraint?.constant ?? 67) - scrollView.contentOffset.y > 67 {
                        
                        collabNavigationView.progressViewHeightConstraint?.constant -= scrollView.contentOffset.y //Decrementing the height of the progressView
                        
                        collabNavigationView.tableViewTopAnchorWithStackView?.constant -= scrollView.contentOffset.y //Decrementing the topAnchor of the tableView
                        
                        scrollView.contentOffset.y = 0
                    }
                    
                    //If the progress view height minus the scrollView contentOffset is less than 67
                    else {
                        
                        //This height will only allow the searchBar to be shown
                        collabNavigationView.progressViewHeightConstraint?.constant = 67
                        
                        //If the collabNavigationView is expanded
                        if navigationItem.hidesBackButton {
                            
                            //Setting the top anchor based on if the iPhone has a notch -- an iPhone with a notch will cause the progressView to have a larger topAnchor
                            //Therefore the top anchor of the tableView will also have to be larger by 20 points to compensate
                            collabNavigationView.tableViewTopAnchorWithStackView?.constant = keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 92 : 72
                        }
                        
                        //The collabNavigationView isn't expanded
                        else {
                            
                            //Setting the topAnchor when only the searchBar of the collabProgress view is shown
                            collabNavigationView.tableViewTopAnchorWithStackView?.constant = 72
                        }
                    }
                }
                
                else {
                    
                    let maximumProgressViewHeight: CGFloat = ((UIScreen.main.bounds.width * 0.5) + 12 + 55) + 87
                    
                    //If the progressView height is less than the maximum allowable height for the progressView
                    if collabNavigationView.progressViewHeightConstraint?.constant ?? 87 < maximumProgressViewHeight {
                        
                        collabNavigationView.progressViewHeightConstraint?.constant = maximumProgressViewHeight
                        
                        //If the collabNavigationView is expanded
                        if navigationItem.hidesBackButton {
                            
                            //Setting the top anchor based on if the iPhone has a notch -- an iPhone with a notch will cause the progressView to have a larger topAnchor
                            //Therefore the top anchor of the tableView will also have to be larger by 20 points to compensate
                            collabNavigationView.tableViewTopAnchorWithStackView?.constant = maximumProgressViewHeight + (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0)
                        }
                        
                        //The collabNavigationView isn't expanded
                        else {
                            
                            //Setting to the value that won't cause the tableView constraints to break
                            collabNavigationView.tableViewTopAnchorWithStackView?.constant = collabNavigationView.maximumTableViewTopAnchorWithStackView
                        }
                        
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                            
                            self.collabNavigationView.layoutIfNeeded()
                        }
                    }
                }
            }
            
            else if selectedTab == "Blocks" {
                
                //If the tableView is scrolling down
                if previousContentOffsetYCoord < scrollView.contentOffset.y {
                    
                    if let firstVisibleCellIndexPath = collabNavigationView.collabTableView.indexPathsForVisibleRows?.first {
                        
                        //"isDragging" checks if the user is the one who caused the scrollView to scroll
                        if let startTime = collab?.dates["startTime"], let adjustedDate = calendar.date(byAdding: .day, value: firstVisibleCellIndexPath.row, to: startTime), !calendar.isDate(adjustedDate, inSameDayAs: collabNavigationView.calendarView.selectedDates.first ?? Date()), scrollView.isDragging {
                            
                            collabCalendarView.calendarView.selectDates([adjustedDate])
                            collabCalendarView.calendarView.scrollToDate(adjustedDate)
                            
                            collabNavigationView.calendarView.selectDates([adjustedDate])
                            collabNavigationView.calendarView.scrollToDate(adjustedDate)

                            let vibrateMethods = VibrateMethods()
                            vibrateMethods.warningVibration()
                        }
                    }
                }
                
                //If the tableView is scrolling up
                else {
                    
                    if let lastVisibleCellIndexPath = collabNavigationView.collabTableView.indexPathsForVisibleRows?.last {
                
                        //"isDragging" checks if the user is the one who caused the scrollView to scroll
                        if let startTime = collab?.dates["startTime"], let adjustedDate = calendar.date(byAdding: .day, value: lastVisibleCellIndexPath.row, to: startTime), !calendar.isDate(adjustedDate, inSameDayAs: collabNavigationView.calendarView.selectedDates.first ?? Date()), scrollView.isDragging {
                            
                            collabCalendarView.calendarView.selectDates([adjustedDate])
                            collabCalendarView.calendarView.scrollToDate(adjustedDate)
                            
                            collabNavigationView.calendarView.selectDates([adjustedDate])
                            collabNavigationView.calendarView.scrollToDate(adjustedDate)
                
                            let vibrateMethods = VibrateMethods()
                            vibrateMethods.warningVibration()
                        }
                    }
                }
                
                previousContentOffsetYCoord = scrollView.contentOffset.y
                
                determineHiddenBlocks(scrollView)
            }
        }
    }
    
    
    //MARK: - Should Scroll To Top
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        
        if let startTime = collab?.dates["startTime"] {
            
            collabCalendarView.calendarView.selectDates([startTime])
            collabCalendarView.calendarView.scrollToDate(startTime)
            
            collabNavigationView.calendarView.selectDates([startTime])
            collabNavigationView.calendarView.scrollToDate(startTime)
        }
        
        return true
    }
    
    
    //MARK: - Scroll View Will End Dragging
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == collabNavigationView.collabTableView {
            
            if selectedTab == "Progress" {
                
                let progressViewHeight: CGFloat = ((UIScreen.main.bounds.width * 0.5) + 12 + 55) + 87
                
                if (collabNavigationView.progressViewHeightConstraint?.constant ?? 0) < progressViewHeight * 0.7 && (collabNavigationView.progressViewHeightConstraint?.constant ?? 0) != 67 {
                    
                    //This height will only allow the searchBar to be shown
                    collabNavigationView.progressViewHeightConstraint?.constant = 67
                    
                    //If the collabNavigationView is expanded
                    if navigationItem.hidesBackButton {
                        
                        //Setting the top anchor based on if the iPhone has a notch -- an iPhone with a notch will cause the progressView to have a larger topAnchor
                        //Therefore the top anchor of the tableView will also have to be larger by 20 points to compensate
                        collabNavigationView.tableViewTopAnchorWithStackView?.constant = keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 92 : 72
                    }
                    
                    //The collabNavigationView isn't expanded
                    else {
                        
                        //Setting the topAnchor when only the searchBar of the collabProgress view is shown
                        collabNavigationView.tableViewTopAnchorWithStackView?.constant = 72
                    }
                    
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        
                        self.view.layoutIfNeeded()
                    }

                }
                
                //Will handle the progress animation
                if blocks?.count ?? 0 == 0 {
                    
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        
                        self.collabNavigationView.handleProgressAnimation()
                        
                        self.view.layoutIfNeeded()
                    }
                }
            }
            
            else if selectedTab == "Blocks" {
                
                //If the calendar isn't presented
                //If the calendar is presented and the "collabNavigationView" has a height that doesn't require the "addBlockButton" and "tabBar" to be hidden
                //If the calendar is presented and the view is expanded
                if !calendarPresented || (calendarPresented && (self.addBlockButton.frame.minY - 330 >= 200 || collabNavigationViewTopAnchor?.constant ?? 0 == 0)) {
                    
                    if velocity.y < 0 {
                        
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                            
                            self.addBlockButton.alpha = 1
                            self.tabBar.alpha = 1
                        }
                    }
                    
                    else if velocity.y > 0.5 {
                        
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                            
                            self.addBlockButton.alpha = 0
                            self.tabBar.alpha = 0
                        }
                    }
                }
            }
        }
    }
}
