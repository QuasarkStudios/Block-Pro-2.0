//
//  LogInViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/23/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase
import iProgressHUD

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var bpLabel: UILabel!
    
    @IBOutlet weak var emailTextFieldContainer: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextFieldContainer: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var signInButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var signInButtonHeightConstraint: NSLayoutConstraint!
    
    var iProgressAttached: Bool = false
    
    var allowProgressAnimation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bpLabel.layer.cornerRadius = 0.5 * bpLabel.bounds.size.width
        bpLabel.clipsToBounds = true
        
        bpLabel.layer.borderWidth = 3
        bpLabel.layer.borderColor = UIColor.black.cgColor
        
        emailTextFieldContainer.layer.cornerRadius = 20
        emailTextFieldContainer.clipsToBounds = true
        
        emailTextFieldContainer.layer.borderWidth = 1
        emailTextFieldContainer.layer.borderColor = UIColor.black.cgColor
        
        emailTextField.delegate = self
        
        emailTextField.borderStyle = .none
        
        passwordTextFieldContainer.layer.cornerRadius = 20
        passwordTextFieldContainer.clipsToBounds = true
        
        passwordTextFieldContainer.layer.borderWidth = 1
        passwordTextFieldContainer.layer.borderColor = UIColor.black.cgColor
        
        passwordTextField.delegate = self
        
        passwordTextField.borderStyle = .none
        
        signInButton.layer.cornerRadius = 22.5
        signInButton.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = true
        
        tabBarController?.tabBar.isHidden = true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    private func validateTextEntered (_ text: String) -> Bool {
        
        let textArray = Array(text)
        var textEntered: Bool = false
        
        //For loop that checks to see if "blockNameTextField" isn't empty
        for char in textArray {
            
            if char != " " {
                textEntered = true
                break
            }
        }
        
        return textEntered
    }
    
    
    private func attachProgressAnimation () {
        
        let iProgress: iProgressHUD = iProgressHUD()
        
        iProgress.isShowModal = false
        iProgress.isShowCaption = false
        iProgress.isTouchDismiss = false
        iProgress.boxColor = .clear
        
        iProgress.indicatorSize = 100
        
        iProgress.attachProgress(toView: signInButton)
        
        signInButton.updateIndicator(style: .ballClipRotate)
    }
    
    
    private func animateSignInButton (shrink: Bool) {
        
        if shrink {
            
            self.signInButton.setTitleColor(.clear, for: .normal)
            
            signInButtonWidthConstraint.constant = 55
            signInButtonHeightConstraint.constant = 55
            
            UIView.animate(withDuration: 0.35, animations: {
                
                self.view.layoutIfNeeded()
                
                self.signInButton.layer.cornerRadius = 0.5 * 55
                self.signInButton.clipsToBounds = false
                
            }) { (finished: Bool) in
                
                if !self.iProgressAttached && self.allowProgressAnimation {
                    
                    self.attachProgressAnimation()
                    self.signInButton.showProgress()
                    
                    self.iProgressAttached = true
                }
                
                else if self.allowProgressAnimation {
                    
                    self.signInButton.showProgress()
                }
            }
        }
        
        else {
            
            signInButton.dismissProgress()
            
            signInButton.setTitleColor(.white, for: .normal)
            
            signInButtonWidthConstraint.constant = 140
            signInButtonHeightConstraint.constant = 45
            
            UIView.animate(withDuration: 0.35, animations: {
                
                self.view.layoutIfNeeded()
                
                self.signInButton.layer.cornerRadius = 22.5
                self.signInButton.clipsToBounds = true
                
            })
        }
    }
    
    private func userSignedIn () {
        
        signInButton.dismissProgress()
        
        signInButton.backgroundColor = UIColor(hexString: "262626", withAlpha: 1)
        
        signInButtonCenterYAnchor.constant = 0
        signInButtonWidthConstraint.constant = view.frame.height * 1.5
        signInButtonHeightConstraint.constant = view.frame.height * 1.5
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.layoutIfNeeded()
            
            self.signInButton.layer.cornerRadius = 0.5 * (self.view.frame.height * 1.5)
        
        }) { (finished: Bool) in
            
            self.performSegue(withIdentifier: "moveToHomeView", sender: self)
        }
    }
    
    @IBAction func signInButton(_ sender: Any) {
        
        signInButton.isEnabled = false
        
        if !validateTextEntered(emailTextField.text!) {
            
            ProgressHUD.showError("Please enter in your email")
            signInButton.isEnabled = true
        }
        
        else if !validateTextEntered(passwordTextField.text!) {
            
            ProgressHUD.showError("Please enter in your password")
            signInButton.isEnabled = true
        }
        
        else {
            
            allowProgressAnimation = true
            animateSignInButton(shrink: true)
            
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                
                if error != nil {
                    
                    self.allowProgressAnimation = false
                    
                    self.animateSignInButton(shrink: false)
                    
                    ProgressHUD.showError(error?.localizedDescription)
                    self.signInButton.isEnabled = true
                }
                
                else {
                    
                    self.signInButton.isEnabled = true
                    
                    self.userSignedIn()
                }
            }
        }
    }
    
    
    @IBAction func signupButton(_ sender: Any) {
        
        
    }
    
    @IBAction func skipButton(_ sender: Any) {
        
        performSegue(withIdentifier: "moveToHomeView", sender: self)
    }
    
    @objc private func dismissKeyboard () {
        
        view.endEditing(true)
    }
}
