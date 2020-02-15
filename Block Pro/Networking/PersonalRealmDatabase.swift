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
    
    let realm = try! Realm()
    
    var allBlockDates: Results<TimeBlocksDate>? //Results container used to hold all "TimeBlocksDate" objects from the Realm database
    var currentBlocksDate: Results<TimeBlocksDate>? //Results container that holds only one "TimeBlocksDate" object that matches the current date or user selected date
    var currentDateObject: TimeBlocksDate? //Variable that will contain a "TimeBlocksDate" object that matches the current date or the selected user date
    
    var blockData: Results<Block>? //Setting the variable "blockData" to type "Results" that will contain "Block" objects; "Results" is an auto-updating container type in Realm
    
    let formatter = DateFormatter()
    
    //Creation of to pre-define the block tuple's structure and allow for it to be used as a return of a function
    typealias blockTuple = ( blockID: String, notificationID: String, name: String, startHour: String, startMinute: String, startPeriod: String, endHour: String, endMinute: String, endPeriod: String, category: String)
    var functionTuple: blockTuple = (blockID: "", notificationID : "", name: "", startHour: "", startMinute: "", startPeriod: "", endHour: "", endMinute: "", endPeriod: "", category: "")

    var blockArray = [blockTuple]() //Array that holds all the data for each TimeBlock
    
    func findTimeBlocks (_ todaysDate: Date) -> [blockTuple] {

      formatter.dateFormat = "yyyy MM dd"
      let functionDate: String = formatter.string(from: todaysDate)
      
      //Filters the Realm database and sets the currentBlocksDate container to one "TimeBlocksDate" object that has a date matching the functionDate
      currentBlocksDate = realm.objects(TimeBlocksDate.self).filter("timeBlocksDate = %@", functionDate)
  
      //If there is 1 "TimeBlocksObject" currently in the "currentBlocksDate" variable
      if currentBlocksDate?.count ?? 0 != 0 {
          
          currentDateObject = currentBlocksDate![0] //Sets the 1 "TimeBlocksObject" retrieived after the filter to "currentDateObject"
          
          //If there are any Blocks in the "TimeBlocksObject"
          if currentDateObject?.timeBlocks.count != 0 {
              
              blockData = currentDateObject?.timeBlocks.sorted(byKeyPath: "startHour")
              blockArray = organizeBlocks(sortRealmBlocks(), functionTuple)
              //calculateBlockHeights()
          }
          
          //Used if blockArray was populated with TimeBlocks from a different date and now the user has selected a date with no TimeBlocks
          else {
              
              blockData = nil
              blockArray.removeAll()
              //rowHeights.removeAll()
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
        
        return blockArray
    }

    //MARK: - Sort TimeBlocks Function
    
    func sortRealmBlocks () -> [(key: Int, value: Block)] {
        
        var sortedBlocks: [Int : Block] = [:]
        
        for timeBlocks in blockData! {
    
            sortedBlocks[Int(timeBlocks.startHour + timeBlocks.startMinute)!] = timeBlocks
        }
        
        return sortedBlocks.sorted(by: {$0.key < $1.key})
    }
    
    //Function responsible for organizing TimeBlocks and bufferBlocks
    func organizeBlocks (_ sortedBlocks: [(key: Int, value: Block)], _ blockTuple: blockTuple) -> [(blockTuple)] {
        
        var firstIteration: Bool = true //Tracks if the for loop is on its first iteration or not
        var count: Int = 0 //Variable that tracks which index of the "sortedBlocks" array the for loop is on
        var arrayCleanCount: Int = 0
        
        var bufferBlockTuple = blockTuple //Tuples must be passed by value, not by reference
        var timeBlockTuple = blockTuple //Tuples must be passed by value, not by reference
        var returnBlockArray = [blockTuple] //Array of blockTuples going to be returned from the function
        
        for blocks in sortedBlocks {
            
            //If the for loop is on its first iteration
            if firstIteration == true {
                
                //Creating the first Buffer Block starting at 12:00 AM until the first TimeBlock
                bufferBlockTuple.name = "Buffer Block"
                bufferBlockTuple.startHour = "0"; bufferBlockTuple.startMinute = "0"; bufferBlockTuple.startPeriod = "AM"
                bufferBlockTuple.endHour = blocks.value.startHour; bufferBlockTuple.endMinute = blocks.value.startMinute; bufferBlockTuple.endPeriod = blocks.value.startPeriod

                //Creating the first TimeBlock from the values returned from the sortBlocks function
                timeBlockTuple.name = blocks.value.name
                timeBlockTuple.startHour = blocks.value.startHour; timeBlockTuple.startMinute = blocks.value.startMinute; timeBlockTuple.startPeriod = blocks.value.startPeriod
                timeBlockTuple.endHour = blocks.value.endHour; timeBlockTuple.endMinute = blocks.value.endMinute; timeBlockTuple.endPeriod = blocks.value.endPeriod
                
                timeBlockTuple.category = blocks.value.blockCategory
                timeBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this timeBlock
                timeBlockTuple.notificationID = blocks.value.notificationID //Assigning the notificationID of this timeBlock
                
                returnBlockArray.append(bufferBlockTuple) //Appending the first BufferBlock
                returnBlockArray.append(timeBlockTuple) //Appending the first TimeBlock
                firstIteration = false
                
                //If statement that creates a buffer block after the first TimeBlock
                if (count + 1) < sortedBlocks.count {
                    
                    bufferBlockTuple.startHour = blocks.value.endHour; bufferBlockTuple.startMinute = blocks.value.endMinute; bufferBlockTuple.startPeriod = blocks.value.endPeriod
                    
                    bufferBlockTuple.endHour = sortedBlocks[count + 1].value.startHour; bufferBlockTuple.endMinute = sortedBlocks[count + 1].value.startMinute; bufferBlockTuple.endPeriod = sortedBlocks[count + 1].value.startPeriod
            
                    returnBlockArray.append(bufferBlockTuple) //Appending the second BufferBlock after the first TimeBlock
                }
                count += 1
            }
            
            //If the for loop is not on its first iteration
            else {
                
                //If there is more than one TimeBlock left
                if (count + 1) < sortedBlocks.count {
                    
                    //Creating the next TimeBlock from the values returned from the sortBlocks func
                    timeBlockTuple.name = blocks.value.name
                    timeBlockTuple.startHour = blocks.value.startHour; timeBlockTuple.startMinute = blocks.value.startMinute; timeBlockTuple.startPeriod = blocks.value.startPeriod
                    timeBlockTuple.endHour = blocks.value.endHour; timeBlockTuple.endMinute = blocks.value.endMinute; timeBlockTuple.endPeriod = blocks.value.endPeriod
                    
                    timeBlockTuple.category = blocks.value.blockCategory
                    timeBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this timeBlock
                    timeBlockTuple.notificationID = blocks.value.notificationID //Assigning the notificationID of this timeBlock
                    
                    //Creating the next Buffer Block after the last TimeBlock
                    bufferBlockTuple.startHour = blocks.value.endHour; bufferBlockTuple.startMinute = blocks.value.endMinute; bufferBlockTuple.startPeriod = blocks.value.endPeriod
                    
                    bufferBlockTuple.endHour = sortedBlocks[count + 1].value.startHour; bufferBlockTuple.endMinute = sortedBlocks[count + 1].value.startMinute; bufferBlockTuple.endPeriod = sortedBlocks[count + 1].value.startPeriod
                    
                    returnBlockArray.append(timeBlockTuple) //Appending the next TimeBlock
                    returnBlockArray.append(bufferBlockTuple) //Appending the next bufferBlock
                    count += 1
                }
                
                //If there is only one more TimeBlock left
                else {
                    
                    //Creating the next TimeBlock from the values returned from the sortBlocks func
                    timeBlockTuple.name = blocks.value.name
                    timeBlockTuple.startHour = blocks.value.startHour; timeBlockTuple.startMinute = blocks.value.startMinute; timeBlockTuple.startPeriod = blocks.value.startPeriod
                    timeBlockTuple.endHour = blocks.value.endHour; timeBlockTuple.endMinute = blocks.value.endMinute; timeBlockTuple.endPeriod = blocks.value.endPeriod
                    
                    timeBlockTuple.category = blocks.value.blockCategory
                    timeBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this timeBlock
                    timeBlockTuple.notificationID = blocks.value.notificationID //Assigning the notificationID of this timeBlock
                    
                    returnBlockArray.append(timeBlockTuple)
                    count += 1
                }
                
            }
        }
        
        arrayCleanCount = returnBlockArray.count

        while arrayCleanCount > 0 {
        
             //If the startTime and endTime of a block are the same, remove it from the array to be returned
             if (returnBlockArray[arrayCleanCount - 1].startHour == returnBlockArray[arrayCleanCount - 1].endHour) && (returnBlockArray[arrayCleanCount - 1].startMinute == returnBlockArray[arrayCleanCount - 1].endMinute) && (returnBlockArray[arrayCleanCount - 1].startPeriod == returnBlockArray[arrayCleanCount - 1].endPeriod) {
                
                _ = returnBlockArray.remove(at: arrayCleanCount - 1) //Removing a particular block
            }
            arrayCleanCount -= 1
        }
        
        return returnBlockArray
    }
    
}
