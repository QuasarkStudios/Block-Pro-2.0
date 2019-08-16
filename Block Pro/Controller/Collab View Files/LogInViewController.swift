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


#warning("rename view controller")
class LogInViewController: UIViewController {
    
    var attachListenerDelegate: UserSignIn?
    var registerUserDelegate: UserRegistration?
    
    lazy var db = Firestore.firestore()
    
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
    
    var uniqueUsername: Bool?
    
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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        
        logInButton.isEnabled = false
        
        if loginEmailTextField.text == "" {
            ProgressHUD.showError("Please enter in your email")
            logInButton.isEnabled = true
        }
        else if loginPasswordTextField.text == "" {
            ProgressHUD.showError("Please enter in your password")
            logInButton.isEnabled = true
        }
        else {
            
            ProgressHUD.show()
            
            Auth.auth().signIn(withEmail: loginEmailTextField.text!, password: loginPasswordTextField.text!) { (user, error) in
                
                if error != nil {
                    
                    ProgressHUD.showError(error?.localizedDescription)
                    self.logInButton.isEnabled = true
                }
                else {

                    
//                    self.attachListenerDelegate?.attachListener()

                    
                    self.performSegue(withIdentifier: "moveToUpcomingCollabs", sender: self)
                }
            }
        }
        
    }
    
    
    @IBAction func registerButton(_ sender: Any) {
        
        registerButton.isEnabled = false
        
        usernameVerification {
            
            print(self.uniqueUsername)
            
            if self.firstNameTextField.text == "" || self.lastNameTextField.text == "" {
                ProgressHUD.showError("Please finish entering in your name.")
                self.registerButton.isEnabled = true
            }
            else if self.usernameTextField.text == "" {
                ProgressHUD.showError("Please enter in your username.")
                self.registerButton.isEnabled = true
            }
            else if self.uniqueUsername ?? false == false {
                ProgressHUD.showError("Sorry, that username already exists. Please enter in a new one.")
                self.registerButton.isEnabled = true
            }
            else if self.registerEmailTextField.text == "" {
                ProgressHUD.showError("Please enter in a email address.")
                self.registerButton.isEnabled = true
            }
            else if (self.registerPasswordTextField_1.text == "" || self.registerReenterPasswordTextField_2.text == "") {
                ProgressHUD.showError("Please finish entering in your password.")
                self.registerButton.isEnabled = true
            }
            else if self.registerPasswordTextField_1.text != self.registerReenterPasswordTextField_2.text {
                ProgressHUD.showError("Sorry, your passwords don't match. Please try again.")
                self.registerButton.isEnabled = true
            }
            else {
                
                Auth.auth().createUser(withEmail: self.registerEmailTextField.text!, password: self.registerPasswordTextField_1.text!) { authResult, error in
                    
                    if error != nil {
                        
                        ProgressHUD.showError(error?.localizedDescription)
                        self.registerButton.isEnabled = true
                    }
                    else {
                        
                        guard let userID = authResult?.user.uid else { return }
                        
                        self.createNewUser(userID, completion: {
                            
                            ProgressHUD.showSuccess("Account Created!")
                            
                            self.performSegue(withIdentifier: "moveToUpcomingCollabs", sender: self)
                        })
                        
                    }
                }
            }
        }
        
    }
    
    func usernameVerification (completion: @escaping () -> ()) {
        
        db.collection("Users").whereField("username", isEqualTo: usernameTextField.text).getDocuments { (snapshot, error) in
            //print("check")
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                self.registerButton.isEnabled = true
            }
            
            else {
                
                if snapshot?.isEmpty == true {
                    self.uniqueUsername = true
                    completion()
                }
                else {
                    self.uniqueUsername = false
                    completion()
                }
                print(self.uniqueUsername)
            }
        }
//
//        if let verification = uniqueUsername {
//            print("check")
//            if verification == true {
//                return true
//            }
//            else {
//                return false
//            }
//        }
//        else {
//            return false
//        }
        
    }
    
    
    func createNewUser (_ userID: String, completion: @escaping () -> ()) {
        
        self.db.collection("Users").document(userID).setData(["userID" : userID, "firstName" : self.firstNameTextField.text!, "lastName" : self.lastNameTextField.text!, "username" : self.usernameTextField.text!])
        
        completion()
    }
    
    
    @IBAction func newRegisterButton(_ sender: Any) {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.logInContainer.frame.origin.y = -500
        }) { (finished: Bool) in
            
            self.navigationItem.title = "Register"
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.registerContainer.frame.origin.y = 100
            })
        }
    }
    
    
    @IBAction func backToLoginButton(_ sender: Any) {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.registerContainer.frame.origin.y = 750
            
        }) { (finished: Bool) in
            
            self.navigationItem.title = "Log In"
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.logInContainer.frame.origin.y = 100
            })
        }
    }
    
    //Function that dismisses the keyboard and the PickerViews
    @objc func dismissKeyboard () {
        
        view.endEditing(true)
    }
    
}
