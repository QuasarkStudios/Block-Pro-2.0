//
//  RegistrationPasswordCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

protocol PasswordEntered: AnyObject {
    
    func passwordEntered(password: String)
    
    func passwordRentryEntered(passwordRentry: String)
}

class RegistrationPasswordCell: UICollectionViewCell, UITextFieldDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRentryTextField: UITextField!
    
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var passwordRentryErrorLabel: UILabel!
    
    @IBOutlet weak var progressView: UIView!
    
    weak var passwordEnteredDelegate: PasswordEntered?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        passwordTextField.delegate = self
        passwordRentryTextField.delegate = self
        
        passwordErrorLabel.adjustsFontSizeToFitWidth = true
        passwordRentryErrorLabel.adjustsFontSizeToFitWidth = true
        
        passwordErrorLabel.isHidden = true
        passwordRentryErrorLabel.isHidden = true
        
        progressView.backgroundColor = .clear
        
        configureiProgress()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    private func configureiProgress () {
        
        let iProgress: iProgressHUD = iProgressHUD()
        
        iProgress.isShowModal = false
        iProgress.isShowCaption = false
        iProgress.isTouchDismiss = false
        iProgress.boxColor = .clear
        
        iProgress.indicatorSize = 100
        iProgress.indicatorColor = .black
        
        iProgress.attachProgress(toView: progressView)
        
        progressView.updateIndicator(style: .circleStrokeSpin)
    }
    
    @IBAction func passwordTextChanged(_ sender: Any) {
        
        passwordErrorLabel.isHidden = true
        
        passwordEnteredDelegate?.passwordEntered(password: passwordTextField.text!)
        
    }
    
    @IBAction func passwordRentryTextChanged(_ sender: Any) {
        
        passwordRentryErrorLabel.isHidden = true
        
        passwordEnteredDelegate?.passwordRentryEntered(passwordRentry: passwordRentryTextField.text!)
    }
}
