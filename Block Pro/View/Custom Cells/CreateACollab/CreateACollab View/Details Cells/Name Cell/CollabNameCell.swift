//
//  CollabNameCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol CollabNameEntered: AnyObject {
    
    func nameEntered (_ name: String)
}

class CollabNameCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var collabNameTextField: UITextField!
    
    weak var collabNameEnteredDelegate: CollabNameEntered?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureTextField()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureTextField () {
        
        textFieldContainer.layer.borderWidth = 1
        textFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        textFieldContainer.layer.cornerRadius = 10
        textFieldContainer.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            textFieldContainer.layer.cornerCurve = .continuous
        }

        collabNameTextField.delegate = self
        
        collabNameTextField.borderStyle = .none
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func textChanged(_ sender: Any) {
        
        collabNameEnteredDelegate?.nameEntered(collabNameTextField.text!)
    }
}
