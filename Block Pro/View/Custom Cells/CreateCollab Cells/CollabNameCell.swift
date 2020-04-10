//
//  CollabNameCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabNameCell: UITableViewCell, UITextFieldDelegate {

    
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var collabNameTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureTextField()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureTextField () {
        
        textFieldContainer.backgroundColor = .clear
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
}
