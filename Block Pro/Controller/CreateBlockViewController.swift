//
//  CreateBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/29/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift

class CreateBlockViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    let realm = try! Realm()
    var blocks: Results<Block>?
    
    @IBOutlet weak var blockNameTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var note1TextView: UITextView!
    
    @IBOutlet weak var timePicker: UIPickerView!
    
    let hours: [String] = [" ", "12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    let minutes: [String] = [" ", "00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    let timePeriods: [String] = [" ", "AM", "PM"]
    
    var tag: String = ""
    
    var userSelectedStartHour: String = ""
    var userSelectedStartMinute: String = ""
    var userSelectedStartPeriod: String = ""
    
    var userSelectedEndHour: String = ""
    var userSelectedEndMinute: String = ""
    var userSelectedEndPeriod: String = ""
    
    let amDictionaries: [String : String] = ["12" : "0", "1" : "1", "2" : "2", "3" : "3", "4" : "4", "5" : "5", "6" : "6", "7" : "7", "8" : "8", "9" : "9", "10" : "10", "11" : "11"]
    let pmDictionaries: [String : String] = ["12" : "12", "1" : "13", "2" : "14", "3" : "15", "4" : "16", "5" : "17", "6" : "18", "7" : "19", "8" : "20", "9" : "21", "10" : "22", "11" : "23"]
    
    var bufferStartHour: Int = 0
    var bufferStartMinute: Int = 0
    var bufferStartPeriod: Int = 0
    
    var bufferEndHour: Int = 0
    var bufferEndMinute: Int = 0
    var bufferEndPeriod: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        blockNameTextField.delegate = self
        startTimeTextField.delegate = self
        endTimeTextField.delegate = self
        
        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.frame.origin.y = 700
        
        //blockNameTextField.inputView = UIView()
        startTimeTextField.inputView = UIView()
        endTimeTextField.inputView = UIView()
        
        note1TextView.layer.cornerRadius = 0.05 * note1TextView.bounds.size.width
        note1TextView.clipsToBounds = true
        
        blocks = realm.objects(Block.self)
    }
    
    
    //MARK: - PickerView DataSource Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
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
    
    
    //MARK: - TextView Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == blockNameTextField {
            
            UIView.animate(withDuration: 0.2) {
                
                self.timePicker.frame.origin.y = 700
            }
            
            timePicker.selectRow(0, inComponent: 0, animated: true)
            timePicker.selectRow(0, inComponent: 1, animated: true)
            timePicker.selectRow(0, inComponent: 2, animated: true)
        }
            
        else if textField == startTimeTextField {
            
            tag = "start"
            UIView.animate(withDuration: 0.2) {
                
                self.timePicker.frame.origin.y = 450
            }
            
            timePicker.selectRow(0, inComponent: 0, animated: true)
            timePicker.selectRow(0, inComponent: 1, animated: true)
            timePicker.selectRow(0, inComponent: 2, animated: true)
        }
            
        else if textField == endTimeTextField {
            
            tag = "end"
            UIView.animate(withDuration: 0.2) {
                
                self.timePicker.frame.origin.y = 450
            }
            
            timePicker.selectRow(0, inComponent: 0, animated: true)
            timePicker.selectRow(0, inComponent: 1, animated: true)
            timePicker.selectRow(0, inComponent: 2, animated: true)
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == startTimeTextField {
            startTimeTextField.text = ("\(userSelectedStartHour):" + "\(userSelectedStartMinute) " + userSelectedStartPeriod)
        }
            
        else if textField == endTimeTextField {
            endTimeTextField.text = ("\(userSelectedEndHour):" + "\(userSelectedEndMinute) " + userSelectedEndPeriod)
        }
    }
    
    
    //MARK: - PickerView Delegate Method
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 && tag == "start" {
            userSelectedStartHour = hours[row]
            print(userSelectedStartHour)
        }
        else if component == 0 && tag == "end" {
            userSelectedEndHour = hours[row]
        }
        
        if component == 1 && tag == "start" {
            userSelectedStartMinute = minutes[row]
        }
        else if component == 1 && tag == "end" {
            userSelectedEndMinute = minutes[row]
        }
        
        if component == 2 && tag == "start" {
            userSelectedStartPeriod = timePeriods[row]
        }
        else if component == 2 && tag == "end" {
            userSelectedEndPeriod = timePeriods[row]
        }
        print ("userSelectedStartTime = \(userSelectedStartHour)" + "\(userSelectedStartMinute)" + userSelectedStartPeriod)
        print ("userSelectedEndTime = \(userSelectedEndHour)" + "\(userSelectedEndMinute)" + userSelectedEndPeriod )
        
    }
    
    
    func configureBufferBlocks () {
        
        let timeBlockViewObject = TimeBlockViewController()
        
        var sortedBlocks = timeBlockViewObject.sortBlockResults()
        
        for timeBlocks in sortedBlocks {
            
            if (bufferStartHour == Int(timeBlocks.value.startHour)!) && (bufferStartMinute == Int(timeBlocks.value.startMinute)!) && (bufferStartPeriod == Int(timeBlocks.value.startPeriod)!) {
                
                bufferStartMinute += 5
                
                if bufferStartMinute == 60 {
                    
                    bufferStartHour += 1
                    bufferStartMinute = 0
                }
            }
        }
        
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func createPressed(_ sender: Any) {
        
        let newBlock = Block()
        
        newBlock.name = blockNameTextField.text!
        
        newBlock.startHour = userSelectedStartHour
        newBlock.startMinute = userSelectedStartMinute
        newBlock.startPeriod = userSelectedStartPeriod
        
        newBlock.endHour = userSelectedEndHour
        newBlock.endMinute = userSelectedEndMinute
        newBlock.endPeriod = userSelectedEndPeriod
        
        do {
            try realm.write {
                realm.add(newBlock)
                }
            } catch {
                print ("Error adding a new block \(error)")
            }
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
