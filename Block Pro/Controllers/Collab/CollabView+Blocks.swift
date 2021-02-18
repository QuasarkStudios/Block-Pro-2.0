//
//  CollabView+Blocks.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/16/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

extension CollabViewController {
    
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
                    
                    self?.blocks = retrievedBlocks?.sorted(by: { $0.starts! < $1.starts! })
                    
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
                    
                    self?.determineHiddenBlocks(self!.collabNavigationView.collabTableView)
                }
            }
            
            scrollToCurrentDate()
        }
    }
    
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
                    
                    collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
                
                else if currentDate >= deadline {
                    
                    collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: calendar.dateComponents([.day], from: startTime, to: deadline).day ?? 0, section: 0), at: .top, animated: false)
                }
            }
        }
    }
    
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
}

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

extension CollabViewController: BlockSelectedProtocol {
    
    func blockSelected (_ block: Block) {
        
        selectedBlock = block
        
        performSegue(withIdentifier: "moveToSelectedBlockView", sender: self)
    }
}
