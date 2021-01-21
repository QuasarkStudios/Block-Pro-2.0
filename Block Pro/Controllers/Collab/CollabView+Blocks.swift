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
        
        if collab != nil {
            
            firebaseBlock.retrieveCollabBlocks(collab!) { [weak self] (error, retrievedBlocks) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                }
                
                else {
                    
                    if self?.blocks == nil {
                        
                        self?.blocks = []
                    }
                    
                    self?.blocks = retrievedBlocks
                    
                    if self?.selectedTab == "Blocks" {
                        
                        self?.collabNavigationView.collabTableView.reloadData()
                    }
                }
            }
            
            scrollToCurrentDate()
        }
    }
    
    func scrollToCurrentDate () {
        
        if collab != nil {
            
            if let startTime = collab?.dates["startTime"], let deadline = collab?.dates["deadline"] {
                
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
}
