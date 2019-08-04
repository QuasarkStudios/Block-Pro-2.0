//
//  AUCollabBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/29/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

//Add or update collab block
class AUCollabBlockViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var blockNameTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var blockContainer: UIView!
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationTimeSegments: UISegmentedControl!
    @IBOutlet weak var timeSegmentContainer: UIView!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var timePickerContainer: UIView!
    @IBOutlet weak var categoryPickerContainer: UIView!
    
    let db = Firestore.firestore()
    let currentUser = UserData.singletonUser
    
    var blockObjectArray: [CollabBlock] = [CollabBlock]()
    var validTimeBlock : [String : Bool] = ["startTimeValidation": true, "endTimeValidation" : true, "rangeValidation" : true]
    
    let formatter = DateFormatter()
    
    var selectedView: String = ""
    
    var collabID: String = ""
    var blockID: String = "" //Variable that holds the "blockID" of the CollabBlock being updated
    
    //Arrays that holds the title for each row of the "categoryPicker"
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
    
    var notificationID: String = UUID().uuidString //Variable that holds either the notficationID of a new TimeBlock or the "notficationID" of a TimeBlock being updated
    var notificationTimes: [Int] = [5, 10, 15] //Variable that holds values that will be used after user selects the "Notification Time Segment"
    var notificationIndex: Int = 0 //Variable that tracks which segment of the "Notification Time Segment" is selected
    
    override func viewDidLoad() {
        super.viewDidLoad()

        blockNameTextField.delegate = self
        startTimeTextField.delegate = self
        endTimeTextField.delegate = self
        
        categoryTextField.delegate = self
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        timePickerContainer.frame.origin.y = 750
        categoryPickerContainer.frame.origin.y = 750
        
        startTimeTextField.inputView = UIView()
        endTimeTextField.inputView = UIView()
        categoryTextField.inputView = UIView()
        
        timePickerContainer.layer.cornerRadius = 0.1 * timePickerContainer.bounds.size.width
        timePickerContainer.clipsToBounds = true
        
        timePicker?.addTarget(self, action: #selector(timeSelected(timePicker:)), for: .valueChanged)
        timeSelected(timePicker: timePicker)
        
        categoryPickerContainer.layer.cornerRadius = 0.1 * categoryPickerContainer.bounds.size.width
        categoryPickerContainer.clipsToBounds = true
        
        timeSegmentContainer.layer.cornerRadius = 0.035 * timeSegmentContainer.bounds.size.width
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        navigationItem.title = "Add Collab Block"
        
        blockContainer.backgroundColor = UIColor(hexString: "#EFEFF4")
        blockContainer.layer.cornerRadius = 0.05 * blockContainer.bounds.size.width
        blockContainer.clipsToBounds = true
        
        //getFirebaseBlocks(completion: <#([CollabBlock])#>)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return blockCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return blockCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        categoryTextField.text = blockCategories[row]
        selectedCategory = blockCategories[row]
        blockContainer.backgroundColor = UIColor(hexString: blockCategoryColors[blockCategories[row]])
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
            
        case blockNameTextField:
            UIView.animate(withDuration: 0.2) {
                self.timePickerContainer.frame.origin.y = 750
                self.categoryPickerContainer.frame.origin.y = 750
            }
            
        case startTimeTextField:
            tag = "start"
            
            UIView.animate(withDuration: 0.15, animations: {
                self.categoryPickerContainer.frame.origin.y = 750
            }) { (finished: Bool) in
                
                UIView.animate(withDuration: 0.15) {
                    self.timePickerContainer.frame.origin.y = 475
                }
            }
            
        case endTimeTextField:
            tag = "end"
            
            UIView.animate(withDuration: 0.15, animations: {
                self.categoryPickerContainer.frame.origin.y = 750
            }) { (finished: Bool) in
                
                UIView.animate(withDuration: 0.15) {
                    self.timePickerContainer.frame.origin.y = 475
                }
            }
            
        case categoryTextField:
            
            UIView.animate(withDuration: 0.15, animations: {
                self.timePickerContainer.frame.origin.y = 750
            }) { (finished: Bool) in
                
                UIView.animate(withDuration: 0.15) {
                    self.categoryPickerContainer.frame.origin.y = 475
                }
            }
            
        default:
            break
        }
        
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
    
    //MARK: - Calculate Valid Time Blocks
    
    func calcValidTimeBlock ( _ blockID: String = "0")  {

        //If other TimeBlocks have already been created for this day, verify this new TimeBlocks time
        if blockObjectArray.count > 0 {
            print("block object check reached", blockObjectArray.count)
            let calendar = Calendar.current
            let now = Date()

            let newBlockStart = calendar.date(bySettingHour: Int(selectedStartHour)!, minute: Int(selectedStartMinute)!, second: 0, of: now)! //Converts "newBlockStart" from a String to a Date
            let newBlockEnd = calendar.date(bySettingHour: Int(selectedEndHour)!, minute: Int(selectedEndMinute)!, second: 0, of: now)! //Converts "newBlockEnd" from a String to a Date
            var newBlockArray: [Date] = [newBlockStart] //Creation of an array that holds all the times the new TimeBlock can't interfere with

            //While loop that populates the "newBlockArray" with times the new TimeBlock can't interfere with
            while newBlockArray.contains(newBlockEnd) != true {
                newBlockArray.append(newBlockArray[newBlockArray.count - 1].addingTimeInterval(300)) //Appending a new time
            }

            _ = newBlockArray.remove(at: 0) //Removes the "newBlockStart" time from the newBlockArray; that time will be checked later in function
            _ = newBlockArray.remove(at: newBlockArray.count - 1) //Removes the "newBlockEnd" time from the newBlockArray; that time will be checked later in function

            for collabBlock in blockObjectArray {

                //If this TimeBlock is not the one being updated by the user
                if collabBlock.blockID != blockID {

                    let firebaseBlockStart = calendar.date(bySettingHour: Int(collabBlock.startHour)!, minute: Int(collabBlock.startMinute)!, second: 0, of: now)! //Converts "firebaseBlockStart" from a String to a Date
                    let firebaseBlockEnd = calendar.date(bySettingHour: Int(collabBlock.endHour)!, minute: Int(collabBlock.endMinute)!, second: 0, of: now)! //Converts "firebaseBlockEnd" from a String to a Date
                    let firebaseBlockRange: ClosedRange = firebaseBlockStart...firebaseBlockEnd

                    //If the "newBlockStart" is greater than or equal to "realmBlockStart" and less than "realmBlockEnd"
                    if newBlockStart >= firebaseBlockStart && newBlockStart < firebaseBlockEnd {
                        print("newblockstart", newBlockStart)
                        print("newblockend", newBlockEnd)
                        print("firebaseblockstart", firebaseBlockStart)
                        print("firebaseblockstart", firebaseBlockStart)
                        validTimeBlock["startTimeValidation"] = false

                        break
                    }
                        //If the "newBlockEnd" is greater than "realmBlockStart" and less than or equal to "realmBlockEnd"
                    else if newBlockEnd > firebaseBlockStart && newBlockEnd <= firebaseBlockEnd {
                        validTimeBlock["endTimeValidation"] = false
                        break
                    }

                    //For loop that ensures that no time in a new TimeBlock other than it's start and end time interferes with another TimeBlocks times other than its start and end times
                    for times in newBlockArray {

                        if firebaseBlockRange.contains(times) {
                            validTimeBlock["rangeValidation"] = false
                        }
                    }
                }
            }

        }


        //print(validTimeBlock)
        
    }
    
    func getFirebaseBlocks (_ blockID: String = "0", completion: @escaping () -> ())  {
        
        var startTimeValidation: Bool = true //Variable that tracks if the startTime of the TimeBlock is valid
        var endTimeValidation: Bool = true //Variable that tracks if the endTime of the TimeBlock is valid
        var rangeValidation: Bool = true  //Variable that tracks if the range of the TimeBlock is valid
        
        
        db.collection("Collaborations").document(collabID).collection("CollabBlocks").getDocuments { (snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
                
            else {
                
                if snapshot?.isEmpty == true {
                    print("no collabs")
                    completion()
                }
                    
                else {
                    
                    for document in snapshot!.documents {
                        
                        let collabBlock = CollabBlock()
                        
                        collabBlock.blockID = document.data()["blockID"] as! String
                        collabBlock.notificationID = document.data()["notificationID"] as! String
                        collabBlock.name = document.data()["name"] as! String
                        
                        collabBlock.startHour = document.data()["startHour"] as! String
                        collabBlock.startMinute = document.data()["startMinute"] as! String
                        collabBlock.startPeriod = document.data()["startPeriod"] as! String
                        
                        collabBlock.endHour = document.data()["endHour"] as! String
                        collabBlock.endMinute = document.data()["endMinute"] as! String
                        collabBlock.endPeriod = document.data()["endPeriod"] as! String
                        
                        collabBlock.blockCategory = document.data()["blockCategory"] as! String
                        
                        self.blockObjectArray.append(collabBlock)
                        
                    }
                    completion()
                }
            }
        }
    }
    
    func add_updateCollabBlock() {
        
        //If this is the "CreateBlockView", create a new CollabBlock
        if selectedView == "Add" {
            
            let blockID = UUID().uuidString
            
            let newBlock: [String : Any] = ["creator" : ["userID" : currentUser.userID, "firstName" : currentUser.firstName, "lastName" : currentUser.lastName], "blockID" : blockID, "notificationID" : "", "name" : blockNameTextField.text!, "startHour" : selectedStartHour, "startMinute" : selectedStartMinute, "startPeriod" : selectedStartPeriod, "endHour" : selectedEndHour, "endMinute" : selectedEndMinute, "endPeriod" : selectedEndPeriod, "blockCategory" : selectedCategory]
            
            db.collection("Collaborations").document(collabID).collection("CollabBlocks").document(blockID).setData(newBlock)
            
            ProgressHUD.showSuccess("TimeBlock created!")
            
            dismiss(animated: true, completion: nil)
        }
            
    }
    


    @IBAction func create_editButtonPressed(_ sender: Any) {
        
//        var validTimeBlock : [String : Bool]
        
        //If the user hasn't entered a name for a TimeBlock
        if blockNameTextField.text! == "" {
            ProgressHUD.showError("Please enter a name for this CollabBlock")
        }
            //If the user hasn't finished entering the start time for a TimeBlock
        else if startTimeTextField.text == "" {
            ProgressHUD.showError("Please enter when this CollabBlock should begin")
        }
            //If the user hasn't finished entering the end time for a TimeBlock
        else if endTimeTextField.text == "" {
            ProgressHUD.showError("Please finish entering when this CollabBlock should end")
        }
            //If the start time and end time for a TimeBlock are the same
        else if selectedStartHour == selectedEndHour && selectedStartMinute == selectedEndMinute && selectedStartPeriod == selectedEndPeriod {
            ProgressHUD.showError("Sorry, the times for CollabBlocks can't be the same")
        }
            //If end time is before the start time
        else if selectedEndHour < selectedStartHour {
            ProgressHUD.showError("Sorry, the end time for a CollabBlock can't be before it's start time")
        }
            //If end time is before the start time
        else if (selectedEndHour == selectedStartHour) && (selectedEndMinute < selectedStartMinute) {
            ProgressHUD.showError("Sorry, the end time for a CollabBlock can't be before it's start time")
        }
            //This code block is reached only if the TimeBlock passed all other tests
        else {
            
            //If the user is creating a new TimeBlock, call "calcValidTimeBlock" without entering a "blockID" showing that a block isn't being updated
            if selectedView == "Add" {
                
                getFirebaseBlocks {
                    self.calcValidTimeBlock()
                    
                    print(self.validTimeBlock)
                    
                    //If statements that check if the TimeBlock failed any tests in the "calcValidTimeBlock" function
                    if self.validTimeBlock["startTimeValidation"] == false {
                        ProgressHUD.showError("The starting time of this TimeBlock conflicts with another")
                    }
                    else if self.validTimeBlock["endTimeValidation"] == false {
                        ProgressHUD.showError("The ending time of this TimeBlock conflicts with another")
                    }
                    else if self.validTimeBlock["rangeValidation"] == false {
                        ProgressHUD.showError("This TimeBlock conflicts with another")
                    }
                        
                        //AYEEEE IT PASSED ALL THE TESTS, GO AHEAD AND ADD THAT SHIT
                    else {
                        
                        //scheduleNotification()
                        self.add_updateCollabBlock()
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
                //If the user is updating a TimeBlock, call "calcValidTimeBlock" entering a "blockID" showing that a block is being updated
            else {
                //validTimeBlock = calcValidTimeBlock(selectedStartHour, selectedStartMinute, selectedEndHour, selectedEndMinute, blockID)
            }
            
            
//            //If statements that check if the TimeBlock failed any tests in the "calcValidTimeBlock" function
//            if validTimeBlock["startTimeValid"] == false {
//                ProgressHUD.showError("The starting time of this TimeBlock conflicts with another")
//            }
//            else if validTimeBlock["endTimeValid"] == false {
//                ProgressHUD.showError("The ending time of this TimeBlock conflicts with another")
//            }
//            else if validTimeBlock["validRange"] == false {
//                ProgressHUD.showError("This TimeBlock conflicts with another")
//            }
//
//                //AYEEEE IT PASSED ALL THE TESTS, GO AHEAD AND ADD THAT SHIT
//            else {
//
//                //scheduleNotification()
//                add_updateCollabBlock()
//                dismiss(animated: true, completion: nil)
//            }
        }
    }
    
    @objc func dismissKeyboard () {
        
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.2) {
            
            self.timePickerContainer.frame.origin.y = 750
            self.categoryPickerContainer.frame.origin.y = 750
        }
        
        categoryPicker.selectRow(0, inComponent: 0, animated: true)
    }
}
