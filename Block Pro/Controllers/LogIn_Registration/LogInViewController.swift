//
//  LogInViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/23/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import FirebaseAuth
import iProgressHUD
import BEMCheckBox

class LogInViewController: UIViewController, UITextFieldDelegate, BEMCheckBoxDelegate {

    @IBOutlet weak var bpLabel: UILabel!
    
    @IBOutlet weak var skipAnimationView: UIView!
    @IBOutlet weak var skipViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var skipViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var signInButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var signInButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    let defaults = UserDefaults.standard
    
    let userAuth = FirebaseAuthentication()
    
    var iProgressAttached: Bool = false
    
    var allowProgressAnimation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bpLabel.layer.cornerRadius = 0.5 * bpLabel.bounds.size.width
        bpLabel.clipsToBounds = true
        
        bpLabel.layer.borderWidth = 3
        bpLabel.layer.borderColor = UIColor.black.cgColor
        
        emailTextField.delegate = self
        
        passwordTextField.delegate = self
        
        signInButton.layer.cornerRadius = 22.5
        signInButton.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        checkBox.onAnimationType = BEMAnimationType.oneStroke
        checkBox.offAnimationType = BEMAnimationType.oneStroke
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = true
        
        tabBarController?.tabBar.isHidden = true
        
        let keepUserSignedIn = defaults.value(forKey: "keepUserSignedIn") as? Bool ?? false
        
        if let currentUser = Auth.auth().currentUser, keepUserSignedIn {
            
            automaticallySignInUser(user: currentUser)
        }
        
        else if keepUserSignedIn {
            
            checkBox.on = true
        }
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
    
    
    private func attachProgressAnimation (view: UIView, completion: (() -> Void)? = nil) {
        
        let iProgress: iProgressHUD = iProgressHUD()
        
        iProgress.isShowModal = false
        iProgress.isShowCaption = false
        iProgress.isTouchDismiss = false
        iProgress.boxColor = .clear
        
        iProgress.indicatorSize = 100
        
        iProgress.attachProgress(toView: view)
        
        view.updateIndicator(style: .ballClipRotate)
        
        completion?()
    }
    
    
    private func addSplashScreen () {
        
        var splashView: UIView {
            
            let view = UIView(frame: self.view.frame)
            view.backgroundColor = UIColor(hexString: "262626")
            return view
        }
        
        view.addSubview(splashView)
        
        var bpLabel: UILabel {
            
            let label = UILabel()
            
            label.frame.size = CGSize(width: 150, height: 150)
            label.center = view.center
            
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 50)
            label.numberOfLines = 2
            label.text = "BP"
            label.textAlignment = .center
            label.textColor = .white
            return label
        }
        
        view.addSubview(bpLabel)
        
//        var progressView: UIView {
//
//            let view = UIView()
//            view.frame.size = CGSize(width: 55, height: 55)
//            view.center = CGPoint(x: self.view.center.x, y: self.view.center.x + 75)
//            view.backgroundColor = .systemPink
//
//            return view
//        }
//
//        view.addSubview(progressView)
        
        attachProgressAnimation(view: self.view) {
            
            self.view.showProgress()
        }
        
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
                    
                    self.attachProgressAnimation(view: self.signInButton)
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
    
    private func animateSignInSkipped (completion: @escaping (() -> Void)) {
        
        skipViewWidthConstraint.constant = 2000
        skipViewHeightConstraint.constant = 2000
        
        UIView.animate(withDuration: 0.75, animations: {
            
            self.view.layoutIfNeeded()
            
        }) { (finished: Bool) in
            
            completion()
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
    
    private func automaticallySignInUser (user: User) {
        
        addSplashScreen()
        
        userAuth.retrieveSignedInUser(user) { (error) in
            
            self.view.dismissProgress()
            
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

            userAuth.logInUser(email: emailTextField.text!, password: passwordTextField.text!) { [weak self] (error) in
                
                if error != nil {
                    
                    self?.allowProgressAnimation = false

                    self?.animateSignInButton(shrink: false)

                    ProgressHUD.showError(error?.localizedDescription)
                    self?.signInButton.isEnabled = true
                }
                
                else {
                    
                    self?.signInButton.isEnabled = true

                    self?.userSignedIn()
                }
            }
        }
    }
    
    
    @IBAction func checkBox(_ sender: Any) {
        
        defaults.setValue(checkBox.on, forKey: "keepUserSignedIn")
    }
    
    
    @IBAction func keepMeSignedIn(_ sender: Any) {
        
        checkBox.setOn(!checkBox.on, animated: true)
        defaults.setValue(checkBox.on, forKey: "keepUserSignedIn")
    }
    
    @IBAction func signupButton(_ sender: Any) {
        
        
    }
    
    @IBAction func skipButton(_ sender: Any) {
        
        animateSignInSkipped {
            
            self.performSegue(withIdentifier: "moveToHomeView", sender: self)
        }
    }
    
    @objc private func dismissKeyboard () {
        
        view.endEditing(true)
    }
}
