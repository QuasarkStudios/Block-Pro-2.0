//
//  RegistrationPasswordCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

protocol AccountLogInInfoEntered: AnyObject {
    
    func emailEntered (email: String)
    
    func passwordEntered(password: String)
    
    func passwordReentryEntered(passwordReentry: String)
}

class RegistrationAccountCreationCell: UICollectionViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordReentryTextField: UITextField!
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var passwordReentryErrorLabel: UILabel!
    
    @IBOutlet weak var progressView1: UIView!
    @IBOutlet weak var progressView2: UIView!
    @IBOutlet weak var progressView3: UIView!
    
    
    weak var accountLogInInfoEnteredDelegate: AccountLogInInfoEntered?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = "Enter your E-mail and \n Create your Password"
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordReentryTextField.delegate = self
        
        emailErrorLabel.adjustsFontSizeToFitWidth = true
        passwordErrorLabel.adjustsFontSizeToFitWidth = true
        passwordReentryErrorLabel.adjustsFontSizeToFitWidth = true
        
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        passwordReentryErrorLabel.isHidden = true
        
        progressView1.backgroundColor = .clear
        progressView2.backgroundColor = .clear
        progressView3.backgroundColor = .clear
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
        
        iProgress.attachProgress(toView: progressView1)
        iProgress.attachProgress(toView: progressView2)
        iProgress.attachProgress(toView: progressView3)
        
        progressView1.updateIndicator(style: .circleStrokeSpin)
        progressView2.updateIndicator(style: .circleStrokeSpin)
        progressView3.updateIndicator(style: .circleStrokeSpin)
    }
    
    
    @IBAction func emailTextChanged(_ sender: Any) {
        
        emailErrorLabel.isHidden = true
        
        accountLogInInfoEnteredDelegate?.emailEntered(email: emailTextField.text!)
    }
    
    @IBAction func passwordTextChanged(_ sender: Any) {
        
        passwordErrorLabel.isHidden = true
        
        accountLogInInfoEnteredDelegate?.passwordEntered(password: passwordTextField.text!)
        
    }
    
    @IBAction func passwordReentryTextChanged(_ sender: Any) {
        
        passwordReentryErrorLabel.isHidden = true
        
        accountLogInInfoEnteredDelegate?.passwordReentryEntered(passwordReentry: passwordReentryTextField.text!)
    }
}
