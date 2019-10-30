//
//  AUCollabBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/29/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

//Add or update collab block
class AUCollabBlockViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var blockOutline: UIView!
    @IBOutlet weak var blockContainer: UIView!
    
    @IBOutlet weak var initialOutline: UIView!
    @IBOutlet weak var initialLabel: UILabel!
    
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
    
    let db = Firestore.firestore()
    let currentUser = UserData.singletonUser
    
    var blockObjectArray: [CollabBlock] = [CollabBlock]()
    var validCollabBlock : [String : Bool] = ["startTimeValidation": true, "endTimeValidation" : true, "rangeValidation" : true]
    
    let formatter = DateFormatter()
    
    var selectedView: String = ""
    
    var collabID: String = ""
    var collabDate: String = ""
    var selectedBlock: CollabBlock? //Variable that holds the CollabBlock being updated
    
    //Arrays that holds the title for each row of the "categoryPicker"
    let blockCategories: [String] = ["", "Work", "Creative Time", "Sleep", "Food/Eat", "Leisure", "Exercise", "Self-Care", "Other"]
    let blockCategoryColors: [String : String] = ["Work": "#5065A0", "Creative Time" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#AAAAAA"]
    
    var tag: String = ""
    
    var selectedStartHour: String = ""
    var selectedStartMinute: String = ""
    var selectedStartPeriod: String = ""
    
    var selectedEndHour: String = ""
    var selectedEndMinute: String = ""
    var selectedEndPeriod: String = ""
    
    var selectedCategory: String = ""
    
    var notificationID: String = UUID().uuidString //Variable that holds either the notficationID of a new CollabBlock or the "notficationID" of a CollabBlock being updated
    var notificationTimes: [Int] = [5, 10, 15] //Variable that holds values that will be used after user selects the "Notification Time Segment"
    var notificationIndex: Int = 0 //Variable that tracks which segment of the "Notification Time Segment" is selected
    
    var notificationSettings: [String : [String : Any]] = [:] //["notificationID" : "", "scheduled" : false, "minsBefore" : 0]
    
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
         
        initialOutline.layer.cornerRadius = 0.5 * initialOutline.bounds.size.width
        initialOutline.clipsToBounds = true
         
        initialLabel.layer.cornerRadius = 0.5 * initialLabel.bounds.size.width
        initialLabel.clipsToBounds = true
         
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
        
        notificationSettings = [currentUser.userID : ["notificationID" : "", "scheduled" : false, "minsBefore" : 0]]
        
        if selectedView == "Add" {
            
            navigationItem.title = "Add Collab Block"
            
            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(add_editCollabBlock1))
            navigationItem.rightBarButtonItem = addButton
            
            initialLabel.text = "Me"
            initialOutline.backgroundColor = UIColor(hexString: "#EFEFF4")
            
        }
            
        else if selectedView == "Edit" {
            
            navigationItem.title = "Edit Collab Block"
            
            let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(add_editCollabBlock1))
            navigationItem.rightBarButtonItem = editButton
            
            guard let block = selectedBlock else { return }
            
            if block.blockCategory == "" {
                blockOutline.backgroundColor = .lightGray
                initialOutline.backgroundColor = .lightGray
            }
            else {
                blockOutline.backgroundColor = UIColor(hexString: blockCategoryColors[block.blockCategory]!)
                initialOutline.backgroundColor = UIColor(hexString: blockCategoryColors[block.blockCategory]!)
            }
            
            if block.creator["userID"] == currentUser.userID {
                
                initialLabel.text = "Me"
            }
            else {
                
                let firstNameArray = Array(block.creator["firstName"]!)
                let lastNameArray = Array(block.creator["lastName"]!)
                
                initialLabel.text = "\(firstNameArray[0])" + "\(lastNameArray[0])"
            }
            
            blockNameTextField.text = block.name
            startTimeTextField.text = convertTo12Hour(block.startHour, block.startMinute)
            endTimeTextField.text = convertTo12Hour(block.endHour, block.endMinute)
            
            selectedStartHour = block.startHour; selectedStartMinute = block.startMinute; selectedStartPeriod = block.startPeriod
            selectedEndHour = block.endHour; selectedEndMinute = block.endMinute; selectedEndPeriod = block.endPeriod
            
            categoryTextField.text = block.blockCategory
            selectedCategory = block.blockCategory
            
            
            guard let notifSettings = block.notificationSettings[currentUser.userID] else { return }
            
            if notifSettings["scheduled"] as! Bool == true {
                
                notificationSettings = [currentUser.userID : ["notificationID" : notifSettings["notificationID"] as Any, "scheduled" : true, "minsBefore" : notifSettings["minsBefore"] as Any]]
                
                notificationID = notifSettings["notificationID"] as! String
                
                notificationSwitch.isOn = true
                notificationTimeSegments.selectedSegmentIndex = notifSettings["minsBefore"] as! Int
            }
                
            else {
                notificationSwitch.isOn = false
                
                self.notificationViewHeightConstraint.constant = 43
                self.segmentContainerBottomConstraint.constant = -40
            }
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
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0{
            containersPresentedTopAnchor = 40
        }
            
            //iPhone SE
        else if UIScreen.main.bounds.width == 320.0 {
            
            timeContainerHeightConstraint.constant = 150
            categoryContainerHeightConstraint.constant = 150
            
            containersPresentedTopAnchor = 17.5
        }
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
        blockOutline.backgroundColor = UIColor(hexString: blockCategoryColors[blockCategories[row]] ?? "#AAAAAA")
        initialOutline.backgroundColor = UIColor(hexString: blockCategoryColors[blockCategories[row]] ?? "#AAAAAA")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
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
    
    func getFirebaseBlocks (_ blockID: String = "0", completion: @escaping () -> ())  {
        
        blockObjectArray.removeAll()
        
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
                        //collabBlock.notificationID = document.data()["notificationID"] as! String
                        collabBlock.name = document.data()["name"] as! String; #warning ("tell user which block the new one interferes with")
                        
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
                    completion()
                }
            }
        }
    }
    
 
    
    //MARK: - Calculate Valid Collab Blocks
    
    func calcValidCollabBlock ( _ blockID: String = "0")  {

        validCollabBlock["startTimeValidation"] = true
        validCollabBlock["endTimeValidation"] = true
        validCollabBlock["rangeValidation"] = true
        
        //If other TimeBlocks have already been created for this day, verify this new TimeBlocks time
        if blockObjectArray.count > 0 {
            
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
 
                        validCollabBlock["startTimeValidation"] = false

                        break
                    }
                        //If the "newBlockEnd" is greater than "realmBlockStart" and less than or equal to "realmBlockEnd"
                    else if newBlockEnd > firebaseBlockStart && newBlockEnd <= firebaseBlockEnd {
                        
                        validCollabBlock["endTimeValidation"] = false
                        break
                    }

                    //For loop that ensures that no time in a new TimeBlock other than it's start and end time interferes with another TimeBlocks times other than its start and end times
                    for times in newBlockArray {

                        if firebaseBlockRange.contains(times) {
                            
                            validCollabBlock["rangeValidation"] = false
                            break
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func notificationSwitch(_ sender: Any) {
        
        if notificationSwitch.isOn == true {
            //notificationTimeSegments.isEnabled = true
            
            self.notificationViewHeightConstraint.constant = 85
            self.segmentContainerBottomConstraint.constant = 5
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
        }
        else {
            //notificationTimeSegments.isEnabled = false
            
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
    
    func scheduleNotification () {
        
        if notificationSwitch.isOn {
            
            notificationSettings = [currentUser.userID : ["notificationID" : notificationID as Any, "scheduled" : true, "minsBefore" : notificationIndex as Any]]
        
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            let content = UNMutableNotificationContent()
            let trigger: UNCalendarNotificationTrigger
            let request: UNNotificationRequest
            
            
            var notificationDate: [String : String] = ["Month": "", "Day" : "", "Year": ""]
            
            formatter.dateFormat = "MMMM d, yyyy"
            
            let scheduledDate = formatter.date(from: collabDate)
            
            formatter.dateFormat = "M"
            notificationDate["Month"] = formatter.string(from: scheduledDate!)
            
            
            formatter.dateFormat = "d"
            notificationDate["Day"] = formatter.string(from: scheduledDate!)
            
            formatter.dateFormat = "yyyy"
            notificationDate["Year"] = formatter.string(from: scheduledDate!)
            
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
    
    @objc func add_editCollabBlock1 () {
        
        let blockNameArray = Array(blockNameTextField.text ?? "")
        var blockNameEntered: Bool = false
        
        //For loop that checks to see if "blockNameTextField" isn't empty
        for char in blockNameArray {
            
            if char != " " {
                blockNameEntered = true
                break
            }
        }
        
        //If the user hasn't entered a name for a CollabBlock
        if blockNameEntered != true {
            ProgressHUD.showError("Please enter a name for this CollabBlock")
        }
            //If the user hasn't finished entering the start time for a CollabBlock
        else if startTimeTextField.text == "" {
            ProgressHUD.showError("Please enter when this CollabBlock should begin")
        }
            //If the user hasn't finished entering the end time for a CollabBlock
        else if endTimeTextField.text == "" {
            ProgressHUD.showError("Please enter when this CollabBlock should end")
        }
            //If the start time and end time for a CollabBlock are the same
        else if selectedStartHour == selectedEndHour && selectedStartMinute == selectedEndMinute && selectedStartPeriod == selectedEndPeriod {
            ProgressHUD.showError("Sorry, the times for CollabBlocks can't be the same")
        }
            //If end time is before the start time
        else if Int(selectedEndHour)! < Int(selectedStartHour)! {
            ProgressHUD.showError("Sorry, the end time for a CollabBlock can't be before it's start time")
        }
            //If end time is before the start time
        else if (selectedEndHour == selectedStartHour) && (Int(selectedEndMinute)! < Int(selectedStartMinute)!) {
            ProgressHUD.showError("Sorry, the end time for a CollabBlock can't be before it's start time")
        }
            //This code block is reached only if the CollabBlock passed all other tests
        else {
            
            //If the user is creating a new TimeBlock, call "calcValidTimeBlock" without entering a "blockID" showing that a block isn't being updated
            if selectedView == "Add" {
                
                getFirebaseBlocks {
                    self.calcValidCollabBlock()
                    
                    //If statements that check if the CollabBlock failed any tests in the "calcValidCollabBlock" function
                    if self.validCollabBlock["startTimeValidation"] == false {
                        ProgressHUD.showError("The starting time of this TimeBlock conflicts with another")
                    }
                    else if self.validCollabBlock["endTimeValidation"] == false {
                        ProgressHUD.showError("The ending time of this TimeBlock conflicts with another")
                    }
                    else if self.validCollabBlock["rangeValidation"] == false {
                        ProgressHUD.showError("This TimeBlock conflicts with another")
                    }
                        
                        //AYEEEE IT PASSED ALL THE TESTS
                    else {
                        
                        self.scheduleNotification()
                        self.add_editCollabBlock2()
                        
                    }
                }
            }
                //If the user is updating a TimeBlock, call "calcValidTimeBlock" entering a "blockID" showing that a block is being updated
            else if selectedView == "Edit" {
                
                //If the user is creating a new TimeBlock, call "calcValidTimeBlock" without entering a "blockID" showing that a block isn't being updated
                
                guard let block = selectedBlock else { return }
                
                getFirebaseBlocks {
                    self.calcValidCollabBlock(block.blockID)
                    
                    print(self.validCollabBlock)
                    
                    //If statements that check if the TimeBlock failed any tests in the "calcValidTimeBlock" function
                    if self.validCollabBlock["startTimeValidation"] == false {
                        ProgressHUD.showError("The starting time of this TimeBlock conflicts with another")
                    }
                    else if self.validCollabBlock["endTimeValidation"] == false {
                        ProgressHUD.showError("The ending time of this TimeBlock conflicts with another")
                    }
                    else if self.validCollabBlock["rangeValidation"] == false {
                        ProgressHUD.showError("This TimeBlock conflicts with another")
                    }
                        
                        //AYEEEE IT PASSED ALL THE TESTS, GO AHEAD AND ADD THAT SHIT
                    else {
                        
                        self.scheduleNotification()
                        self.add_editCollabBlock2()
                        
                    }
                }
                
            }
            
        }
    }
    
    func add_editCollabBlock2 () {

        if notificationSwitch.isOn {
            
            notificationSettings = [currentUser.userID : ["notificationID" : notificationID as Any, "scheduled" : true, "minsBefore" : notificationIndex as Any]]
        }
        
        else {
            
            notificationSettings = [currentUser.userID : ["notificationID" : "" as Any, "scheduled" : false, "minsBefore" : 0 as Any]]
        }
        
        //If this is the "CreateBlockView", create a new CollabBlock
        if selectedView == "Add" {
            
            let blockID = UUID().uuidString
            
            let newBlock: [String : Any] = ["creator" : ["userID" : currentUser.userID, "firstName" : currentUser.firstName, "lastName" : currentUser.lastName], "blockID" : blockID, "name" : blockNameTextField.text!, "startHour" : selectedStartHour, "startMinute" : selectedStartMinute, "startPeriod" : selectedStartPeriod, "endHour" : selectedEndHour, "endMinute" : selectedEndMinute, "endPeriod" : selectedEndPeriod, "blockCategory" : selectedCategory, "notificationSettings" : notificationSettings]
            
            db.collection("Collaborations").document(collabID).collection("CollabBlocks").document(blockID).setData(newBlock) { (error) in
                
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                }
                else {
                    //ProgressHUD.showSuccess("CollabBlock created!")
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
        
        else if selectedView == "Edit" {
            
            let updatedBlock: [String : Any] = ["name" : blockNameTextField.text!, "startHour" : selectedStartHour, "startMinute" : selectedStartMinute, "startPeriod" : selectedStartPeriod, "endHour" : selectedEndHour, "endMinute" : selectedEndMinute, "endPeriod" : selectedEndPeriod, "blockCategory" : selectedCategory, "notificationSettings" : notificationSettings]
            
            guard let block = selectedBlock else { return }
            
            db.collection("Collaborations").document(collabID).collection("CollabBlocks").document(block.blockID).getDocument { (snapshot, error) in
                
                if error != nil {
                    ProgressHUD.showError("Sorry, an error occured while updating this CollabBlock")
                    self.navigationController?.popViewController(animated: true)
                }
                
                else {
                    
                    if snapshot?.data() == nil {
                        
                        ProgressHUD.showError("Sorry, this CollabBlock has been deleted by your collaborator")
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    else {
                        
                        self.db.collection("Collaborations").document(self.collabID).collection("CollabBlocks").document(block.blockID).setData(updatedBlock, merge: true) { (error) in
                            
                            if error != nil {
                                ProgressHUD.showError(error?.localizedDescription)
                            }
                            else {
                                //ProgressHUD.showSuccess("CollabBlock Updated!")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    @objc func dismissKeyboard () {
        
        view.endEditing(true)
        
        self.view.layoutIfNeeded()
        timeContainerTopAnchor.constant = 500
        categoryContainerTopAnchor.constant = 500
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()

        }
        //categoryPicker.selectRow(0, inComponent: 0, animated: true)
    }
}
