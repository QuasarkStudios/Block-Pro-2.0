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
    
    //MARK: - Validate Name
    
    internal func validateName (_ cell: NameOnboardingCollectionViewCell) {
        
        //The first and last name has been entered properly
        if newUser.firstName.strictValidationOfTextEntered(withSpecialCharacters: ["-"]) && newUser.lastName.strictValidationOfTextEntered(withSpecialCharacters: ["-"]) {
            
            progressBarWidthConstraint?.constant = 36
            
            UIView.animate(withDuration: 0.5) {
                
                self.view.layoutIfNeeded()
            }
            
            //The onboardingPreviousButton would've been disbaled at this point of the registration process
            UIView.transition(with: onboardingPreviousButton, duration: 0.25, options: .transitionCrossDissolve) {
                
                self.onboardingPreviousButton.isEnabled = true
            }

            registrationCollectionView.scrollToItem(at: IndexPath(row: 4, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        //The first and last name hasn't been entered properly
        else {
            
            //If the user didn't enter their name
            if !newUser.firstName.leniantValidationOfTextEntered() {
                
                cell.firstNameErrorLabel.text = "Please enter in your first name"
                cell.presentFirstNameErrorLabel(present: true)
            }
            
            //If the user entered their name incorrectly
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
    
    
    //MARK: - Validate E-mail
    
    internal func validateEmail (_ cell: EmailOnboardingCollectionViewCell) {
        
        //If the email has been entered
        if newUser.email.leniantValidationOfTextEntered() {
            
            cell.errorLabel.textColor = .black
            cell.errorLabel.text = "Verifying..."
            
            cell.displayProgress()
            
            //Checks to see if the email has been formatted properly and whether or not it's been used for another account
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
                    
                    //If this email has already been used by another account
                    if emailInUse ?? true {
                        
                        cell.errorLabel.textColor = .systemRed
                        cell.errorLabel.text = "Sorry, but this email is already in use"
                    }
                    
                    //If this email hasn't been used by another account
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
    
    
    //MARK: - Validate Username
    
    internal func validateUsername (_ cell: UsernameOnboardingCollectionViewCell) {
        
        //If the username has been entered
        if newUser.username.leniantValidationOfTextEntered() {
            
            cell.usernameTextField.text = newUser.username.lowercased()
            
            //If the username has been entered in properly
            if newUser.username.strictValidationOfTextEntered(withSpecialCharacters: ["-", "_"]) {
                
                cell.errorLabel.textColor = .black
                cell.errorLabel.text = "Verifying..."
                
                cell.displayProgress()
                
                //Checks to see if this username has been used before
                firebaseAuth.validateUsername(username: newUser.username) { [weak self] (snapshot, error) in
                    
                    cell.progressView.dismissProgress()
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                        
                        cell.errorLabel.text = ""
                    }
                    
                    else {
                        
                        //This username has never been used before
                        if snapshot?.isEmpty ?? false {
                            
                            self?.progressBarWidthConstraint?.constant = 108
                            
                            UIView.animate(withDuration: 0.5) {
                                
                                self?.view.layoutIfNeeded()
                            }
                            
                            self?.onboardingNextButton.setTitle("Done", for: .normal)
                            
                            self?.registrationCollectionView.scrollToItem(at: IndexPath(row: 6, section: 0), at: .centeredHorizontally, animated: true)
                            
                            cell.errorLabel.text = ""
                        }
                        
                        //This username has been used before
                        else {
                            
                            cell.errorLabel.textColor = .systemRed
                            cell.errorLabel.text = "Sorry, but this username is already being used"
                        }
                    }
                }
            }
            
            //If the username hasn't been entered properly
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
    
    
    //MARK: - Validate Password
    
    internal func validatePassword (_ cell: PasswordOnboardingCollectionViewCell) {
        
        //If the password has been entered
        if newUser.password.leniantValidationOfTextEntered() {
            
            SVProgressHUD.show()
            
            //Hides these views because interaction with them can interrupt the process of creating an account for the user
            UIView.animate(withDuration: 0.3) {
                
                self.onboardingPreviousButton.alpha = 0
                self.onboardingNextButton.alpha = 0
                
                self.signInButton.alpha = 0
            }
            
            firebaseAuth.createNewUser(newUser: newUser) { [weak self] (error) in
                
                if let error = error {
                    
                    SVProgressHUD.dismiss()
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        self?.onboardingPreviousButton.alpha = 1
                        self?.onboardingNextButton.alpha = 1
                        
                        self?.signInButton.alpha = 1
                    }
                    
                    if let errorCode = self?.firebaseAuth.getErrorCode(error) {
                        
                        switch errorCode {
                            
                            case .weakPassword:
                                
                                cell.errorLabel.textColor = .systemRed
                                cell.errorLabel.text = error.localizedDescription
                              
                            //If the email was entered in improperly and it wasn't caught by the validateEmail func
                            //Sadly common because Firebase checkSignInMethods only invalidates some improperly entered emails
                            case .invalidEmail:
                                
                                SVProgressHUD.showError(withStatus: "Sorry, but your email is badly formatted")
                                
                                //Brings the user back to the emailOnboardingCell
                                self?.progressBarWidthConstraint?.constant = 36
                                
                                UIView.animate(withDuration: 0.5) {
                                    
                                    self?.view.layoutIfNeeded()
                                }
                                
                                self?.onboardingNextButton.setTitle("Next", for: .normal)
                                
                                self?.registrationCollectionView.scrollToItem(at: IndexPath(item: 4, section: 0), at: .centeredHorizontally, animated: true)
                                
                            default:
                                
                                SVProgressHUD.showError(withStatus: error.localizedDescription)
                        }
                    }
                }
                
                //The user's account was created
                else {
                    
                    SVProgressHUD.dismiss()
                    
                    self?.progressBarWidthConstraint?.constant = 144
    
                    self?.collectionViewBottomAnchorWithSignInButton?.isActive = false
                    self?.collectionViewBottomAnchorWithView?.isActive = true
                    
                    UIView.animate(withDuration: 0.5) {

                        self?.view.layoutIfNeeded()

                        self?.reconfigureCollectionViewLayoutForProfilePicture()
                    }
                    
                    self?.registrationCollectionView.scrollToItem(at: IndexPath(row: 7, section: 0), at: .centeredHorizontally, animated: true)
                }
            }
        }
        
        else {
            
            cell.errorLabel.textColor = .systemRed
            cell.errorLabel.text = "Please enter in your password"
        }
    }
}
