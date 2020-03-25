//
//  HomePersonalNetworking.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/13/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import RealmSwift

class PersonalRealmDatabase {

    static let sharedInstance = PersonalRealmDatabase()
    
    let realm = try! Realm()

    var allBlockDates: Results<TimeBlocksDate>? //Results container used to hold all "TimeBlocksDate" objects from the Realm database
    var currentBlocksDate: Results<TimeBlocksDate>? //Results container that holds only one "TimeBlocksDate" object that matches the current date or user selected date
    var currentDateObject: TimeBlocksDate? //Variable that will contain a "TimeBlocksDate" object that matches the current date or the selected user date

    var blockData: Results<Block>? //Setting the variable "blockData" to type "Results" that will contain "Block" objects; "Results" is an auto-updating container type in Realm

    let formatter = DateFormatter()

    //Creation of to pre-define the block tuple's structure and allow for it to be used as a return of a function
    typealias blockTuple = (blockID: String, name: String, begins: Date, ends: Date, category: String, notificationID: String, scheduled: Bool, minsBefore: Double)
    var functionTuple: blockTuple = (blockID: "", name: "", begins: Date(), ends: Date(), category: "", notificationID: "", scheduled: false, minsBefore: 0)

    var blockArray: [blockTuple]? //= [blockTuple]() //Array that holds all the data for each TimeBlock

