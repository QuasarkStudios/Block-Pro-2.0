//
//  ConvoNameInfoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/16/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol ConvoNameEnteredProtocol: AnyObject {
    
    func convoNameEntered (name: String)
}

class ConvoNameInfoCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var nameTextFieldContainer: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    
    var personalConversation: Conversation? {
        didSet {
            
            if let name = personalConversation?.conversationName {
                
                nameTextField.text = name
                nameTextField.textAlignment = .center
                nameTextField.isUserInteractionEnabled = true
            }
        }
    }
    
    var collabConversation: Conversation? {
        didSet {
            
            if let name = collabConversation?.conversationName {
                
                nameTextField.text = name
                nameTextField.textAlignment = .center
                nameTextField.isUserInteractionEnabled = false
            }
        }
    }
    
    weak var nameEnteredDelegate: ConvoNameEnteredProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        nameTextFieldContainer.backgroundColor = .white
        nameTextFieldContainer.layer.cornerRadius = 18
        nameTextFieldContainer.clipsToBounds = true
        nameTextFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        nameTextFieldContainer.layer.borderWidth = 1
        
        if #available(iOS 13.0, *) {
            nameTextFieldContainer.layer.cornerCurve = .continuous
        }
        
        nameTextField.delegate = self
        nameTextField.borderStyle = .none
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        nameTextField.textAlignment = .left
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        nameTextField.textAlignment = .center
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        nameTextField.endEditing(true)
        return true
    }
    
    
    @IBAction func nameTextChanged(_ sender: Any) {
        
        nameEnteredDelegate?.convoNameEntered(name: nameTextField.text!)
    }
}
