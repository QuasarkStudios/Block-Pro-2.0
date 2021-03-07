//
//  CollabView+Blocks.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/16/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

extension CollabViewController {
    
    //MARK: - Retrieve Blocks
    
    func retrieveBlocks () {
        
        var scrollToFirstBlock: Bool = true
        
        if collab != nil {
            
            firebaseBlock.retrieveCollabBlocks(collab!) { [weak self] (error, retrievedBlocks) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                }
                
                else {
                    
                    if self?.blocks == nil {
                        
                        self?.blocks = []
                    }
                    
                    //Setting the sorted retrievedBlocks to the blocks array for the collabViewController
                    self?.blocks = retrievedBlocks?.sorted(by: { $0.starts! < $1.starts! })
                    
                    //Setting the blocks to the collabHomeMembersCell so each members progress can be recalculated
                    if let cell = self?.collabHomeTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CollabHomeMembersCell {
                        
                        cell.blocks = self?.blocks
                    }
                    
                    //Removing any deleted blocks notifications and rescheduling all blocks notifications just in case their times may have changed
                    self?.removeDeletedBlockNotifications(self?.collab?.collabID ?? "", self?.blocks, completion: {
                        
                        self?.rescheduleBlockNotifications(self?.blocks)
                    })
                                                 
                                                         
                    //Sets the blocks for the memberProfileVC only if it is presented
                    self?.memberProfileVC?.blocks = self?.blocks
                    
                    if self?.selectedTab == "Blocks" {
                        
                        self?.collabNavigationView.collabTableView.reloadData()
                        self?.collabNavigationView.calendarView.reloadData()
                        
                        if self?.calendarPresented ?? false {
                            
                            //Will reload the calendar when the blocks are set
                            self?.collabCalendarView.blocks = self?.blocks
                        }
                        
                        if scrollToFirstBlock {
                            
                            self?.scrollToFirstBlock()
                            scrollToFirstBlock = false
                        }
                    }
                    
                    else if self?.selectedTab == "Progress" {
                        
                        self?.collabNavigationView.collabProgressView.blocks = retrievedBlocks
                        
                        //If the blocks aren't filtered meaning no search is ongoing and the block haven't been filtered by a status
                        if !(self?.blocksFiltered ?? true) {
                            
                            self?.collabNavigationView.collabTableView.reloadData()
                        }
                        
                        else {
                            
                            for block in self?.filteredBlocks ?? [] {
                                
                                //Find the blockIndex for a certain filtered block
                                if let blockIndex = self?.filteredBlocks.firstIndex(where: { $0.blockID == block.blockID }) {
                                    
                                    //If this filtered block exists in the retrievedBlocks
                                    if let retrievedBlock = retrievedBlocks?.first(where: { $0.blockID == block.blockID }) {
                                        
                                        self?.filteredBlocks[blockIndex] = retrievedBlock
                                    }
                                    
                                    //If this filtered block doesn't exist in the retrievedBlocks signaling that this block was deleted
                                    else {
                                        
                                        self?.filteredBlocks.remove(at: blockIndex)
                                    }
                                }
                                
                                //If this block doesn't exist in the filteredBlocks array, signaling that it was just created
                                else {
                                    
                                    self?.filteredBlocks.append(block)
                                }
                            }
                            
                            self?.filteredBlocks.sort(by: { $0.starts! < $1.starts! })
                            
                            self?.collabNavigationView.collabTableView.reloadData()
                        }
                        
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                            
                            self?.collabNavigationView.handleProgressAnimation()
                            
                            self?.view.layoutIfNeeded()
                        }
                    }
                    
                    //Determining which blocks should be hidden in the collabNavigationView
                    self?.determineHiddenBlocks(self!.collabNavigationView.collabTableView)
                }
            }
            
