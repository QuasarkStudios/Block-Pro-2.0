//
//  RegistrationValidationMethods.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/6/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation
import SVProgressHUD

extension RegistrationViewController {
    
    internal func validateName (_ cell: NameOnboardingCollectionViewCell) {
        
        if newUser.firstName.strictValidationOfTextEntered(withSpecialCharacters: ["-"]) && newUser.lastName.strictValidationOfTextEntered(withSpecialCharacters: ["-"]) {
            
            progressBarWidthConstraint?.constant = 36
            
            UIView.animate(withDuration: 0.5) {
                
                self.view.layoutIfNeeded()
            }
            
            UIView.transition(with: onboardingPreviousButton, duration: 0.25, options: .transitionCrossDissolve) {
                
                self.onboardingPreviousButton.isEnabled = true
            }

            registrationCollectionView.scrollToItem(at: IndexPath(row: 4, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        else {
            
            if !newUser.firstName.leniantValidationOfTextEntered() {
                
                cell.firstNameErrorLabel.text = "Please enter in your first name"
                cell.presentFirstNameErrorLabel(present: true)
            }
            
            else if !newUser.firstName.strictValidationOfTextEntered(withSpecialCharacters: ["-"]) {
                
                cell.firstNameErrorLabel.text = "Sorry, but your first name is badly formatted"
                cell.presentFirstNameErrorLabel(present: true)
            }
            
            if !newUser.lastName.leniantValidationOfTextEntered() {
                
                cell.lastNameErrorLabel.text = "Please enter in your last name"
                cell.presentLastNameErrorLabel(present: true)
            }
            
            else if !newUser.lastName.strictValidationOfTextEntered(withSpecialCharacters: ["-"]) {
                
                cell.lastNameErrorLabel.text = "Sorry, but your last name is badly formatted"
                cell.presentLastNameErrorLabel(present: true)
            }
        }
    }
    
    internal func validateEmail (_ cell: EmailOnboardingCollectionViewCell) {
        
        if newUser.email.leniantValidationOfTextEntered() {
            
            cell.errorLabel.textColor = .black
            cell.errorLabel.text = "Verifying..."
            
            cell.displayProgress()
            
            firebaseAuth.verifyEmailAddress(newUser.email) { [weak self] (emailInUse, error) in
                
                cell.progressView.dismissProgress()
                
                if let error = error {
                    
                    //Retrives the error code from Firebase
                    if let errorCode = self?.firebaseAuth.getErrorCode(error) {
                        
                        switch errorCode {
                            
                            case .invalidEmail:
                                
                                cell.errorLabel.textColor = .systemRed
                                cell.errorLabel.text = "Sorry, but this email is badly formatted"
                            
                            default:
                                
                                SVProgressHUD.showError(withStatus: error.localizedDescription)
                                
                                cell.errorLabel.text = ""
                        }
                    }
                }
                
                else {
                    
                    if emailInUse ?? true {
                        
                        cell.errorLabel.textColor = .systemRed
                        cell.errorLabel.text = "Sorry, but this email is already in use"
                    }
                    
                    else {
                        
                        self?.progressBarWidthConstraint?.constant = 72
                        
                        UIView.animate(withDuration: 0.5) {
                            
                            self?.view.layoutIfNeeded()
                        }

                        self?.registrationCollectionView.scrollToItem(at: IndexPath(row: 5, section: 0), at: .centeredHorizontally, animated: true)
                        
                        cell.errorLabel.text = ""
                    }
                }
            }
        }
        
        else {
            
            cell.errorLabel.textColor = .systemRed
            cell.errorLabel.text = "Please enter in your E-mail Address"
        }
    }
    
    internal func validateUsername (_ cell: UsernameOnboardingCollectionViewCell) {
        
        if newUser.username.leniantValidationOfTextEntered() {
            
            cell.usernameTextField.text = newUser.username.lowercased()
            
            if newUser.username.strictValidationOfTextEntered(withSpecialCharacters: ["-", "_"]) {
                
                cell.errorLabel.textColor = .black
                cell.errorLabel.text = "Verifying..."
                
                cell.displayProgress()
                
                firebaseAuth.validateUsername(username: newUser.username) { [weak self] (snapshot, error) in
                    
                    cell.progressView.dismissProgress()
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                        
                        cell.errorLabel.text = ""
                    }
                    
                    else {
                        
                        if snapshot?.isEmpty ?? false {
                            
                            self?.progressBarWidthConstraint?.constant = 108
                            
                            UIView.animate(withDuration: 0.5) {
                                
                                self?.view.layoutIfNeeded()
                            }
                            
                            self?.onboardingNextButton.setTitle("Done", for: .normal)
                            
                            self?.registrationCollectionView.scrollToItem(at: IndexPath(row: 6, section: 0), at: .centeredHorizontally, animated: true)
                            
                            cell.errorLabel.text = ""
                        }
                        
                        else {
                            
                            cell.errorLabel.textColor = .systemRed
                            cell.errorLabel.text = "Sorry, but this username is already being used"
                        }
                    }
                }
            }
            
            else {
                
                cell.errorLabel.textColor = .systemRed
                cell.errorLabel.text = "Sorry, but this username is badly formatted"
            }
        }
        
        else {
            
            cell.errorLabel.textColor = .systemRed
            cell.errorLabel.text = "Please enter in your username"
        }
    }
    
    internal func validatePassword (_ cell: PasswordOnboardingCollectionViewCell) {
        
        if newUser.password.leniantValidationOfTextEntered() {
            
            SVProgressHUD.show()
            
            signInButton.alpha = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                
                SVProgressHUD.dismiss()
                
                self.progressBarWidthConstraint?.constant = 144
                
                self.collectionViewBottomAnchorWithSignInButton?.isActive = false
                self.collectionViewBottomAnchorWithView?.isActive = true
                
                UIView.animate(withDuration: 0.5) {
                    
                    self.view.layoutIfNeeded()
                    
                    self.onboardingPreviousButton.alpha = 0
                    self.onboardingNextButton.alpha = 0
                    
                    self.reconfigureCollectionViewLayoutForProfilePicture()
                    
//                    self.signInButton.alpha = 1
                }
                
                self.registrationCollectionView.scrollToItem(at: IndexPath(row: 7, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
        
        else {
            
            cell.errorLabel.textColor = .systemRed
            cell.errorLabel.text = "Please enter in your password"
        }
    }
}
