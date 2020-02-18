//
//  AddUpdateBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift

class AddEditBlockViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var addEditButton: UIBarButtonItem!
    
    
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var beginsTextField: UITextField!
    @IBOutlet weak var endsTextField: UITextField!
    
    var timePicker: UIDatePicker = UIDatePicker()
    var timePickerBackground: UIView = UIView()
    
    lazy var realm = try! Realm()
    var currentDateObject: TimeBlocksDate?
    
    let formatter = DateFormatter()
    
    var currentDate: Date?
    
    var blockName: String = ""
    var blockCategory: String = ""
    var blockBegins: Date? //HH:mm - 24 hour format; h:mm a - 12 hour format
    var blockEnds: Date?
    
    var tag: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear  //.view.backgroundColor = .clear
        
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 18)!]

        blockView.backgroundColor = UIColor.flatBlue().withAlphaComponent(0.85)
        blockView.layer.cornerRadius = 10
        
        timeLabel.addCharacterSpacing(kernValue: 1.38)
        
        nameTextField.delegate = self
        categoryTextField.delegate = self
        beginsTextField.delegate = self
        endsTextField.delegate = self
        
        nameTextField.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.3)
        
        categoryTextField.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.3)
        categoryTextField.inputView = UIView()
        
        beginsTextField.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.3)
        beginsTextField.inputView = UIView()
        
        endsTextField.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.3)
        endsTextField.inputView = UIView()
        
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 5
        timePicker.addTarget(self, action: #selector(timeSelected(timePicker:)), for: .allEvents)
        //timeSelected(timePicker: timePicker)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == nameTextField {
            
            //guard let picker = timePicker else { return }

        }
        
        else if textField == categoryTextField {
            
            nameTextField.endEditing(true)
            
            
            
            presentTimePicker()
            
        }
        
        else if textField == beginsTextField {
            
            nameTextField.endEditing(true)
            
            tag = "begins"
            
            presentTimePicker()
        }
        
        else if textField == endsTextField {
            
            nameTextField.endEditing(true)
            
            tag = "ends"
            
            presentTimePicker()
        }
        
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//        if textField == nameTextField {
//
//            blockName = textField.text!
//        }
//
//        else if textField == categoryTextField {
//
//            blockCategory = textField.text!
//        }
//
//        else if textField == beginsTextField {
//
//
//            blockBegins = textField.text!
//        }
//
//        else {
//
//            blockEnds = textField.text!
//        }
//    }
    
    func presentTimePicker () {
        
        timePickerBackground.frame = CGRect(x: 0, y: endsTextField.frame.maxY + 25, width: view.frame.width, height: 0)
        timePickerBackground.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.3)
        
        timePicker.frame = CGRect(x: 10, y: 0, width: timePickerBackground.frame.width - 10, height: 0)
        
        view.addSubview(timePickerBackground)
        timePickerBackground.addSubview(timePicker)
        
        UIView.animate(withDuration: 0.5) {
            
            self.timePickerBackground.frame = CGRect(x: 0, y: self.endsTextField.frame.maxY + 25, width: self.view.frame.width, height: 200)
            self.timePicker.frame = CGRect(x: 10, y: 0, width: self.timePickerBackground.frame.width - 10, height: 200)
            
        }
        
    }
    
    @objc func timeSelected (timePicker: UIDatePicker) {
        
        //"MM-dd-yyyy HH:mm"
        
        
        if tag == "begins" {
            
            var date: String = ""
            
            formatter.dateFormat = "MM-dd-yyyy "
            date = formatter.string(from: currentDate!)
            
            formatter.dateFormat = "HH:mm"
            date += formatter.string(from: timePicker.date)
            
            formatter.dateFormat = "MM-dd-yyyy HH:mm"
            blockBegins = formatter.date(from: date)
            
            formatter.dateFormat = "h:mm a"
            beginsTextField.text = formatter.string(from: timePicker.date)
            
        }
        
        else if tag == "ends" {
            
            var date: String = ""
            
            formatter.dateFormat = "MM-dd-yyyy "
            date = formatter.string(from: currentDate!)
            
            formatter.dateFormat = "HH:mm"
            date += formatter.string(from: timePicker.date)
            
            formatter.dateFormat = "MM-dd-yyyy HH:mm"
            blockEnds = formatter.date(from: date)
            
            formatter.dateFormat = "h:mm a"
            endsTextField.text = formatter.string(from: timePicker.date)
        }
    
    }
    
    @objc func dismissKeyboard () {
        
        nameTextField.endEditing(true)
        categoryTextField.endEditing(true)
        beginsTextField.endEditing(true)
        endsTextField.endEditing(true)
        
    }
    
    
    @IBAction func addEditButton(_ sender: Any) {
        
        let newBlock = Block()
        
        newBlock.name = nameTextField.text!
        
        newBlock.begins = blockBegins!
        newBlock.ends = blockEnds!
        
        newBlock.category = categoryTextField.text!
        
        do {
            
            try realm.write {
                
                print("block saved")
                currentDateObject?.timeBlocks.append(newBlock)
            }
        } catch {
            print("Error adding block \(error)")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}

extension UILabel {
    
    func addCharacterSpacing(kernValue: Double = 1.15) {

        if let labelText = text, labelText.count > 0 {

            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
