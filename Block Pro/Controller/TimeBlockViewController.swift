//
//  ViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/17/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift

class TimeBlockViewController: AddBlockViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    let realm = try! Realm() //Initializing a new "Realm"
    var blocks: Results<Block>? //Setting the variable "blocks" to type "Results" that will contain "Block" objects; "Results" is an auto-updating container type in Realm
    
    //Variable storing "CustomTimeTableCell" text for each indexPath
    let cellTimes: [String] = ["12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM", "5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"]
    
    var cellAnimated = [Bool](repeating: false, count: 24) //Variable that helps track whether or not a certain cell has been animated onto the screen yet
    
    var userSelectedStartTime = [String](repeating: "", count: 3)
    var userSelectedEndTime = [String](repeating: "", count: 3)
    var tag: String = ""
    
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var blockTableView: UITableView!
    @IBOutlet weak var verticalTableViewSeperator: UIImageView!
    
    //let testObject = AddBlockViewController()
    
    lazy var createView = createNewBlockView() //testObject.createNewBlockView()
    lazy var enterBlockTitle = createTextField(xCord: 20, yCord: 35, width: 300, height: 40, placeholderText: "TimeBlock Name", keyboard: "default")
    lazy var enterBlockStart = createTextField(xCord: 20, yCord: 110, width: 70, height: 40, placeholderText: "0:00", keyboard: "picker")
    lazy var enterBlockEnd = createTextField(xCord: 250, yCord: 110, width: 70, height: 40, placeholderText: "0:00", keyboard: "picker")
    lazy var timePicker = createPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeTableView.delegate = self
        timeTableView.dataSource = self
        
        timeTableView.showsVerticalScrollIndicator = false
        timeTableView.allowsSelection = false
        timeTableView.separatorStyle = .none
        timeTableView.rowHeight = 90.0
        
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
        
        enterBlockTitle.delegate = self
        enterBlockStart.delegate = self
        enterBlockEnd.delegate = self
        
        timePicker.delegate = self
        timePicker.dataSource = self
        
        
        
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
        
        if tableView == timeTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath) as! CustomTimeTableCell
            cell.timeLabel.font = UIFont(name: "Helvetica Neue", size: 9) //Setting the font and font size of the cell
            cell.timeLabel.text = cellTimes[indexPath.row] //Setting the time the cell should display
            
            //Every cell that does not have the text "11:00 PM" should have a black "cellSeperator"
            if cell.timeLabel.text == "11:00 PM" {
                cell.cellSeperator.backgroundColor = UIColor.white
            }
              
            else {
                cell.cellSeperator.backgroundColor = UIColor.black
                print (cell.frame.height)
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
                    
                    //Use of optional binding to check if "blocks" container isn't nil; if so, a "CustomBlockTableCell" will be created using a "Block" object
                    if let blockData = blocks?[indexPath.row] {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! CustomBlockTableCell
                        
                        cell.eventLabel.text = blockData.name
                        cell.startLabel.text = blockData.start
                        cell.endLabel.text = blockData.end
                        
                        animateBlock(cell, indexPath)
                        return cell
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
    
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == blocks?.count ?? 0 {
        
        let blockView: UIView = createView

        blockView.addSubview(blockTitleLabel)
        blockView.addSubview(enterBlockTitle)
        blockView.addSubview(blockStartLabel)
        blockView.addSubview(enterBlockStart)
        blockView.addSubview(blockEndLabel)
        blockView.addSubview(enterBlockEnd)
        
        
        self.view.addSubview(blockView)
        self.view.addSubview(createBlockButton)
        
        //timePicker.center = self.view.center
        //timePicker.backgroundColor?.withAlphaComponent(0.6) /
        self.view.addSubview(timePicker)
        
        UIView.animate(withDuration: 0.65) {
            
            blockView.frame.origin.y = 200
            self.createBlockButton.frame.origin.y = 410
            
            self.timeTableView.alpha = 0.5
            self.blockTableView.alpha = 0.5
            }
        
        }

        
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == enterBlockTitle {
            UIView.animate(withDuration: 0.4) {
                self.timePicker.frame.origin.y = 950
            }
        }
        else if textField == enterBlockStart {
            tag = "start"
            UIView.animate(withDuration: 0.3) {
                self.timePicker.frame.origin.y = 450
            }
        }
        else if textField == enterBlockEnd {
            tag = "end"
            UIView.animate(withDuration: 0.5) {
                self.timePicker.frame.origin.y = 450
            }
        }
        print (timePicker.frame.origin)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == enterBlockStart {
            enterBlockStart.text = ("\(userSelectedStartTime[0]):" + "\(userSelectedStartTime[1]) " + "\(userSelectedStartTime[2])")
        }
        
        else if textField == enterBlockEnd {
            enterBlockEnd.text = ("\(userSelectedEndTime[0]):" + "\(userSelectedEndTime[1]) " + "\(userSelectedEndTime[2])")
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 && tag == "start" {
            userSelectedStartTime[0] = hours[row]
        }
        else if component == 0 && tag == "end" {
            userSelectedEndTime[0] = hours[row]
        }
        
        if component == 1 && tag == "start" {
            userSelectedStartTime[1] = minutes[row]
        }
        else if component == 1 && tag == "end" {
            userSelectedEndTime[1] = minutes[row]
        }
        
        if component == 2 && tag == "start" {
            userSelectedStartTime[2] = timePeriods[row]
        }
        else if component == 2 && tag == "end" {
            userSelectedEndTime[2] = timePeriods[row]
        }
        print ("userSelectedStartTime = \(userSelectedStartTime)")
        print ("userSelectedEndTime = \(userSelectedEndTime)")
        
    }
    
    @objc override func createBlockButtonPressed () {
        
        let newBlock = Block()
        
        newBlock.name = enterBlockTitle.text!
        newBlock.start = enterBlockStart.text!
        newBlock.end = enterBlockEnd.text!
        
        do {
            try realm.write {
                realm.add(newBlock)
                }
            } catch {
                print ("Error adding a new block \(error)")
            }
        
        UIView.animate(withDuration: 0.65, animations: {
            
            self.blockView.frame.origin.y = 1200
            self.timePicker.frame.origin.y = 950
            self.createBlockButton.frame.origin.y = 950
            
            self.timeTableView.alpha = 1.0
            self.blockTableView.alpha = 1.0
            
        }) { (true) in
            //self.blockView.removeFromSuperview()
            self.enterBlockTitle.text = ""
            self.timePicker.removeFromSuperview()
            //self.createBlockButton.removeFromSuperview()
        }
        
        blockTableView.reloadData()
        
    }
}
