//
//  RegistrationEmailCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

protocol EmailEntered: AnyObject {
    
    func emailEntered (email: String)
}

class RegistrationEmailCell: UICollectionViewCell, UITextFieldDelegate {

    @IBOutlet weak var emailTitleLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!

    @IBOutlet weak var progressView: UIView!
    
    weak var emailEnteredDelegate: EmailEntered?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        emailTitleLabel.text = "What's your E-mail \n Address?"
        
        emailTextField.delegate = self
        
        emailErrorLabel.adjustsFontSizeToFitWidth = true
        emailErrorLabel.isHidden = true
        
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
    
    @IBAction func emailTextChanged(_ sender: Any) {
        
        emailErrorLabel.isHidden = true
        
        emailEnteredDelegate?.emailEntered(email: emailTextField.text!)
    }
}
