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


class TimeBlockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm() //Initializing a new "Realm"
    
    var allBlockDates: Results<TimeBlocksDate>? //Results container used to hold all "TimeBlocksDate" objects from the Realm database
    var currentBlocksDate: Results<TimeBlocksDate>? //Results container that holds only one "TimeBlocksDate" object that matches the current date or user selected date
    var currentDateObject: TimeBlocksDate? //Variable that will contain a "TimeBlocksDate" object that matches the current date or the selected user date
    
    var currentDate: Date = Date() //Variable that hold either the current date or the user selected date
    
    var blockData: Results<Block>? //Setting the variable "blockData" to type "Results" that will contain "Block" objects; "Results" is an auto-updating container type in Realm
    
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var timeTableViewTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var verticalTableViewSeperator: UIView!
    @IBOutlet weak var tableSeperatorTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var blockTableView: UITableView!
    @IBOutlet weak var blockTableViewTopAnchor: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var timeBlockBarItem: UITabBarItem!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var calendarContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var calendarContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var calendarViewBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    
    
    @IBOutlet weak var monthlyContainer: UIView!
    @IBOutlet weak var dailyContainer: UIView!
    @IBOutlet weak var weeklyContainer: UIView!
    

    
    let formatter = DateFormatter() //Global initialization of DateFormatter object
    
    //Array containing "CustomTimeTableCell" text for each indexPath
    let cellTimes: [String] = ["12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM", "5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"]
    
    //Dictionary that contains the color for each block based on its category
    let blockCategoryColors: [String : String] = ["Work": "#5065A0", "Creative Time" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#EFEFF4"]
    
    var rowHeights: [CGFloat] = []
    
    var cellAnimated = [String]() //Variable that helps track whether or not a certain cell has been animated onto the screen yet
    
    //Creation of to pre-define the block tuple's structure and allow for it to be used as a return of a function
    typealias blockTuple = ( blockID: String, notificationID: String, name: String, startHour: String, startMinute: String, startPeriod: String, endHour: String, endMinute: String, endPeriod: String, note1: String, note2: String, note3: String, category: String)
    var functionTuple: blockTuple = (blockID: "", notificationID : "", name: "", startHour: "", startMinute: "", startPeriod: "", endHour: "", endMinute: "", endPeriod: "", note1: "", note2: "", note3: "", category: "")

    var blockArray = [blockTuple]() //Array that holds all the data for each TimeBlock
    
    var bigBlockID: String = "" //Variable that stores the UUID for each TimeBlock
    var notificationID: String = "" //Variable that stores the UUID for each TimeBlock notification
    
    var numberOfRows: Int = 6 //Variable that stores how many rows the calendarView should display
    

    var timeBlockViewTracker: Bool = false //Variable that tracks whether or not the TimeBlock view is present
    
    
    //MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeTableView.delegate = self
        timeTableView.dataSource = self
        
        timeTableView.showsVerticalScrollIndicator = false
        timeTableView.allowsSelection = false
        timeTableView.separatorStyle = .none
        timeTableView.rowHeight = 120.0
        
        blockTableView.delegate = self
        blockTableView.dataSource = self
        blockTableView.separatorStyle = .none
        
//        verticalTableViewSeperator.layer.cornerRadius = 0.5 * verticalTableViewSeperator.bounds.size.width
//        verticalTableViewSeperator.clipsToBounds = true
        
        timeTableView.register(UINib(nibName: "CustomTimeTableCell", bundle: nil), forCellReuseIdentifier: "timeCell")
        blockTableView.register(UINib(nibName: "CustomBlockTableCell", bundle: nil), forCellReuseIdentifier: "blockCell")
        //blockTableView.register(UINib(nibName: "CustomAddBlockTableCell", bundle: nil), forCellReuseIdentifier: "addBlockCell")
        
        timeTableView.frame = CGRect(x: 0, y: 136, width: 82, height: 592)
        verticalTableViewSeperator.frame = CGRect(x: 82, y: 136, width: 2, height: 592)
        blockTableView.frame = CGRect(x: 84, y: 136, width: 291, height: 592)

        verticalTableViewSeperator.backgroundColor = UIColor(hexString: "F2F2F2")?.darken(byPercentage: 0.3)
        
        tabBarController?.delegate = self
        
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
        //dayButton.setTitleColor(.lightGray, for: .normal)
        weekButton.setTitleColor(.lightGray, for: .normal)
        

        
        allBlockDates = realm.objects(TimeBlocksDate.self)
        
        formatter.dateFormat = "EEEE, MMMM d"
        //dateLabel.text = formatter.string(from: currentDate)
        
        navigationItem.title = formatter.string(from: currentDate)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        findTimeBlocks(currentDate)
        allBlockDates = realm.objects(TimeBlocksDate.self)
        calculateBlockHeights()
        blockTableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        timeBlockViewTracker = true //TimeBlock view is present
        timeBlockBarItem.image = UIImage(named: "plus") //Changes the TabBar Item to be a plus button
        scrollToFirstBlock()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        timeBlockViewTracker = false //TimeBlock view is not present
        timeBlockBarItem.image = UIImage(named: "list") //Changes the TabBar Item to be a list button
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
            }
            
            //Used if blockArray was populated with TimeBlocks from a different date and now the user has selected a date with no TimeBlocks
            else {
                blockArray.removeAll()
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
                timeBlockTuple.note1 = blocks.value.note1; timeBlockTuple.note2 = blocks.value.note2; timeBlockTuple.note3 = blocks.value.note3
                
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
                    timeBlockTuple.note1 = blocks.value.note1; timeBlockTuple.note2 = blocks.value.note2; timeBlockTuple.note3 = blocks.value.note3
                    
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
                    timeBlockTuple.note1 = blocks.value.note1; timeBlockTuple.note2 = blocks.value.note2; timeBlockTuple.note3 = blocks.value.note3
                    
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
            
            //Not entirely sure if this if statement is still needed; delete later is no problems occur
//            if returnBlockArray[arrayCleanCount - 1].blockName == "" {
//                let remove = returnBlockArray.remove(at: arrayCleanCount - 1)
//            }
        
             //If the startTime and endTime of a block are the same, remove it from the array to be returned
             if (returnBlockArray[arrayCleanCount - 1].startHour == returnBlockArray[arrayCleanCount - 1].endHour) && (returnBlockArray[arrayCleanCount - 1].startMinute == returnBlockArray[arrayCleanCount - 1].endMinute) && (returnBlockArray[arrayCleanCount - 1].startPeriod == returnBlockArray[arrayCleanCount - 1].endPeriod) {
                
                _ = returnBlockArray.remove(at: arrayCleanCount - 1) //Removing a particular block
            }
            arrayCleanCount -= 1
        }
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
                
                var blockColor: UIColor!
                
                if blockArray[indexPath.row].category != "" {
                    blockColor = UIColor(hexString: blockCategoryColors[blockArray[indexPath.row].category]!)
                }
                else {
                    blockColor = UIColor(hexString: "#EFEFF4")
                }
                
                switch rowHeights[indexPath.row] {
                    
                case 10.0:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "fiveMinCell", for: indexPath) as! TimeFiveMinCell
                    
                    cell.containerView.backgroundColor = blockColor
                    cell.containerView.layer.cornerRadius = 0.013 * cell.containerView.bounds.size.width
                    cell.containerView.clipsToBounds = true
                    
                    cell.nameLabel.text = blockArray[indexPath.row].name
                    cell.nameLabel.font = UIFont(name: "HelveticaNeue", size: 10.5)
                    cell.nameLabel.textColor = ContrastColorOf(blockColor, returnFlat: false)
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                case 20.0:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "tenMinCell", for: indexPath) as! TimeTenMinCell
                    
                    cell.containerView.backgroundColor = blockColor
                    cell.containerView.layer.cornerRadius = 0.03 * cell.containerView.bounds.size.width
                    cell.containerView.clipsToBounds = true
                    
                    cell.nameLabel.text = blockArray[indexPath.row].name
                    cell.nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 15.0)
                    cell.nameLabel.textColor = ContrastColorOf(blockColor, returnFlat: false)
                    cell.nameLabel.adjustsFontSizeToFitWidth = true
                    
                    cell.alphaView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                    cell.alphaView.layer.cornerRadius = 0.045 * cell.alphaView.bounds.size.width
                    cell.alphaView.clipsToBounds = true
                    
                    cell.startLabel.text = convertTo12Hour(blockArray[indexPath.row].startHour, blockArray[indexPath.row].startMinute)
                    
                    cell.startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
                    cell.startLabel.textColor = UIColor.black
                    
                    cell.toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
                    cell.toLabel.textColor = UIColor.black
                    
                    cell.endLabel.text = convertTo12Hour(blockArray[indexPath.row].endHour, blockArray[indexPath.row].endMinute)
                    
                    cell.endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
                    cell.endLabel.textColor = UIColor.black
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                case 30.0:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "fifteenMinCell", for: indexPath) as! TimeFifteenMinCell
                    
                    cell.outlineView.backgroundColor = blockColor
                    cell.outlineView.layer.cornerRadius = 0.035 * cell.outlineView.bounds.size.width
                    cell.outlineView.clipsToBounds = true
                    
                    cell.containerView.layer.cornerRadius = 0.035 * cell.containerView.bounds.size.width
                    cell.containerView.clipsToBounds = true
                    
                    cell.nameLabel.text = blockArray[indexPath.row].name
                    cell.nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 14.0)
                    cell.nameLabel.adjustsFontSizeToFitWidth = true
                    
                    cell.alphaView.layer.cornerRadius = 0.05 * cell.alphaView.bounds.size.width
                    cell.alphaView.clipsToBounds = true
                    
                    cell.startLabel.text = convertTo12Hour(blockArray[indexPath.row].startHour, blockArray[indexPath.row].startMinute)
                    cell.startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
                    
                    cell.toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
                    
                    cell.endLabel.text = convertTo12Hour(blockArray[indexPath.row].endHour, blockArray[indexPath.row].endMinute)
                    cell.endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                case 40.0:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "twentyMinCell", for: indexPath) as! TimeTwentyMinCell
                    
                    cell.outlineView.backgroundColor = blockColor
                    cell.outlineView.layer.cornerRadius = 0.035 * cell.outlineView.bounds.size.width
                    cell.outlineView.clipsToBounds = true
                    
                    cell.containerView.layer.cornerRadius = 0.035 * cell.containerView.bounds.size.width
                    cell.containerView.clipsToBounds = true
                    
                    cell.nameLabel.text = blockArray[indexPath.row].name
                    cell.nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 15.0)
                    cell.nameLabel.adjustsFontSizeToFitWidth = true
                    
                    cell.alphaView.layer.cornerRadius = 0.085 * cell.alphaView.bounds.size.width
                    cell.alphaView.clipsToBounds = true
                    
                    cell.startLabel.text = convertTo12Hour(blockArray[indexPath.row].startHour, blockArray[indexPath.row].startMinute)
                    cell.startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 12.5)
                    
                    cell.toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 22)
                    
                    cell.endLabel.text = convertTo12Hour(blockArray[indexPath.row].endHour, blockArray[indexPath.row].endMinute)
                    cell.endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 12.5)
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                case 50.0:
                  
                    let cell = tableView.dequeueReusableCell(withIdentifier: "twentyfiveMinCell", for: indexPath) as! TimeTwentyFiveMinCell
                    
                    cell.outlineView.backgroundColor = blockColor
                    cell.outlineView.layer.cornerRadius = 0.035 * cell.outlineView.bounds.size.width
                    cell.outlineView.clipsToBounds = true

                    cell.containerView.layer.cornerRadius = 0.035 * cell.containerView.bounds.size.width
                    cell.containerView.clipsToBounds = true

                    cell.nameLabel.text = blockArray[indexPath.row].name
                    cell.nameLabel.adjustsFontSizeToFitWidth = true
                    cell.nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 15.0)
                    
                    if UIScreen.main.bounds.width == 320.0 {
                        
                        cell.alphaViewLeadingAnchor.constant = 30
                        cell.alphaViewTrailingAnchor.constant = 30
                        
                    }
                    
                    cell.alphaView.layer.cornerRadius = 0.035 * cell.alphaView.bounds.size.width
                    cell.alphaView.clipsToBounds = true
                    
                    cell.startLabel.text = convertTo12Hour(blockArray[indexPath.row].startHour, blockArray[indexPath.row].startMinute)
                    cell.startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 13)
                    
                    cell.toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
                    
                    cell.endLabel.text = convertTo12Hour(blockArray[indexPath.row].endHour, blockArray[indexPath.row].endMinute)
                    cell.endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 13)
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                default:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "thirtyMinAndUpCell", for: indexPath) as! TimeThirtyMinAndUpCell
                    
                    cell.outlineView.backgroundColor = blockColor
                    cell.outlineView.layer.cornerRadius = 0.035 * cell.outlineView.bounds.size.width
                    cell.outlineView.clipsToBounds = true
                    
                    cell.superContainerView.layer.cornerRadius = 0.035 * cell.superContainerView.bounds.size.width
                    cell.superContainerView.clipsToBounds = true
                    
                    cell.subContainerView.backgroundColor = .none
                    
                    cell.nameLabel.text = blockArray[indexPath.row].name
                    cell.nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16.0)
                    cell.nameLabel.adjustsFontSizeToFitWidth = true
                    
                    if UIScreen.main.bounds.width == 320.0 {
                        
                        cell.alphaViewLeadingAnchor.constant = 30
                        cell.alphaViewTrailingAnchor.constant = 30
                    }
                    
                    cell.alphaView.layer.cornerRadius = 0.035 * cell.alphaView.bounds.size.width
                    cell.alphaView.clipsToBounds = true
                    
                    cell.startLabel.text = convertTo12Hour(blockArray[indexPath.row].startHour, blockArray[indexPath.row].startMinute)
                    cell.startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 13)
                    
                    cell.toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
                    
                    cell.endLabel.text = convertTo12Hour(blockArray[indexPath.row].endHour, blockArray[indexPath.row].endMinute)
                    cell.endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 13)
                    
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
        //dateLabel.text = formatter.string(from: currentDate)
    
        navigationItem.title = formatter.string(from: currentDate)
        
        calendarView.scrollToDate(currentDate)
        
        calendarView.selectDates([currentDate]) //Selects the new date in the calendar
        findTimeBlocks(currentDate) //Restarts the process of retreiving the data from Realm with the new date
        blockTableView.reloadData()
    }
    
    
    //Button that moves to the next day in the calendar
    @IBAction func nextDay(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        currentDate = currentDate.addingTimeInterval(86400) //Adds one day worth of seconds from the currentDate
        formatter.dateFormat = "EEEE, MMMM d"
        //dateLabel.text = formatter.string(from: currentDate)
        
        navigationItem.title = formatter.string(from: currentDate)
        
        calendarView.scrollToDate(currentDate)
        
        calendarView.selectDates([currentDate]) //Selects the new date in the calendar
        findTimeBlocks(currentDate) //Restarts the process of retreiving the data from Realm with the new date
        blockTableView.reloadData()
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
//
                
            UIView.animate(withDuration: 0.2, animations: {

                self.view.layoutIfNeeded()

                
            }) { (finished: Bool) in

                UIView.animate(withDuration: 0.2, animations: {
                    
                    //self.numberOfRows = 6 //Changes the number of rows for the calendar to 6
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
            bigBlockVC.notificationID = notificationID //Setting the notificationID in the BlockPopoverView to the notificationID of the selected TimeBlock
            bigBlockVC.currentDateObject = currentDateObject //Setting the currentDateObject of the BlockPopoverView to the currentDateObject of this view
            
            bigBlockVC.blockDeletedDelegate = self //Neccasary for Delegates and Protocols of deleting blocks
            bigBlockVC.reloadDataDelegate = self //Neccasary for Delegates and Protocols of reloading data
            
        }
        
        else if segue.identifier == "moveToAddBlockView" {
            
            let createBlockVC = segue.destination as! Add_Update_BlockViewController
            
            createBlockVC.blockData = blockData //Setting the blockData of the AddBlockView to the blockData of this view
            createBlockVC.currentDateObject = currentDateObject //Setting the currentDateObject of the AddBlockView to the currentDateObject of this view

        }
    }
}


//MARK: - UITabBarControllerDelegate Extension

extension TimeBlockViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        //If the timeBlockView is currently presented, perform the segue
        if timeBlockViewTracker == true {
            performSegue(withIdentifier: "moveToAddBlockView", sender: self)
        }
    }
}


