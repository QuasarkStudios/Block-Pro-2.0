//
//  CollabView+Progress.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/12/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

extension CollabViewController: CollabProgressProtocol {
    
    //MARK: - Filter Blocks
    
    func filterBlocks (status: BlockStatus?) {
        
        //Stops any ongoing search
        collabNavigationView.collabProgressView.searchBar?.searchTextField.text = ""
        collabNavigationView.collabProgressView.searchBar?.searchTextField.resignFirstResponder()
        
        filteredBlocks.removeAll()
        
        //Evident that one of the "progressContainers" and not the "collabContainer" was selected
        if status != nil {
            
            searchBeingConducted = false
            blocksFiltered = true
            
            for block in blocks ?? [] {
                
                //If this block has a status
                if let blockStatus = block.status {
                    
                    if blockStatus == status! {
                        
                        filteredBlocks.append(block)
                    }
                }
                
                //If this block doesn't have a status
                else if let starts = block.starts, let ends = block.ends {

                    //In Progress
                    if Date().isBetween(startDate: starts, endDate: ends) {

                        if status == .inProgress {

                            filteredBlocks.append(block)
                        }
                    }

                    //Late
                    else if Date() > ends {

                        if status == .late {

                            filteredBlocks.append(block)
                        }
                    }
                }
            }
            
            filteredBlocks.sort(by: { $0.starts! < $1.starts! })
        }
        
        //Evident that the "collabContainer" was selected
        else {
            
            blocksFiltered = false
        }
        
        UIView.transition(with: collabNavigationView.collabTableView, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.collabNavigationView.collabTableView.reloadData()
        }
    }
    
    
    //MARK: - Search Began
    
    func searchBegan() {
        
        //If all previous searches have been completed
        if !searchBeingConducted {
            
            if blocks != nil/*, !blocksFiltered*/ {
                
                filteredBlocks = blocks!
            }
            
            searchBeingConducted = true
            blocksFiltered = true
            
            UIView.transition(with: collabNavigationView.collabTableView, duration: 0.3, options: .transitionCrossDissolve) {

                self.collabNavigationView.collabTableView.reloadData()
            }
            
            //Selecting the "collabContainer" in the "collabProgressView"
            collabNavigationView.collabProgressView.progressStackView.arrangedSubviews.forEach { (container) in
                
                if container.tag == 0 {
                    
                    let label = container.subviews.first(where: { $0 as? UILabel != nil }) as? UILabel
                    label?.textColor = .black
                }
                
                else {
                    
                    let label = container.subviews.first(where: { $0 as? UILabel != nil }) as? UILabel
                    label?.textColor = .placeholderText
                }
            }
            
            collabNavigationView.collabProgressView.setCollabSelectedProgressLabelText()
        }
        
        //Must set here
        collabNavigationView.progressViewHeightConstraint?.constant = 67
        collabNavigationView.tableViewTopAnchorWithStackView?.constant = keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 92 : 72
        
        expandView()
    }
    
    
    //MARK: - Search Text Changed
    
    func searchTextChanged(searchText: String) {
        
        filteredBlocks.removeAll()
        
        if searchText.leniantValidationOfTextEntered() {
            
            for block in blocks ?? [] {
                
                //If the name of the block contains the searchText
                if let name = block.name, name.localizedCaseInsensitiveContains(searchText) {
                    
                    filteredBlocks.append(block)
                }
                
                else {
                    
                    //If the block has status assigned
                    if let blockStatus = block.status {
                        
                        let statusDictionary: [BlockStatus : String] = [.notStarted : "Not Started", .inProgress : "In Progress", .completed : "Completed", .needsHelp : "Needs Help", .late : "Late"]
                        
                        if let status = statusDictionary[blockStatus], status.localizedCaseInsensitiveContains(searchText) {
                            
                            filteredBlocks.append(block)
                        }
                    }
                    
                    //If the block doesn't have a status assigned
                    else if let starts = block.starts, let ends = block.ends {
                        
                        var status: String?
                        
                        if Date().isBetween(startDate: starts, endDate: ends) {
                            
                            status = "In Progress"
                        }
                        
                        else if Date() < starts {
                            
                            status = "Not Started"
                        }
                        
                        else if Date() > ends {
                             
                            status = "Late"
                        }
                        
                        if status?.localizedCaseInsensitiveContains(searchText) ?? false {
                            
                            filteredBlocks.append(block)
                        }
                    }
                }
            }
        }
        
        else {
            
            if blocks != nil {
                
                filteredBlocks = blocks!
            }
        }
        
        filteredBlocks.sort(by: { $0.starts! < $1.starts! })
        
        UIView.transition(with: collabNavigationView.collabTableView, duration: 0.3, options: .transitionCrossDissolve) {

            self.collabNavigationView.collabTableView.reloadData()
        }
    }
    
    
    //MARK: - Search Ended
    
    func searchEnded (searchText: String) {
        
        //Ensures that the searchBar is empty signaling the search has concluded
        if !searchText.leniantValidationOfTextEntered() {
            
            searchBeingConducted = false
            blocksFiltered = false

            filteredBlocks = []
            
            collabNavigationView.collabTableView.reloadData()
        }
    }
}
