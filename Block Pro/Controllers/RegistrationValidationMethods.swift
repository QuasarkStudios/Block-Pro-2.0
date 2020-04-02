//
//  RegistrationValidationFunctions.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/2/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

extension RegistrationViewController {
    
    private func validateText (_ text: String) -> Bool {
        
        let letters = CharacterSet.letters
        let numbers = CharacterSet.decimalDigits
        
        for char in text.unicodeScalars {
            
            if letters.contains(char) || numbers.contains(char) {
                
                return true
            }
        }
        
        return false
    }
    
    //MARK: - Validate User Name
    
    internal func validateName (completion: ((_ validated: Bool) -> Void)) {
        
        if validateText(newUser.firstName) && validateText(newUser.lastName) {
            
            completion(true)
        }
        
        else {
            
            guard let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? RegistrationNameCell else { return }
            
                if !validateText(newUser.firstName) {
                    
                    cell.firstNameErrorLabel.isHidden = false
                }
                
                if !validateText(newUser.lastName) {
                    
                    cell.lastNameErrorLabel.isHidden = false
                }
            
                completion(false)
        }
    }
    
    
    //MARK: - Validate Username
    
    internal func validateUsername (completion: @escaping ((_ validated: Bool) -> Void)) {
        
        if validateText(newUser.username) {
            
            guard let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? RegistrationUsernameCell else { return }
            
                cell.usernameErrorLabel.text = "Verifying..."
                cell.usernameErrorLabel.textColor = .black
                cell.usernameErrorLabel.isHidden = false
                
                cell.progressView.showProgress()
                
                userAuth.validateUsername(username: newUser.username) { (snapshot, error) in
                    
                    if error != nil {
                        
                        ProgressHUD.showError(error?.localizedDescription)
                        
                        cell.progressView.dismissProgress()
                        
                        completion(false)
                    }
                    
                    else {
                        
                        if snapshot?.isEmpty == false {
                            
                            cell.usernameErrorLabel.textColor = .systemRed
                            cell.usernameErrorLabel.text = "Sorry, but this username is already being used"
                            
                            cell.progressView.dismissProgress()
                            
                            completion(false)
                        }
                        
                        else {
                            
                            cell.progressView.dismissProgress()
                            
                            cell.usernameErrorLabel.isHidden = true
                            
                            completion(true)
                        }
                    }
                }
        }
        
        else {
            
            guard let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? RegistrationUsernameCell else { return }
            
                cell.usernameErrorLabel.textColor = .systemRed
                cell.usernameErrorLabel.text = "Please enter in a username"
                cell.usernameErrorLabel.isHidden = false
            
                completion(false)
        }
    }
    
    
    //MARK: - Validate Account Info and Create New Account
    