    let categoryColors: [String : String] = ["Work": "#5065A0", "Creativity" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#AAAAAA"]
    
    func findTimeBlocks (_ todaysDate: Date) -> TimeBlocksDate {

      formatter.dateFormat = "yyyy MM dd"
      let functionDate: String = formatter.string(from: todaysDate)

      //Filters the Realm database and sets the currentBlocksDate container to one "TimeBlocksDate" object that has a date matching the functionDate
      currentBlocksDate = realm.objects(TimeBlocksDate.self).filter("timeBlocksDate = %@", functionDate)

      //If there is 1 "TimeBlocksObject" currently in the "currentBlocksDate" variable
      if currentBlocksDate?.count ?? 0 != 0 {

          currentDateObject = currentBlocksDate![0] //Sets the 1 "TimeBlocksObject" retrieived after the filter to "currentDateObject"

          //If there are any Blocks in the "TimeBlocksObject"
          if currentDateObject?.timeBlocks.count != 0 {

              blockData = currentDateObject?.timeBlocks.sorted(byKeyPath: "begins")
              blockArray = organizeBlocks()
          }

          
          else {

            blockData = nil
            blockArray = nil
          }

      }

      //If there is 0 "TimeBlocksObject" in the "currentBlocksDate" variable, then this else statement will create one matching the current selected date
      else {

          let newDate = TimeBlocksDate()
          newDate.timeBlocksDate = functionDate

          do {
              try realm.write {

                  realm.add(newDate)
              }
          } catch {
              print ("Error creating a new date \(error)")
          }

          _ = findTimeBlocks(todaysDate) //Calls function again now knowing there will be a "TimeBlocksObject" to be assigned to the "currentBlocksDate" variable
        }

        return currentDateObject!
    }

    

    //Function responsible for organizing TimeBlocks and bufferBlocks
    private func organizeBlocks () -> [(blockTuple)]? {

        var blockTuple = functionTuple //Tuples must be passed by value, not by reference
        var organizedBlocks: [blockTuple] = []// = [functionTuple] //Array of blockTuples going to be returned from the function

        var sortedBlocks: [Block] = []
        
        if blockData != nil {
            
            for timeBlock in blockData! {

                sortedBlocks.append(timeBlock)
            }
            
            sortedBlocks = sortedBlocks.sorted(by: {$0.begins! < $1.begins!})
            
            for block in sortedBlocks {
                
                blockTuple.blockID = block.blockID
                
                blockTuple.name = block.name
                blockTuple.begins = block.begins!
                blockTuple.ends = block.ends!
                blockTuple.category = block.category
                
                blockTuple.notificationID = block.notificationID
                blockTuple.scheduled = block.scheduled
                blockTuple.minsBefore = block.minsBefore
                
                organizedBlocks.append(blockTuple)
            }
        }

        return organizedBlocks
    }
    
    func verifyBlock (_ blockID: String?, _ begins: Date, _ ends: Date) -> Bool {
        
        var conflictingBlocks: [blockTuple] = []
        
        if blockArray != nil {
            
            var count: Int = 0
            
            //Loop that determines the first conflicting blocks for the block being added/updated
            for block in blockArray! {
                
                //If the block from the blockArray isn't the block being added/updated
                if block.blockID != blockID ?? "" {
                    
                    var currentBlockDate: Date = block.begins //Starting time of the block from the blockArray
                    
                    while currentBlockDate <= block.ends {
                        
                        //If the block from the "blockArray" conflicts with the block being added/updated
                        if currentBlockDate.isBetween(startDate: begins, endDate: ends) {
                            
                            conflictingBlocks.append(block)
                            break
                        }
                        
                        else {
                            
                           currentBlockDate = currentBlockDate.addingTimeInterval(150) //Incrementing the time by 2 minutes and 30 seconds
                        }
                    }
                }
                
                count += 1
            }
            
        }
        
        //If the block being added/updated has 2 or less conflicting blocks
        if conflictingBlocks.count <= 2 {
            
            return true
        }
        
        //If the block being added/updated has more than 2 conflicting blocks
        else {
            
            var count: Int = 0
            
            var secondConflictingBlocks: [[blockTuple]] = []
            
            //Loop that is used to find the blocks that conflict with the conflicting blocks
            for conflictingBlock in conflictingBlocks {
                
                secondConflictingBlocks.append([]) //Adds a new index for each block in the "conflictingBlocks" array
                
                for block in blockArray! {
                    
                    //If this block isn't the same as the one from the conflicting array and isn't the block being updated
                    if conflictingBlock.blockID != block.blockID && blockID ?? "" != block.blockID {
                        
                        var currentBlockDate: Date = block.begins //Starting time of the block from the blockArray
                        
                        while currentBlockDate <= block.ends {
                            
                            //If the block from the "blockArray" conflicts with the block from the "conflictingBlocks" array
                            if currentBlockDate.isBetween(startDate: conflictingBlock.begins, endDate: conflictingBlock.ends) {
                                
                                secondConflictingBlocks[count].append(block) //Appending the block at the index that correlates with the block it conflicts with
                                break
                            }
                            
                            else {
                                
                                currentBlockDate = currentBlockDate.addingTimeInterval(150) //Incrementing the time by 2 minutes and 30 seconds
                            }
                        }
                    }
                    
                }
                
                count += 1
            }
            
            
            var secondConflictingCount: Int = 0
            var conflictingArrayCount: Int = 0
            
            //Loop that checks if each block in the "secondConflictingArray" actually conflicts with block being added/updated
            for conflictingArray in secondConflictingBlocks {
                
                conflictingArrayCount = conflictingArray.count //Set to the count of the array because the array is accessed from the last index first
                
                while conflictingArrayCount > 0 {
                    
                    var isBetween: Bool = false
                    
                    var currentBlockDate: Date = conflictingArray[conflictingArrayCount - 1].begins //Starting time of the block from the "conflictingArray"
                    
                    while currentBlockDate <= conflictingArray[conflictingArrayCount - 1].ends {
                        
                        //If the block truly does conflict with the block being added/updated
                        if currentBlockDate.isBetween(startDate: begins, endDate: ends) {
                            
                            isBetween = true
                            break
                        }
                        
                        else {
                            
                            currentBlockDate = currentBlockDate.addingTimeInterval(150)
                        }
                    }
                    
                    //If the block doesn't conflict with the block being added/updated
                    if isBetween == false {
                        
                        secondConflictingBlocks[secondConflictingCount].remove(at: conflictingArrayCount - 1) //Removing the block that doesn't conflict
 
                    }
                    
                    conflictingArrayCount -= 1
                }
                
                secondConflictingCount += 1
            }
            
            
            secondConflictingCount = 0
            conflictingArrayCount = 0
            
            var thirdConflictingBlocks: [[blockTuple]] = []
            
            //Loop that finds the blocks that conflict with the second conflicting blocks
            for conflictingArray in secondConflictingBlocks {
                
                conflictingArrayCount = conflictingArray.count //Set to the count of the array because the array is accessed from the last index first
                
                thirdConflictingBlocks.append([]) //Adds a new index for each array in "secondConflictingBlocks"
                
                while conflictingArrayCount > 0 {

                    for block in blockArray! {
                        
                        //If this block isn't the same as the block from the same index of the "conflictingArray", isn't the block being added/updated, and isn't the block from "secondConflictingArray"
                        if block.blockID != conflictingBlocks[secondConflictingCount].blockID && block.blockID != blockID ?? "" && block.blockID != conflictingArray[conflictingArrayCount - 1].blockID {
                            
                            var currentBlockDate: Date = block.begins //Starting time of the block from the blockArray
                            
                            while currentBlockDate <= block.ends {
                                
                                if conflictingArrayCount > 0 {
                                    
                                    //If this block conflicts with the block from the "secondConflictingArray"
                                    if currentBlockDate.isBetween(startDate: conflictingArray[conflictingArrayCount - 1].begins, endDate: conflictingArray[conflictingArrayCount - 1].ends) {
                                        
                                        thirdConflictingBlocks[secondConflictingCount].append(block)
                                        break
                                    }
                                    
                                    else {
                                        
                                        currentBlockDate = currentBlockDate.addingTimeInterval(150) //Incrementing the time by 2 minutes and 30 seconds
                                    }
                                }
                                
                                //If the count at the index of the "secondConflictingArray" is 0
                                else {
                                    break
                                }
                            }
                        }
                    }
                    conflictingArrayCount -= 1
                }
                secondConflictingCount += 1
            }

            
            var thirdConflictingCount: Int = 0
            conflictingArrayCount = 0
            
            //Loop that checks if each block in the "thirdConflictingArray" actually conflicts with block being added/updated
            for conflictingArray in thirdConflictingBlocks {
                
                conflictingArrayCount = conflictingArray.count //Set to the count of the array because the array is accessed from the last index first
                
                while conflictingArrayCount > 0 {
                    
                    var isBetween : Bool = false
                    
                    var currentBlockDate: Date = conflictingArray[conflictingArrayCount - 1].begins //Starting time of the block from the "conflictingArray"
                    
                    while currentBlockDate <= conflictingArray[conflictingArrayCount - 1].ends {
                        
                        //If the block truly does conflict with the block being added/updated
                        if currentBlockDate.isBetween(startDate: begins, endDate: ends) {
                            
                            isBetween = true
                            break
                        }
                        
                        else {
                            
                            currentBlockDate = currentBlockDate.addingTimeInterval(150) //Incrementing the time by 2 minutes and 30 seconds
                        }
                    }
                    
                    //If the block doesn't conflict with the block being added/updated
                    if isBetween == false {
                        
                        thirdConflictingBlocks[thirdConflictingCount].remove(at: conflictingArrayCount - 1) //Removing the block that doesn't conflict
                    }
                    
                    conflictingArrayCount -= 1
                }
                
                thirdConflictingCount += 1
            }

            
            
            var conflictingTimes: [[Date]] = []
            var conflictingTimeArrayCount: Int = 0
            
            //Loop that determines all the conflicting times between the first and second conflicting blocks
            for conflictingBlock in conflictingBlocks {
                
                conflictingTimes.append([])
                
                //Loops through the blocks in each array at a certain index of the "secondConflictingBlocks" array
                for secondConflictingBlock in secondConflictingBlocks[conflictingTimeArrayCount] {
                    
                    var currentBlockDate: Date = secondConflictingBlock.begins //Starting time of each "secondConflictingBlock"
                        
                    while currentBlockDate <= secondConflictingBlock.ends {
                        
                        //If a certain time of the "secondConflictingBlock" conflicts with the original conflicting block
                        if currentBlockDate.isBetween(startDate: conflictingBlock.begins, endDate: conflictingBlock.ends) {
                            
                            conflictingTimes[conflictingTimeArrayCount].append(currentBlockDate) //Adds the conflicting time to the "conflictingTimes" array
                            
                            currentBlockDate = currentBlockDate.addingTimeInterval(150) //Incrementing the time by 2 minutes and 30 seconds
                        }
                        
                        else {
                            
                            currentBlockDate = currentBlockDate.addingTimeInterval(150) //Incrementing the time by 2 minutes and 30 seconds
                        }
                    }
                }
                conflictingTimeArrayCount += 1
            }

            
            var timeArrayCount: Int = 0
            
            conflictingArrayCount = 0
            
            //Loop that checks if each block from the "thirdConflictingBlocks" array
            for conflictingArray in thirdConflictingBlocks {
                
                timeArrayCount = conflictingTimes[conflictingArrayCount].count //Set to the count of the array because the array is accessed from the last index first
                
                while timeArrayCount > 0 {
                    
                    var isBetween: Bool = false
                    
                    for block in conflictingArray {
                        
                        //If this time conflicts with a block from a certain index of the "thirdConflictingArray"
                        if conflictingTimes[conflictingArrayCount][timeArrayCount - 1].isBetween(startDate: block.begins, endDate: block.ends) {
                            
                            isBetween = true
                            break
                        }
                    }
                    
                    //If this time doesn't conflict with a block from a certain index of the "thirdConflictingArray"
                    if isBetween == false {
                        
                        conflictingTimes[conflictingArrayCount].remove(at: timeArrayCount - 1) //Remove this time from the "conflictingTimes" array
                    }
                    
                    timeArrayCount -= 1
                }
                
                conflictingArrayCount += 1
            }
            
            
            //Loop that checks if the block being added/updated conflicts with any time from the "conflictingTimes" array
            for times in conflictingTimes {

                for time in times {

                    //If the block conflicts
                    if time.isBetween(startDate: begins, endDate: ends) {
                        
                        return false
                    }
                }
            }
            
            return true
        }
    }
    
    
    func addBlock (_ blockDict: [String : Any], _ currentDate: TimeBlocksDate) {
        
        let newBlock = Block()
        
        newBlock.name = blockDict["name"] as! String

        newBlock.begins = blockDict["begins"] as? Date
        newBlock.ends = blockDict["ends"] as? Date

        newBlock.category = blockDict["category"] as! String
        
        newBlock.notificationID = blockDict["notificationID"] as! String
        newBlock.scheduled = blockDict["scheduled"] as! Bool
        newBlock.minsBefore = blockDict["minsBefore"] as! Double
        
        do {
            
            try realm.write {
                
                currentDate.timeBlocks.append(newBlock)
            }
        } catch {
            
            print("Error adding block \(error)")
        }
    }
    
    
    func updateBlock (_ blockDict: [String : Any], _ currentDate: TimeBlocksDate) {
        
        let updatedBlock = Block()
        
        updatedBlock.blockID = blockDict["blockID"] as! String
        updatedBlock.name = blockDict["name"] as! String

        updatedBlock.begins = blockDict["begins"] as? Date
        updatedBlock.ends = blockDict["ends"] as? Date

        updatedBlock.category = blockDict["category"] as! String
        
        updatedBlock.notificationID = blockDict["notificationID"] as! String
        updatedBlock.scheduled = blockDict["scheduled"] as! Bool
        updatedBlock.minsBefore = blockDict["minsBefore"] as! Double
        
        do {
            try self.realm.write {
                
                realm.add(updatedBlock, update: .modified)
            }
        } catch {
            
            print ("Error updating block \(error)")
        }
    }
    
    func deleteBlock (blockID: String) {
        
        guard let deletedBlock = realm.object(ofType: Block.self, forPrimaryKey: blockID) else { return }
        
        do {
            
            try realm.write {
                realm.delete(deletedBlock)
            }
        } catch {
            
            print("Error deleting timeBlock, \(error)")
        }
    }
}
