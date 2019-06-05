//
//  AddBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/22/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class AddBlockViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    let blockView = UIView()
    
    let blockTitleLabel = UILabel()
    let blockStartLabel = UILabel()
    let blockEndLabel = UILabel()
    
    let createBlockButton = UIButton()
    
    let textField = UITextField ()
    let pickerView = UIPickerView()

    let hours: [String] = [" ", "Hour", "12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    let minutes: [String] = [" ", "00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    let timePeriods: [String] = [" ", "AM", "PM"]
    
    
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
    
    
    func createTextField (xCord: CGFloat, yCord: CGFloat, width: CGFloat, height: CGFloat, placeholderText: String, keyboard: String) -> UITextField {
        
        let textField = UITextField(frame: CGRect(x: xCord, y: yCord, width: width, height: height))
        
        textField.placeholder = placeholderText
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center

        
        switch keyboard {
        case "default":
            textField.keyboardType = UIKeyboardType.default
        case "number":
            textField.keyboardType = UIKeyboardType.numberPad
        case "picker":
            textField.inputView = UIView()
        default:
            textField.keyboardType = UIKeyboardType.default
        }
        
        return textField
    }
    
    func createPickerView (/*xCord: CGFloat, yCord: CGFloat, width: CGFloat, height: CGFloat*/) -> UIPickerView {
        
        let pickerView = UIPickerView(frame: CGRect(x: 37.5, y: 950, width: 300, height: 180))

        pickerView.backgroundColor = UIColor.white
        
        return pickerView
    }
    
    @objc func createBlockButtonPressed () {
        
    }
    
    
    func createNewBlockView () -> UIView  {
        
        
        blockView.frame = CGRect(x: 12.5, y: 1200, width: 350, height: 200)
        blockView.backgroundColor = UIColor.blue
        blockView.layer.cornerRadius = 0.05 * blockView.bounds.size.width
        blockView.clipsToBounds = true
        
        blockTitleLabel.frame = CGRect(x: 22, y: 5, width: 255, height: 30)
        blockTitleLabel.text = "Enter the title of your TimeBlock below: "
        blockTitleLabel.font = UIFont(name: "Helvetica Neue", size: 20)
        blockTitleLabel.adjustsFontSizeToFitWidth = true
        blockTitleLabel.textColor = UIColor.white
        
        blockStartLabel.frame = CGRect(x: 22, y: 80, width: 70, height: 30)
        blockStartLabel.text = "Start time:"
        blockStartLabel.font = UIFont(name: "Helvetica Neue", size: 20)
        blockStartLabel.adjustsFontSizeToFitWidth = true
        blockStartLabel.textColor = UIColor.white
        
        blockEndLabel.frame = CGRect(x: 252, y: 80, width: 70, height: 30)
        blockEndLabel.text = "End time:"
        blockEndLabel.font = UIFont(name: "Helvetica Neue", size: 20)
        blockEndLabel.adjustsFontSizeToFitWidth = true
        blockEndLabel.textColor = UIColor.white
        
        createBlockButton.setTitle("Create Block", for: .normal)
        createBlockButton.backgroundColor = UIColor.gray
        createBlockButton.setTitleColor(UIColor.white, for: .normal)
        createBlockButton.frame = CGRect(x: 17, y: 950, width: 350, height: 40)
        createBlockButton.addTarget(self, action: #selector(self.createBlockButtonPressed), for: .touchUpInside)
        
        return blockView
    }
    
    
}