//MARK: - JTAppleCalendarViewDelegate and JTAppleCalendarViewDataSource Extensions

extension TimeBlockViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    //Function that asks the data source to return the start and end boundary dates as well as the calendar to use
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2019 05 17")! //Beginning date of the calendar
        let endDate = formatter.date(from: "2020 01 01")! //Ending date of the calendar
        
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
            
            cell.selectedView.isHidden = false
            cell.selectedView.alpha = 0.45
            
            //Responsible for cell selection animation
            UIView.animate(withDuration: 0.05, animations: {

                //cell.selectedView.frame = CGRect(x: 12, y: 4, width: 27, height: 27)
                cell.selectedView.layer.cornerRadius = 0.5 * cell.selectedView.bounds.size.width
                
            }) { (finished: Bool) in
                
                //cell.bringSubviewToFront(cell.dateContainer) //Bring the date text of cell to the front
            }
            
            currentDate = cellState.date //Sets the currentDate of the view to the date of the selected cell
            formatter.dateFormat = "EEEE, MMMM d"
            //dateLabel.text = formatter.string(from: currentDate) //Changes the dateLabel of the view to the new currentDate
            
            navigationItem.title = formatter.string(from: currentDate)
            
            findTimeBlocks(currentDate)
            blockTableView.reloadData()
            scrollToFirstBlock()
        }

        else {
            
            
            
            if cellState.date != currentDate {
                
            }
            
                //Responsible for cell deselection animation
                UIView.animate(withDuration: 0.05, animations: {

                    //cell.selectedView.frame = CGRect(x: 0, y: -8, width: 50, height: 50)

                }) { (finished: Bool) in
                    cell.selectedView.isHidden = true
                    cell.selectedView.layer.cornerRadius = 0.0
                    
                }
            
        }
    }
    
    //Function that handles when a cell has TimeBlocks for it
    func handleCellEvents (cell: DateCell, cellState: CellState) {
        
        formatter.dateFormat = "yyyy MM dd"

        let cellDate = formatter.string(from: cellState.date)

        var calandarData: [String : Results<Block>] = populateDataSource() //Setting calendarData to the "Block" container returned from the "poplateDataSource" function

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
        formatter.dateFormat = "MMMM"

        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthLabel.text = formatter.string(from: range.start)
        
        var gradientLayer: CAGradientLayer!
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 450, height: 50)
        gradientLayer.colors = [UIColor(hexString: "#e35d5b")?.cgColor as Any, UIColor(hexString: "#e53935")?.cgColor as Any]
        
        header.layer.addSublayer(gradientLayer)
        
        //header.backgroundColor = UIColor(hexString: "E35D5B")
        
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
            blockTableView.reloadData()
        
    }
    
}


//MARK: - ReloadData Protocol Extension

extension TimeBlockViewController: ReloadData {
    
    func reloadData() {
        
        findTimeBlocks(currentDate)
        allBlockDates = realm.objects(TimeBlocksDate.self)
        blockTableView.reloadData()
    }
}
