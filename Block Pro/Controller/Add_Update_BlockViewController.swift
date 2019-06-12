//
//  CreateBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/29/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift

class Add_Update_BlockViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    let realm = try! Realm()
    var realmData: Results<Block>?
    
    @IBOutlet weak var blockNameTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var note1TextView: UITextView!
    @IBOutlet weak var note2TextView: UITextView!
    @IBOutlet weak var note3TextView: UITextView!
    
    @IBOutlet weak var timePicker: UIPickerView!
    
    @IBOutlet weak var create_edit_blockButton: UIButton!
    
    let amDictionaries: [String : String] = ["12" : "0", "1" : "1", "2" : "2", "3" : "3", "4" : "4", "5" : "5", "6" : "6", "7" : "7", "8" : "8", "9" : "9", "10" : "10", "11" : "11"]
    let pmDictionaries: [String : String] = ["12" : "12", "1" : "13", "2" : "14", "3" : "15", "4" : "16", "5" : "17", "6" : "18", "7" : "19", "8" : "20", "9" : "21", "10" : "22", "11" : "23"]
    
    let hours: [String] = [" ", "12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    let minutes: [String] = [" ", "00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    let timePeriods: [String] = [" ", "AM", "PM"]
    
    var tag: String = ""
    
    var selectedStartHour: String = ""
    var selectedStartMinute: String = ""
    var selectedStartPeriod: String = ""
    
    var selectedEndHour: String = ""
    var selectedEndMinute: String = ""
    var selectedEndPeriod: String = ""
    
    var bigBlockData = (blockName: "", blockStartHour: "", blockStartMinute: "", blockStartPeriod: "", blockEndHour: "", blockEndMinute: "", blockEndPeriod: "", note1: "", note2: "", note3: "")
    
    var blockID: String = ""
    
    var invalidTimeRanges = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        blockNameTextField.delegate = self
        startTimeTextField.delegate = self
        endTimeTextField.delegate = self
        
        note1TextView.delegate = self
        note2TextView.delegate = self
        note3TextView.delegate = self
        
        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.frame.origin.y = 700
        
        //blockNameTextField.inputView = UIView()
        startTimeTextField.inputView = UIView()
        endTimeTextField.inputView = UIView()
        
        note1TextView.layer.cornerRadius = 0.05 * note1TextView.bounds.size.width
        note1TextView.clipsToBounds = true
        
        note2TextView.layer.cornerRadius = 0.05 * note2TextView.bounds.size.width
        note2TextView.clipsToBounds = true

        note3TextView.layer.cornerRadius = 0.05 * note3TextView.bounds.size.width
        note3TextView.clipsToBounds = true

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        configureEditView()
        
        //calcInvalidTimeRanges()
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
    
    
    //MARK: - TextField Delegate Methods
    
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
        
        print ("userSelectedStartTime = \(selectedStartHour)" + "\(selectedStartMinute)" + selectedStartPeriod)
        print ("userSelectedEndTime = \(selectedEndHour)" + "\(selectedEndMinute)" + selectedEndPeriod )
        
    }
    
    func convertTo24Hour (_ funcStartHour: String, _ funcStartPeriod: String, _ funcEndHour: String, _ funcEndPeriod: String) {
        
        if funcStartHour == "12" && funcStartPeriod == "AM" {
            selectedStartHour = "0"
        }
        
        if funcStartPeriod == "PM" && funcStartHour != "12" {
            selectedStartHour = "\(Int(funcStartHour)! + 12)"
        }
        
        if funcEndPeriod == "PM" && funcEndPeriod != "12" {
            selectedEndHour = "\(Int(funcEndHour)! + 12)"
        }
    }
    
    func configureEditView () {
        
        guard let bigBlockData = realm.object(ofType: Block.self, forPrimaryKey: blockID) else { return }
        
            blockNameTextField.text = bigBlockData.name
            startTimeTextField.text = convertTo12Hour(bigBlockData.startHour, bigBlockData.startMinute)
            endTimeTextField.text = convertTo12Hour(bigBlockData.endHour, bigBlockData.endMinute)
        
            note1TextView.text = bigBlockData.note1
            note2TextView.text = bigBlockData.note2
            note3TextView.text = bigBlockData.note3
        
            create_edit_blockButton.setTitle("Edit", for: .normal)
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
            return "YOU GOT IT WRONG BEYOTCH"
        }
    }
    
    func calcInvalidTimeRanges () {
        
        realmData = realm.objects(Block.self)

        for blocks in realmData! {
            
            var incremStartHour = blocks.startHour
            var incremStartMinute = blocks.startMinute
            var incremStartPeriod = blocks.startPeriod
            
            let incremStartTime = blocks.startHour + blocks.startMinute + blocks.startPeriod
            let blockStartTime = blocks.startHour + blocks.startMinute + blocks.startPeriod
            let blockEndTime = blocks.endHour + blocks.endMinute + blocks.endPeriod
            
            invalidTimeRanges.append([blockStartTime])
            print(invalidTimeRanges)
            while incremStartTime != blockEndTime {

                incremStartMinute = "\(Int(incremStartMinute)! + 5)"

                if incremStartMinute == "60" && incremStartHour == "12" {


                }
            }
            
            
            
        }
    }

    
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func create_edit_ButtonPressed(_ sender: Any) {
        
        convertTo24Hour(selectedStartHour, selectedStartPeriod, selectedEndHour, selectedEndPeriod)
        
        print (selectedStartHour)
        print (selectedEndHour)
        
        if create_edit_blockButton.titleLabel?.text == "Create" {
        
            let newBlock = Block()
            
            newBlock.name = blockNameTextField.text!
            
            newBlock.startHour = selectedStartHour
            newBlock.startMinute = selectedStartMinute
            newBlock.startPeriod = selectedStartPeriod
            
            newBlock.endHour = selectedEndHour
            newBlock.endMinute = selectedEndMinute
            newBlock.endPeriod = selectedEndPeriod
            
            newBlock.note1 = note1TextView.text
            newBlock.note2 = note2TextView.text
            newBlock.note3 = note3TextView.text
            
            do {
                try realm.write {
                    realm.add(newBlock)
                }
            } catch {
                print ("Error adding a new block \(error)")
            }
        }
        
        else if create_edit_blockButton.titleLabel?.text == "Edit" {
        print("cool")
            let updatedBlock = Block()
            
            //realmData = realm.objects(Block.self)
            
            updatedBlock.blockID = blockID
            
            updatedBlock.name = blockNameTextField.text!
            
            updatedBlock.startHour = selectedStartHour
            updatedBlock.startMinute = selectedStartMinute
            updatedBlock.startPeriod = selectedStartPeriod

            updatedBlock.endHour = selectedEndHour
            updatedBlock.endMinute = selectedEndMinute
            updatedBlock.endPeriod = selectedEndPeriod

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
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard () {
        
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.2) {
            
            self.timePicker.frame.origin.y = 700
        }
        
        timePicker.selectRow(0, inComponent: 0, animated: true)
        timePicker.selectRow(0, inComponent: 1, animated: true)
        timePicker.selectRow(0, inComponent: 2, animated: true)
    
    }
    
}
