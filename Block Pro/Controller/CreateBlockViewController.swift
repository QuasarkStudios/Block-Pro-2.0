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
    
//    var bufferStartHour: Int = 0
//    var bufferStartMinute: Int = 0
//    var bufferStartPeriod: String = "AM"
//
//    var bufferEndHour: Int = 0
//    var bufferEndMinute: Int = 0
//    var bufferEndPeriod: String = "AM"

    var bufferTuple = (bufferName: "Buffer Block", bufferStartHour: 0, bufferStartMinute: 0, bufferStartPeriod: "AM", bufferEndHour: 0, bufferEndMinute: 0, bufferEndPeriod: "AM")
    
    var blockArray: [(bufferName: String, bufferStartHour: Int, bufferStartMinute: Int, bufferStartPeriod: String, bufferEndHour: Int, bufferEndMinute: Int, bufferEndPeriod: String)] = []
    
    
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
        
        //print(blocks)
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
        let sortedBlocks = timeBlockViewObject.sortBlockResults()
        var count: Int = 0
        
        while count < sortedBlocks.count {
            
            if sortedBlocks[count].value.startPeriod == "AM" && sortedBlocks[count].value.endPeriod == "AM" {
                
                if count == 0 {
                    
                    bufferTuple.bufferEndHour = Int(amDictionaries[sortedBlocks[count].value.startHour]!)!
                    bufferTuple.bufferEndMinute = Int(sortedBlocks[count].value.startMinute)!
                    bufferTuple.bufferEndPeriod = sortedBlocks[count].value.startPeriod
                    
                    //bufferArray.append(bufferTuple)
                    
                    if ((count + 1) < sortedBlocks.count) && (sortedBlocks[count].value.endPeriod == "AM" && sortedBlocks[count + 1].value.startPeriod == "AM") {
                        
                        bufferTuple.bufferStartHour = Int(amDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                        
                        bufferTuple.bufferEndHour = Int(amDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                        
                    }
                    
                    else if ((count + 1) < sortedBlocks.count) && (sortedBlocks[count].value.endPeriod == "AM" && sortedBlocks[count + 1].value.startPeriod == "PM") {
                        
                        bufferTuple.bufferStartHour = Int(amDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                        
                        bufferTuple.bufferEndHour = Int(pmDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                    
                    else if ((count + 1) < sortedBlocks.count) && (sortedBlocks[count].value.endPeriod == "PM" && sortedBlocks[count + 1].value.startPeriod == "PM") {
                        
                        bufferTuple.bufferStartHour = Int(pmDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                        
                        bufferTuple.bufferEndHour = Int(pmDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                    
                }
                
                else {
                    
                    bufferTuple.bufferStartHour = Int(amDictionaries[sortedBlocks[count].value.endHour]!)!
                    bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                    bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                    
                    if (count + 1) < sortedBlocks.count {
                        
                        bufferTuple.bufferEndHour = Int(amDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                    
                    else {
                        
                        bufferTuple.bufferEndHour = Int(amDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count].value.endPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                }
            }
            
            else if sortedBlocks[count].value.startPeriod == "AM" && sortedBlocks[count].value.endPeriod == "PM" {
            
                if count == 0 {
                    
                    bufferTuple.bufferEndHour = Int(amDictionaries[sortedBlocks[count].value.startHour]!)!
                    bufferTuple.bufferEndMinute = Int(sortedBlocks[count].value.startMinute)!
                    bufferTuple.bufferEndPeriod = sortedBlocks[count].value.startPeriod
                    
                    //bufferArray.append(bufferTuple)
                    
                    if ((count + 1) < sortedBlocks.count) && (sortedBlocks[count].value.endPeriod == "AM" && sortedBlocks[count + 1].value.startPeriod == "AM") {
                        
                        bufferTuple.bufferStartHour = Int(amDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                        
                        bufferTuple.bufferEndHour = Int(amDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                        
                    }
                        
                    else if ((count + 1) < sortedBlocks.count) && (sortedBlocks[count].value.endPeriod == "AM" && sortedBlocks[count + 1].value.startPeriod == "PM") {
                        
                        bufferTuple.bufferStartHour = Int(amDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                        
                        bufferTuple.bufferEndHour = Int(pmDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                        
                    else if ((count + 1) < sortedBlocks.count) && (sortedBlocks[count].value.endPeriod == "PM" && sortedBlocks[count + 1].value.startPeriod == "PM") {
                        
                        bufferTuple.bufferStartHour = Int(pmDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                        
                        bufferTuple.bufferEndHour = Int(pmDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                }
                    
                else {
                    print ("check1", count)
                    bufferTuple.bufferStartHour = Int(pmDictionaries[sortedBlocks[count].value.endHour]!)!
                    bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                    bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                    
                    if (count + 1) < sortedBlocks.count {
                        
                        bufferTuple.bufferEndHour = Int(pmDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                        
                    else {
                        
                        bufferTuple.bufferEndHour = Int(pmDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count].value.endPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                }
            }
            
                
            else if sortedBlocks[count].value.startPeriod == "PM" && sortedBlocks[count].value.endPeriod == "PM" {
                print("PMcheck")
                if count == 0 {
                    
                    bufferTuple.bufferEndHour = Int(pmDictionaries[sortedBlocks[count].value.startHour]!)!
                    bufferTuple.bufferEndMinute = Int(sortedBlocks[count].value.startMinute)!
                    bufferTuple.bufferEndPeriod = sortedBlocks[count].value.startPeriod
                    
                    //bufferArray.append(bufferTuple)
                    
                    if ((count + 1) < sortedBlocks.count) && (sortedBlocks[count].value.endPeriod == "AM" && sortedBlocks[count + 1].value.startPeriod == "AM") {
                        
                        bufferTuple.bufferStartHour = Int(amDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                        
                        bufferTuple.bufferEndHour = Int(amDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                        
                    }
                        
                    else if ((count + 1) < sortedBlocks.count) && (sortedBlocks[count].value.endPeriod == "AM" && sortedBlocks[count + 1].value.startPeriod == "PM") {
                        
                        bufferTuple.bufferStartHour = Int(amDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                        
                        bufferTuple.bufferEndHour = Int(pmDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                        
                    else if ((count + 1) < sortedBlocks.count) && (sortedBlocks[count].value.endPeriod == "PM" && sortedBlocks[count + 1].value.startPeriod == "PM") {
                        
                        bufferTuple.bufferStartHour = Int(pmDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                        
                        bufferTuple.bufferEndHour = Int(pmDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                }
                    
                else {
                    print ("check2", count)
                    bufferTuple.bufferStartHour = Int(pmDictionaries[sortedBlocks[count].value.endHour]!)!
                    bufferTuple.bufferStartMinute = Int(sortedBlocks[count].value.endMinute)!
                    bufferTuple.bufferStartPeriod = sortedBlocks[count].value.endPeriod
                    
                    if (count + 1) < sortedBlocks.count {
                        
                        bufferTuple.bufferEndHour = Int(pmDictionaries[sortedBlocks[count + 1].value.startHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count + 1].value.startMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count + 1].value.startPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                        
                    else {
                        
                        bufferTuple.bufferEndHour = Int(pmDictionaries[sortedBlocks[count].value.endHour]!)!
                        bufferTuple.bufferEndMinute = Int(sortedBlocks[count].value.endMinute)!
                        bufferTuple.bufferEndPeriod = sortedBlocks[count].value.endPeriod
                        
                        //bufferArray.append(bufferTuple)
                    }
                }
            }
            
            
            //  MOVE ALL BUFFERARRAY.APPEND TO THE BOTTOM BEFORE COUNT INCREMENT; ONLY PLACE IT SHOULD BE NECCASARY
            // CREATE A FUNC THAT SAVES BUFFER DATA TO REALM EACH ITERATION OF THE WHILE LOOP
            
            blockArray.append(bufferTuple)
            
            print (count,":", blockArray[count])
            
           
            
            count += 1
            
            
            
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
        
//        blockArray.append((bufferName: newBlock.name, bufferStartHour: newBlock.startHour, bufferStartMinute: newBlock.startMinute, bufferStartPeriod: newBlock.startPeriod = userSelectedStartPeriod, bufferEndHour: newBlock.endHour, bufferEndMinute: newBlock.endMinute, bufferEndPeriod: newBlock.endPeriod))
        
        do {
            try realm.write {
                realm.add(newBlock)
            }
        } catch {
            print ("Error adding a new block \(error)")
        }
        
        configureBufferBlocks()
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
