//
//  ViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/17/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift
import JTAppleCalendar
import UserNotifications
import iProgressHUD


class TimeBlockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var timeTableViewTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var verticalTableViewSeperator: UIView!
    @IBOutlet weak var tableSeperatorTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var blockTableView: UITableView!
    @IBOutlet weak var blockTableViewTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var timeBlockBarItem: UITabBarItem!
    
    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var calendarContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var calendarContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var calendarViewBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    
    lazy var realm = try! Realm() //Initializing a new "Realm"
    
    //let personalRealmDatabase = PersonalRealmDatabase()
    
    var allBlockDates: Results<TimeBlocksDate>? //Results container used to hold all "TimeBlocksDate" objects from the Realm database
    var currentBlocksDate: Results<TimeBlocksDate>? //Results container that holds only one "TimeBlocksDate" object that matches the current date or user selected date
    var currentDateObject: TimeBlocksDate? //Variable that will contain a "TimeBlocksDate" object that matches the current date or the selected user date
    
    var currentDate: Date = Date() //Variable that hold either the current date or the user selected date
    
    var blockData: Results<Block>? //Setting the variable "blockData" to type "Results" that will contain "Block" objects; "Results" is an auto-updating container type in Realm
    
    let formatter = DateFormatter() //Global initialization of DateFormatter object
    
    //Array containing "CustomTimeTableCell" text for each indexPath
    let cellTimes: [String] = ["12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM", "5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"]
    
    //Dictionary that contains the color for each block based on its category
    let blockCategoryColors: [String : String] = ["Work": "#5065A0", "Creativity" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#AAAAAA"]
    
    var cellAnimated = [String]() //Variable that helps track whether or not a certain cell has been animated onto the screen yet
    
    //Creation of to pre-define the block tuple's structure and allow for it to be used as a return of a function
    typealias blockTuple = ( blockID: String, notificationID: String, name: String, startHour: String, startMinute: String, startPeriod: String, endHour: String, endMinute: String, endPeriod: String, category: String)
    var functionTuple: blockTuple = (blockID: "", notificationID : "", name: "", startHour: "", startMinute: "", startPeriod: "", endHour: "", endMinute: "", endPeriod: "", category: "")

    var blockArray = [blockTuple]() //Array that holds all the data for each TimeBlock
    var rowHeights: [CGFloat] = []

    var bigBlockID: String = "" //Variable that stores the UUID for each TimeBlock
    var notificationID: String = "" //Variable that stores the UUID for each TimeBlock notification
    
    var numberOfRows: Int = 6 //Variable that stores how many rows the calendarView should display
    
    var timeBlockViewTracker: Bool = false //Variable that tracks whether or not the TimeBlock view is present
    
    var selectedView: String = ""
    
    var viewInitiallyLoaded: Bool = false
    
    //MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
    
        UINavigationBar.appearance().tintColor = .red
        
        if viewInitiallyLoaded == false {

            presentSplashView {

                self.findTimeBlocks(self.currentDate)
                self.allBlockDates = self.realm.objects(TimeBlocksDate.self)

                self.timeTableView.reloadData()
                self.blockTableView.reloadData()
                self.scrollToFirstBlock()
            }

            viewInitiallyLoaded = true
        }

        else {

        //blockArray = personalRealmDatabase.findTimeBlocks(currentDate)
        
            findTimeBlocks(currentDate)
            allBlockDates = realm.objects(TimeBlocksDate.self)
            blockTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        timeBlockViewTracker = true //TimeBlock view is present
        timeBlockBarItem.image = UIImage(named: "plus") //Changes the TabBar Item to be a plus button
        scrollToFirstBlock()
        
        tabBarController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        UINavigationBar.appearance().tintColor = UIColor(hexString: "#e35d5b")
        
        timeBlockViewTracker = false //TimeBlock view is not present
        timeBlockBarItem.image = UIImage(named: "list") //Changes the TabBar Item to be a list button
        
        dismiss(animated: true, completion: nil)
    }
    
    func configureView () {
        
        timeTableView.delegate = self
        timeTableView.dataSource = self
        
        timeTableView.showsVerticalScrollIndicator = false
        timeTableView.allowsSelection = false
        timeTableView.separatorStyle = .none
        timeTableView.rowHeight = 120.0
        
        timeTableView.register(UINib(nibName: "CustomTimeTableCell", bundle: nil), forCellReuseIdentifier: "timeCell")

        verticalTableViewSeperator.backgroundColor = UIColor(hexString: "F2F2F2")?.darken(byPercentage: 0.3)
        
        blockTableView.delegate = self
        blockTableView.dataSource = self
        blockTableView.separatorStyle = .none
        
        formatter.dateFormat = "EEEE, MMMM d"
        navigationItem.title = formatter.string(from: currentDate)
        
        calendarContainerTopAnchor.constant = 0
        calendarContainerHeightConstraint.constant = 0
        calendarContainer.backgroundColor = UIColor(hexString: "E35D5B")
        calendarContainer.layer.cornerRadius = 0.05 * calendarContainer.bounds.size.width
        calendarContainer.clipsToBounds = true
        
        calendarViewBottomAnchor.constant = 0
        calendarView.layer.cornerRadius = 0.05 * calendarView.bounds.size.width
        calendarView.clipsToBounds = true
        
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        
        monthButton.setTitleColor(.lightGray, for: .normal)
        weekButton.setTitleColor(.lightGray, for: .normal)
    }
    
    
    //MARK: - Find TimeBlocks Function

    func findTimeBlocks (_ todaysDate: Date) {

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
                calculateBlockHeights()
            }

            //Used if blockArray was populated with TimeBlocks from a different date and now the user has selected a date with no TimeBlocks
            else {

                blockData = nil
                blockArray.removeAll()
                rowHeights.removeAll()
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

            findTimeBlocks(todaysDate) //Calls function again now knowing there will be a "TimeBlocksObject" to be assigned to the "currentBlocksDate" variable
        }
    }
    
    
    //MARK: - TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        //Assigning the amount of rows for the "timeTableView"
        if tableView == timeTableView {
            return cellTimes.count
        }
        
        //Assigning the amount of rows for the "blockTableView"
        else {
            return blockArray.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = configureCell(tableView, indexPath) //Configuring cell
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        bigBlockID = blockArray[indexPath.row].blockID //Setting the UUID of a certain TimeBlocks after it's selection to be used to identify the TimeBlock in other views
        notificationID = blockArray[indexPath.row].notificationID //Setting the UUID of a TimeBlocks notification to be used in other views
       
        performSegue(withIdentifier: "presentBlockPopover", sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if tableView == blockTableView && indexPath.row < blockArray.count {

            return rowHeights[indexPath.row]
        }

        //The tableView is the timeTableView
        else {
            return 120.0
        }
    }
    
    
    //Function that controls both the timeTableView and the blockTableView moving together
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == timeTableView {
            blockTableView.contentOffset = scrollView.contentOffset
            blockTableView.contentSize.height = scrollView.contentSize.height
        }
        else {
            timeTableView.contentOffset = scrollView.contentOffset
            timeTableView.contentSize.height = scrollView.contentSize.height
        }
    }
    
    
    //MARK: - Sort TimeBlocks Function
    
    func sortRealmBlocks () -> [(key: Int, value: Block)] {
        
        var sortedBlocks: [Int : Block] = [:]
        
        for timeBlocks in blockData! {
    
//            sortedBlocks[Int(timeBlocks.startHour + timeBlocks.startMinute)!] = timeBlocks
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
        
//        for blocks in sortedBlocks {
//            
//            //If the for loop is on its first iteration
//            if firstIteration == true {
//                
//                //Creating the first Buffer Block starting at 12:00 AM until the first TimeBlock
//                bufferBlockTuple.name = "Buffer Block"
//                bufferBlockTuple.startHour = "0"; bufferBlockTuple.startMinute = "0"; bufferBlockTuple.startPeriod = "AM"
//                bufferBlockTuple.endHour = blocks.value.startHour; bufferBlockTuple.endMinute = blocks.value.startMinute; bufferBlockTuple.endPeriod = blocks.value.startPeriod
//
//                //Creating the first TimeBlock from the values returned from the sortBlocks function
//                timeBlockTuple.name = blocks.value.name
//                timeBlockTuple.startHour = blocks.value.startHour; timeBlockTuple.startMinute = blocks.value.startMinute; timeBlockTuple.startPeriod = blocks.value.startPeriod
//                timeBlockTuple.endHour = blocks.value.endHour; timeBlockTuple.endMinute = blocks.value.endMinute; timeBlockTuple.endPeriod = blocks.value.endPeriod
//                
//                timeBlockTuple.category = blocks.value.blockCategory
//                timeBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this timeBlock
//                timeBlockTuple.notificationID = blocks.value.notificationID //Assigning the notificationID of this timeBlock
//                
//                returnBlockArray.append(bufferBlockTuple) //Appending the first BufferBlock
//                returnBlockArray.append(timeBlockTuple) //Appending the first TimeBlock
//                firstIteration = false
//                
//                //If statement that creates a buffer block after the first TimeBlock
//                if (count + 1) < sortedBlocks.count {
//                    
//                    bufferBlockTuple.startHour = blocks.value.endHour; bufferBlockTuple.startMinute = blocks.value.endMinute; bufferBlockTuple.startPeriod = blocks.value.endPeriod
//                    
//                    bufferBlockTuple.endHour = sortedBlocks[count + 1].value.startHour; bufferBlockTuple.endMinute = sortedBlocks[count + 1].value.startMinute; bufferBlockTuple.endPeriod = sortedBlocks[count + 1].value.startPeriod
//            
//                    returnBlockArray.append(bufferBlockTuple) //Appending the second BufferBlock after the first TimeBlock
//                }
//                count += 1
//            }
//            
//            //If the for loop is not on its first iteration
//            else {
//                
//                //If there is more than one TimeBlock left
//                if (count + 1) < sortedBlocks.count {
//                    
//                    //Creating the next TimeBlock from the values returned from the sortBlocks func
//                    timeBlockTuple.name = blocks.value.name
//                    timeBlockTuple.startHour = blocks.value.startHour; timeBlockTuple.startMinute = blocks.value.startMinute; timeBlockTuple.startPeriod = blocks.value.startPeriod
//                    timeBlockTuple.endHour = blocks.value.endHour; timeBlockTuple.endMinute = blocks.value.endMinute; timeBlockTuple.endPeriod = blocks.value.endPeriod
//                    
//                    timeBlockTuple.category = blocks.value.blockCategory
//                    timeBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this timeBlock
//                    timeBlockTuple.notificationID = blocks.value.notificationID //Assigning the notificationID of this timeBlock
//                    
//                    //Creating the next Buffer Block after the last TimeBlock
//                    bufferBlockTuple.startHour = blocks.value.endHour; bufferBlockTuple.startMinute = blocks.value.endMinute; bufferBlockTuple.startPeriod = blocks.value.endPeriod
//                    
//                    bufferBlockTuple.endHour = sortedBlocks[count + 1].value.startHour; bufferBlockTuple.endMinute = sortedBlocks[count + 1].value.startMinute; bufferBlockTuple.endPeriod = sortedBlocks[count + 1].value.startPeriod
//                    
//                    returnBlockArray.append(timeBlockTuple) //Appending the next TimeBlock
//                    returnBlockArray.append(bufferBlockTuple) //Appending the next bufferBlock
//                    count += 1
//                }
//                
//                //If there is only one more TimeBlock left
//                else {
//                    
//                    //Creating the next TimeBlock from the values returned from the sortBlocks func
//                    timeBlockTuple.name = blocks.value.name
//                    timeBlockTuple.startHour = blocks.value.startHour; timeBlockTuple.startMinute = blocks.value.startMinute; timeBlockTuple.startPeriod = blocks.value.startPeriod
//                    timeBlockTuple.endHour = blocks.value.endHour; timeBlockTuple.endMinute = blocks.value.endMinute; timeBlockTuple.endPeriod = blocks.value.endPeriod
//                    
//                    timeBlockTuple.category = blocks.value.blockCategory
//                    timeBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this timeBlock
//                    timeBlockTuple.notificationID = blocks.value.notificationID //Assigning the notificationID of this timeBlock
//                    
//                    returnBlockArray.append(timeBlockTuple)
//                    count += 1
//                }
//                
//            }
//        }
//        
//        arrayCleanCount = returnBlockArray.count
//
//        while arrayCleanCount > 0 {
//        
//             //If the startTime and endTime of a block are the same, remove it from the array to be returned
//             if (returnBlockArray[arrayCleanCount - 1].startHour == returnBlockArray[arrayCleanCount - 1].endHour) && (returnBlockArray[arrayCleanCount - 1].startMinute == returnBlockArray[arrayCleanCount - 1].endMinute) && (returnBlockArray[arrayCleanCount - 1].startPeriod == returnBlockArray[arrayCleanCount - 1].endPeriod) {
//                
//                _ = returnBlockArray.remove(at: arrayCleanCount - 1) //Removing a particular block
//            }
//            arrayCleanCount -= 1
//        }
        
        return returnBlockArray
    }
    
    func configureCell (_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == timeTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath) as! CustomTimeTableCell

            cell.timeLabel.text = cellTimes[indexPath.row]
            cell.timeLabel.textColor = UIColor(hexString: "F2F2F2")?.darken(byPercentage: 0.8)
            
            if cell.timeLabel.text == "11:00 PM" {
                cell.cellSeperator.backgroundColor = UIColor.white
            }
                
            else {
    
                cell.cellSeperator.backgroundColor = UIColor(hexString: "F2F2F2")?.darken(byPercentage: 0.3)
            }
            return cell
        }
        
        else {
            
            if blockArray[indexPath.row].name != "Buffer Block" {
                
                switch rowHeights[indexPath.row] {
                    
                case 10.0:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "fiveMinCell", for: indexPath) as! TimeFiveMinCell
                    cell.block = blockArray[indexPath.row]
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                case 20.0:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "tenMinCell", for: indexPath) as! TimeTenMinCell
                    cell.block = blockArray[indexPath.row]
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                case 30.0:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "fifteenMinCell", for: indexPath) as! TimeFifteenMinCell
                    cell.block = blockArray[indexPath.row]
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                case 40.0:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "twentyMinCell", for: indexPath) as! TimeTwentyMinCell
                    cell.block = blockArray[indexPath.row]
                                        
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                case 50.0:
                  
                    let cell = tableView.dequeueReusableCell(withIdentifier: "twentyfiveMinCell", for: indexPath) as! TimeTwentyFiveMinCell
                    cell.block = blockArray[indexPath.row]
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                default:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "thirtyMinAndUpCell", for: indexPath) as! TimeThirtyMinAndUpCell
                    cell.block = blockArray[indexPath.row]
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                }
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.isUserInteractionEnabled = false
                return cell
            }
        }
    }
    
    //Function thats responsible for converting time stored in Realm from 24 hour format to 12 hour format
    func convertTo12Hour (_ funcHour: String, _ funcMinute: String) -> String {
        
        if funcHour == "0" {
            return "12" + ":" + funcMinute + " " + "AM"
        }
        else if funcHour == "12" {
            return "12" + ":" + funcMinute + " " + "PM"
        }
        else if Int(funcHour)! < 12 {
            return funcHour + ":" + funcMinute + " " + "AM"
        }
        else if Int(funcHour)! > 12 {
            return "\(Int(funcHour)! - 12)" + ":" + funcMinute + " " + "PM"
        }
        else {
            return "Error"
        }
    }

    func calculateBlockHeights () {
        
        var calcHour: Int = 0
        var calcMinute: Int = 0
        
        rowHeights.removeAll()
        
        for block in blockArray {
            
            //If the endMinute of the block is greater than the startMinute of the block
            if Int(block.endMinute)! > Int(block.startMinute)! {
                
                calcHour = Int(block.endHour)! - Int(block.startHour)!
                calcMinute = Int(block.endMinute)! - Int(block.startMinute)!
                rowHeights.append(CGFloat((calcHour * 120) + (calcMinute * 2)))
            }
            
            //If the endMinute of the block is equal to the startMinute of the block
            else if Int(block.endMinute)! == Int(block.startMinute)! {
                
                calcHour = Int(block.endHour)! - Int(block.startHour)!
                rowHeights.append(CGFloat(calcHour * 120))
            }
            
            //If the endMinute of the block is less than the startMinute of the block
            else {
                
                calcHour = (Int(block.endHour)! - 1) - Int(block.startHour)!
                calcMinute = ((Int(block.endMinute)! + 60) - Int(block.startMinute)!)
                rowHeights.append(CGFloat((calcHour * 120) + (calcMinute * 2)))
            }
        }
    }
    
    //Function responsible for animating a TimeBlock
    func animateBlock (_ cell: UITableViewCell, _ cellHeight: CGFloat, _ indexPath: IndexPath) {
        
        switch cellHeight {
            
        case 10.0:
            
            let funcCell = cell as! TimeFiveMinCell
            
            //If a certain TimeBlock has not yet been animated
            if cellAnimated.contains(blockArray[indexPath.row].blockID) != true {
                
                //Sets the x coordinate of the "containerView" for the "CustomBlockTableCell" equal to 500 + (indexPath.row * 150)
                funcCell.containerView.frame.origin.x = CGFloat(500) + CGFloat(indexPath.row * 150)
                
                //Animates a cell onto the screen
                UIView.animate(withDuration: 1.3) {
                    funcCell.containerView.frame.origin.x = 5.0
                }
                
                cellAnimated.append(blockArray[indexPath.row].blockID) //Adds the animated TimeBlock's blockID into the cellAnimated array
            }
                
                //If a cell has already been animated, it simply sets the x coordinate of the cell to be 5
            else {
                funcCell.containerView.frame.origin.x = 5.0
            }
            
        case 20.0:
            
            let funcCell = cell as! TimeTenMinCell
            
            //If a certain TimeBlock has not yet been animated
            if cellAnimated.contains(blockArray[indexPath.row].blockID) != true {
                
                //Sets the x coordinate of the "containerView" for the "CustomBlockTableCell" equal to 500 + (indexPath.row * 150)
                funcCell.containerView.frame.origin.x = CGFloat(500) + CGFloat(indexPath.row * 150)
                
                //Animates a cell onto the screen
                UIView.animate(withDuration: 1.3) {
                    funcCell.containerView.frame.origin.x = 5.0
                }
                
                cellAnimated.append(blockArray[indexPath.row].blockID) //Adds the animated TimeBlock's blockID into the cellAnimated array
            }
                
                //If a cell has already been animated, it simply sets the x coordinate of the cell to be 5
            else {
                funcCell.containerView.frame.origin.x = 5.0
            }
            
        case 30.0:
            
            let funcCell = cell as! TimeFifteenMinCell
            
            //If a certain TimeBlock has not yet been animated
            if cellAnimated.contains(blockArray[indexPath.row].blockID) != true {
                
                //Sets the x coordinate of the "containerView" for the "CustomBlockTableCell" equal to 500 + (indexPath.row * 150)
                funcCell.outlineView.frame.origin.x = CGFloat(500) + CGFloat(indexPath.row * 150)
                
                //Animates a cell onto the screen
                UIView.animate(withDuration: 1.3) {
                    funcCell.outlineView.frame.origin.x = 5.0
                }
                
                cellAnimated.append(blockArray[indexPath.row].blockID) //Adds the animated TimeBlock's blockID into the cellAnimated array
            }
                
                //If a cell has already been animated, it simply sets the x coordinate of the cell to be 5
            else {
                funcCell.outlineView.frame.origin.x = 5.0
            }
            
        case 40.0:
            
            let funcCell = cell as! TimeTwentyMinCell
            
            //If a certain TimeBlock has not yet been animated
            if cellAnimated.contains(blockArray[indexPath.row].blockID) != true {
                
                //Sets the x coordinate of the "containerView" for the "CustomBlockTableCell" equal to 500 + (indexPath.row * 150)
                funcCell.outlineView.frame.origin.x = CGFloat(500) + CGFloat(indexPath.row * 150)
                
                //Animates a cell onto the screen
                UIView.animate(withDuration: 1.3) {
                    funcCell.outlineView.frame.origin.x = 5.0
                }
                
                cellAnimated.append(blockArray[indexPath.row].blockID) //Adds the animated TimeBlock's blockID into the cellAnimated array
            }
                
                //If a cell has already been animated, it simply sets the x coordinate of the cell to be 5
            else {
                funcCell.outlineView.frame.origin.x = 5.0
            }
            
        case 50.0:
            
            let funcCell = cell as! TimeTwentyFiveMinCell
            
            //If a certain TimeBlock has not yet been animated
            if cellAnimated.contains(blockArray[indexPath.row].blockID) != true {
                
                //Sets the x coordinate of the "containerView" for the "CustomBlockTableCell" equal to 500 + (indexPath.row * 150)
                funcCell.outlineView.frame.origin.x = CGFloat(500) + CGFloat(indexPath.row * 150)
                
                //Animates a cell onto the screen
                UIView.animate(withDuration: 1.3) {
                    funcCell.outlineView.frame.origin.x = 5.0
                }
                
                cellAnimated.append(blockArray[indexPath.row].blockID) //Adds the animated TimeBlock's blockID into the cellAnimated array
            }
                
                //If a cell has already been animated, it simply sets the x coordinate of the cell to be 5
            else {
                funcCell.outlineView.frame.origin.x = 5.0
            }
            
        default:
            
            let funcCell = cell as! TimeThirtyMinAndUpCell
            
            //If a certain TimeBlock has not yet been animated
            if cellAnimated.contains(blockArray[indexPath.row].blockID) != true {
                
                //Sets the x coordinate of the "containerView" for the "CustomBlockTableCell" equal to 500 + (indexPath.row * 150)
                funcCell.outlineView.frame.origin.x = CGFloat(500) + CGFloat(indexPath.row * 150)
                
                //Animates a cell onto the screen
                UIView.animate(withDuration: 1.3) {
                    funcCell.outlineView.frame.origin.x = 5.0
                }
                
                cellAnimated.append(blockArray[indexPath.row].blockID) //Adds the animated TimeBlock's blockID into the cellAnimated array
            }
                
                //If a cell has already been animated, it simply sets the x coordinate of the cell to be 5
            else {
                funcCell.outlineView.frame.origin.x = 5.0
            }
            
        }
    }

    
    //Function that allows the tableViews to scroll to the first TimeBlock
    func scrollToFirstBlock() {
        
        if blockArray.count != 0 {
            
            if blockArray[0].name != "Buffer Block" {
                let indexPath = NSIndexPath(row: 0, section: 0)
                blockTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
            }
            else {
                let indexPath = NSIndexPath(row: 1, section: 0)
                blockTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
            }
            
        }
    }
    
    
    //MARK: - Button Functions 
    
    //Button that moves to the previous day in the calendar
    @IBAction func previousDay(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        currentDate = currentDate.addingTimeInterval(-86400) //Subtracts one day worth of seconds from the currentDate
        formatter.dateFormat = "EEEE, MMMM d"
    
        navigationItem.title = formatter.string(from: currentDate)
        
        calendarView.scrollToDate(currentDate)
        
        calendarView.selectDates([currentDate]) //Selects the new date in the calendar
        findTimeBlocks(currentDate) //Restarts the process of retreiving the data from Realm with the new date
        
        //blockArray = personalRealmDatabase.findTimeBlocks(currentDate)
        
        blockTableView.reloadData()
        scrollToFirstBlock()
    }
    
    
    //Button that moves to the next day in the calendar
    @IBAction func nextDay(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        currentDate = currentDate.addingTimeInterval(86400) //Adds one day worth of seconds from the currentDate
        formatter.dateFormat = "EEEE, MMMM d"
        
        navigationItem.title = formatter.string(from: currentDate)
        
        calendarView.scrollToDate(currentDate)
        
        calendarView.selectDates([currentDate]) //Selects the new date in the calendar
        findTimeBlocks(currentDate) //Restarts the process of retreiving the data from Realm with the new date
        
        //blockArray = personalRealmDatabase.findTimeBlocks(currentDate)
        
        blockTableView.reloadData()
        scrollToFirstBlock()
    }
    
    
    //Button that animates the Month calendar onto the view
    @IBAction func monthlyButton(_ sender: Any) {
        
        if monthButton.titleColor(for: .normal) == UIColor(hexString: "E35D5B") {
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
        
        else {
            
            self.calendarView.selectDates([self.currentDate])
            
            monthButton.setTitleColor(UIColor(hexString: "E35D5B"), for: .normal)
            dayButton.setTitleColor(.lightGray, for: .normal)
            weekButton.setTitleColor(.lightGray, for: .normal)
            
            //iPhone SE
            if UIScreen.main.bounds.width == 320.0 {
                
                calendarContainerTopAnchor.constant = 5
                calendarContainerHeightConstraint.constant = 195
                
            }
            
            //iPhone 8
            else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {
                
                calendarContainerTopAnchor.constant = 5
                calendarContainerHeightConstraint.constant = 230
                
            }
            
            else {
                
                calendarContainerTopAnchor.constant = 5
                calendarContainerHeightConstraint.constant = 255
            }
            
            
            calendarViewBottomAnchor.constant = 2
            
            numberOfRows = 6 //Changes the number of rows for the calendar to just 1
            calendarView.reloadData(withanchor: currentDate) //Reloads the calendar with the new date
                
            UIView.animate(withDuration: 0.2, animations: {

                self.view.layoutIfNeeded()

                
            }) { (finished: Bool) in

                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.calendarView.selectDates([self.currentDate])
                    self.calendarView.reloadData(withanchor: self.currentDate) //Reloads the calendar with the new date
                })
            }
        }
    }
    
    @IBAction func dailyButton(_ sender: Any) {
        
        if dayButton.titleColor(for: .normal) == UIColor(hexString: "E35D5B") {
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
        
        else {
            
            monthButton.setTitleColor(.lightGray, for: .normal)
            dayButton.setTitleColor(UIColor(hexString: "E35D5B"), for: .normal)
            weekButton.setTitleColor(.lightGray, for: .normal)
            
            calendarContainerTopAnchor.constant = 0
            calendarContainerHeightConstraint.constant = 0
            
            calendarViewBottomAnchor.constant = 0
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }

    //Button that animates the Week calendar onto the view
    @IBAction func weeklyButton(_ sender: Any) {

        if weekButton.titleColor(for: .normal) == UIColor(hexString: "E35D5B") {
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
        
        else {
            
            monthButton.setTitleColor(.lightGray, for: .normal)
            dayButton.setTitleColor(.lightGray, for: .normal)
            weekButton.setTitleColor(UIColor(hexString: "E35D5B"), for: .normal)
            
            numberOfRows = 1 //Changes the number of rows for the calendar to just 1
            calendarView.reloadData(withanchor: currentDate) //Reloads the calendar with the new date
            
            calendarContainerTopAnchor.constant = 5
            calendarContainerHeightConstraint.constant = 90
            
            calendarViewBottomAnchor.constant = 2
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.calendarView.selectDates([self.currentDate])
                self.calendarView.reloadData(withanchor: self.currentDate)
                
            }
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "presentBlockPopover" {

            let bigBlockVC = segue.destination as! BlockPopoverViewController

            bigBlockVC.blockID = bigBlockID //Setting the blockID in the BlockPopoverView to the blockID of the selected TimeBlock
            
            bigBlockVC.updateTimeBlockDelegate = self
            bigBlockVC.blockDeletedDelegate = self //Neccasary for Delegates and Protocols of deleting blocks
        }
        
        else if segue.identifier == "moveToAUBlockView" {
            
            let add_updateBlockVC = segue.destination as! Add_Update_BlockViewController
            
            add_updateBlockVC.blockData = blockData //Setting the blockData of the AddBlockView to the blockData of this view
            add_updateBlockVC.currentDateObject = currentDateObject //Setting the currentDateObject of the AddBlockView to the currentDateObject of this view
            add_updateBlockVC.selectedView = selectedView
            
            if selectedView == "Edit" {
                
                add_updateBlockVC.blockID = bigBlockID
            }
            
            let cancelItem = UIBarButtonItem()
            cancelItem.title = "Cancel"
            navigationItem.backBarButtonItem = cancelItem
            
        }
    }
}

//Extension for the splashView
extension TimeBlockViewController {
    
    func presentSplashView (completion: @escaping () -> ()) {
        
        let splashView = UIView()
        let blockLabel = UILabel()
        
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true
        
        view.addSubview(splashView)
        
        splashView.frame = self.view.frame
        splashView.backgroundColor = UIColor(hexString: "23FCD1")
        
        blockLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 50)
        blockLabel.numberOfLines = 2
        blockLabel.text = "BP"
        blockLabel.textAlignment = .center
        blockLabel.textColor = .white
        
        view.addSubview(blockLabel)
        
        blockLabel.translatesAutoresizingMaskIntoConstraints = false

        blockLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        blockLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        blockLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        blockLabel.heightAnchor.constraint(equalToConstant: 155).isActive = true
        
        presentProgress()
        
        //Removes the splash screen after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {

            self.view.dismissProgress()

            UIView.animate(withDuration: 0.25, animations: {

                self.navigationController?.isNavigationBarHidden = false
                self.tabBarController?.tabBar.isHidden = false

                splashView.backgroundColor = .white

            }) { (finished: Bool) in

                splashView.removeFromSuperview()
                blockLabel.removeFromSuperview()

                let defaults = UserDefaults.standard
                defaults.setValue(true, forKey: "splashViewPresented")
                
                completion()
            }
        }
    }
    
    func presentProgress () {
        
        let iProgress: iProgressHUD = iProgressHUD()
        
        iProgress.isShowModal = false
        iProgress.isShowCaption = false
        iProgress.isTouchDismiss = false
        iProgress.boxColor = UIColor.clear
        iProgress.indicatorSize = 180

        iProgress.attachProgress(toView: view)
        view.updateIndicator(style: .ballClipRotateMultiple)
        view.showProgress()
    }
}