    internal func validateAccountInfoAndCreateUser (completion: @escaping (( _ validated: Bool, _ userID: String?) -> Void)) {
        
        if validateText(newUser.email) && validateText(newUser.password) && validateText(newUser.passwordReentry) {
            
            if newUser.password == newUser.passwordReentry {
                
                guard let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as? RegistrationAccountCreationCell else { return }
                
                    cell.emailErrorLabel.text = "Verifying..."
                    cell.emailErrorLabel.textColor = .black
                    cell.emailErrorLabel.isHidden = false
                    
                    cell.passwordErrorLabel.text = "Verifying..."
                    cell.passwordErrorLabel.textColor = .black
                    cell.passwordErrorLabel.isHidden = false
                    
                    cell.passwordReentryErrorLabel.text = "Verifying..."
                    cell.passwordReentryErrorLabel.textColor = .black
                    cell.passwordReentryErrorLabel.isHidden = false
                    
                    cell.progressView1.showProgress()
                    cell.progressView2.showProgress()
                    cell.progressView3.showProgress()
                    
                    userAuth.validateAccountInfoAndRegisterNewUser(email: newUser.email, password: newUser.password) { [weak self] (userID, error) in
                        
                        //Cast error to type NSError to be able to retrieve it's error code
                        if let error = error as NSError? {
                            
                            self?.handleAccountInfoErrors(error, cell)
                            
                            completion(false, nil)
                        }
                        
                        else {
                            
                            if let userID = userID {
                                
                                self?.backToSignInButton.setTitleColor(.clear, for: .normal)
                                
                                completion(true, userID)
                            }
                            
                            else {
                                
                                ProgressHUD.showError("Sorry, something went wrong while making your account. Please try again!")

                                self?.backToSignInButton.isEnabled = true
                                
                                completion(false, nil)
                            }
                        }
                        
                        cell.progressView1.dismissProgress()
                        cell.progressView2.dismissProgress()
                        cell.progressView3.dismissProgress()
                    }
            }
            
            else {
                
                guard let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as? RegistrationAccountCreationCell else { return }
                
                    cell.passwordReentryErrorLabel.textColor = .systemRed
                    cell.passwordReentryErrorLabel.text = "Sorry, but your passwords don't match"
                    cell.passwordReentryErrorLabel.isHidden = false
                
                    cell.progressView1.dismissProgress()
                    cell.progressView2.dismissProgress()
                    cell.progressView3.dismissProgress()
                
                    completion(false, nil)
            }
        }
        
        else {
            
            guard let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as? RegistrationAccountCreationCell else { return }
            
                if !validateText(newUser.email) {
                    
                    cell.emailErrorLabel.text = "Please enter in your email"
                    cell.emailErrorLabel.textColor = .systemRed
                    cell.emailErrorLabel.isHidden = false
                }
            
                if !validateText(newUser.password) {
                    
                    cell.passwordErrorLabel.textColor = .systemRed
                    cell.passwordErrorLabel.text = "Please enter your password"
                    cell.passwordErrorLabel.isHidden = false
                }
                
                if !validateText(newUser.passwordReentry) {
                    
                    cell.passwordReentryErrorLabel.textColor = .systemRed
                    cell.passwordReentryErrorLabel.text = "Please re-enter your password"
                    cell.passwordReentryErrorLabel.isHidden = false
                }
            
                cell.progressView1.dismissProgress()
                cell.progressView2.dismissProgress()
                cell.progressView3.dismissProgress()
            
                completion(false, nil)
        }
    }
    
    
    //MARK: - Handle Account Info Errors
    
    private func handleAccountInfoErrors (_ error: NSError, _ cell: RegistrationAccountCreationCell) {
        
        //Retrives the error code from Firebase
        if let errorCode = userAuth.getErrorCode(error) {
            
            switch errorCode {
                
            case .invalidEmail:
                
                cell.emailErrorLabel.text = "Sorry, but this email is badly formatted"
                cell.emailErrorLabel.textColor = .systemRed
                cell.emailErrorLabel.isHidden = false
                
                cell.passwordErrorLabel.isHidden = true
                cell.passwordReentryErrorLabel.isHidden = true
                
            case .emailAlreadyInUse:
                
                cell.emailErrorLabel.text = "Sorry, but this email is already in use"
                cell.emailErrorLabel.textColor = .systemRed
                cell.emailErrorLabel.isHidden = false
                
                cell.passwordErrorLabel.isHidden = true
                cell.passwordReentryErrorLabel.isHidden = true
                
            case .weakPassword:
                
                cell.emailErrorLabel.isHidden = true
                
                cell.passwordErrorLabel.text = error.localizedDescription
                cell.passwordErrorLabel.textColor = .systemRed
                cell.passwordErrorLabel.isHidden = false
                
                cell.passwordReentryErrorLabel.text = error.localizedDescription
                cell.passwordReentryErrorLabel.textColor = .systemRed
                cell.passwordReentryErrorLabel.isHidden = false
                
            default:
                
                ProgressHUD.showError(error.localizedDescription)
            }
        }
    }
}
