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
    var realmData: Results<Block>? //Setting the variable "blocks" to type "Results" that will contain "Block" objects; "Results" is an auto-updating container type in Realm
    
    //Variable storing "CustomTimeTableCell" text for each indexPath
    let cellTimes: [String] = ["12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM", "5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"]
    
    //Add 24 time setting
    
    var cellAnimated = [Bool](repeating: false, count: 24) //Variable that helps track whether or not a certain cell has been animated onto the screen yet
    
    //Creation of to pre-define the block tuple's structure and allow for it to be used as a return of a function
    typealias blockTuple = ( blockID: String, blockName: String, blockStartHour: String, blockStartMinute: String, blockStartPeriod: String, blockEndHour: String, blockEndMinute: String, blockEndPeriod: String, note1: String, note2: String, note3: String)
    var functionTuple: blockTuple = (blockID: "", blockName: "", blockStartHour: "", blockStartMinute: "", blockStartPeriod: "", blockEndHour: "", blockEndMinute: "", blockEndPeriod: "", note1: "", note2: "", note3: "")
    var blockArray = [blockTuple]()
    
    var bigBlockID: String = ""
    
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
        //blockTableView.rowHeight = 90.0
        
        verticalTableViewSeperator.layer.cornerRadius = 0.5 * verticalTableViewSeperator.bounds.size.width
        verticalTableViewSeperator.clipsToBounds = true
        
        timeTableView.register(UINib(nibName: "CustomTimeTableCell", bundle: nil), forCellReuseIdentifier: "timeCell")
        blockTableView.register(UINib(nibName: "CustomBlockTableCell", bundle: nil), forCellReuseIdentifier: "blockCell")
        blockTableView.register(UINib(nibName: "CustomAddBlockTableCell", bundle: nil), forCellReuseIdentifier: "addBlockCell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        realmData = realm.objects(Block.self)
        blockArray = organizeBlocks(sortRealmBlocks(), functionTuple)
        blockTableView.reloadData()
        
        
        // TODO: Add code to allow for tableView to be loaded back at the top of screen or at the first timeBlock
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
            
            else {
                return blockArray.count //(blocks?.count ?? 1) + 1
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = configureCell(tableView, indexPath)
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as! CustomBlockTableCell
        
        bigBlockID = blockArray[indexPath.row].blockID
        
        performSegue(withIdentifier: "presentBlockPopover", sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var count: Int = 0

        var returnHeight: CGFloat = 120.0

        if tableView == blockTableView && indexPath.row < blockArray.count {//blocks?.count ?? 0 {

            while count < blockArray.count {//blocks?.count ?? 1 {

                returnHeight = configureBlockHeight2(indexPath: indexPath)
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
    
    func sortRealmBlocks () -> [(key: Int, value: Block)] {
        
        realmData = realm.objects(Block.self)
        var sortedBlocks: [Int : Block] = [:]
        
        for timeBlocks in realmData! {
            
            if timeBlocks.startPeriod == "AM" {
                sortedBlocks[Int(timeBlocks.startHour + timeBlocks.startMinute)!] = timeBlocks
                //print (sortedBlocks)
            }

            else if timeBlocks.startPeriod == "PM" {
                sortedBlocks[Int(timeBlocks.startHour + timeBlocks.startMinute)!] = timeBlocks
                //print (sortedBlocks)
            }
        }
        return sortedBlocks.sorted(by: {$0.key < $1.key})
    }
    
    
    func organizeBlocks (_ sortedBlocks: [(key: Int, value: Block)],_ blockTuple: blockTuple) -> [(blockTuple)] {
        
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
                bufferBlockTuple.blockStartHour = "0"; bufferBlockTuple.blockStartMinute = "0"; bufferBlockTuple.blockStartPeriod = "AM"
                bufferBlockTuple.blockEndHour = blocks.value.startHour; bufferBlockTuple.blockEndMinute = blocks.value.startMinute; bufferBlockTuple.blockEndPeriod = blocks.value.startPeriod

                //Creating the first TimeBlock from the values returned from the sortBlocks func
                timeBlockTuple.blockName = blocks.value.name
                timeBlockTuple.blockStartHour = blocks.value.startHour; timeBlockTuple.blockStartMinute = blocks.value.startMinute; timeBlockTuple.blockStartPeriod = blocks.value.startPeriod
                timeBlockTuple.blockEndHour = blocks.value.endHour; timeBlockTuple.blockEndMinute = blocks.value.endMinute; timeBlockTuple.blockEndPeriod = blocks.value.endPeriod
                timeBlockTuple.note1 = blocks.value.note1; timeBlockTuple.note2 = blocks.value.note2; timeBlockTuple.note3 = blocks.value.note3
                
                timeBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this timeBlock
                
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
                    timeBlockTuple.note1 = blocks.value.note1; timeBlockTuple.note2 = blocks.value.note2; timeBlockTuple.note3 = blocks.value.note3
                    
                    timeBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this timeBlock
                    
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
                    timeBlockTuple.note1 = blocks.value.note1; timeBlockTuple.note2 = blocks.value.note2; timeBlockTuple.note3 = blocks.value.note3
                    
                    timeBlockTuple.blockID = blocks.value.blockID //Assigning the blockID of this timeBlock
                    
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
            
            if blockArray.count == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) //(withIdentifier: "addBlockCell", for: indexPath) as! CustomAddBlockTableCell
                cell.textLabel?.text = "Add a new cell below"
                return cell
            }
                
            else {
                if indexPath.row < blockArray.count {
                        
                        if blockArray[indexPath.row].blockName != "Buffer Block" {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! CustomBlockTableCell
                            
                            cell.nameLabel.text = blockArray[indexPath.row].blockName
                            cell.startLabel.text = convertTo12Hour(blockArray[indexPath.row].blockStartHour, blockArray[indexPath.row].blockStartMinute)
                            cell.endLabel.text = convertTo12Hour(blockArray[indexPath.row].blockEndHour, blockArray[indexPath.row].blockEndMinute)
                            
                            cell.note1TextView.text = blockArray[indexPath.row].note1; cell.note1Bullet.isHidden = true; cell.note1TextView.isHidden = true
                            cell.note2TextView.text = blockArray[indexPath.row].note2; cell.note2Bullet.isHidden = true; cell.note2TextView.isHidden = true
                            cell.note3TextView.text = blockArray[indexPath.row].note3; cell.note3Bullet.isHidden = true; cell.note3TextView.isHidden = true
                            
                            cell.cellContainerView.frame = CGRect(x: 0, y: 2, width: 280, height: (cell.frame.height - 2.0)) //POSSIBLY TAKE 1 POINT OFF Y AND 1 OFF HEIGHT TO MAKE CELL LOOK MORE SYMETRICAL
                            
                            configureBlockLayout(cell)
                            animateBlock(cell, indexPath)
                            return cell
                        }
                        
                        else { //Creation of a buffer block
                            
                            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                            cell.isUserInteractionEnabled = false
                            
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
        }
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
    
    func configureBlockLayout (_ cell: CustomBlockTableCell) {
        
        let cellHeight: CGFloat = cell.frame.height
        
        switch cellHeight {
            
        case 10.0:
            cell.cellContainerView.layer.cornerRadius = 0.015 * cell.cellContainerView.bounds.size.width

            cell.alphaView.frame.origin = CGPoint(x: 200.0, y: 200.0) //Done to remove alphaView from 5 minute block without lingering effects of reusing cells
            
            cell.nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 9.0)
            cell.nameLabel.frame.origin = CGPoint(x: 18.0, y: -7.0)
            
            cell.startLabel.frame.origin = CGPoint(x: 200.0, y: 200.0)
            cell.toLabel.frame.origin = CGPoint(x: 200.0, y: 200.0)     //Done to remove labels from 5 minute block without lingering effects of reusing cells
            cell.endLabel.frame.origin = CGPoint(x: 200.0, y: 200.0)
            
        case 20.0:
            cell.cellContainerView.layer.cornerRadius = 0.03 * cell.cellContainerView.bounds.size.width
            
            cell.nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 15.0)
            cell.nameLabel.frame.origin.y = -2.0
            
            cell.alphaView.frame = CGRect(x: 116.0, y: 2.0, width: 160.0, height: 13.5)
            cell.alphaView.layer.cornerRadius = 0.04 * cell.alphaView.bounds.size.width
            
            cell.startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
            cell.startLabel.frame.origin = CGPoint(x: 128.0, y: 0.0)
            
            cell.toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
            cell.toLabel.frame.origin = CGPoint(x: 193.0, y: 1.5)
            
            cell.endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 11.5)
            cell.endLabel.frame.origin = CGPoint(x: 213.0, y: 0.0)
            
        case 30.0:
            cell.cellContainerView.layer.cornerRadius = 0.05 * cell.cellContainerView.bounds.size.width
            
            cell.nameLabel.frame.origin.y = 4.0
            
            cell.alphaView.frame = CGRect(x: 116.0, y: 4.0, width: 160.0, height: 19.5)
            cell.alphaView.layer.cornerRadius = 0.06 * cell.alphaView.bounds.size.width
            
            cell.startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 12.5)
            cell.startLabel.frame.origin = CGPoint(x: 127.0, y: 5.0)
            
            cell.toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 21)
            cell.toLabel.frame.origin = CGPoint(x: 192.0, y: 6.5)
            
            cell.endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 12.5)
            cell.endLabel.frame.origin = CGPoint(x: 212.0, y: 5.0)
            
        case 40.0:
            cell.cellContainerView.layer.cornerRadius = 0.05 * cell.cellContainerView.bounds.size.width
            
            cell.nameLabel.frame.origin.y = 8.0
            
            cell.alphaView.frame = CGRect(x: 116.0, y: 6.0, width: 160.0, height: 25.5)
            cell.alphaView.layer.cornerRadius = 0.08 * cell.alphaView.bounds.size.width
            
            cell.startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 13.5)
            cell.startLabel.frame.origin = CGPoint(x: 128.0, y: 9.0)
            
            cell.toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
            cell.toLabel.frame.origin = CGPoint(x: 196.0, y: 10.5)
            
            cell.endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 13.5)
            cell.endLabel.frame.origin = CGPoint(x: 213.0, y: 9.0)
            
        case 50.0:
            cell.cellContainerView.layer.cornerRadius = 0.05 * cell.cellContainerView.bounds.size.width
            
            cell.nameLabel.frame.origin.y = 13.0
            
            cell.alphaView.frame = CGRect(x: 116.0, y: 8.0, width: 160.0, height: 31.5)
            cell.alphaView.layer.cornerRadius = 0.095 * cell.alphaView.bounds.size.width
            
            cell.startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 14.5)
            cell.startLabel.frame.origin = CGPoint(x: 128.0, y: 14.0)
            
            cell.toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
            cell.toLabel.frame.origin = CGPoint(x: 194.0, y: 15.5)
            
            cell.endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 14.5)
            cell.endLabel.frame.origin = CGPoint(x: 213.0, y: 14.0)
            
        case 60.0:
            cell.cellContainerView.layer.cornerRadius = 0.05 * cell.cellContainerView.bounds.size.width
            
            cell.nameLabel.frame.origin.y = 19.0
            
            cell.alphaView.frame = CGRect(x: 116.0, y: 10.0, width: 160.0, height: 37.5)
            cell.alphaView.layer.cornerRadius = 0.115 * cell.alphaView.bounds.size.width
            
            cell.startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 14.5)
            cell.startLabel.frame.origin = CGPoint(x: 128.0, y: 19.0)
            
            cell.toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
            cell.toLabel.frame.origin = CGPoint(x: 193.0, y: 20.5)
            
            cell.endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 14.5)
            cell.endLabel.frame.origin = CGPoint(x: 213.0, y: 19.0)

        default:
            cell.cellContainerView.layer.cornerRadius = 0.05 * cell.cellContainerView.bounds.size.width
            
            cell.nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 17.0)
            cell.nameLabel.frame.origin.y = 8.0
            
            cell.alphaView.isHidden = false
            cell.alphaView.frame = CGRect(x: 7, y: 35, width: 266, height: cell.cellContainerView.frame.height - 40.0)
            cell.alphaView.layer.cornerRadius = 0.05 * cell.alphaView.bounds.size.width
            
            cell.startLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 14.5)
            cell.startLabel.frame.origin = CGPoint(x: 25.0, y: 40.0)
            
            cell.toLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
            cell.toLabel.frame.origin = CGPoint(x: 90.0, y: 42.0)
            
            cell.endLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 14.5)
            cell.endLabel.frame.origin = CGPoint(x: 110.0, y: 40.0)
        }
    }
    
    func configureBlockHeight2 (indexPath: IndexPath) -> CGFloat{

        var calcHour: Int = 0
        var calcMinute: Int = 0

        if indexPath.row < blockArray.count {
        
            if Int(blockArray[indexPath.row].blockEndMinute)! > Int(blockArray[indexPath.row].blockStartMinute)! {
                print(indexPath.row)
                calcHour = Int(blockArray[indexPath.row].blockEndHour)! - Int(blockArray[indexPath.row].blockStartHour)!
                calcMinute = Int(blockArray[indexPath.row].blockEndMinute)! - Int(blockArray[indexPath.row].blockStartMinute)!
                return CGFloat((calcHour * 120) + calcMinute * 2)
            }

            else if Int(blockArray[indexPath.row].blockEndMinute)! == Int(blockArray[indexPath.row].blockStartMinute)! {
                print(indexPath.row)
                calcHour = Int(blockArray[indexPath.row].blockEndHour)! - Int(blockArray[indexPath.row].blockStartHour)!
                return CGFloat(calcHour * 120)
            }
            
            else {
                print(indexPath.row)
                calcHour = (Int(blockArray[indexPath.row].blockEndHour)! - 1) - Int(blockArray[indexPath.row].blockStartHour)!
                calcMinute = ((Int(blockArray[indexPath.row].blockEndMinute)! + 60) - Int(blockArray[indexPath.row].blockStartMinute)!)
                return CGFloat((calcHour * 120) + (calcMinute * 2))
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "presentBlockPopover" {

            let bigBlockVC = segue.destination as! BlockPopoverViewController

            bigBlockVC.blockID = bigBlockID
            
            bigBlockVC.delegate = self //Neccasary for Delegates and Protocols of deleting blocks
            
        }
        
        else if segue.identifier == "moveToAddBlockView" {
            
            let createBlockVC = segue.destination as! Add_Update_BlockViewController
            
        }
    }
    
    @IBAction func segueButton(_ sender: Any) {
        
        performSegue(withIdentifier: "moveToAddBlockView", sender: self)
        
    }
}

extension TimeBlockViewController: BlockDeleted {
    
    func deleteBlock() {
        
        guard let deletedBlock = realm.object(ofType: Block.self, forPrimaryKey: bigBlockID) else { return }

            do {
                try realm.write {
                    realm.delete(deletedBlock)
                }
            } catch {
                print ("Error deleting timeBlock, \(error)")
            }

            realmData = realm.objects(Block.self)

            blockArray = organizeBlocks(sortRealmBlocks(), functionTuple)

            blockTableView.reloadData()
    
    }
    
}
