//
//  BlockSettingCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/3/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol TextEdits {
    
    func textBeganEditing ()
    
    func textEdited (_ text: String)
}

class BlockNameSettingCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    var textEditsDelegate: TextEdits?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameTextField.delegate = self
        
        nameTextField.borderStyle = .none
        nameTextField.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.35)
        
        nameTextField.layer.cornerRadius = 6
        nameTextField.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textEditsDelegate?.textBeganEditing()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textEditsDelegate?.textEdited(textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
}
