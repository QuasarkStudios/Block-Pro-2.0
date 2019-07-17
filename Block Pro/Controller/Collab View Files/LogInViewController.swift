//
//  LogInViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/11/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

protocol UserSignIn {
    
    func attachListener ()
}

protocol UserRegistration {
    
    func newUser(_ firstName: String, _ lastName: String, _ username: String)
}

class LogInViewController: UIViewController {
    
    var attachListenerDelegate: UserSignIn?
    var registerUserDelegate: UserRegistration?
    
    @IBOutlet weak var logInContainer: UIView!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var loginEmailTextField: UITextField!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var newRegisterButton: UIButton!
    
    
    @IBOutlet weak var registerContainer: UIView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerPasswordTextField_1: UITextField!
    @IBOutlet weak var registerReenterPasswordTextField_2: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logInContainer.frame.origin = CGPoint(x: 39, y: 100)
        
        logInContainer.layer.cornerRadius = 0.1 * logInContainer.bounds.size.width
        logInContainer.clipsToBounds = true
        
        logInButton.layer.cornerRadius = 0.07 * logInButton.bounds.size.width
        logInButton.clipsToBounds = true
        
        
        registerContainer.frame.origin.y = 750
        
        registerContainer.layer.cornerRadius = 0.1 * registerContainer.bounds.size.width
        registerContainer.clipsToBounds = true
        
        registerButton.layer.cornerRadius = 0.07 * registerButton.bounds.size.width
        registerButton.clipsToBounds = true
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        
        //ProgressHUD.show()
        
        if loginEmailTextField.text != "" {
            
            if loginPasswordTextField.text != "" {
                
                Auth.auth().signIn(withEmail: loginEmailTextField.text!, password: loginPasswordTextField.text!) { (user, error) in
                    
                    if error != nil {
                        
                        ProgressHUD.showError(error?.localizedDescription)
                    }
                    else {
                        
                        ProgressHUD.showSuccess("Logged In!")
                        
                        self.attachListenerDelegate?.attachListener()
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
            else {
                ProgressHUD.showError("Please enter in your password")
            }
        }
        
        else {
            
            ProgressHUD.showError("Please enter in your email")
        }
    }
    
    
    @IBAction func registerButton(_ sender: Any) {
        
        registerUser()
    }
    
    func registerUser () {
        
        if firstNameTextField.text == "" || lastNameTextField.text == "" {
            ProgressHUD.showError("Please finish entering in your name.")
        }
        else if usernameTextField.text == "" {
            ProgressHUD.showError("Please enter in your username.")
        }
        else if registerEmailTextField.text == "" {
            ProgressHUD.showError("Please enter in a email address.")
        }
        else if (registerPasswordTextField_1.text == "" || registerReenterPasswordTextField_2.text == "") {
            ProgressHUD.showError("Please finish entering in your password.")
        }
        else if registerPasswordTextField_1.text != registerReenterPasswordTextField_2.text {
            ProgressHUD.showError("Sorry, your passwords don't match. Please try again.")
        }
        else {
            
            Auth.auth().createUser(withEmail: registerEmailTextField.text!, password: registerPasswordTextField_1.text!) { authResult, error in
                
                if error != nil {
                    
                    ProgressHUD.showError(error?.localizedDescription)
                }
                else {
                    
                    ProgressHUD.showSuccess("Account Created!")
                    
                    self.registerUserDelegate?.newUser(self.firstNameTextField.text!, self.lastNameTextField.text!, self.usernameTextField.text!)
                    
                    //self.attachListenerDelegate?.attachListener()
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func newRegisterButton(_ sender: Any) {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.logInContainer.frame.origin.y = -500
        }) { (finished: Bool) in
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.registerContainer.frame.origin.y = 100
            })
        }
    }
    
    
    @IBAction func backToLoginButton(_ sender: Any) {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.registerContainer.frame.origin.y = 750
            
        }) { (finished: Bool) in
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.logInContainer.frame.origin.y = 100
            })
        }
    }
    
}
