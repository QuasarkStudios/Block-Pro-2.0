//
//  CollabBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/10/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
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
    
    let formatter = DateFormatter()
    
    let cellTimes: [String] = ["12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM", "5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"]
    
    let blockCategoryColors: [String : String] = ["Work": "#5065A0", "Creative Time" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#EFEFF4"]
    
    var collabID: String = ""
    var collabName: String = ""
    var collabDate: String = ""
    
    var cellAnimated = [String]() //Variable that helps track whether or not a certain cell has been animated onto the screen yet
    
    typealias blockTuple = (creator: [String : String], blockID: String, name: String, startHour: String, startMinute: String, startPeriod: String, endHour: String, endMinute: String, endPeriod: String, category: String, notificationSettings: [String : Any])
    var functionTuple: blockTuple = (creator: ["" : ""], blockID: "", name: "", startHour: "", startMinute: "", startPeriod: "", endHour: "", endMinute: "", endPeriod: "", category: "", notificationSettings: ["" : ""])
    
    var blockObjectArray: [CollabBlock] = [CollabBlock]()
    var blockArray = [blockTuple]()
    var selectedBlock: CollabBlock?
    
    var bigBlockID: String = ""
    //var notificationID: String = ""
    var notificationSettings: [String : Any] = [:]
    
    var selectedView: String = ""
    
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
        //blockTableView.rowHeight = 120.0
        
        timeTableView.register(UINib(nibName: "CustomTimeTableCell", bundle: nil), forCellReuseIdentifier: "timeCell")
        
        blockTableView.register(UINib(nibName: "CollabBlockTableCell", bundle: nil), forCellReuseIdentifier: "collabCell")
        
        formatter.dateFormat = "EEEE, MMMM d"
        
        //self.title = formatter.string(from: Date())
        navigationItem.title = collabName
        
//        db.clearPersistence { (error) in
//
//            if error != nil {
//                print("error clearing persistent data:", error)
//            }
//        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        getCollabBlocks {
            
            self.blockArray = self.organizeBlocks(self.sortCollabBlocks(), self.functionTuple)
            self.blockTableView.reloadData()
            self.scrollToFirstBlock()
        }
        
        //scrollToFirstBlock()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        listener?.remove()
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

        var returnHeight: CGFloat = 120.0

        if tableView == blockTableView && indexPath.row < blockArray.count {

            returnHeight = configureBlockHeight(indexPath: indexPath)
            return returnHeight
        }

            //The tableView is the timeTableView
        else {
            return returnHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for block in blockObjectArray {
            
            if block.blockID == blockArray[indexPath.row].blockID {
                
                selectedBlock = block
            }
        }
        
        bigBlockID = blockArray[indexPath.row].blockID
        //notificationID = blockArray[indexPath.row].notificationID
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
            
            cell.frame = CGRect(x: 0, y: 0, width: 65, height: 120)
            cell.timeLabel.frame = CGRect(x: 0, y: 49, width: 65, height: 20)
            cell.timeLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 13) //Setting the font and font size of the cell
            cell.timeLabel.text = cellTimes[indexPath.row] //Setting the time the cell should display
            
            cell.cellSeperator.frame = CGRect(x: 6, y: 119, width: 52, height: 0.5)
            
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
            
                if blockArray[indexPath.row].name != "Buffer Block" {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabCell", for: indexPath) as! CollabBlockTableCell
                    
                    cell.nameLabel.text = blockArray[indexPath.row].name
                    cell.startLabel.text = convertTo12Hour(blockArray[indexPath.row].startHour, blockArray[indexPath.row].startMinute)
                    cell.endLabel.text = convertTo12Hour(blockArray[indexPath.row].endHour, blockArray[indexPath.row].endMinute)
                    
                    cell.cellContainerView.frame = CGRect(x: 0, y: 2, width: 301, height: (cell.frame.height - 2.0)) //POSSIBLY TAKE 1 POINT OFF Y AND 1 OFF HEIGHT TO MAKE CELL LOOK MORE SYMETRICAL
                    
                    //If the user didn't select a category for this TimeBlock
                    if blockArray[indexPath.row].category != "" {
                        cell.cellContainerView.backgroundColor = UIColor(hexString: blockCategoryColors[blockArray[indexPath.row].category])
                    }
                        //If the user did select a category for this TimeBlock
                    else {
                        cell.cellContainerView.backgroundColor = UIColor(hexString: "#EFEFF4")
                    }
                    
                    if blockArray[indexPath.row].creator["userID"] == currentUser.userID {
                        
                        cell.initialLabel.text = "Me"
                        
                    }
                    else {
                        
                        let firstNameArray = Array(blockArray[indexPath.row].creator["firstName"]!)
                        let lastNameArray = Array(blockArray[indexPath.row].creator["lastName"]!)
                        
                        cell.initialLabel.text = "\(firstNameArray[0])" + "\(lastNameArray[0])"
                    }
                    
                    animateBlock(cell, indexPath)
                    
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    cell.isUserInteractionEnabled = false
                    
                    return cell
                    
                }
        }
        
    }
    
    func getCollabBlocks (completion: @escaping () -> ()) {
        
//        blockObjectArray.removeAll()
        
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
            return "YOU GOT IT WRONG BEYOTCH"
        }
    }
    
    //Function responsible for configuring the height of each Block
    func configureBlockHeight (indexPath: IndexPath) -> CGFloat{
        
        var calcHour: Int = 0
        var calcMinute: Int = 0
        
        //If statement mainly to ensure the code for this statement is running safely
        if indexPath.row < blockArray.count {
            
            //If the endMinute of the block is greater than the startMinute of the block
            if Int(blockArray[indexPath.row].endMinute)! > Int(blockArray[indexPath.row].startMinute)! {
                
                calcHour = Int(blockArray[indexPath.row].endHour)! - Int(blockArray[indexPath.row].startHour)!
                calcMinute = Int(blockArray[indexPath.row].endMinute)! - Int(blockArray[indexPath.row].startMinute)!
                return CGFloat((calcHour * 120) + calcMinute * 2)
            }
                
                //If the endMinute of the block is equal to the startMinute of the block
            else if Int(blockArray[indexPath.row].endMinute)! == Int(blockArray[indexPath.row].startMinute)! {
                
                calcHour = Int(blockArray[indexPath.row].endHour)! - Int(blockArray[indexPath.row].startHour)!
                return CGFloat(calcHour * 120)
            }
                
                //If the endMinute of the block is less than the startMinute of the block
            else {
                
                calcHour = (Int(blockArray[indexPath.row].endHour)! - 1) - Int(blockArray[indexPath.row].startHour)!
                calcMinute = ((Int(blockArray[indexPath.row].endMinute)! + 60) - Int(blockArray[indexPath.row].startMinute)!)
                return CGFloat((calcHour * 120) + (calcMinute * 2))
            }
        }
            
        else {
            return 90.0
        }
    }
    
    //Function responsible for animating a TimeBlock
    func animateBlock (_ cell: CollabBlockTableCell, _ indexPath: IndexPath) {
        
        //If a certain TimeBlock has not yet been animated
        if cellAnimated.contains(blockArray[indexPath.row].blockID) != true {
            
            //Sets the x coordinate of the "cellContainerView" for the "CustomBlockTableCell" equal to 500 + (indexPath.row * 150)
            cell.cellContainerView.frame.origin.x = CGFloat(500) + CGFloat(indexPath.row * 150)
            
            //Animates a cell onto the screen
            UIView.animate(withDuration: 1) {
                cell.cellContainerView.frame.origin.x = 5.0
            }
            
            cellAnimated.append(blockArray[indexPath.row].blockID) //Adds the animated TimeBlock's blockID into the cellAnimated array
        }
            
            //If a cell has already been animated, it simply sets the x coordinate of the cell to be 5
        else {
            cell.cellContainerView.frame.origin.x = 5.0
        }
    }
    
    
    @IBAction func addBlockButton(_ sender: Any) {
        
        selectedView = "Add"
        performSegue(withIdentifier: "moveToAUBlockView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "presentBlockPopover" {
            
            let bigBlockVC = segue.destination as! CollabBlockPopoverViewController
            
            bigBlockVC.updateCollabBlockDelegate = self
            bigBlockVC.deleteCollabBlockDelegate = self
            
            bigBlockVC.collabID = collabID
            bigBlockVC.blockID = bigBlockID
            //bigBlockVC.notificationID = notificationID
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
