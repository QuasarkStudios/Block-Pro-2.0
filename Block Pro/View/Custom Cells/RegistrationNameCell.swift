//
//  RegistrationNameCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/27/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol NameEntered: AnyObject {
    
    func firstNameEntered (firstName: String)
    
    func lastNameEntered (lastName: String)
}

class RegistrationNameCell: UICollectionViewCell, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    
    weak var nameEnteredDelegate: NameEntered?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        firstNameErrorLabel.adjustsFontSizeToFitWidth = true
        lastNameErrorLabel.adjustsFontSizeToFitWidth = true
        
        firstNameErrorLabel.isHidden = true
        lastNameErrorLabel.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func firstNameTextChanged(_ sender: Any) {
        
        firstNameErrorLabel.isHidden = true
        
        nameEnteredDelegate?.firstNameEntered(firstName: firstNameTextField.text!)
    }
    
    @IBAction func lastNameTextChanged(_ sender: Any) {
        
        lastNameErrorLabel.isHidden = true
        
        nameEnteredDelegate?.lastNameEntered(lastName: lastNameTextField.text!)
    }
}
