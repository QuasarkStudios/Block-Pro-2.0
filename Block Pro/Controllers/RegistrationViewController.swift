//
//  RegistrationViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/27/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var gifView: UIImageView!
    @IBOutlet weak var gifViewLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var gifViewTrailingAnchor: NSLayoutConstraint!
    @IBOutlet weak var gifViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var trackBar: UIView!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var letsLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var registrationCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backToSignInButton: UIButton!
    
    lazy var db = Firestore.firestore()
    
    var newUserInfo: [String : String] = [:]
    
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gifView.loadGif(name: "giphy")
        
        startButton.layer.cornerRadius = 22.5
        startButton.clipsToBounds = true
        
        view.bringSubviewToFront(welcomeLabel)
        view.bringSubviewToFront(backToSignInButton)
        
        trackBar.alpha = 0
        prevButton.alpha = 0
        nextButton.alpha = 0
        
        configureProgressBars()
        
        configureCollectionView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "registrationNameCell", for: indexPath) as! RegistrationNameCell
            
            cell.nameEnteredDelegate = self
            
            return cell
        }
        
        else if indexPath.row == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "registrationEmailCell", for: indexPath) as! RegistrationEmailCell

            cell.emailEnteredDelegate = self
            
            return cell
        }
        
        else if indexPath.row == 2 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "registrationUsernameCell", for: indexPath) as! RegistrationUsernameCell
            
            cell.usernameEnteredDelegate = self
            
            return cell
        }
        
        else if indexPath.row == 3 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "registrationPasswordCell", for: indexPath) as! RegistrationPasswordCell
            
            cell.passwordEnteredDelegate = self
            
            return cell
        }
        
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "registrationProfilePicCell", for: indexPath) as! RegistrationProfilePicCell
            
            return cell
        }
    }
    
    private func configureCollectionView () {
        
        registrationCollectionView.dataSource = self
        registrationCollectionView.delegate = self
        
        registrationCollectionView.register(UINib(nibName: "RegistrationNameCell", bundle: nil), forCellWithReuseIdentifier: "registrationNameCell")
        
        registrationCollectionView.register(UINib(nibName: "RegistrationEmailCell", bundle: nil), forCellWithReuseIdentifier: "registrationEmailCell")
        
        registrationCollectionView.register(UINib(nibName: "RegistrationUsernameCell", bundle: nil), forCellWithReuseIdentifier: "registrationUsernameCell")
        
        registrationCollectionView.register(UINib(nibName: "RegistrationPasswordCell", bundle: nil), forCellWithReuseIdentifier: "registrationPasswordCell")
        
        registrationCollectionView.register(UINib(nibName: "RegistrationProfilePicCell", bundle: nil), forCellWithReuseIdentifier: "registrationProfilePicCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 575)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        registrationCollectionView.collectionViewLayout = layout
        
        registrationCollectionView.isPagingEnabled = true
        
        registrationCollectionView.showsHorizontalScrollIndicator = false
        
        registrationCollectionView.isScrollEnabled = false
        
        registrationCollectionView.backgroundColor = .clear
        
        collectionViewHeightConstraint.constant = 0
    }
    
    private func configureProgressBars () {
        
        trackBar.layer.cornerRadius = 7.5
        trackBar.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            trackBar.layer.cornerCurve = .continuous
        }
        
        progressBar.layer.cornerRadius = 5.5
        progressBar.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            progressBar.layer.cornerCurve = .continuous
        }

        progressBarWidthConstraint.constant = 0
    }
    
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
    
    private func validateEntries () {
        
        if selectedIndex == 0 {
            
            if validateText(newUserInfo["firstName"] ?? "") && validateText(newUserInfo["lastName"] ?? "") {
                
                moveToNextRow()
            }
            
            else {
                
                let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! RegistrationNameCell
                
                if !validateText(newUserInfo["firstName"] ?? "") {
                    
                    cell.firstNameErrorLabel.isHidden = false
                }
                
                if !validateText(newUserInfo["lastName"] ?? "") {
                    
                    cell.lastNameErrorLabel.isHidden = false
                }
            }
        }
        
        else if selectedIndex == 1 {
            
            if validateText(newUserInfo["email"] ?? "") {
                
                let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as! RegistrationEmailCell
                
                cell.emailErrorLabel.text = "Verifying..."
                cell.emailErrorLabel.textColor = .black
                cell.emailErrorLabel.isHidden = false
                
                cell.progressView.showProgress()
                
                Auth.auth().fetchSignInMethods(forEmail: newUserInfo["email"] ?? "") { (email, error) in
                    
                    if error != nil {
                        
                        cell.emailErrorLabel.textColor = .systemRed
                        cell.emailErrorLabel.text = error?.localizedDescription
                        
                        cell.progressView.dismissProgress()
                    }
                    
                    else {
                        
                        if email != nil {
                            
                            cell.emailErrorLabel.textColor = .systemRed
                            cell.emailErrorLabel.text = "Sorry, but this email is already being used"
                            
                            cell.progressView.dismissProgress()
                        }
                            
                        else {
                            
                            cell.progressView.dismissProgress()
                            
                            cell.emailErrorLabel.isHidden = true
                            
                            self.moveToNextRow()
                        }
                    }
                }
            }
            
            else {
                
                let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as! RegistrationEmailCell
                
                cell.emailErrorLabel.textColor = .systemRed
                cell.emailErrorLabel.text = "Please enter in your E-mail Address"
                cell.emailErrorLabel.isHidden = false
            }
        }
        
        else if selectedIndex == 2 {
            
            if validateText(newUserInfo["username"] ?? "") {
                
                let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as! RegistrationUsernameCell
                
                cell.usernameErrorLabel.text = "Verifying..."
                cell.usernameErrorLabel.textColor = .black
                cell.usernameErrorLabel.isHidden = false
                
                cell.progressView.showProgress()
                
                db.collection("Users").whereField("username", isEqualTo: newUserInfo["username"] ?? "").getDocuments { (snapshot, error) in
                    
                    if error != nil {
                        
                        ProgressHUD.showError(error?.localizedDescription)
                        
                        cell.progressView.dismissProgress()
                    }
                    
                    else {
                        
                        if snapshot?.isEmpty == false {
                            
                            cell.usernameErrorLabel.textColor = .systemRed
                            cell.usernameErrorLabel.text = "Sorry, but this username is already being used"
                            
                            cell.progressView.dismissProgress()
                        }
                        
                        else {
                            
                            cell.progressView.dismissProgress()
                            
                            cell.usernameErrorLabel.isHidden = true
                            
                            self.moveToNextRow()
                        }
                    }
                }
            }
            
            else {
                
                let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as! RegistrationUsernameCell
                
                cell.usernameErrorLabel.textColor = .systemRed
                cell.usernameErrorLabel.text = "Please enter in a username"
                cell.usernameErrorLabel.isHidden = false
            }
        }
        
        else if selectedIndex == 3 {
            
            if validateText(newUserInfo["password"] ?? "") && validateText(newUserInfo["passwordRentry"] ?? "") {
                
                if newUserInfo["password"] ?? "" == newUserInfo["passwordRentry"] ?? "" {
                    
                    let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 3, section: 0)) as! RegistrationPasswordCell
                    
                    cell.passwordRentryErrorLabel.text = "Verifying..."
                    cell.passwordRentryErrorLabel.textColor = .black
                    cell.passwordRentryErrorLabel.isHidden = false
                    
                    cell.progressView.showProgress()
                    
                    Auth.auth().createUser(withEmail: newUserInfo["email"]!, password: newUserInfo["password"]!) { (authResult, error) in

                        if error != nil {

                            cell.passwordRentryErrorLabel.textColor = .systemRed
                            cell.passwordRentryErrorLabel.text = error?.localizedDescription

                            cell.progressView.dismissProgress()
                        }

                        else {

                            guard let userID = authResult?.user.uid else {

                                ProgressHUD.showError("Sorry, something went wrong while making your account. Please try again!")

                                cell.progressView.dismissProgress()

                                return
                            }

                            self.createNewUser(userID: userID) {

                                //cell.progressView.dismissProgress()

                                self.moveToNextRow()
                            }
                        }
                    }
                    
                    moveToNextRow()
                }
                
                else {
                    
                    let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 3, section: 0)) as! RegistrationPasswordCell
                    
                    cell.passwordRentryErrorLabel.textColor = .systemRed
                    cell.passwordRentryErrorLabel.text = "Sorry, but your passwords don't match"
                    cell.passwordRentryErrorLabel.isHidden = false
                }
            }
            
            else {
                
                let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 3, section: 0)) as! RegistrationPasswordCell
                
                if !validateText(newUserInfo["password"] ?? "") {
                    
                    cell.passwordErrorLabel.textColor = .systemRed
                    cell.passwordErrorLabel.text = "Please enter your password"
                    cell.passwordErrorLabel.isHidden = false
                }
                
                if !validateText(newUserInfo["passwordRentry"] ?? "") {
                    
                    cell.passwordRentryErrorLabel.textColor = .systemRed
                    cell.passwordRentryErrorLabel.text = "Please re-enter your password"
                    cell.passwordRentryErrorLabel.isHidden = false
                }
            }
        }
        
        nextButton.isEnabled = true
    }
    
    private func createNewUser (userID: String, completion: (() -> Void)) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        
        db.collection("Users").document(userID).setData(["userID" : userID, "firstName" : newUserInfo["firstName"]!, "lastName" : newUserInfo["lastName"]!, "username" : newUserInfo["username"]!, "accountCreated" : formatter.string(from: Date())] )
        
        completion()
    }
    
    private func moveToNextRow () {
        
        selectedIndex += 1
        
        progressBarWidthConstraint.constant = ((trackBar.frame.width - 6) / 4) * CGFloat(selectedIndex)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.layoutIfNeeded()
            
            if self.selectedIndex == 4 {
                
                self.prevButton.alpha = 0
                self.nextButton.alpha = 0
            }
            
        })
        
        if !prevButton.isEnabled {
            
            prevButton.setTitleColor(.black, for: .normal)
            prevButton.isEnabled = true
        }
        
        registrationCollectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    private func moveToPreviousRow () {
        
        selectedIndex -= 1
        
        progressBarWidthConstraint.constant = ((trackBar.frame.width - 6) / 4) * CGFloat(selectedIndex)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.layoutIfNeeded()
            
        })
        
        if selectedIndex == 0 {
            
            prevButton.setTitleColor(UIColor(hexString: "AAAAAA"), for: .normal)
            prevButton.isEnabled = false
        }
        
        registrationCollectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func startButton(_ sender: Any) {
        
        gifViewLeadingAnchor.constant = 125
        gifViewTrailingAnchor.constant = 125
        gifViewHeightConstraint.constant = 75
        
        collectionViewHeightConstraint.constant = 575
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.layoutIfNeeded()
            
            self.welcomeLabel.alpha = 0
            self.letsLabel.alpha = 0
            self.startButton.alpha = 0
            
        }) { (finished: Bool) in
            
            self.welcomeLabel.removeFromSuperview()
            self.letsLabel.removeFromSuperview()
            self.startButton.removeFromSuperview()
            
            self.prevButton.isEnabled = false
            self.prevButton.setTitleColor(UIColor(hexString: "AAAAAA"), for: .normal)
            
            UIView.animate(withDuration: 0.5) {
                
                self.trackBar.alpha = 1
                self.prevButton.alpha = 1
                self.nextButton.alpha = 1
            }
        }
    }
    
    @IBAction func prevButton(_ sender: Any) {
        
        moveToPreviousRow()
        
        dismissKeyboard()
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
        
        nextButton.isEnabled = false
        
        validateEntries()
        
        dismissKeyboard()
        
        print(newUserInfo)
    }
    
    
    @IBAction func backToSignInButton(_ sender: Any) {
        
        navigationController?.popToRootViewController(animated: false)
    }
    
    @objc func dismissKeyboard () {
        
        view.endEditing(true)
    }
}

extension RegistrationViewController: NameEntered {
    
    func firstNameEntered (firstName: String) {
        
        newUserInfo["firstName"] = firstName
    }
    
    func lastNameEntered (lastName: String) {
        
        newUserInfo["lastName"] = lastName
    }
}

extension RegistrationViewController: EmailEntered {
    
    func emailEntered(email: String) {
        
        newUserInfo["email"] = email
    }
}

extension RegistrationViewController: UsernameEntered {
    
    func usernameEntered(username: String) {
        
        newUserInfo["username"] = username
    }
}

extension RegistrationViewController: PasswordEntered {
    
    func passwordEntered(password: String) {
        
        newUserInfo["password"] = password
    }
    
    func passwordRentryEntered(passwordRentry: String) {
        
        newUserInfo["passwordRentry"] = passwordRentry
    }
}