            scrollToCurrentDate()
        }
    }
    
    
    //MARK: - Scroll To Current Date
    
    func scrollToCurrentDate () {
        
        if collab != nil {
            
            if var startTime = collab?.dates["startTime"], var deadline = collab?.dates["deadline"] {
                
                //Formatting the startTime and deadline so that the only the date and not the time is truly used
                formatter.dateFormat = "yyyy MM dd"
                
                startTime = formatter.date(from: formatter.string(from: startTime)) ?? Date()
                deadline = formatter.date(from: formatter.string(from: deadline)) ?? Date()
                
                let currentDate = Date()
                
                if currentDate.isBetween(startDate: startTime, endDate: deadline) {
                    
                    collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: calendar.dateComponents([.day], from: startTime, to: currentDate).day ?? 0, section: 0), at: .top, animated: false)
                }
                
                else if currentDate <= startTime {
                    
                    //Scrolls to the first row
                    collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
                
                else if currentDate >= deadline {
                    
                    //Scrolls to the last row
                    collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: calendar.dateComponents([.day], from: startTime, to: deadline).day ?? 0, section: 0), at: .top, animated: false)
                }
            }
        }
    }
    
    
    //MARK: - Scroll to First Block
    
    func scrollToFirstBlock (indexPathToScrollTo: IndexPath? = nil, animate: Bool = true) {
        
        //If an indexPath was passed in, likely meaning this func was called after a new date was selected
        if let collabStartTime = collab?.dates["startTime"], let indexPath = indexPathToScrollTo, let date = calendar.date(byAdding: .day, value: indexPath.row, to: collabStartTime) {
            
            var blocksForSelectedDate: [Block] = []

            for block in blocks ?? [] {
                
                //If this block is in the day of selected date
                if let starts = block.starts, calendar.isDate(starts, inSameDayAs: date) {
                    
                    blocksForSelectedDate.append(block)
                }
            }
            
            //Sorting the blocks
            blocksForSelectedDate.sort(by: { $0.starts! < $1.starts! })
            
            if let firstBlock = blocksForSelectedDate.first {
                
                //ycoord
                let blockStartHour = calendar.dateComponents([.hour], from: firstBlock.starts!).hour!
                let blockStartMinute = calendar.dateComponents([.minute], from: firstBlock.starts!).minute!
                let yCoord = CGFloat((Double(blockStartHour) * 90) + (Double(blockStartMinute) * 1.5)) + 50
                
                collabNavigationView.collabTableView.setContentOffset(CGPoint(x: 0, y: (CGFloat(2210 * indexPath.row)) + yCoord), animated: animate)
            }
            
            //If no block has yet been created for the selected date
            else {
                
                self.collabNavigationView.collabTableView.scrollToRow(at: indexPath, at: .top, animated: animate)
            }
        }
        
        //If no indexPath was passed in, likely meaning this func was called when retrieving blocks for the first time
        else if let indexPath = collabNavigationView.collabTableView.indexPathsForVisibleRows?.last {
            
            if let cell = collabNavigationView.collabTableView.cellForRow(at: indexPath) as? BlocksTableViewCell {
                
                var blocks = cell.blocks
                blocks?.sort(by: { $0.starts! < $1.starts! })
                
                //Scrolling to the first block for the selected date
                if let firstBlock = blocks?.first {
                    
                    //ycoord
                    let blockStartHour = calendar.dateComponents([.hour], from: firstBlock.starts!).hour!
                    let blockStartMinute = calendar.dateComponents([.minute], from: firstBlock.starts!).minute!
                    let yCoord = CGFloat((Double(blockStartHour) * 90) + (Double(blockStartMinute) * 1.5)) + 50
                    
                    UIView.animate(withDuration: 0, delay: 0, options: .curveEaseInOut) {
                        
                        self.collabNavigationView.collabTableView.contentOffset.y += yCoord
                    }
                }
            }
        }
    }
    
    
    //MARK: - Remove Block Notifications
    
    private func removeDeletedBlockNotifications (_ collabID: String, _ blocks: [Block]?, completion: @escaping (() -> Void)) {
        
        notificationScheduler.getPendingNotifications { [weak self] (requests) in
            
            var remindersToDelete: [String] = []
            
            for request in requests {
                
                //If the identifier contains the collabID and contains the phrase "blockID" signifying that it's a notification for a block
                if request.identifier.contains(collabID) && request.identifier.contains("blockID:") {
                    
                    //Tracks whether or not the reminder should be deleted
                    var deleteReminder: Bool = true
                    
                    for block in blocks ?? [] {
                        
                        //If the requestID is for a block that still exists/has not been deleted
                        if let blockID = block.blockID, request.identifier.contains(blockID) {
                            
                            deleteReminder = false
                            break
                        }
                    }
                    
                    //If the requestID has a blockID that does not correspond with any block retrieved from Firebase -- likely because the block has been deleted by another user
                    if deleteReminder {
                        
                        remindersToDelete.append(request.identifier)
                    }
                }
            }
            
            self?.notificationScheduler.removeNotifications(identifers: remindersToDelete)
            
            completion()
        }
    }
    
    
    //MARK: - Reschedule Block Notifications
    
    private func rescheduleBlockNotifications (_ retrievedBlocks: [Block]?) {
        
        var blocks: [Block] = []
        retrievedBlocks?.forEach({ blocks.append($0) }) //Appending the retrieved blocks to the local block array of this func
        
        notificationScheduler.getPendingNotifications { [weak self] (requests) in
            
            var count = 0
            
            while count < blocks.count {
                
                if let blockID = blocks[count].blockID {
                    
                    for request in requests {
                        
                        //If a request identifier contains the blockID
                        if request.identifier.contains(blockID) {
                            
                            let requestID = Array(request.identifier)
                            
                            //Get the last char in the identifier's string, which will be used to determine which reminder the user selected
                            if let reminder = requestID.last, Int(String(reminder)) != nil {
                                
                                if blocks[count].reminders == nil {
                                    
                                    blocks[count].reminders = []
                                }
                                
                                //Appending the selected reminder
                                blocks[count].reminders?.append(Int(String(reminder))!)
                            }
                        }
                    }
                }
                
                //Rescheduling the block notifications -- will overwrite any pending notifications that have not been sent yet
                self?.notificationScheduler.scheduleCollabBlockNotifications(collab: self?.collab, blocks[count])
                
                count += 1
            }
        }
    }
}


