//
//  LogInViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/11/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase


class LogIn_RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var logInContainer: UIView!
    
    @IBOutlet weak var loginContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var loginContainerLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var loginContainerTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var newRegisterButton: UIButton!
    
    @IBOutlet weak var registerContainer: UIView!
    
    @IBOutlet weak var registerContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var registerContainerLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var registerContainerTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerPasswordTextField_1: UITextField!
    @IBOutlet weak var registerReenterPasswordTextField_2: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    lazy var db = Firestore.firestore()
    
    var firstNameVerified: Bool?
    var lastNameVerified: Bool?
    var usernameVerified: Bool?
    var password1Verified: Bool?
    var password2Verified: Bool?
    
    var uniqueUsername: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureConstraints()
    }
    
    func configureView () {
        
        loginEmailTextField.delegate = self
        loginPasswordTextField.delegate = self
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        usernameTextField.delegate = self
        
        registerEmailTextField.delegate = self
        registerPasswordTextField_1.delegate = self
        registerReenterPasswordTextField_2.delegate = self
        
        
        logInContainer.layer.cornerRadius = 0.1 * logInContainer.bounds.size.width
        logInContainer.clipsToBounds = true
        
        logInButton.layer.cornerRadius = 0.06 * logInButton.bounds.size.width
        logInButton.clipsToBounds = true
        
        
        registerContainer.layer.cornerRadius = 0.1 * registerContainer.bounds.size.width
        registerContainer.clipsToBounds = true
        
        registerButton.layer.cornerRadius = 0.06 * registerButton.bounds.size.width
        registerButton.clipsToBounds = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func configureConstraints () {
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            loginContainerTopAnchor.constant = 125
            registerContainerTopAnchor.constant = 850
        }
            
        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {
            
            loginContainerTopAnchor.constant = 100
            registerContainerTopAnchor.constant = 850
        }
            
        //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            loginContainerTopAnchor.constant = 125
            registerContainerTopAnchor.constant = 850
        }
            
        //iPhone 8
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0{
            
            loginContainerTopAnchor.constant = 100
            registerContainerTopAnchor.constant = 850
        }
            
        //iPhone SE
        else if UIScreen.main.bounds.width == 320.0 {
            
            loginContainerTopAnchor.constant = 70
            loginContainerLeadingAnchor.constant = 15
            loginContainerTrailingAnchor.constant = 15
            
            registerContainerTopAnchor.constant = 850
            registerContainerLeadingAnchor.constant = 15
            registerContainerTrailingAnchor.constant = 15
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //iPhone SE
        if UIScreen.main.bounds.width == 320.0 {
            
            if textField == firstNameTextField || textField == lastNameTextField {
                
                view.layoutIfNeeded()
                registerContainerTopAnchor.constant = 70
                
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }
            }
            else if textField == usernameTextField {
                
                view.layoutIfNeeded()
                registerContainerTopAnchor.constant = 50
                
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }
            }
            
            else if textField == registerEmailTextField {
                
                view.layoutIfNeeded()
                registerContainerTopAnchor.constant = 30
                
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }
            }
            else if textField == registerPasswordTextField_1 || textField == registerReenterPasswordTextField_2 {
                
                view.layoutIfNeeded()
                registerContainerTopAnchor.constant = -25
                
                UIView.animate(withDuration: 0.15) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        //iPhone SE
        if UIScreen.main.bounds.width == 320.0 {
            if registerContainerTopAnchor.constant < 850 {
                
                view.layoutIfNeeded()
                registerContainerTopAnchor.constant = 70
                
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }
            }
        }

        return true
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


                    
                    self.performSegue(withIdentifier: "moveToUpcomingCollabs", sender: self)
                }
            }
        }
        
    }
    
    
    @IBAction func registerButton(_ sender: Any) {
        
        registerButton.isEnabled = false
        
        verification {
            
            if self.firstNameVerified ?? false == false || self.lastNameVerified ?? false == false {
                ProgressHUD.showError("Please finish entering in your name.")
                self.registerButton.isEnabled = true
            }
            else if self.usernameVerified ?? false == false {
                ProgressHUD.showError("Please finish entering in your username.")
                self.registerButton.isEnabled = true
            }
            else if self.uniqueUsername ?? false == false {
                ProgressHUD.showError("Sorry, that username already exists. Please enter in a new one.")
                self.registerButton.isEnabled = true
            }
            else if self.password1Verified ?? false == false || self.password2Verified ?? false == false {
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
    
    
    func verification (completion: @escaping () -> ()) {
        
        let letters = CharacterSet.letters
        let numbers = CharacterSet.decimalDigits
        
        if firstNameTextField.text?.isEmpty == true {
            firstNameVerified = false
        }
        else {
            
            for char in firstNameTextField.text!.unicodeScalars {
                
                if letters.contains(char) {
                    firstNameVerified = true
                    break
                }
                else if numbers.contains(char) {
                    firstNameVerified = true
                    break
                }
                else {
                    firstNameVerified = false
                }
            }
        }
        
        ////////////////////////////////////////////////////////////////////
        if lastNameTextField.text?.isEmpty == true {
            lastNameVerified = false
        }
        else {
            
            for char in lastNameTextField.text!.unicodeScalars {
                if letters.contains(char) {
                    lastNameVerified = true
                    break
                }
                else if numbers.contains(char) {
                    lastNameVerified = true
                    break
                }
                else {
                    lastNameVerified = false
                }
            }
        }

        ////////////////////////////////////////////////////////////////////
        if usernameTextField.text?.isEmpty == true {
            usernameVerified = false
        }
        else {
            
            for char in usernameTextField.text!.unicodeScalars {
                if letters.contains(char) {
                    usernameVerified = true
                    break
                }
                else if numbers.contains(char) {
                    usernameVerified = true
                    break
                }
                else {
                    usernameVerified = false
                }
            }
        }

        ////////////////////////////////////////////////////////////////////
        if registerPasswordTextField_1.text?.isEmpty == true {
            password1Verified = false
        }
        else {
            for char in registerPasswordTextField_1.text!.unicodeScalars {
                if letters.contains(char) {
                    password1Verified = true
                    break
                }
                else if numbers.contains(char) {
                    password1Verified = true
                    break
                }
                password1Verified = false
            }
        }
        
        ////////////////////////////////////////////////////////////////////
        if registerReenterPasswordTextField_2.text?.isEmpty == true {
            password2Verified = false
        }
        else {
            
            for char in registerReenterPasswordTextField_2.text!.unicodeScalars {
                if letters.contains(char) {
                    password2Verified = true
                    break
                }
                else if numbers.contains(char) {
                    password2Verified = true
                    break
                }
                else {
                    password2Verified = false
                }
            }
        }


        print(firstNameVerified)
        print(lastNameVerified)
        print(usernameVerified)
        print(password1Verified)
        print(password2Verified)
        
        //registerButton.isEnabled = true
        
        db.collection("Users").whereField("username", isEqualTo: usernameTextField.text!.lowercased()).getDocuments { (snapshot, error) in
            
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
                print("unique username", self.uniqueUsername, "\(self.usernameTextField.text!.lowercased()) \n")
            }
        }
    }
    
    
    func createNewUser (_ userID: String, completion: @escaping () -> ()) {
        
        db.collection("Users").document(userID).setData(["userID" : userID, "firstName" : firstNameTextField.text!, "lastName" : lastNameTextField.text!, "username" : usernameTextField.text!.lowercased()])
        
        completion()
    }
    
    
    @IBAction func newRegisterButton(_ sender: Any) {
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            self.loginContainerTopAnchor.constant = -500
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.navigationItem.title = "Register"
                self.registerContainerTopAnchor.constant = 125
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.view.layoutIfNeeded()
                })
            }
        }
            
        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {
            
            self.loginContainerTopAnchor.constant = -500
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.navigationItem.title = "Register"
                self.registerContainerTopAnchor.constant = 80
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.view.layoutIfNeeded()
                })
            }
        }
            
        //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            self.loginContainerTopAnchor.constant = -500
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.navigationItem.title = "Register"
                self.registerContainerTopAnchor.constant = 95
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.view.layoutIfNeeded()
                })
            }
        }
            
        //iPhone 8
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0{
            
            self.loginContainerTopAnchor.constant = -500
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.navigationItem.title = "Register"
                self.registerContainerTopAnchor.constant = 70
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.view.layoutIfNeeded()
                })
            }
        }
            
        //iPhone SE
        else if UIScreen.main.bounds.width == 320.0 {
            
            self.loginContainerTopAnchor.constant = -500
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.navigationItem.title = "Register"
                self.registerContainerTopAnchor.constant = 70
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    
    @IBAction func backToLoginButton(_ sender: Any) {
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            self.registerContainerTopAnchor.constant = 850
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.navigationItem.title = "Log In"
                self.loginContainerTopAnchor.constant = 125
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.view.layoutIfNeeded()
                })
            }
        }
            
        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {
            
            self.registerContainerTopAnchor.constant = 850
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.navigationItem.title = "Log In"
                self.loginContainerTopAnchor.constant = 100
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.view.layoutIfNeeded()
                })
            }
            
        }
            
        //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            self.registerContainerTopAnchor.constant = 850
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.navigationItem.title = "Log In"
                self.loginContainerTopAnchor.constant = 125
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.view.layoutIfNeeded()
                })
            }
        }
            
        //iPhone 8
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0{
            
            self.registerContainerTopAnchor.constant = 850
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.navigationItem.title = "Log In"
                self.loginContainerTopAnchor.constant = 100
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.view.layoutIfNeeded()
                })
            }
        }
            
        //iPhone SE
        else if UIScreen.main.bounds.width == 320.0 {
            
            self.registerContainerTopAnchor.constant = 850
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.navigationItem.title = "Log In"
                self.loginContainerTopAnchor.constant = 70
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    
    //Function that dismisses the keyboard and the PickerViews
    @objc func dismissKeyboard () {
        
        view.endEditing(true)
        
        //iPhone SE
        if UIScreen.main.bounds.width == 320.0 {
            if registerContainerTopAnchor.constant < 850 {
                
                view.layoutIfNeeded()
                registerContainerTopAnchor.constant = 70
                
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}
