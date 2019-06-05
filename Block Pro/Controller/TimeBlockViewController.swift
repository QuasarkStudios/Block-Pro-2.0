//
//  ViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/17/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift

class TimeBlockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    let realm = try! Realm() //Initializing a new "Realm"
    var blocks: Results<Block>? //Setting the variable "blocks" to type "Results" that will contain "Block" objects; "Results" is an auto-updating container type in Realm
    
    let createBlockViewObject = CreateBlockViewController()
    
    //Variable storing "CustomTimeTableCell" text for each indexPath
    let cellTimes: [String] = ["12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM", "5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"]
    
    let amDictionaries: [String : String] = ["12" : "0", "1" : "1", "2" : "2", "3" : "3", "4" : "4", "5" : "5", "6" : "6", "7" : "7", "8" : "8", "9" : "9", "10" : "10", "11" : "11"]
    let pmDictionaries: [String : String] = ["12" : "12", "1" : "13", "2" : "14", "3" : "15", "4" : "16", "5" : "17", "6" : "18", "7" : "19", "8" : "20", "9" : "21", "10" : "22", "11" : "23"]
    
    var cellAnimated = [Bool](repeating: false, count: 24) //Variable that helps track whether or not a certain cell has been animated onto the screen yet
    
    var userSelectedStartHour: String = ""
    var userSelectedStartMinute: String = ""
    var userSelectedStartPeriod: String = ""
    
    var userSelectedEndHour: String = ""
    var userSelectedEndMinute: String = ""
    var userSelectedEndPeriod: String = ""
    
    //Creation of to pre-define the block tuple's structure and allow for it to be used as a return of a function
    typealias blockTuple = (blockName: String, blockStartHour: String, blockStartMinute: String, blockStartPeriod: String, blockEndHour: String, blockEndMinute: String, blockEndPeriod: String)
    var functionTuple: blockTuple = (blockName: "", blockStartHour: "", blockStartMinute: "", blockStartPeriod: "", blockEndHour: "", blockEndMinute: "", blockEndPeriod: "")
    var blockArray = [blockTuple]()
    
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var blockTableView: UITableView!
    @IBOutlet weak var verticalTableViewSeperator: UIImageView!

    
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
        blockTableView.rowHeight = 90.0
        
        verticalTableViewSeperator.layer.cornerRadius = 0.5 * verticalTableViewSeperator.bounds.size.width
        verticalTableViewSeperator.clipsToBounds = true
        
        timeTableView.register(UINib(nibName: "CustomTimeTableCell", bundle: nil), forCellReuseIdentifier: "timeCell")
        blockTableView.register(UINib(nibName: "CustomBlockTableCell", bundle: nil), forCellReuseIdentifier: "blockCell")
        blockTableView.register(UINib(nibName: "CustomAddBlockTableCell", bundle: nil), forCellReuseIdentifier: "addBlockCell")
        
        blocks = realm.objects(Block.self)
        
        blockArray = configureBufferBlocks(sortBlockResults(), functionTuple)
        print("Test 1:", blockArray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        blockArray = configureBufferBlocks(sortBlockResults(), functionTuple)
        blockTableView.reloadData()
    }

    
    //MARK: - TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        //Assigning the amount of rows for the "timeTableView"
        if tableView == timeTableView {
            return cellTimes.count
        }
        
        //Assigning the amount of rows for the "blockTableView"
        else {
            
            if blockArray.count == 0 { //blocks?.count ?? 0 == 0 { //If the "blocks" container is empty, just return one cell
                return 1
            }
            
            else { //Return the count of the "blocks" container plus one more
                return blockArray.count + 1//(blocks?.count ?? 1) + 1
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = configureCell(tableView, indexPath)
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == blockArray.count {
            
            performSegue(withIdentifier: "performSegue", sender: self)
            blockTableView.deselectRow(at: indexPath, animated: true)
        }
        else {
            blockTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var count: Int = 0

        var returnHeight: CGFloat = 120.0

        if tableView == blockTableView && indexPath.row < blockArray.count {//blocks?.count ?? 0 {

            while count < blockArray.count {//blocks?.count ?? 1 {

                returnHeight = configureBlockHeight(indexPath: indexPath)
                count += 1
                //print (returnHeight)
                return returnHeight
            }
        }
        return returnHeight
    }
    
    
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
    
    func sortBlockResults () -> [(key: Int, value: Block)] {
        
        var sortedBlocks: [Int : Block] = [:]
        
        for timeBlocks in blocks! {
            
            if timeBlocks.startPeriod == "AM" {
                sortedBlocks[Int(amDictionaries[timeBlocks.startHour]! + timeBlocks.startMinute)!] = timeBlocks
                //print (sortedBlocks)
            }

            else if timeBlocks.startPeriod == "PM" {
                sortedBlocks[Int(pmDictionaries[timeBlocks.startHour]! + timeBlocks.startMinute)!] = timeBlocks
                //print (sortedBlocks)
            }
        }
        return sortedBlocks.sorted(by: {$0.key < $1.key})
    }
    
    
    func configureBufferBlocks (_ sortedBlocks: [(key: Int, value: Block)],_ blockTuple: blockTuple) -> [(blockTuple)] {
        
        var returnBlockArray = [blockTuple]
        var firstIteration: Bool = true
        var count: Int = 0
        var arrayCleanCount: Int = 0
        
        var bufferBlockTuple = blockTuple //Tuples must be passed by value, not by reference
        var timeBlockTuple = blockTuple //Tuples must be passed by value, not by reference
        
        for blocks in sortedBlocks {
            
            if firstIteration == true {
                
                //Creating the first Buffer Block starting at 12:00 AM until the first TimeBlocks
                bufferBlockTuple.blockName = "Buffer Block"
                bufferBlockTuple.blockStartHour = "12"; bufferBlockTuple.blockStartMinute = "0"; bufferBlockTuple.blockStartPeriod = "AM"
                bufferBlockTuple.blockEndHour = blocks.value.startHour; bufferBlockTuple.blockEndMinute = blocks.value.startMinute; bufferBlockTuple.blockEndPeriod = blocks.value.startPeriod

                //Creating the first TimeBlock from the values returned from the sortBlocks func
                timeBlockTuple.blockName = blocks.value.name
                timeBlockTuple.blockStartHour = blocks.value.startHour; timeBlockTuple.blockStartMinute = blocks.value.startMinute; timeBlockTuple.blockStartPeriod = blocks.value.startPeriod
                timeBlockTuple.blockEndHour = blocks.value.endHour; timeBlockTuple.blockEndMinute = blocks.value.endMinute; timeBlockTuple.blockEndPeriod = blocks.value.endPeriod
                
                returnBlockArray.append(bufferBlockTuple) //Appending the first BufferBlock
                returnBlockArray.append(timeBlockTuple) //Appending the first TimeBlock
                firstIteration = false
                
                if (count + 1) < sortedBlocks.count {
                    
                    //Creating the second Buffer Block after the last TimeBlock
                    bufferBlockTuple.blockStartHour = blocks.value.endHour; bufferBlockTuple.blockStartMinute = blocks.value.endMinute; bufferBlockTuple.blockStartPeriod = blocks.value.endPeriod
                    
                    bufferBlockTuple.blockEndHour = sortedBlocks[count + 1].value.startHour; bufferBlockTuple.blockEndMinute = sortedBlocks[count + 1].value.startMinute; bufferBlockTuple.blockEndPeriod = sortedBlocks[count + 1].value.startPeriod
            
                    returnBlockArray.append(bufferBlockTuple) //Appending the second BufferBlock after the first TimeBlock
                }
                count += 1
            }
            
            else { //If there is more than one TimeBlock left
                
                if (count + 1) < sortedBlocks.count {
                    
                    //Creating the next TimeBlock from the values returned from the sortBlocks func
                    timeBlockTuple.blockName = blocks.value.name
                    timeBlockTuple.blockStartHour = blocks.value.startHour; timeBlockTuple.blockStartMinute = blocks.value.startMinute; timeBlockTuple.blockStartPeriod = blocks.value.startPeriod
                    timeBlockTuple.blockEndHour = blocks.value.endHour; timeBlockTuple.blockEndMinute = blocks.value.endMinute; timeBlockTuple.blockEndPeriod = blocks.value.endPeriod
                    
                    //Creating the next Buffer Block after the last TimeBlock
                    bufferBlockTuple.blockStartHour = blocks.value.endHour; bufferBlockTuple.blockStartMinute = blocks.value.endMinute; bufferBlockTuple.blockStartPeriod = blocks.value.endPeriod
                    
                    bufferBlockTuple.blockEndHour = sortedBlocks[count + 1].value.startHour; bufferBlockTuple.blockEndMinute = sortedBlocks[count + 1].value.startMinute; bufferBlockTuple.blockEndPeriod = sortedBlocks[count + 1].value.startPeriod
                    
                    returnBlockArray.append(timeBlockTuple)
                    returnBlockArray.append(bufferBlockTuple)
                    count += 1
                }
                
                else { //If there is only one more TimeBlock left
                    
                    //Creating the next TimeBlock from the values returned from the sortBlocks func
                    timeBlockTuple.blockName = blocks.value.name
                    timeBlockTuple.blockStartHour = blocks.value.startHour; timeBlockTuple.blockStartMinute = blocks.value.startMinute; timeBlockTuple.blockStartPeriod = blocks.value.startPeriod
                    timeBlockTuple.blockEndHour = blocks.value.endHour; timeBlockTuple.blockEndMinute = blocks.value.endMinute; timeBlockTuple.blockEndPeriod = blocks.value.endPeriod
                    
                    returnBlockArray.append(timeBlockTuple)
                    count += 1
                }
            }
        }
        
        arrayCleanCount = returnBlockArray.count

        while arrayCleanCount > 0 {
            
            if returnBlockArray[arrayCleanCount - 1].blockName == "" {
                let remove = returnBlockArray.remove(at: arrayCleanCount - 1)
            }
            
            else if (returnBlockArray[arrayCleanCount - 1].blockStartHour == returnBlockArray[arrayCleanCount - 1].blockEndHour) && (returnBlockArray[arrayCleanCount - 1].blockStartMinute == returnBlockArray[arrayCleanCount - 1].blockEndMinute) && (returnBlockArray[arrayCleanCount - 1].blockStartPeriod == returnBlockArray[arrayCleanCount - 1].blockEndPeriod) {
                let remove = returnBlockArray.remove(at: arrayCleanCount - 1)
            }
            arrayCleanCount -= 1
        }
        //print(blockArray.count)
        return returnBlockArray
    }
    
    
    func configureCell (_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == timeTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath) as! CustomTimeTableCell
            cell.timeLabel.font = UIFont(name: "Helvetica Neue", size: 11.5) //Setting the font and font size of the cell
            cell.timeLabel.text = cellTimes[indexPath.row] //Setting the time the cell should display
            //cell.timeLabel.frame.origin = cell.center
            
            //Every cell that does not have the text "11:00 PM" should have a black "cellSeperator"
            if cell.timeLabel.text == "11:00 PM" {
                cell.cellSeperator.backgroundColor = UIColor.white
            }
                
            else {
                cell.cellSeperator.backgroundColor = UIColor.black
            }
            return cell
        }
            
        else {
            
            var blockData = configureBufferBlocks(sortBlockResults(), functionTuple)
            
            //If "blocks" container is empty, a "CustomAddBlockTableCell" is going to be used in the tableView to allow the user to add another "blockCell"
            if blockArray.count == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "addBlockCell", for: indexPath) as! CustomAddBlockTableCell
                return cell
            }
                
                //If "blocks" container isn't empty, a "CustomBlockTableCell" is going to be used for every "indexPath.row" that is less than the count of the "blocks" container
            else {
                if indexPath.row < blockArray.count {
                    
                    //Boolean test to check that the "blocks" container isn't nil; if so, a "CustomBlockTableCell" will be created using a "Block" object returned from the "sortBlockResults" function
                    if indexPath.row < blockArray.count {//(blocks?[indexPath.row]) != nil {
                        
                        //var sortedBlocks = sortBlockResults()
                        
                        if blockArray[indexPath.row].blockName != "Buffer Block" {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! CustomBlockTableCell
                            
                            cell.eventLabel.text = blockArray[indexPath.row].blockName
                            cell.startLabel.text = blockArray[indexPath.row].blockStartHour + ":" + blockArray[indexPath.row].blockStartMinute + " " + blockArray[indexPath.row].blockStartPeriod
                            cell.endLabel.text = blockArray[indexPath.row].blockEndHour + ":" + blockArray[indexPath.row].blockEndMinute + " " + blockArray[indexPath.row].blockEndPeriod
                            
                            cell.cellContainerView.frame = CGRect(x: 0, y: 2, width: 280, height: (cell.frame.height - 2.0)) //Beginning adjustments for the cellContainerView
                            
                            animateBlock(cell, indexPath)
                            return cell
                        }
                        
                        else {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                            cell.selectionStyle = .none
                            //cell.textLabel?.text = blockArray[indexPath.row].blockName
                            return cell
                        }
                        
                        
                    }
                        //UHHHH NOT SURE YET
                    else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                        cell.textLabel!.text = "Error Creating Time Block"
                        return cell
                    }
                }
                    
                    //For every last cell in the tableView, a "CustomAddBlockTableCell" is going to be used
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "addBlockCell", for: indexPath) as! CustomAddBlockTableCell
                    return cell
                }
            }
        }
    }
    
    
    func configureBlockHeight (indexPath: IndexPath/*, blockTuples: [(blockTuple)]*/) -> CGFloat {
        
        var calcHour: Int = 0
        var calcMinute: Int = 0
        
        if indexPath.row < blockArray.count { //(blocks?[indexPath.row]) != nil {
            
            //var sortedBlocks = sortBlockResults()
            //var blockData = blockTuples
            
            if Int(blockArray[indexPath.row].blockEndMinute)! > Int(blockArray[indexPath.row].blockStartMinute)! {
                
                if blockArray[indexPath.row].blockStartPeriod == "AM" && blockArray[indexPath.row].blockEndPeriod == "AM" {
                    
                    calcHour = Int(amDictionaries[blockArray[indexPath.row].blockEndHour]!)! - Int(amDictionaries[blockArray[indexPath.row].blockStartHour]!)!
                    calcMinute = (Int(blockArray[indexPath.row].blockEndMinute)! - Int(blockArray[indexPath.row].blockStartMinute)!)
                    return CGFloat((calcHour * 120) + (calcMinute * 2))
                }
                
                else if blockArray[indexPath.row].blockStartPeriod == "AM" && blockArray[indexPath.row].blockEndPeriod == "PM" {
                    
                    calcHour = Int(pmDictionaries[blockArray[indexPath.row].blockEndHour]!)! - Int(amDictionaries[blockArray[indexPath.row].blockStartHour]!)!
                    calcMinute = (Int(blockArray[indexPath.row].blockEndMinute)! - Int(blockArray[indexPath.row].blockStartMinute)!)
                    return CGFloat((calcHour * 120) + (calcMinute * 2))
                }
                
                else {
                    calcHour = Int(pmDictionaries[blockArray[indexPath.row].blockEndHour]!)! - Int(pmDictionaries[blockArray[indexPath.row].blockStartHour]!)!
                    calcMinute = (Int(blockArray[indexPath.row].blockEndMinute)! - Int(blockArray[indexPath.row].blockStartMinute)!)
                    return CGFloat((calcHour * 120) + (calcMinute * 2))
                }
                
            }
            
            else if Int(blockArray[indexPath.row].blockEndMinute)! == Int(blockArray[indexPath.row].blockStartMinute)! {
                
                if blockArray[indexPath.row].blockStartPeriod == "AM" && blockArray[indexPath.row].blockEndPeriod == "AM" {
                    //Add a 0 key and value in am dictionary
                    calcHour = Int(amDictionaries[blockArray[indexPath.row].blockEndHour]!)! - Int(amDictionaries[blockArray[indexPath.row].blockStartHour]!)!
                    return CGFloat(calcHour * 120)
                }
                
                else if blockArray[indexPath.row].blockStartPeriod == "AM" && blockArray[indexPath.row].blockEndPeriod == "PM" {
                    
                    calcHour = Int(pmDictionaries[blockArray[indexPath.row].blockEndHour]!)! - Int(amDictionaries[blockArray[indexPath.row].blockStartHour]!)!
                    return CGFloat(calcHour * 120)
                }
                
                else {
                    
                    calcHour = Int(pmDictionaries[blockArray[indexPath.row].blockEndHour]!)! - Int(pmDictionaries[blockArray[indexPath.row].blockStartHour]!)!
                    return CGFloat(calcHour * 120)
                }
            }
            
            else {
                
                if blockArray[indexPath.row].blockStartPeriod == "AM" && blockArray[indexPath.row].blockEndPeriod == "AM" {
                
                    calcHour = (Int(amDictionaries[blockArray[indexPath.row].blockEndHour]!)! - 1) - Int(amDictionaries[blockArray[indexPath.row].blockStartHour]!)!
                    calcMinute = ((Int(blockArray[indexPath.row].blockEndMinute)! + 60) - Int(blockArray[indexPath.row].blockStartMinute)!)
                    return CGFloat((calcHour * 120) + (calcMinute * 2))
                }
                
                else if blockArray[indexPath.row].blockStartPeriod == "AM" && blockArray[indexPath.row].blockEndPeriod == "PM" {
                    
                    calcHour = (Int(pmDictionaries[blockArray[indexPath.row].blockEndHour]!)! - 1) - Int(amDictionaries[blockArray[indexPath.row].blockStartHour]!)!
                    calcMinute = ((Int(blockArray[indexPath.row].blockEndMinute)! + 60) - Int(blockArray[indexPath.row].blockStartMinute)!)
                    return CGFloat((calcHour * 120) + (calcMinute * 2))
                }
                
                else {
                   
                    calcHour = (Int(pmDictionaries[blockArray[indexPath.row].blockEndHour]!)! - 1) - Int(pmDictionaries[blockArray[indexPath.row].blockStartHour]!)!
                    calcMinute = ((Int(blockArray[indexPath.row].blockEndMinute)! + 60) - Int(blockArray[indexPath.row].blockStartMinute)!)
                    return CGFloat((calcHour * 120) + (calcMinute * 2))
                }
            }
        }
        
        else {
            return 90.0
        }
    }
    
    
    func animateBlock (_ cell: CustomBlockTableCell, _ indexPath: IndexPath) {
        
        //If statement checking to see if a certain cell has been animated onto the screen or not
        if cellAnimated[indexPath.row] == false {
            
            //Sets the x coordinate of the "cellContainerView" for the "CustomBlockTableCell" equal to 500 + (indexPath.row * 150)
            cell.cellContainerView.frame.origin.x = CGFloat(500) + CGFloat(indexPath.row * 150)
        
            //Animates a cell onto the screen
            UIView.animate(withDuration: 2) {
                cell.cellContainerView.frame.origin.x = 5.0
            }
            
           cellAnimated[indexPath.row] = true
        }
            
        //If a cell has already been animated, it simply sets the x coordinate of the cell to be 5
        else {
            cell.cellContainerView.frame.origin.x = 5.0
        }
    }
    
}