//MARK: - Block Created Protocol

extension CollabViewController: BlockCreatedProtocol {
    
    func blockCreated (_ block: Block) {
        
        formatter.dateFormat = "yyyy MM dd"
        
        if let collabStartTime = formatter.date(from: formatter.string(from: collab?.dates["startTime"] ?? Date())), let blockStartTime = block.starts {
            
            //yCoordForDay
            let yCoordForDay: CGFloat = CGFloat(calendar.dateComponents([.day], from: collabStartTime, to: blockStartTime).day ?? 0) * 2210
            
            //yCoordForBlockTime
            let blockStartHour = calendar.dateComponents([.hour], from: blockStartTime).hour!
            let blockStartMinute = calendar.dateComponents([.minute], from: blockStartTime).minute!
            let yCoordForBlockTime = CGFloat((Double(blockStartHour) * 90) + (Double(blockStartMinute) * 1.5)) + 50
            
            collabNavigationView.collabTableView.contentOffset.y = yCoordForDay + yCoordForBlockTime
            
            collabCalendarView.calendarView.selectDates([blockStartTime])
            collabCalendarView.calendarView.scrollToDate(blockStartTime)
            
            collabNavigationView.calendarView.selectDates([blockStartTime])
            collabNavigationView.calendarView.scrollToDate(blockStartTime)
        }
    }
}


//MARK: - Block Selected Protocol

extension CollabViewController: BlockSelectedProtocol {
    
    func blockSelected (_ block: Block) {
        
        selectedBlock = block
        
        performSegue(withIdentifier: "moveToSelectedBlockView", sender: self)
    }
}
