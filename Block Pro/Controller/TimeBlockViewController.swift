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
    
    
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var blockTableView: UITableView!
    @IBOutlet weak var verticalTableViewSeperator: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeTableView.delegate = self
        timeTableView.dataSource = self
        
        timeTableView.showsVerticalScrollIndicator = false
        //timeTableView.allowsSelection = false
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

    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            
            if blocks?.count ?? 0 == 0 { //If the "blocks" container is empty, just return one cell
                return 1
            }
            
            else { //Return the count of the "blocks" container plus one more
                return (blocks?.count ?? 1) + 1
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = configureCell(tableView, indexPath)
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == blocks?.count ?? 0 {
            
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

        if tableView == blockTableView && indexPath.row < blocks?.count ?? 0 {

            while count < blocks?.count ?? 1 {

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
            
            print(blocks?.count)
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
            
            //If "blocks" container is empty, a "CustomAddBlockTableCell" is going to be used in the tableView to allow the user to add another "blockCell"
            if blocks?.count ?? 0 == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "addBlockCell", for: indexPath) as! CustomAddBlockTableCell
                return cell
            }
                
                //If "blocks" container isn't empty, a "CustomBlockTableCell" is going to be used for every "indexPath.row" that is less than the count of the "blocks" container
            else {
                
                if indexPath.row < blocks?.count ?? 0 {
                    
                    //Boolean test to check that the "blocks" container isn't nil; if so, a "CustomBlockTableCell" will be created using a "Block" object returned from the "sortBlockResults" function
                    if (blocks?[indexPath.row]) != nil {
                        
                        var sortedBlocks = sortBlockResults()
                        
                        //if sortedBlocks[indexPath.row].value.startHour != "" {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! CustomBlockTableCell
                            
                            cell.eventLabel.text = sortedBlocks[indexPath.row].value.name
                            cell.startLabel.text = sortedBlocks[indexPath.row].value.startHour + ":" + sortedBlocks[indexPath.row].value.startMinute + " " + sortedBlocks[indexPath.row].value.startPeriod
                            cell.endLabel.text = sortedBlocks[indexPath.row].value.endHour + ":" + sortedBlocks[indexPath.row].value.endMinute + " " + sortedBlocks[indexPath.row].value.endPeriod
                            
                            cell.cellContainerView.frame = CGRect(x: 0, y: 2, width: 280, height: (cell.frame.height - 2.0)) //Beginning adjustments for the cellContainerView
                            
                            animateBlock(cell, indexPath)
                            return cell
                        //}
                        
//                        else {
//                            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//                            return cell
//                        }
                        
                        
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
    
    
    func configureBlockHeight (indexPath: IndexPath) -> CGFloat {
        
        var calcHour: Int = 0
        var calcMinute: Int = 0
        
        if (blocks?[indexPath.row]) != nil {
            
            var sortedBlocks = sortBlockResults()
            print (sortedBlocks.count)
            if Int(sortedBlocks[indexPath.row].value.endMinute)! > Int(sortedBlocks[indexPath.row].value.startMinute)! {
                
                if sortedBlocks[indexPath.row].value.startPeriod == "AM" && sortedBlocks[indexPath.row].value.endPeriod == "AM" {
                    
                    calcHour = Int(amDictionaries[sortedBlocks[indexPath.row].value.endHour]!)! - Int(amDictionaries[sortedBlocks[indexPath.row].value.startHour]!)!
                    calcMinute = (Int(sortedBlocks[indexPath.row].value.endMinute)! - Int(sortedBlocks[indexPath.row].value.startMinute)!)
                    return CGFloat((calcHour * 120) + (calcMinute * 2))
                }
                
                else if sortedBlocks[indexPath.row].value.startPeriod == "AM" && sortedBlocks[indexPath.row].value.endPeriod == "PM" {
                    
                    calcHour = Int(pmDictionaries[sortedBlocks[indexPath.row].value.endHour]!)! - Int(amDictionaries[sortedBlocks[indexPath.row].value.startHour]!)!
                    calcMinute = (Int(sortedBlocks[indexPath.row].value.endMinute)! - Int(sortedBlocks[indexPath.row].value.startMinute)!)
                    return CGFloat((calcHour * 120) + (calcMinute * 2))
                }
                
                else {
                    calcHour = Int(pmDictionaries[sortedBlocks[indexPath.row].value.endHour]!)! - Int(pmDictionaries[sortedBlocks[indexPath.row].value.startHour]!)!
                    calcMinute = (Int(sortedBlocks[indexPath.row].value.endMinute)! - Int(sortedBlocks[indexPath.row].value.startMinute)!)
                    return CGFloat((calcHour * 120) + (calcMinute * 2))
                }
                
            }
            
            else if Int(sortedBlocks[indexPath.row].value.endMinute)! == Int(sortedBlocks[indexPath.row].value.startMinute)! {
                
                if sortedBlocks[indexPath.row].value.startPeriod == "AM" && sortedBlocks[indexPath.row].value.endPeriod == "AM" {
                    
                    calcHour = Int(amDictionaries[sortedBlocks[indexPath.row].value.endHour]!)! - Int(amDictionaries[sortedBlocks[indexPath.row].value.startHour]!)!
                    return CGFloat(calcHour * 120)
                }
                
                else if sortedBlocks[indexPath.row].value.startPeriod == "AM" && sortedBlocks[indexPath.row].value.endPeriod == "PM" {
                    
                    calcHour = Int(pmDictionaries[sortedBlocks[indexPath.row].value.endHour]!)! - Int(amDictionaries[sortedBlocks[indexPath.row].value.startHour]!)!
                    return CGFloat(calcHour * 120)
                }
                
                else {
                    
                    calcHour = Int(pmDictionaries[sortedBlocks[indexPath.row].value.endHour]!)! - Int(pmDictionaries[sortedBlocks[indexPath.row].value.startHour]!)!
                    return CGFloat(calcHour * 120)
                }
            }
            
            else {
                
                if sortedBlocks[indexPath.row].value.startPeriod == "AM" && sortedBlocks[indexPath.row].value.endPeriod == "AM" {
                
                    calcHour = (Int(amDictionaries[sortedBlocks[indexPath.row].value.endHour]!)! - 1) - Int(amDictionaries[sortedBlocks[indexPath.row].value.startHour]!)!
                    calcMinute = ((Int(sortedBlocks[indexPath.row].value.endMinute)! + 60) - Int(sortedBlocks[indexPath.row].value.startMinute)!)
                    return CGFloat((calcHour * 120) + (calcMinute * 2))
                }
                
                else if sortedBlocks[indexPath.row].value.startPeriod == "AM" && sortedBlocks[indexPath.row].value.endPeriod == "PM" {
                    
                    calcHour = (Int(pmDictionaries[sortedBlocks[indexPath.row].value.endHour]!)! - 1) - Int(amDictionaries[sortedBlocks[indexPath.row].value.startHour]!)!
                    calcMinute = ((Int(sortedBlocks[indexPath.row].value.endMinute)! + 60) - Int(sortedBlocks[indexPath.row].value.startMinute)!)
                    return CGFloat((calcHour * 120) + (calcMinute * 2))
                }
                
                else {
                   
                    calcHour = (Int(pmDictionaries[sortedBlocks[indexPath.row].value.endHour]!)! - 1) - Int(pmDictionaries[sortedBlocks[indexPath.row].value.startHour]!)!
                    calcMinute = ((Int(sortedBlocks[indexPath.row].value.endMinute)! + 60) - Int(sortedBlocks[indexPath.row].value.startMinute)!)
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
