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
    typealias blockTuple = (blockID: String, notificationID: String, name: String, begins: Date, ends: Date, category: String)
    var functionTuple: blockTuple = (blockID: "", notificationID : "", name: "", begins: Date(), ends: Date(), category: "")

    var blockArray: [blockTuple]? //= [blockTuple]() //Array that holds all the data for each TimeBlock
    var blockHeights: [CGRect] = []
    
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
            
            //print(blockArray)
              //calculateBlockHeights()
          }

          //Used if blockArray was populated with TimeBlocks from a different date and now the user has selected a date with no TimeBlocks
          else {

            blockData = nil
            blockArray?.removeAll()
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

        return currentDateObject!
    }

    

    //Function responsible for organizing TimeBlocks and bufferBlocks
    func organizeBlocks () -> [(blockTuple)]? {

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
                
                organizedBlocks.append(blockTuple)
            }
        }

        return organizedBlocks
    }

}
