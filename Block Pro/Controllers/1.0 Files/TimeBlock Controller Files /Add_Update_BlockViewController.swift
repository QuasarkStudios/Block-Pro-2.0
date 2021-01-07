//
//  CreateBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/29/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class Add_Update_BlockViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var blockOutline: UIView!
    @IBOutlet weak var blockContainer: UIView!
    
    @IBOutlet weak var blockNameTextField: UITextField!
    
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var notificationSwitchContainer: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBOutlet weak var timeSegmentContainer: UIView!
    @IBOutlet weak var notificationTimeSegments: UISegmentedControl!
    @IBOutlet weak var segmentContainerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timePickerContainer: UIView!
    @IBOutlet weak var timeContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var timeContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var categoryPickerContainer: UIView!
    @IBOutlet weak var categoryContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var categoryContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    lazy var realm = try! Realm() //Initializing a new "Realm"
    var blockData: Results<Block2>? //Setting the variable "blockData" to type "Results" that will contain "Block" objects; "Results" is an auto-updating container type in Realm
    
    var currentDateObject: TimeBlocksDate? //Variable that will contain a "TimeBlocksDate" object that matches the current date or the selected user date
    
    var selectedView: String = ""
    
    let formatter = DateFormatter()

    //Arrays that holds the title for each row of the "categoryPicker"
    let blockCategories: [String] = ["", "Work", "Creativity", "Sleep", "Food/Eat", "Leisure", "Exercise", "Self-Care", "Other"]
    let blockCategoryColors: [String : String] = ["Work": "#5065A0", "Creativity" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#AAAAAA"]
    
    var tag: String = "" //Variable that helps track if selectedRows from the "timePicker" should be assigned to the "startTime" variables and textFields or the "endTime" variables and textFields
    
    var selectedStartHour: String = ""
    var selectedStartMinute: String = ""
    var selectedStartPeriod: String = ""
    
    var selectedEndHour: String = ""
    var selectedEndMinute: String = ""
    var selectedEndPeriod: String = ""
    
    var selectedCategory: String = ""
    
    var blockID: String = "" //Variable that holds the "blockID" of the TimeBlock being updated
    
    var notificationID: String = UUID().uuidString //Variable that holds either the notficationID of a new TimeBlock or the "notficationID" of a TimeBlock being updated
    var notificationTimes: [Int] = [5, 10, 15] //Variable that holds values that will be used after user selects the "Notification Time Segment"
    var notificationIndex: Int = 0 //Variable that tracks which segment of the "Notification Time Segment" is selected
    
    var containersPresentedTopAnchor: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView1()
        configureView2()
        configureConstraints()
    }
    
    func configureView1 () {
        
        blockOutline.backgroundColor = .lightGray
        blockOutline.layer.cornerRadius = 0.05 * blockOutline.bounds.size.width
        blockOutline.clipsToBounds = true
        
        blockContainer.backgroundColor = UIColor(hexString: "#EFEFF4")
        blockContainer.layer.cornerRadius = 0.05 * blockContainer.bounds.size.width
        blockContainer.clipsToBounds = true
        
        blockNameTextField.delegate = self

        alphaView.layer.cornerRadius = 0.03 * alphaView.bounds.size.width
        alphaView.clipsToBounds = true
        
        startTimeTextField.delegate = self
        endTimeTextField.delegate = self
        categoryTextField.delegate = self
        
        startTimeTextField.inputView = UIView()
        endTimeTextField.inputView = UIView()
        categoryTextField.inputView = UIView()
        
        notificationView.clipsToBounds = true
        
        notificationSwitchContainer.layer.cornerRadius = 0.053 * notificationSwitchContainer.bounds.size.width
        notificationSwitchContainer.clipsToBounds = true
        
        timeSegmentContainer.layer.cornerRadius = 0.03 * timeSegmentContainer.bounds.size.width
        
        timePickerContainer.layer.cornerRadius = 0.1 * timePickerContainer.bounds.size.width
        timePickerContainer.clipsToBounds = true
        
        timePicker?.addTarget(self, action: #selector(timeSelected(timePicker:)), for: .valueChanged)
        timeSelected(timePicker: timePicker)
        
        categoryPickerContainer.layer.cornerRadius = 0.1 * categoryPickerContainer.bounds.size.width
        categoryPickerContainer.clipsToBounds = true
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func configureView2 () {
        
        if selectedView == "Add" {
            
            navigationItem.title = "Add Time Block"
            
            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(add_editTimeBlock1))
            navigationItem.rightBarButtonItem = addButton
            
        }
            
        else if selectedView == "Edit" {
            
            navigationItem.title = "Edit Time Block"
            
            let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(add_editTimeBlock1))
            navigationItem.rightBarButtonItem = editButton
            
            guard let bigBlockData = realm.object(ofType: Block2.self, forPrimaryKey: blockID) else { return }
            
                blockNameTextField.text = bigBlockData.name
//                startTimeTextField.text = convertTo12Hour(bigBlockData.startHour, bigBlockData.startMinute)
//                endTimeTextField.text = convertTo12Hour(bigBlockData.endHour, bigBlockData.endMinute)
//
//                selectedStartHour = bigBlockData.startHour; selectedStartMinute = bigBlockData.startMinute; selectedStartPeriod = bigBlockData.startPeriod
//                selectedEndHour = bigBlockData.endHour; selectedEndMinute = bigBlockData.endMinute; selectedEndPeriod = bigBlockData.endPeriod
                
                notificationID = bigBlockData.notificationID
                
                if bigBlockData.scheduled == true {
                    
                    self.notificationViewHeightConstraint.constant = 85
                    self.segmentContainerBottomConstraint.constant = 5
                    
//                    notificationTimeSegments.selectedSegmentIndex = bigBlockData.minsBefore
                    notificationSwitch.isOn = true
                }
                    
                else {
                    
                    self.notificationViewHeightConstraint.constant = 43
                    self.segmentContainerBottomConstraint.constant = -40
                    
                    notificationTimeSegments.selectedSegmentIndex = 0
                    notificationSwitch.isOn = false
                }
                
                categoryTextField.text = bigBlockData.category //Setting the block category
                
                guard let categoryColor = UIColor(hexString: blockCategoryColors[bigBlockData.category] ?? "#AAAAAA") else { return }
                
                    blockOutline.backgroundColor? = categoryColor
        }
    }
    
    func configureConstraints () {
        
        if selectedView == "Add" {
            
            notificationViewHeightConstraint.constant = 43
            segmentContainerBottomConstraint.constant = -40
        }
        
        timeContainerTopAnchor.constant = 500
        categoryContainerTopAnchor.constant = 500
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            containersPresentedTopAnchor = 125
        }
            
            //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {
            
            containersPresentedTopAnchor = 75
        }
            
            //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            containersPresentedTopAnchor = 80.5
        }
            
            //iPhone 8
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {
            containersPresentedTopAnchor = 40
        }
            
            //iPhone SE
        else if UIScreen.main.bounds.width == 320.0 {
            
            timeContainerHeightConstraint.constant = 150
            categoryContainerHeightConstraint.constant = 150
            
            containersPresentedTopAnchor = 17.5
        }
    }

    
    //MARK: - PickerView DataSource Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return blockCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return blockCategories[row]
    }
    
    
    //MARK: - PickerView Delegate Method
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            
        categoryTextField.text = blockCategories[row]
        selectedCategory = blockCategories[row]
        blockOutline.backgroundColor = UIColor(hexString: blockCategoryColors[blockCategories[row]] ?? "#AAAAAA")
    }
    
    
    //MARK: - TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //Switch statement that handles the animations of the PickerViews and also sets the "tag" varibale based on the selected textField
        switch textField {
            
        case blockNameTextField:
            
            self.view.layoutIfNeeded()
            timeContainerTopAnchor.constant = 500
            categoryContainerTopAnchor.constant = 500
            
            UIView.animate(withDuration: 0.2) {
                
                self.view.layoutIfNeeded()
            }
            
        case startTimeTextField:
            
            tag = "start"
                  
            self.view.layoutIfNeeded()
            categoryContainerTopAnchor.constant = 500
            
            UIView.animate(withDuration: 0.15, animations: {
                self.view.layoutIfNeeded()
                
            }, completion: { (finished: Bool) in
                
                self.timeContainerTopAnchor.constant = self.containersPresentedTopAnchor
                
                UIView.animate(withDuration: 0.15, animations: {
                    self.view.layoutIfNeeded()
                })
            })
            
        case endTimeTextField:
            
            tag = "end"
            
            self.view.layoutIfNeeded()
            categoryContainerTopAnchor.constant = 500
            
            UIView.animate(withDuration: 0.15, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                
                self.timeContainerTopAnchor.constant = self.containersPresentedTopAnchor
                
                UIView.animate(withDuration: 0.15, animations: {
                    self.view.layoutIfNeeded()
                })
            })
            
        case categoryTextField:
            
            self.view.layoutIfNeeded()
            timeContainerTopAnchor.constant = 500
            
            UIView.animate(withDuration: 0.15, animations: {
                
                self.view.layoutIfNeeded()
            }) { (finished: Bool) in
                
                self.categoryContainerTopAnchor.constant = self.containersPresentedTopAnchor
                
                UIView.animate(withDuration: 0.15, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    @objc func timeSelected (timePicker: UIDatePicker) {
        
        if tag == "start" {
            
            formatter.dateFormat = "h:mm a"
            startTimeTextField.text = formatter.string(from: timePicker.date)
            
            formatter.dateFormat = "H"
            selectedStartHour = formatter.string(from: timePicker.date)
            
            formatter.dateFormat = "mm"
            selectedStartMinute = formatter.string(from: timePicker.date)
            
            formatter.dateFormat = "a"
            selectedStartPeriod = formatter.string(from: timePicker.date)
        }
        
        else if tag == "end" {
            
            formatter.dateFormat = "h:mm a"
            endTimeTextField.text = formatter.string(from: timePicker.date)
            
            formatter.dateFormat = "H"
            selectedEndHour = formatter.string(from: timePicker.date)
            
            formatter.dateFormat = "mm"
            selectedEndMinute = formatter.string(from: timePicker.date)
            
            formatter.dateFormat = "a"
            selectedEndPeriod = formatter.string(from: timePicker.date)
        }
    }

    
    //MARK: - Time Conversion Functions
    
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
    
    //MARK: - Calculate Valid Time Blocks
    
    func calcValidTimeBlock (_ startHour: String, _ startMinute: String, _ endHour: String, _ endMinute: String, _ blockID: String = "0") -> [String : Bool] {
        
        var startTimeValidation: Bool = true //Variable that tracks if the startTime of the TimeBlock is valid
        var endTimeValidation: Bool = true //Variable that tracks if the endTime of the TimeBlock is valid
        var rangeValidation: Bool = true  //Variable that tracks if the range of the TimeBlock is valid
        
        //If other TimeBlocks have already been created for this day, verify this new TimeBlocks time
        if blockData != nil {
            
            let calendar = Calendar.current
            let now = Date()
            
            let newBlockStart = calendar.date(bySettingHour: Int(startHour)!, minute: Int(startMinute)!, second: 0, of: now)! //Converts "newBlockStart" from a String to a Date
            let newBlockEnd = calendar.date(bySettingHour: Int(endHour)!, minute: Int(endMinute)!, second: 0, of: now)! //Converts "newBlockEnd" from a String to a Date
            var newBlockArray: [Date] = [newBlockStart] //Creation of an array that holds all the times the new TimeBlock can't interfere with
            
            //While loop that populates the "newBlockArray" with times the new TimeBlock can't interfere with
            while newBlockArray.contains(newBlockEnd) != true {
                newBlockArray.append(newBlockArray[newBlockArray.count - 1].addingTimeInterval(300)) //Appending a new time
            }
            
            _ = newBlockArray.remove(at: 0) //Removes the "newBlockStart" time from the newBlockArray; that time will be checked later in function
            _ = newBlockArray.remove(at: newBlockArray.count - 1) //Removes the "newBlockEnd" time from the newBlockArray; that time will be checked later in function
            
            for timeBlocks in blockData! {
                
                //If this TimeBlock is not the one being updated by the user
                if timeBlocks.blockID != blockID {
                    
//                    let realmBlockStart = calendar.date(bySettingHour: Int(timeBlocks.startHour)!, minute: Int(timeBlocks.startMinute)!, second: 0, of: now)! //Converts "realmBlockStart" from a String to a Date
//                    let realmBlockEnd = calendar.date(bySettingHour: Int(timeBlocks.endHour)!, minute: Int(timeBlocks.endMinute)!, second: 0, of: now)! //Converts "realmBlockEnd" from a String to a Date
//                    let realmBlockRange: ClosedRange = realmBlockStart...realmBlockEnd
//
//                    //If the "newBlockStart" is greater than or equal to "realmBlockStart" and less than "realmBlockEnd"
//                    if newBlockStart >= realmBlockStart && newBlockStart < realmBlockEnd {
//                        startTimeValidation = false
//                        break
//                    }
//                    //If the "newBlockEnd" is greater than "realmBlockStart" and less than or equal to "realmBlockEnd"
//                    else if newBlockEnd > realmBlockStart && newBlockEnd <= realmBlockEnd {
//                        endTimeValidation = false
//                        break
//                    }
//
//                    //For loop that ensures that no time in a new TimeBlock other than it's start and end time interferes with another TimeBlocks times other than its start and end times
//                    for times in newBlockArray {
//
//                        if realmBlockRange.contains(times) {
//                            rangeValidation = false
//                        }
//                    }
                }
            }
        }
        return ["startTimeValid" : startTimeValidation, "endTimeValid" : endTimeValidation, "rangeValid" : rangeValidation]
    }
    
    
    //MARK: - Schedule Notification Function
    
    func scheduleNotification () {
        
        if notificationSwitch.isOn {
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            let content = UNMutableNotificationContent()
            let trigger: UNCalendarNotificationTrigger
            let request: UNNotificationRequest
            
            guard let date = currentDateObject?.timeBlocksDate else { return }
            
            let initialDate = Array(date) //Turning the currentDate from a String to an Array of Strings
            
            var notificationDate: [String : String] = ["Year": "", "Month" : "", "Day": ""]
            var count: Int = 0
            
            //While loop that assigns the "Year", "Month", and "Day" values for the "notificationDate" dictionary from the "initialDate" array
            while count < initialDate.count {
                
                if count < 4 {
                    notificationDate["Year"] = notificationDate["Year"]! + "\(initialDate[count])"
                }
                    
                else if count > 4 && count < 7 {
                    notificationDate["Month"] = notificationDate["Month"]! + "\(initialDate[count])"
                }
                    
                else if count > 7 {
                    notificationDate["Day"] = notificationDate["Day"]! + "\(initialDate[count])"
                }
                
                count += 1
            }
            
            //If the selectedStartMinute will become negative but the selectedStartHour will remain positive
            if (Int(selectedStartHour)! >  0) && (Int(selectedStartMinute)! - notificationTimes[notificationIndex] < 0) {
                
                //Assigning the dateComponents year, month, and day values from the "notificationDate" dictionary
                dateComponents.year = Int(notificationDate["Year"]!)!
                dateComponents.month = Int(notificationDate["Month"]!)!
                dateComponents.day = Int(notificationDate["Day"]!)!
                
                //Switch statement that checks how negative the "selectedStartMinute" has become
                switch Int(selectedStartMinute)! {
                    
                case -5:
                    dateComponents.hour = Int(selectedStartHour)! - 1
                    dateComponents.minute = 60 - 5
                    
                case -10:
                    dateComponents.hour = Int(selectedStartHour)! - 1
                    dateComponents.minute = 60 - 10
                    
                case -15:
                    dateComponents.hour = Int(selectedStartHour)! - 1
                    dateComponents.minute = 60 - 15
                    
                default:
                    break
                }
                
                //Configuring and setting the notification
                content.title = "Heads Up!!"
                content.body = blockNameTextField.text! + " in \(notificationTimes[notificationIndex]) minutes"
                content.sound = UNNotificationSound.default
                
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
                
            //If the selectedStartMinute will not become negative
            else if Int(selectedStartMinute)! - notificationTimes[notificationIndex] >= 0 {
                
                //Assigning the dateComponents year, month, and day values from the "notificationDate" dictionary
                dateComponents.year = Int(notificationDate["Year"]!)!
                dateComponents.month = Int(notificationDate["Month"]!)!
                dateComponents.day = Int(notificationDate["Day"]!)!
                
                //Assigning the dateComponents hour and minute
                dateComponents.hour = Int(selectedStartHour)! //Assigning the dateComponents hour the "selectedStartHour"
                dateComponents.minute = Int(selectedStartMinute)! - notificationTimes[notificationIndex] //Assigning the dateComponents minute the selectedStartMinute minus 5 - 15 minutes
                
                //Configuring and setting the notification
                content.title = "Heads Up!!"
                content.body = blockNameTextField.text! + " in \(notificationTimes[notificationIndex]) minutes"
                content.sound = UNNotificationSound.default
                
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
                
            //If the selectedStartHour will become negative signifying the user wants the notification to come a day before
            else if (Int(selectedStartHour)! ==  0) && (Int(selectedStartMinute)! - notificationTimes[notificationIndex] < 0) {
                ProgressHUD.showError("Sorry, notifications coming a day prior isn't currently supported")
            }
        }
        
        else {
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
        }
    }

    
    //MARK: - Add or Update TimeBlock Function
    
    @objc func add_editTimeBlock1 () {
        
        var validTimeBlock : [String : Bool]
        
        let blockNameArray = Array(blockNameTextField.text ?? "")
        var blockNameEntered: Bool = false
        
        //For loop that checks to see if "blockNameTextField" isn't empty
        for char in blockNameArray {
            
            if char != " " {
                blockNameEntered = true
                break
            }
        }
        
        //If the user hasn't entered a name for a TimeBlock
        if blockNameEntered != true {
            ProgressHUD.showError("Please enter a name for this TimeBlock")
        }
        //If the user hasn't finished entering the start time for a TimeBlock
        else if startTimeTextField.text == "" {
            ProgressHUD.showError("Please finish entering when this TimeBlock should begin")
        }
        //If the user hasn't finished entering the end time for a TimeBlock
        else if endTimeTextField.text == "" {
            ProgressHUD.showError("Please finish entering when this TimeBlock should end")
        }
        //If the start time and end time for a TimeBlock are the same
        else if selectedStartHour == selectedEndHour && selectedStartMinute == selectedEndMinute && selectedStartPeriod == selectedEndPeriod {
            ProgressHUD.showError("Sorry, the times for TimeBlocks can't be the same")
        }
        //If end time is before the start time
        else if Int(selectedEndHour)! < Int(selectedStartHour)! {
            ProgressHUD.showError("Sorry, the end time for a TimeBlock can't be before it's start time")
        }
        //If end time is before the start time
        else if (selectedEndHour == selectedStartHour) && (Int(selectedEndMinute)! < Int(selectedStartMinute)!) {
            ProgressHUD.showError("Sorry, the end time for a TimeBlock can't be before it's start time")
        }
        //This code block is reached only if the TimeBlock passed all other tests
        else {
            
            //If the user is creating a new TimeBlock, call "calcValidTimeBlock" without entering a "blockID" showing that a block isn't being updated
            if selectedView == "Add" {
            
                validTimeBlock = calcValidTimeBlock(selectedStartHour, selectedStartMinute, selectedEndHour, selectedEndMinute)
            }
            //If the user is updating a TimeBlock, call "calcValidTimeBlock" entering a "blockID" showing that a block is being updated
            else {
                validTimeBlock = calcValidTimeBlock(selectedStartHour, selectedStartMinute, selectedEndHour, selectedEndMinute, blockID)
            }
            
            //If statements that check if the TimeBlock failed any tests in the "calcValidTimeBlock" function
            if validTimeBlock["startTimeValid"] == false {
                ProgressHUD.showError("The starting time of this TimeBlock conflicts with another")
            }
                
            else if validTimeBlock["endTimeValid"] == false {
                ProgressHUD.showError("The ending time of this TimeBlock conflicts with another")
            }
                
            else if validTimeBlock["rangeValid"] == false {
                ProgressHUD.showError("This TimeBlock conflicts with another")
            }
            
            //AYEEEE IT PASSED ALL THE TESTS
            else {

                scheduleNotification()
                add_editTimeBlock2()
                //dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func add_editTimeBlock2 () {
        
        var scheduled: Bool = false
        var minsBefore: Int = 0
        
        if notificationSwitch.isOn {
            
            scheduled = true
            minsBefore = notificationIndex
        }
        
        else {
            scheduled = false
            minsBefore = 0
        }
        
        //If this is the "CreateBlockView", create a new TimeBlock
        if selectedView == "Add" {
            
            let newBlock = Block2()
            
            newBlock.name = blockNameTextField.text!
            
//            newBlock.startHour = selectedStartHour
//            newBlock.startMinute = selectedStartMinute
//            newBlock.startPeriod = selectedStartPeriod
//            
//            newBlock.endHour = selectedEndHour
//            newBlock.endMinute = selectedEndMinute
//            newBlock.endPeriod = selectedEndPeriod
            
            newBlock.category = selectedCategory
            
            newBlock.notificationID = notificationID
            newBlock.scheduled = scheduled
            //newBlock.minsBefore = minsBefore
            
            do {
                try realm.write {
                    currentDateObject?.timeBlocks.append(newBlock) //Appending the new TimeBlock to "currentDateObject" object
                }
            } catch {
                print ("Error adding a new block \(error)")
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        
        //If this is the "EditBlockView", update a TimeBlock
        else if selectedView == "Edit" {
            
            let updatedBlock = Block2()
            
            updatedBlock.blockID = blockID
            
            updatedBlock.name = blockNameTextField.text!
            
//            updatedBlock.startHour = selectedStartHour
//            updatedBlock.startMinute = selectedStartMinute
//            updatedBlock.startPeriod = selectedStartPeriod
//            
//            updatedBlock.endHour = selectedEndHour
//            updatedBlock.endMinute = selectedEndMinute
//            updatedBlock.endPeriod = selectedEndPeriod
            
            updatedBlock.category = categoryTextField.text!
            
            updatedBlock.notificationID = notificationID
            updatedBlock.scheduled = scheduled
            //updatedBlock.minsBefore = minsBefore
            
            do {
                try self.realm.write {
                    
                    realm.add(updatedBlock, update: .modified)
                    //realm.add(updatedBlock, update: true)
                    
                }
            } catch {
                print ("Error updating block \(error)")
                
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Notification Controls
    
    @IBAction func notificationSwitch(_ sender: Any) {
        
        if notificationSwitch.isOn == true {
            
            self.notificationViewHeightConstraint.constant = 85
            self.segmentContainerBottomConstraint.constant = 5
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
            
        else {
            
            self.notificationViewHeightConstraint.constant = 43
            self.segmentContainerBottomConstraint.constant = -40
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func notificationTimeSegments(_ sender: Any) {
        
        notificationIndex = notificationTimeSegments.selectedSegmentIndex
    }
    
    //Function that dismisses the keyboard and the PickerViews
    @objc func dismissKeyboard () {
        
        view.endEditing(true)
        
        self.view.layoutIfNeeded()
        timeContainerTopAnchor.constant = 500
        categoryContainerTopAnchor.constant = 500
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()

        }
    }
}
