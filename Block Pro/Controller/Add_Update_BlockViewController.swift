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

    let realm = try! Realm()
    var blockData: Results<Block>?
    
    var currentDateObject: TimeBlocksDate?
    
    let timeBlockViewObject = TimeBlockViewController()
    
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
    
    let hours: [String] = ["", "12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    let minutes: [String] = ["", "00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    let timePeriods: [String] = ["", "AM", "PM"]
    
    let blockCategories: [String] = ["", "Work", "Creative Time", "Sleep", "Food/Eat", "Leisure", "Exercise", "Self-Care", "Other"]
    let blockCategoryColors: [String : String] = ["Work": "#5065A0", "Creative Time" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#EFEFF4"]
    
    var tag: String = ""
    
    var selectedStartHour: String = ""
    var selectedStartMinute: String = ""
    var selectedStartPeriod: String = ""
    
    var selectedEndHour: String = ""
    var selectedEndMinute: String = ""
    var selectedEndPeriod: String = ""
    
    var selectedCategory: String = ""
    
    var blockID: String = ""
    
    var notificationTimes: [Int] = [5, 10, 15]
    var notificationIndex: Int = 0

    
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
        
        if pickerView == timePicker {
            return 3
        }
        
        else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
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
        
        else {
            return blockCategories.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
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
        
        else {
            return blockCategories[row]
        }
    }
    
    
    //MARK: - TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        timePicker.selectRow(0, inComponent: 0, animated: true)
        timePicker.selectRow(0, inComponent: 1, animated: true)
        timePicker.selectRow(0, inComponent: 2, animated: true)
        
        categoryPicker.selectRow(0, inComponent: 0, animated: true)
        
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
        
        if textField == startTimeTextField {
            startTimeTextField.text = ("\(selectedStartHour):" + "\(selectedStartMinute) " + selectedStartPeriod)
        }
            
        else if textField == endTimeTextField {
            endTimeTextField.text = ("\(selectedEndHour):" + "\(selectedEndMinute) " + selectedEndPeriod)
        }
    }
    
    
    //MARK: - TextView Delegate Methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
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
    
    
    //MARK: - PickerView Delegate Method
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
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
    
            startTimeTextField.text = selectedStartHour + ":" + selectedStartMinute + " " + selectedStartPeriod
            endTimeTextField.text = selectedEndHour + ":" + selectedEndMinute + " " + selectedEndPeriod
            
        }
        
        else if pickerView == categoryPicker {
            selectedCategory = blockCategories[row]
            categoryTextField.text = selectedCategory
            
            guard let categoryColor = UIColor(hexString: blockCategoryColors[selectedCategory]) else { return }
            categoryColorIndicator.backgroundColor? = categoryColor
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
            return "YOU GOT IT WRONG BEYOTCH"
        }
    }
    
    func convertTo24Hour (_ funcStartHour: String, _ funcStartPeriod: String, _ funcEndHour: String, _ funcEndPeriod: String) {
        
        if funcStartHour == "12" && funcStartPeriod == "AM" {
            selectedStartHour = "0"
        }
        
        if (funcStartHour != "12") && (funcStartPeriod == "PM") {
            selectedStartHour = "\(Int(funcStartHour)! + 12)"
        }
        
        if (funcEndHour != "12") && (funcEndPeriod == "PM") {
            selectedEndHour = "\(Int(funcEndHour)! + 12)"
        }
        
        if (funcEndHour == "12") && (funcEndPeriod == "PM") {
            selectedEndHour = "24"
        }
    }
    
    func configureEditView () {
        
        guard let bigBlockData = realm.object(ofType: Block.self, forPrimaryKey: blockID) else { return }
        
            blockNameTextField.text = bigBlockData.name
            startTimeTextField.text = convertTo12Hour(bigBlockData.startHour, bigBlockData.startMinute)
            endTimeTextField.text = convertTo12Hour(bigBlockData.endHour, bigBlockData.endMinute)
        
            selectedStartHour = bigBlockData.startHour; selectedStartMinute = bigBlockData.startMinute; selectedStartPeriod = bigBlockData.startPeriod
            selectedEndHour = bigBlockData.endHour; selectedEndMinute = bigBlockData.endMinute; selectedEndPeriod = bigBlockData.endPeriod
        
            note1TextView.text = bigBlockData.note1
            note2TextView.text = bigBlockData.note2
            note3TextView.text = bigBlockData.note3
        
            categoryTextField.text = bigBlockData.blockCategory
        
            create_edit_blockButton.setTitle("Edit", for: .normal)
    }
    
    
    //MARK: - Calculate Valid Time Blocks
    
    func calcValidTimeBlock (_ startHour: String, _ startMinute: String, _ endHour: String, _ endMinute: String, _ blockID: String = "0") -> [String : Bool]{
        
        var startTimeValidation: Bool = true
        var endTimeValidation: Bool = true
        var rangeValidation: Bool = true
        
        if blockData != nil {
            
            let calendar = Calendar.current
            let now = Date()
            
            let newBlockStart = calendar.date(bySettingHour: Int(startHour)!, minute: Int(startMinute)!, second: 0, of: now)!
            let newBlockEnd = calendar.date(bySettingHour: Int(endHour)!, minute: Int(endMinute)!, second: 0, of: now)!
            var newBlockArray: [Date] = [newBlockStart]
            
            while newBlockArray.contains(newBlockEnd) != true {
                newBlockArray.append(newBlockArray[newBlockArray.count - 1].addingTimeInterval(300))
            }
            
            let removeBlockStart = newBlockArray.remove(at: 0)
            let removeBlockEnd = newBlockArray.remove(at: newBlockArray.count - 1)
            
            for timeBlocks in blockData! {
                
                if timeBlocks.blockID != blockID {
                    
                    let realmBlockStart = calendar.date(bySettingHour: Int(timeBlocks.startHour)!, minute: Int(timeBlocks.startMinute)!, second: 0, of: now)!
                    let realmBlockEnd = calendar.date(bySettingHour: Int(timeBlocks.endHour)!, minute: Int(timeBlocks.endMinute)!, second: 0, of: now)!
                    let realmBlockRange: ClosedRange = realmBlockStart...realmBlockEnd
                    
                    if newBlockStart >= realmBlockStart && newBlockStart < realmBlockEnd {
                        startTimeValidation = false
                        break
                    }
                    else if newBlockEnd > realmBlockStart && newBlockEnd <= realmBlockEnd {
                        endTimeValidation = false
                        break
                    }
                    
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
    
    func scheduleNotification () {
        
        if notificationSwitch.isOn {
        
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            let uuidString = UUID().uuidString
            let content = UNMutableNotificationContent()
            let trigger: UNCalendarNotificationTrigger
            let request: UNNotificationRequest
            
            guard let date = currentDateObject?.timeBlocksDate else { return }
            
            let initialDate = Array(date)
            
            var notificationDate: [String : String] = ["Year": "", "Month" : "", "Day": ""]
            var count: Int = 0
            
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
                
                dateComponents.year = Int(notificationDate["Year"]!)!
                dateComponents.month = Int(notificationDate["Month"]!)!
                dateComponents.day = Int(notificationDate["Day"]!)!
                
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
                
                content.title = "Heads Up!!"
                content.body = blockNameTextField.text! + " in \(notificationTimes[notificationIndex]) mintues"
                content.sound = UNNotificationSound.default
                
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
                
            //If the selectedStartMinute will not become negative
            else if Int(selectedStartMinute)! - notificationTimes[notificationIndex] >= 0 {
                
                dateComponents.year = Int(notificationDate["Year"]!)!
                dateComponents.month = Int(notificationDate["Month"]!)!
                dateComponents.day = Int(notificationDate["Day"]!)!
                dateComponents.hour = Int(selectedStartHour)!
                dateComponents.minute = Int(selectedStartMinute)! - notificationTimes[notificationIndex]
                
                content.title = "Heads Up!!"
                content.body = blockNameTextField.text! + "in \(notificationTimes[notificationIndex]) mintues"
                content.sound = UNNotificationSound.default
                
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
                
            //If the selectedStartHour will become negative signifying the user wants the notification to come a day before
            else if (Int(selectedStartHour)! ==  0) && (Int(selectedStartMinute)! - notificationTimes[notificationIndex] < 0) {
                ProgressHUD.showError("Sorry, notifications coming a day prior isn't currently supported")
            }
        }
    }

    func add_updateTimeBlock() {
        
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
            
            do {
                try realm.write {
                    currentDateObject?.timeBlocks.append(newBlock)
                }
            } catch {
                print ("Error adding a new block \(error)")
            }
        }
        
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
                    
                    realm.add(updatedBlock, update: true)
                    
                }
            } catch {
                print ("Error updating block \(error)")
                
            }
            
        }
    }
    
    //MARK: - Notification Controls
    
    @IBAction func notificationSwitch(_ sender: Any) {
        
        if notificationSwitch.isOn == true {
            notificationTimeSegments.isEnabled = true
            print("give it to em")
        }
        
        else {
            notificationTimeSegments.isEnabled = false
            print ("they afraid of the truth")
        }
    }
    
    @IBAction func notificationTimeSegments(_ sender: Any) {
        
        notificationIndex = notificationTimeSegments.selectedSegmentIndex
    }
    
    
    //MARK: - Buttons
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func create_edit_ButtonPressed(_ sender: Any) {
        
        var validTimeBlock : [String : Bool]
        
        convertTo24Hour(selectedStartHour, selectedStartPeriod, selectedEndHour, selectedEndPeriod)
        
        if blockNameTextField.text! == "" {
            ProgressHUD.showError("Please enter a name for this Time Block")
        }
        else if selectedStartHour == "" || selectedStartMinute == "" || selectedStartPeriod == "" {
            ProgressHUD.showError("Please finish entering when this Time Block should begin")
        }
        else if selectedEndHour == "" || selectedEndMinute == "" || selectedEndPeriod == "" {
            ProgressHUD.showError("Please finish entering when this Time Block should end")
        }
        else if selectedStartHour == selectedEndHour && selectedStartMinute == selectedEndMinute && selectedStartPeriod == selectedEndPeriod {
            ProgressHUD.showError("Sorry, the times for Time Blocks can't be the same")
        }
        else {
            
            if create_edit_blockButton.titleLabel?.text == "Create" {
            
                validTimeBlock = calcValidTimeBlock(selectedStartHour, selectedStartMinute, selectedEndHour, selectedEndMinute)
            }
            else {
                validTimeBlock = calcValidTimeBlock(selectedStartHour, selectedStartMinute, selectedEndHour, selectedEndMinute, blockID)
            }
            
            if validTimeBlock["startTimeValid"] == false {
                ProgressHUD.showError("The starting time of this TimeBlock conflicts with another")
                timePicker.reloadAllComponents()
            }
            else if validTimeBlock["endTimeValid"] == false {
                ProgressHUD.showError("The ending time of this TimeBlock conflicts with another")
                timePicker.reloadAllComponents()
            }
            else if validTimeBlock["validRange"] == false {
                ProgressHUD.showError("This TimeBlock conflicts with another")
            }
            
            else {

                add_updateTimeBlock()
                scheduleNotification()
                ProgressHUD.showSuccess("Time Block created!")
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
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