//MARK: - UITabBarControllerDelegate Extension

extension TimeBlockViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        //If the timeBlockView is currently presented, perform the segue
        if timeBlockViewTracker == true {
            selectedView = "Add"
            performSegue(withIdentifier: "moveToAUBlockView", sender: self)
        }
    }
}


//MARK: - JTAppleCalendarViewDelegate and JTAppleCalendarViewDataSource Extensions

extension TimeBlockViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    //Function that asks the data source to return the start and end boundary dates as well as the calendar to use
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2010 01 01")! //Beginning date of the calendar
        let endDate = formatter.date(from: "2050 01 01")! //Ending date of the calendar
        
        let calendar = Calendar(identifier: .gregorian)
        
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        
        //If the Month calendar is going to be presented
        if numberOfRows == 6 {
            return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: numberOfRows, calendar: calendar, generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
        }
        //If the Week calendar is going to be presented
        else {
            return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: numberOfRows, calendar: calendar, generateInDates: .off, generateOutDates: .off)
        }
    }
    
    //Function that tells the delegate that the JTAppleCalendar is about to display a date-cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath) //Calling the JTApleCalendarView function
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        configureCalendarCell(view: cell, cellState: cellState)
    }
    
    //Function that configures the cell
    func configureCalendarCell (view: JTAppleCell?, cellState: CellState) {
        
        guard let cell = view as? DateCell else { return }
            cell.dateLabel.text = cellState.text
        
        handleCellText(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, cellState: cellState)
    }
    
    //Function that handles the text color of each cell
    func handleCellText(cell: DateCell, cellState: CellState) {
        
        //If the date isn't an end date for a certain month
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
        }
        
        //If the date is an end date for a certain month
        else {
            cell.dateLabel.textColor = UIColor.gray
        }
        
        if UIScreen.main.bounds.width == 320.0 {
            
            cell.dateLabel.font = UIFont(name: "HelveticaNeue", size: 14)
            
            cell.selectedViewWidthConstraint.constant = 24
            cell.selectedViewHeightConstraint.constant = 24
        }
    }
    
    //Function that handles when a certain cell is selected
    func handleCellSelected (cell: DateCell, cellState: CellState) {

        if cellState.isSelected == true {
            
            cell.singleSelectionView.isHidden = false
            cell.singleSelectionView.alpha = 0.45
            
            //Responsible for cell selection animation
            UIView.animate(withDuration: 0.05) {
                cell.singleSelectionView.layer.cornerRadius = 0.5 * cell.singleSelectionView.bounds.size.width
            }
            
            currentDate = cellState.date //Sets the currentDate of the view to the date of the selected cell
            formatter.dateFormat = "EEEE, MMMM d"
            
            navigationItem.title = formatter.string(from: currentDate)
            
            findTimeBlocks(currentDate)
            
            //blockArray = personalRealmDatabase.findTimeBlocks(currentDate)
            
            blockTableView.reloadData()
            scrollToFirstBlock()
        }

        else {
            
            cell.singleSelectionView.isHidden = true
            cell.singleSelectionView.layer.cornerRadius = 0.0
        }
    }
    
    //Function that handles when a cell has TimeBlocks for it
    func handleCellEvents (cell: DateCell, cellState: CellState) {
        
        formatter.dateFormat = "yyyy MM dd"

        let cellDate = formatter.string(from: cellState.date)

        let calandarData: [String : Results<Block>] = populateDataSource() //Setting calendarData to the "Block" container returned from the "poplateDataSource" function

        //If there is no "Block" container in calendarData that matches a certains cell's date
        if calandarData[cellDate] == nil {
            cell.dotView.isHidden = true
        }

        //If there is a "Block" container with TimeBlocks inside it
        else if calandarData[cellDate]?.count ?? 0 != 0 {
            
            //If a cell is selected, the event indicator should be hidden
            switch cellState.isSelected {
                case true:
                    cell.dotView.isHidden = true
                case false:
                    cell.dotView.isHidden = false
                    cell.dotView.layer.cornerRadius = 0.08 * cell.dotView.bounds.size.width
            }
        }
        
        //If there is a "Block" container with no TimeBlocks inside it
        else {
            cell.dotView.isHidden = true
        }
    }
    
    //Function that populates the dataSource to be used in "handleCellEvents" function
    func populateDataSource () -> [String : Results<Block>] {

        var data: [String : Results<Block>] = [:]

        for dates in allBlockDates! {

            data[dates.timeBlocksDate] = dates.timeBlocks.sorted(byKeyPath: "startHour") //Assigning all the TimeBlocks for a certain date to "data" dictionary
        }
        
        return data
    }
    
    //Function that tells the delegate that a date-cell with a specified date was selected
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCalendarCell(view: cell, cellState: cellState)
    }
    
    //Function that tells the delegate that a date-cell with a specified date was de-selected
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCalendarCell(view: cell, cellState: cellState)
    }
    
    //Function that tells the delegate that the JTAppleCalendar is about to display a header
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthLabel.text = formatter.string(from: range.start)
        
        var gradientLayer: CAGradientLayer!
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 450, height: 50)
        gradientLayer.colors = [UIColor(hexString: "#e35d5b")?.cgColor as Any, UIColor(hexString: "#e53935")?.cgColor as Any]
        
        header.layer.addSublayer(gradientLayer)
        
        header.bringSubviewToFront(header.monthLabel)
        header.bringSubviewToFront(header.dayStackView)
        
        return header
    }

    //Function that is called to retrieve the size to be used for the month headers
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
}


//MARK: - BlockDeleted Protocol Extension

extension TimeBlockViewController: UpdateTimeBlock {
    
    func moveToUpdateView () {
        
        selectedView = "Edit"
        performSegue(withIdentifier: "moveToAUBlockView", sender: self)
    }
}

extension TimeBlockViewController: BlockDeleted {
    
    func deleteBlock() {
        
        guard let deletedBlock = realm.object(ofType: Block.self, forPrimaryKey: bigBlockID) else { return }

            do {
                try realm.write {
                    realm.delete(deletedBlock) //Deletes a certain block
                }
            } catch {
                print ("Error deleting timeBlock, \(error)")
            }
        
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID]) //Deletes a certain blocks notifcation
            findTimeBlocks(currentDate)
        
        //blockArray = personalRealmDatabase.findTimeBlocks(currentDate)
        
            blockTableView.reloadData()
    }
}
