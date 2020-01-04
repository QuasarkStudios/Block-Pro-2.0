//
//  CollabBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/10/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import UserNotifications

class CollabBlockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var blockTableView: UITableView!
    @IBOutlet weak var verticalTableSeperator: UIImageView!
    
    @IBOutlet weak var addBlockButton: UIBarButtonItem!
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration?
    let currentUser = UserData.singletonUser
    
    let cellTimes: [String] = ["12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM", "5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"]
    
    let blockCategoryColors: [String : String] = ["Work": "#5065A0", "Creativity" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#AAAAAA"]
    
    var collabID: String = ""
    var collabName: String = ""
    var collabDate: String = ""
    
    var cellAnimated = [String]() //Variable that helps track whether or not a certain cell has been animated onto the screen yet
    
    typealias blockTuple = (creator: [String : String], blockID: String, name: String, startHour: String, startMinute: String, startPeriod: String, endHour: String, endMinute: String, endPeriod: String, category: String, notificationSettings: [String : Any])
    var functionTuple: blockTuple = (creator: ["" : ""], blockID: "", name: "", startHour: "", startMinute: "", startPeriod: "", endHour: "", endMinute: "", endPeriod: "", category: "", notificationSettings: ["" : ""])
    
    var rowHeights: [CGFloat] = []
    
    var blockObjectArray: [CollabBlock] = [CollabBlock]()
    var blockArray = [blockTuple]()
    var selectedBlock: CollabBlock?
    
    var bigBlockID: String = ""
    var notificationSettings: [String : Any] = [:]
    
    var selectedView: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        ProgressHUD.show()
        
        getCollabBlocks {
            
            self.blockArray = self.organizeBlocks(self.sortCollabBlocks(), self.functionTuple)
            self.calculateBlockHeights()
            self.blockTableView.reloadData()
            self.scrollToFirstBlock()
            
            ProgressHUD.dismiss()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        listener?.remove()
        
        ProgressHUD.dismiss()
    }
    
    
    func configureView () {
        
        navigationItem.title = collabName
        
        timeTableView.delegate = self
        timeTableView.dataSource = self
        
        timeTableView.showsVerticalScrollIndicator = false
        timeTableView.allowsSelection = false
        timeTableView.separatorStyle = .none
        timeTableView.rowHeight = 120.0
        
        timeTableView.register(UINib(nibName: "CustomTimeTableCell", bundle: nil), forCellReuseIdentifier: "timeCell")
        
        verticalTableSeperator.backgroundColor = UIColor(hexString: "F2F2F2")?.darken(byPercentage: 0.3)
        
        blockTableView.delegate = self
        blockTableView.dataSource = self
        
        blockTableView.separatorStyle = .none
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == timeTableView {
            return cellTimes.count
        }
        
        else {
            return blockArray.count
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == timeTableView {
            
            let cell: UITableViewCell = configureCell(tableView, indexPath)
            return cell
        }
        else {
            
            let cell: UITableViewCell = configureCell(tableView, indexPath)
            cell.clipsToBounds = true
            return cell
        }
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for block in blockObjectArray {
            
            if block.blockID == blockArray[indexPath.row].blockID {
                
                selectedBlock = block
            }
        }
        
        bigBlockID = blockArray[indexPath.row].blockID
        notificationSettings = blockArray[indexPath.row].notificationSettings
        
        performSegue(withIdentifier: "presentBlockPopover", sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
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
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "fiveMinCell", for: indexPath) as! CollabFiveMinCell
                    cell.block = blockArray[indexPath.row]
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                case 20.0:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "tenMinCell", for: indexPath) as! CollabTenMinCell
                    cell.block = blockArray[indexPath.row]
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell

                case 30.0:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "fifteenMinCell", for: indexPath) as! CollabFifteenMinCell
                    cell.block = blockArray[indexPath.row]
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                case 40.0:
                   
                    let cell = tableView.dequeueReusableCell(withIdentifier: "twentyMinCell", for: indexPath) as! CollabTwentyMinCell
                    cell.block = blockArray[indexPath.row]
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell

                case 50.0:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "twentyfiveMinCell", for: indexPath) as! CollabTwentyFiveMinCell
                    cell.block = blockArray[indexPath.row]
                    
                    animateBlock(cell, rowHeights[indexPath.row], indexPath)
                    
                    return cell
                    
                default:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "thirtyMinAndUpCell", for: indexPath) as! CollabThirtyMinAndUpCell
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
    
    
    func getCollabBlocks (completion: @escaping () -> ()) {
        
        listener = db.collection("Collaborations").document(collabID).collection("CollabBlocks").addSnapshotListener { (snapshot, error) in
            
            self.blockObjectArray.removeAll()

            if error != nil {
                
                ProgressHUD.showError(error?.localizedDescription)
            }
                
            else {
                
                if snapshot?.isEmpty == true {
                    print ("no collabblocks")
                    completion()
                }
                
                else {
                    
                    for document in snapshot!.documents {
                        
                        let collabBlock = CollabBlock()
                            
                        collabBlock.blockID = document.data()["blockID"] as! String
                        collabBlock.name = document.data()["name"] as! String
                        collabBlock.creator = document.data()["creator"] as! [String : String]
                        
                        collabBlock.startHour = document.data()["startHour"] as! String
                        collabBlock.startMinute = document.data()["startMinute"] as! String
                        collabBlock.startPeriod = document.data()["startPeriod"] as! String
                        
                        collabBlock.endHour = document.data()["endHour"] as! String
                        collabBlock.endMinute = document.data()["endMinute"] as! String
                        collabBlock.endPeriod = document.data()["endPeriod"] as! String
                        
                        collabBlock.blockCategory = document.data()["blockCategory"] as! String
                        
                        collabBlock.notificationSettings = document.data()["notificationSettings"] as! [String : [String : Any]]
                        
                        self.blockObjectArray.append(collabBlock)
                    }

                    self.blockTableView.reloadData()
                    completion()
                }
            }
        }
    }
    
    
    func sortCollabBlocks () -> [(key: Int, value: CollabBlock)] {
        
        var sortedBlocks: [Int : CollabBlock] = [:]
        
        for collabBlocks in blockObjectArray {
            
            sortedBlocks[Int(collabBlocks.startHour + collabBlocks.startMinute)!] = collabBlocks
        }
        
        return sortedBlocks.sorted(by: {$0.key < $1.key})
    }
    
    
    //Function responsible for organizing CollabBlocks and bufferBlocks
    func organizeBlocks (_ sortedBlocks: [(key: Int, value: CollabBlock)], _ blockTuple: blockTuple) -> [(blockTuple)] {
        
        
        var firstIteration: Bool = true //Tracks if the for loop is on its first iteration or not
        var count: Int = 0 //Variable that tracks which index of the "sortedBlocks" array the for loop is on
        var arrayCleanCount: Int = 0
        
        var bufferBlockTuple = blockTuple //Tuples must be passed by value, not by reference
        var collabBlockTuple = blockTuple //Tuples must be passed by value, not by reference
        var returnBlockArray = [blockTuple] //Array of blockTuples going to be returned from the function
        
        for blocks in sortedBlocks {
            
            //If the for loop is on its first iteration
            if firstIteration == true {
                
                //Creating the first Buffer Block starting at 12:00 AM until the first CollabBlock
                bufferBlockTuple.name = "Buffer Block"
                bufferBlockTuple.startHour = "0"; bufferBlockTuple.startMinute = "0"; bufferBlockTuple.startPeriod = "AM"
                bufferBlockTuple.endHour = blocks.value.startHour; bufferBlockTuple.endMinute = blocks.value.startMinute; bufferBlockTuple.endPeriod = blocks.value.startPeriod
                
                //Creating the first CollabBlock from the values returned from the sortBlocks function
                
                collabBlockTuple.creator = blocks.value.creator
                
                collabBlockTuple.name = blocks.value.name
                collabBlockTuple.startHour = blocks.value.startHour; collabBlockTuple.startMinute = blocks.value.startMinute; collabBlockTuple.startPeriod = blocks.value.startPeriod
                collabBlockTuple.endHour = blocks.value.endHour; collabBlockTuple.endMinute = blocks.value.endMinute; collabBlockTuple.endPeriod = blocks.value.endPeriod
                
                collabBlockTuple.category = blocks.value.blockCategory
                collabBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this CollabBlock
                collabBlockTuple.notificationSettings = blocks.value.notificationSettings //Assigning the notificationID of this CollabBlock
                
                returnBlockArray.append(bufferBlockTuple) //Appending the first BufferBlock
                returnBlockArray.append(collabBlockTuple) //Appending the first CollabBlock
                firstIteration = false
                
                //If statement that creates a buffer block after the first CollabBlock
                if (count + 1) < sortedBlocks.count {
                    
                    bufferBlockTuple.startHour = blocks.value.endHour; bufferBlockTuple.startMinute = blocks.value.endMinute; bufferBlockTuple.startPeriod = blocks.value.endPeriod
                    
                    bufferBlockTuple.endHour = sortedBlocks[count + 1].value.startHour; bufferBlockTuple.endMinute = sortedBlocks[count + 1].value.startMinute; bufferBlockTuple.endPeriod = sortedBlocks[count + 1].value.startPeriod
                    
                    returnBlockArray.append(bufferBlockTuple) //Appending the second BufferBlock after the first CollabBlock
                }
                count += 1
            }
                
            //If the for loop is not on its first iteration
            else {
                
                //If there is more than one CollabBlock left
                if (count + 1) < sortedBlocks.count {
                    
                    //Creating the next CollabBlock from the values returned from the sortBlocks func
                    
                    collabBlockTuple.creator = blocks.value.creator
                    
                    collabBlockTuple.name = blocks.value.name
                    collabBlockTuple.startHour = blocks.value.startHour; collabBlockTuple.startMinute = blocks.value.startMinute; collabBlockTuple.startPeriod = blocks.value.startPeriod
                    collabBlockTuple.endHour = blocks.value.endHour; collabBlockTuple.endMinute = blocks.value.endMinute; collabBlockTuple.endPeriod = blocks.value.endPeriod
                    
                    collabBlockTuple.category = blocks.value.blockCategory
                    collabBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this CollabBlock
                    collabBlockTuple.notificationSettings = blocks.value.notificationSettings //Assigning the notificationID of this CollabBlock
                    
                    //Creating the next Buffer Block after the last CollabBlock
                    bufferBlockTuple.startHour = blocks.value.endHour; bufferBlockTuple.startMinute = blocks.value.endMinute; bufferBlockTuple.startPeriod = blocks.value.endPeriod
                    
                    bufferBlockTuple.endHour = sortedBlocks[count + 1].value.startHour; bufferBlockTuple.endMinute = sortedBlocks[count + 1].value.startMinute; bufferBlockTuple.endPeriod = sortedBlocks[count + 1].value.startPeriod
                    
                    returnBlockArray.append(collabBlockTuple) //Appending the next CollabBlock
                    returnBlockArray.append(bufferBlockTuple) //Appending the next bufferBlock
                    count += 1
                }
                    
                //If there is only one more CollabBlock left
                else {
                    
                    //Creating the next CollabBlock from the values returned from the sortBlocks func
                    
                    collabBlockTuple.creator = blocks.value.creator
                    
                    collabBlockTuple.name = blocks.value.name
                    collabBlockTuple.startHour = blocks.value.startHour; collabBlockTuple.startMinute = blocks.value.startMinute; collabBlockTuple.startPeriod = blocks.value.startPeriod
                    collabBlockTuple.endHour = blocks.value.endHour; collabBlockTuple.endMinute = blocks.value.endMinute; collabBlockTuple.endPeriod = blocks.value.endPeriod
                    
                    collabBlockTuple.category = blocks.value.blockCategory
                    collabBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this CollabBlock
                    collabBlockTuple.notificationSettings = blocks.value.notificationSettings //Assigning the notificationID of this CollabBlock
                    
                    returnBlockArray.append(collabBlockTuple)
                    count += 1
                }
                
            }
        }
        
        arrayCleanCount = returnBlockArray.count
        
        while arrayCleanCount > 0 {
            
            if (returnBlockArray[arrayCleanCount - 1].startHour == returnBlockArray[arrayCleanCount - 1].endHour) && (returnBlockArray[arrayCleanCount - 1].startMinute == returnBlockArray[arrayCleanCount - 1].endMinute) && (returnBlockArray[arrayCleanCount - 1].startPeriod == returnBlockArray[arrayCleanCount - 1].endPeriod) {
                
                _ = returnBlockArray.remove(at: arrayCleanCount - 1) //Removing a particular block
            }
            arrayCleanCount -= 1
        }
        
        return returnBlockArray
    }
    

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
    
    
    //Function responsible for calculating the height of each Block
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
    
    //Function responsible for animating a CollabBlock
    func animateBlock (_ cell: UITableViewCell, _ cellHeight: CGFloat, _ indexPath: IndexPath) {
        
        switch cellHeight {
            
        case 10.0:
            
            let funcCell = cell as! CollabFiveMinCell
            
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
            
            let funcCell = cell as! CollabTenMinCell
            
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
            
            let funcCell = cell as! CollabFifteenMinCell
            
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
            
            let funcCell = cell as! CollabTwentyMinCell
            
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
            
            let funcCell = cell as! CollabTwentyFiveMinCell
            
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
            
            let funcCell = cell as! CollabThirtyMinAndUpCell
            
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
    
    func deleteCollab () {
        
        db.collection("Users").document(currentUser.userID).collection("UpcomingCollabs").document(collabID).delete { (error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
        }
        
        db.collection("Users").document(currentUser.userID).collection("HistoricCollabs").document(collabID).delete { (error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addBlockButton(_ sender: Any) {
        
        selectedView = "Add"
        performSegue(withIdentifier: "moveToAUBlockView", sender: self)
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        let deleteAlert = UIAlertController(title: "Are you sure you would like to delete this Collab?" , message: "All data associated with this Collab will also be deleted.", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (deleteAction) in
            
            self.deleteCollab()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "presentBlockPopover" {
            
            let bigBlockVC = segue.destination as! CollabBlockPopoverViewController
            
            bigBlockVC.updateCollabBlockDelegate = self
            bigBlockVC.deleteCollabBlockDelegate = self
            
            bigBlockVC.collabID = collabID
            bigBlockVC.blockID = bigBlockID
        }
        
        else if segue.identifier == "moveToAUBlockView" {
            
            let add_updateBlockVC = segue.destination as! AUCollabBlockViewController
            add_updateBlockVC.collabID = collabID
            add_updateBlockVC.collabDate = collabDate
            add_updateBlockVC.selectedView = selectedView
            
            if selectedView == "Edit" {
                add_updateBlockVC.selectedBlock = selectedBlock
            }
            
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem
        }
    }
}

extension CollabBlockViewController: UpdateCollabBlock {
    
    func moveToUpdateView () {
        
        selectedView = "Edit"
        performSegue(withIdentifier: "moveToAUBlockView", sender: self)
    }
}

extension CollabBlockViewController: DeleteCollabBlock {
    
    func deleteBlock () {
        
        db.collection("Collaborations").document(collabID).collection("CollabBlocks").document(bigBlockID).delete { (error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            else {
                
                ProgressHUD.showSuccess("Collab Block deleted!")
                
                if let notifSettings = self.selectedBlock?.notificationSettings[self.currentUser.userID] {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifSettings["notificationID"] as! String])
                }
                
                self.getCollabBlocks {
                    
                    self.blockArray = self.organizeBlocks(self.sortCollabBlocks(), self.functionTuple)
                    self.blockTableView.reloadData()
                    self.scrollToFirstBlock()
                }
            }
        }
    }
}

extension CollabBlockViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if tabBarController.selectedIndex != 3 {
            tabBarController.delegate = nil
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController == navigationController {
            
            if currentUser.userID != "" {
                
                navigationController?.popToViewController(navigationController!.viewControllers[1], animated: true)
                return false
            }
            
            else {
                return true
            }
        }
        
        else {
            return true
        }
    }
}
