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

class Add_Update_BlockViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    let realm = try! Realm() //Initializing a new "Realm"
    var blockData: Results<Block>? //Setting the variable "blockData" to type "Results" that will contain "Block" objects; "Results" is an auto-updating container type in Realm
    
    var currentDateObject: TimeBlocksDate? //Variable that will contain a "TimeBlocksDate" object that matches the current date or the selected user date
    
    @IBOutlet weak var blockNameTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var note1TextView: UITextView!
    @IBOutlet weak var note2TextView: UITextView!
    @IBOutlet weak var note3TextView: UITextView!
    
    @IBOutlet weak var categoryColorIndicator: UIView!
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationTimeSegments: UISegmentedControl!
    
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var create_edit_blockButton: UIButton!
    
    //Arrays that holds the title for each row of the "timePicker"
    let hours: [String] = ["", "12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    let minutes: [String] = ["", "00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    let timePeriods: [String] = ["", "AM", "PM"]
    
    //Arrays that holds the title for each row of the "categoryPicker"
    let blockCategories: [String] = ["", "Work", "Creative Time", "Sleep", "Food/Eat", "Leisure", "Exercise", "Self-Care", "Other"]
    let blockCategoryColors: [String : String] = ["Work": "#5065A0", "Creative Time" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#EFEFF4"]
    
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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        blockNameTextField.delegate = self
        startTimeTextField.delegate = self
        endTimeTextField.delegate = self
        
        categoryTextField.delegate = self
        
        note1TextView.delegate = self
        note2TextView.delegate = self
        note3TextView.delegate = self
        
        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.frame.origin.y = 750
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.frame.origin.y = 750
        
        //blockNameTextField.inputView = UIView()
        startTimeTextField.inputView = UIView()
        endTimeTextField.inputView = UIView()
        categoryTextField.inputView = UIView()
        
        note1TextView.layer.cornerRadius = 0.05 * note1TextView.bounds.size.width
        note1TextView.clipsToBounds = true
        
        note2TextView.layer.cornerRadius = 0.05 * note2TextView.bounds.size.width
        note2TextView.clipsToBounds = true

        note3TextView.layer.cornerRadius = 0.05 * note3TextView.bounds.size.width
        note3TextView.clipsToBounds = true

        categoryColorIndicator.layer.cornerRadius = 0.25 * categoryColorIndicator.bounds.size.width
        categoryColorIndicator.clipsToBounds = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        configureEditView()
    }
    
    
    //MARK: - PickerView DataSource Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        //Assigning the number of components for the "timePicker"
        if pickerView == timePicker {
            return 3
        }
        
            //Assigning the number of components for the "categoryPicker"
        else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        //Assigning the number of rows for each component of the "timePicker"
        if pickerView == timePicker {
            
            if component == 0 {
                return hours.count
            }
                
            else if component == 1 {
                return minutes.count
            }
                
            else {
                return timePeriods.count
            }
        }
        
        //Assigning the number of rows for each component of the "categoryPicker"
        else {
            return blockCategories.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        //Assigning the title for each row of the "timePicker"
        if pickerView == timePicker {
            
            if component == 0 {
                
                return hours[row]
            }
            else if component == 1 {
                
                return minutes[row]
            }
            else {
                
                return timePeriods[row]
            }
        }
        
        //Assigning the title for each row of the "categoryPicker"
        else {
            return blockCategories[row]
        }
    }
    
    
    //MARK: - PickerView Delegate Method
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //Assigning the selected rows/times of the "timePicker" to its appropriate variables
        if pickerView == timePicker {
            
            if component == 0 && tag == "start" {
                selectedStartHour = hours[row]
            }
            else if component == 0 && tag == "end" {
                selectedEndHour = hours[row]
            }
            if component == 1 && tag == "start" {
                selectedStartMinute = minutes[row]
            }
            else if component == 1 && tag == "end" {
                selectedEndMinute = minutes[row]
            }
            if component == 2 && tag == "start" {
                selectedStartPeriod = timePeriods[row]
            }
            else if component == 2 && tag == "end" {
                selectedEndPeriod = timePeriods[row]
            }
            
            //Setting the text of startTime and endTime textfields
            startTimeTextField.text = selectedStartHour + ":" + selectedStartMinute + " " + selectedStartPeriod
            endTimeTextField.text = selectedEndHour + ":" + selectedEndMinute + " " + selectedEndPeriod
            
        }
            
        //Assigning the selected categories of the "categoryPicker" to its appropriate variables
        else if pickerView == categoryPicker {
            selectedCategory = blockCategories[row]
            categoryTextField.text = selectedCategory
            
            guard let categoryColor = UIColor(hexString: (blockCategoryColors[selectedCategory])!) else { return }
            categoryColorIndicator.backgroundColor? = categoryColor
        }
        
    }
    
    
    //MARK: - TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //Resetting the PickerViews to their first row after a different textField is selected
        timePicker.selectRow(0, inComponent: 0, animated: true)
        timePicker.selectRow(0, inComponent: 1, animated: true)
        timePicker.selectRow(0, inComponent: 2, animated: true)
        
        categoryPicker.selectRow(0, inComponent: 0, animated: true)
        
        //Switch statement that handles the animations of the PickerViews and also sets the "tag" varibale based on the selected textField
        switch textField {
            
            case blockNameTextField:
                UIView.animate(withDuration: 0.2) {
                    self.timePicker.frame.origin.y = 750
                    self.categoryPicker.frame.origin.y = 750
                }
            
            case startTimeTextField:
                tag = "start"
                
                UIView.animate(withDuration: 0.15, animations: {
                    self.categoryPicker.frame.origin.y = 750
                }) { (finished: Bool) in
                    
                    UIView.animate(withDuration: 0.15) {
                        self.timePicker.frame.origin.y = 475
                    }
                }
            
            case endTimeTextField:
                tag = "end"
                
                UIView.animate(withDuration: 0.15, animations: {
                    self.categoryPicker.frame.origin.y = 750
                }) { (finished: Bool) in
                    
                    UIView.animate(withDuration: 0.15) {
                        self.timePicker.frame.origin.y = 475
                    }
                }
            
            case categoryTextField:
                
                UIView.animate(withDuration: 0.15, animations: {
                    self.timePicker.frame.origin.y = 750
                }) { (finished: Bool) in
                    
                    UIView.animate(withDuration: 0.15) {
                        self.categoryPicker.frame.origin.y = 475
                    }
                }
            
            default:
                print ("No textField selected")
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //If statements that set text of the startTime and endTime textFields based on the user's selections
        if textField == startTimeTextField {
            startTimeTextField.text = ("\(selectedStartHour):" + "\(selectedStartMinute) " + selectedStartPeriod)
        }
            
        else if textField == endTimeTextField {
            endTimeTextField.text = ("\(selectedEndHour):" + "\(selectedEndMinute) " + selectedEndPeriod)
        }
    }
    
    
    //MARK: - TextView Delegate Methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        //Used to check which notifications are lined up; staying here for now lol
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests -> () in
            print("\(requests.count) requests --------")
            for request in requests {
                print(request.identifier)
                print(request.content)
                print(request.trigger as Any)
            }
        }
        
        if textView == note1TextView {
            
            UIView.animate(withDuration: 0.2) {
                
                self.timePicker.frame.origin.y = 700
            }
            
            timePicker.selectRow(0, inComponent: 0, animated: true)
            timePicker.selectRow(0, inComponent: 1, animated: true)
            timePicker.selectRow(0, inComponent: 2, animated: true)
        }
        
        else if textView == note2TextView {
            
            UIView.animate(withDuration: 0.2) {
                
                self.timePicker.frame.origin.y = 700
            }
            
            timePicker.selectRow(0, inComponent: 0, animated: true)
            timePicker.selectRow(0, inComponent: 1, animated: true)
            timePicker.selectRow(0, inComponent: 2, animated: true)
        }
        
        else if textView == note3TextView {
            
            UIView.animate(withDuration: 0.2) {
                
                self.timePicker.frame.origin.y = 700
            }
            
            timePicker.selectRow(0, inComponent: 0, animated: true)
            timePicker.selectRow(0, inComponent: 1, animated: true)
            timePicker.selectRow(0, inComponent: 2, animated: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView == note1TextView {
            
        }
        
        else if textView == note2TextView {
            
        }
        
        else if textView == note3TextView {
            
        }
    }
    
    
    //MARK: - Time Conversion Functions
    
    func convertTo12Hour (_ funcHour: String, _ funcMinute: String, _ funcPeriod: String, _ hour: String) -> String {
        
        var selectedHour: String = "" //Variable that will hold the converted hour
        
        //If the funcHour is "0" representing the time is around 12:00 AM
        if funcHour == "0" {
            
            selectedHour = "12"
        }
        //If the funcHour is "12" representing the time is around 12:00 PM
        else if funcHour == "12" {
            
            selectedHour = "12"
        }
        //If the funcHour is less than 12 PM representing the selectedHour should just be set to the funcHour
        else if Int(funcHour)! < 12 {
            
            selectedHour = funcHour
        }
        //If the funcHour is greater than 12 PM representing the selectedHour should just be set to the funcHour - 12
        else if Int(funcHour)! > 12 {
            
            selectedHour = "\(Int(funcHour)! - 12)"
        }
        
        //If the "hour" is "Start", set the selectedStartHour, otherwise, if it is "End", set the selectedEndHour
        if hour == "Start" {
            selectedStartHour = selectedHour
        }
        else if hour == "End" {
            selectedEndHour = selectedHour
        }
        
        return selectedHour + ":" + funcMinute + " " + funcPeriod
    }
    
    func convertTo24Hour (_ funcStartHour: String, _ funcStartPeriod: String, _ funcEndHour: String, _ funcEndPeriod: String) {

        //If the startTime is around 12:00 AM, set the "selectedStartHour" to be 0
        if funcStartHour == "12" && funcStartPeriod == "AM" {
            selectedStartHour = "0"
        }
        
        //If the startTime is around 12:00 PM, set the "selectedStartHour" to be 12
        if funcStartHour == "12"  && funcStartPeriod == "PM" {
            selectedStartHour = "12"
        }
        
        //If the startTime is from 1:00 PM - 11:55 PM, set the "selectedStartHour" to "funcStartHour" + 12
        if (funcStartHour != "12") && (funcStartPeriod == "PM") {
            selectedStartHour = "\(Int(funcStartHour)! + 12)"
        }
        
        //If the endTime is around 12:00 AM, set the "selectedEndHour" to be 0
        if funcEndHour == "12" && funcEndPeriod == "AM" {
            selectedEndHour = "0"
        }
        
        //If the endTime is around 12:00 PM, set the "selectedEndHour" to be 12
        if funcEndHour == "12" && funcEndPeriod == "PM" {
            selectedEndHour = "12"
        }
        
        //If the endTime is from 1:00 PM - 11:55 PM, set the "selectedEndHour" to "funcEndHour" + 12
        if (funcEndHour != "12") && (funcEndPeriod == "PM") {
            selectedEndHour = "\(Int(funcEndHour)! + 12)"
        }
    }
    
    //Function responsible for getting the "EditBlockView" ready
    func configureEditView () {
        
        guard let bigBlockData = realm.object(ofType: Block.self, forPrimaryKey: blockID) else { return }
        
            create_edit_blockButton.setTitle("Edit", for: .normal)
        
            //Setting the textFields for the "EditBlockView"; "convertTo12Hour" function also handles setting the "selectedStartHour" and "selectedEndHour"
            blockNameTextField.text = bigBlockData.name
            startTimeTextField.text = convertTo12Hour(bigBlockData.startHour, bigBlockData.startMinute, bigBlockData.startPeriod, "Start")
            endTimeTextField.text = convertTo12Hour(bigBlockData.endHour, bigBlockData.endMinute, bigBlockData.endPeriod, "End")
        
            //Setting the selectedStartMinute, selectedStartPeriod, selectedEndMinute, and selectedEndPeriod
            selectedStartMinute = bigBlockData.startMinute; selectedStartPeriod = bigBlockData.startPeriod
            selectedEndMinute = bigBlockData.endMinute; selectedEndPeriod = bigBlockData.endPeriod
        
            note1TextView.text = bigBlockData.note1
            note2TextView.text = bigBlockData.note2
            note3TextView.text = bigBlockData.note3
        
            categoryTextField.text = bigBlockData.blockCategory //Setting the block category
        
            guard let categoryColor = UIColor(hexString: blockCategoryColors[bigBlockData.blockCategory] ?? "#ffffff") else { return }
                categoryColorIndicator.backgroundColor? = categoryColor
        
    }
    
    
    //MARK: - Calculate Valid Time Blocks
    
    func calcValidTimeBlock (_ startHour: String, _ startMinute: String, _ endHour: String, _ endMinute: String, _ blockID: String = "0") -> [String : Bool]{
        
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
                    
                    let realmBlockStart = calendar.date(bySettingHour: Int(timeBlocks.startHour)!, minute: Int(timeBlocks.startMinute)!, second: 0, of: now)! //Converts "realmBlockStart" from a String to a Date
                    let realmBlockEnd = calendar.date(bySettingHour: Int(timeBlocks.endHour)!, minute: Int(timeBlocks.endMinute)!, second: 0, of: now)! //Converts "realmBlockEnd" from a String to a Date
                    let realmBlockRange: ClosedRange = realmBlockStart...realmBlockEnd
                    
                    //If the "newBlockStart" is greater than or equal to "realmBlockStart" and less than "realmBlockEnd"
                    if newBlockStart >= realmBlockStart && newBlockStart < realmBlockEnd {
                        startTimeValidation = false
                        break
                    }
                    //If the "newBlockEnd" is greater than "realmBlockStart" and less than or equal to "realmBlockEnd"
                    else if newBlockEnd > realmBlockStart && newBlockEnd <= realmBlockEnd {
                        endTimeValidation = false
                        break
                    }
                    
                    //For loop that ensures that no time in a new TimeBlock other than it's start and end time interferes with another TimeBlocks times other than its start and end times
                    for times in newBlockArray {
                        
                        if realmBlockRange.contains(times) {
                            rangeValidation = false
                        }
                    }
                }
            }
        }
        return ["startTimeValid" : startTimeValidation, "endTimeValid" : endTimeValidation, "rangeValid" : rangeValidation]
    }
    
    
    //MARK: - Schedule Notification Function
    
    func scheduleNotification () {
        
        if notificationSwitch.isOn {
        
            print(Int(selectedStartMinute)! - notificationTimes[notificationIndex])
            
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
                content.body = blockNameTextField.text! + " in \(notificationTimes[notificationIndex]) mintues"
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
                content.body = blockNameTextField.text! + " in \(notificationTimes[notificationIndex]) mintues"
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
    }

    
    //MARK: - Add or Update TimeBlock Function
    
    func add_updateTimeBlock() {
        
        //If this is the "CreateBlockView", create a new TimeBlock
        if create_edit_blockButton.titleLabel?.text == "Create" {
            
            let newBlock = Block()
            
            newBlock.name = blockNameTextField.text!
            
            newBlock.startHour = selectedStartHour
            newBlock.startMinute = selectedStartMinute
            newBlock.startPeriod = selectedStartPeriod
            
            newBlock.endHour = selectedEndHour
            newBlock.endMinute = selectedEndMinute
            newBlock.endPeriod = selectedEndPeriod
            
            newBlock.blockCategory = selectedCategory
            
            newBlock.note1 = note1TextView.text
            newBlock.note2 = note2TextView.text
            newBlock.note3 = note3TextView.text
            
            newBlock.notificationID = notificationID
            
            do {
                try realm.write {
                    currentDateObject?.timeBlocks.append(newBlock) //Appending the new TimeBlock to "currentDateObject" object
                }
            } catch {
                print ("Error adding a new block \(error)")
            }
            
            //ProgressHUD.showSuccess("TimeBlock created!")
        }
        
        //If this is the "EditBlockView", update a TimeBlock
        else if create_edit_blockButton.titleLabel?.text == "Edit" {
            
            let updatedBlock = Block()
            
            updatedBlock.blockID = blockID
            
            updatedBlock.name = blockNameTextField.text!
            
            updatedBlock.startHour = selectedStartHour
            updatedBlock.startMinute = selectedStartMinute
            updatedBlock.startPeriod = selectedStartPeriod
            
            updatedBlock.endHour = selectedEndHour
            updatedBlock.endMinute = selectedEndMinute
            updatedBlock.endPeriod = selectedEndPeriod
            
            updatedBlock.blockCategory = categoryTextField.text!
            
            updatedBlock.note1 = note1TextView.text
            updatedBlock.note2 = note2TextView.text
            updatedBlock.note3 = note3TextView.text
            
            do {
                try self.realm.write {
                    
                    realm.add(updatedBlock, update: .modified)
                    //realm.add(updatedBlock, update: true)
                    
                }
            } catch {
                print ("Error updating block \(error)")
                
            }
            
            //ProgressHUD.showSuccess("TimeBlock updated!")
        }
    }
    
    //MARK: - Notification Controls
    
    @IBAction func notificationSwitch(_ sender: Any) {
        
        if notificationSwitch.isOn == true {
            notificationTimeSegments.isEnabled = true
        }
        
        else {
            notificationTimeSegments.isEnabled = false
        }
    }
    
    @IBAction func notificationTimeSegments(_ sender: Any) {
        
        notificationIndex = notificationTimeSegments.selectedSegmentIndex
    }
    
    
    //MARK: - Cancel, Create, and Edit button Functions
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func create_edit_ButtonPressed(_ sender: Any) {
        
        var validTimeBlock : [String : Bool]
        
        convertTo24Hour(selectedStartHour, selectedStartPeriod, selectedEndHour, selectedEndPeriod) //Function that converts the selected times to 24 hour format
        
        //If the user hasn't entered a name for a TimeBlock
        if blockNameTextField.text! == "" {
            ProgressHUD.showError("Please enter a name for this Time Block")
        }
        //If the user hasn't finished entering the start time for a TimeBlock
        else if selectedStartHour == "" || selectedStartMinute == "" || selectedStartPeriod == "" {
            ProgressHUD.showError("Please finish entering when this Time Block should begin")
        }
        //If the user hasn't finished entering the end time for a TimeBlock
        else if selectedEndHour == "" || selectedEndMinute == "" || selectedEndPeriod == "" {
            ProgressHUD.showError("Please finish entering when this Time Block should end")
        }
        //If the start time and end time for a TimeBlock are the same
        else if selectedStartHour == selectedEndHour && selectedStartMinute == selectedEndMinute && selectedStartPeriod == selectedEndPeriod {
            ProgressHUD.showError("Sorry, the times for Time Blocks can't be the same")
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
            if create_edit_blockButton.titleLabel?.text == "Create" {
            
                validTimeBlock = calcValidTimeBlock(selectedStartHour, selectedStartMinute, selectedEndHour, selectedEndMinute)
            }
            //If the user is updating a TimeBlock, call "calcValidTimeBlock" entering a "blockID" showing that a block is being updated
            else {
                validTimeBlock = calcValidTimeBlock(selectedStartHour, selectedStartMinute, selectedEndHour, selectedEndMinute, blockID)
            }
            
            //If statements that check if the TimeBlock failed any tests in the "calcValidTimeBlock" function
            if validTimeBlock["startTimeValid"] == false {
                ProgressHUD.showError("The starting time of this TimeBlock conflicts with another")
                timePicker.reloadAllComponents() //Not too sure if this is really needed
            }
            else if validTimeBlock["endTimeValid"] == false {
                ProgressHUD.showError("The ending time of this TimeBlock conflicts with another")
                timePicker.reloadAllComponents() //Not too sure if this is really needed
            }
            else if validTimeBlock["validRange"] == false {
                ProgressHUD.showError("This TimeBlock conflicts with another")
            }
            
            //AYEEEE IT PASSED ALL THE TESTS, GO AHEAD AND ADD THAT SHIT
            else {

                scheduleNotification()
                add_updateTimeBlock()
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //Function that dismisses the keyboard and the PickerViews
    @objc func dismissKeyboard () {
        
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.2) {
            
            self.timePicker.frame.origin.y = 750
            self.categoryPicker.frame.origin.y = 750
        }
        
        timePicker.selectRow(0, inComponent: 0, animated: true)
        timePicker.selectRow(0, inComponent: 1, animated: true)
        timePicker.selectRow(0, inComponent: 2, animated: true)
        
        categoryPicker.selectRow(0, inComponent: 0, animated: true)
    }
    
}
