//
//  RegistrationUsernameCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

protocol  UsernameEntered: AnyObject {
    
    func usernameEntered(username: String)
}

class RegistrationUsernameCell: UICollectionViewCell, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    
    @IBOutlet weak var progressView: UIView!
    
    weak var usernameEnteredDelegate: UsernameEntered?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usernameTextField.delegate = self
        
        usernameErrorLabel.adjustsFontSizeToFitWidth = true
        usernameErrorLabel.isHidden = true
        
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
    
    @IBAction func usernameTextChanged(_ sender: Any) {
        
        usernameEnteredDelegate?.usernameEntered(username: usernameTextField.text!)
    }
}
