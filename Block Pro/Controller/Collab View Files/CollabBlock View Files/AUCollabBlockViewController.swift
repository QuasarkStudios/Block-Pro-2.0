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
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var timePickerContainer: UIView!
    @IBOutlet weak var categoryPickerContainer: UIView!
    
    let db = Firestore.firestore()
    
    let formatter = DateFormatter()
    
    var collabID: String = ""
    
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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        navigationItem.title = "Add Collab Block"
        
        blockContainer.backgroundColor = UIColor(hexString: "#EFEFF4")
        blockContainer.layer.cornerRadius = 0.05 * blockContainer.bounds.size.width
        blockContainer.clipsToBounds = true
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
    
    
    func add_updateCollabBlock () {
        
        let blockID = UUID().uuidString
        
        let newBlock: [String : String] = ["blockID" : blockID, "notificationID" : "", "name" : blockNameTextField.text!, "startHour" : selectedStartHour, "startMinute" : selectedStartMinute, "startPeriod" : selectedStartPeriod, "endHour" : selectedEndHour, "endMinute" : selectedEndMinute, "endPeriod" : selectedEndPeriod, "blockCategory" : selectedCategory]
        
        db.collection("Collaborations").document(collabID).collection("CollabBlocks").document(blockID).setData(newBlock)
        
    }

    @IBAction func create_editButtonPressed(_ sender: Any) {
        
        add_updateCollabBlock()
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
