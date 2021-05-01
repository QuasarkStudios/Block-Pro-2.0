//
//  RegistrationViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/27/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewController2: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

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
    @IBOutlet weak var collectionViewTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var backToSignInButton: UIButton!
    
    let userAuth = FirebaseAuthentication()
    
    var newUser = NewUser()
    
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
    
    
    //MARK: - Registration CollectionView Datasource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 4
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "registrationNameCell", for: indexPath) as! RegistrationNameCell
            
            cell.nameEnteredDelegate = self
            
            return cell
        }
        
        else if indexPath.row == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "registrationUsernameCell", for: indexPath) as! RegistrationUsernameCell
            
            cell.usernameEnteredDelegate = self
            
            return cell
        }
        
        else if indexPath.row == 2 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "registrationAccountCreationCell", for: indexPath) as! RegistrationAccountCreationCell
            
            cell.accountLogInInfoEnteredDelegate = self
            
            return cell
        }
        
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "registrationProfilePicCell", for: indexPath) as! RegistrationProfilePicCell
            
            cell.addProfilePictureDelegate = self
            
            return cell
        }
    }
    
    
    //MARK: - Configuring the Registration CollectionView
    
    private func configureCollectionView () {
        
        registrationCollectionView.dataSource = self
        registrationCollectionView.delegate = self
        
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
        
        collectionViewTopAnchor.constant = self.view.frame.height
        
        registrationCollectionView.register(UINib(nibName: "RegistrationNameCell", bundle: nil), forCellWithReuseIdentifier: "registrationNameCell")
        registrationCollectionView.register(UINib(nibName: "RegistrationUsernameCell", bundle: nil), forCellWithReuseIdentifier: "registrationUsernameCell")
        registrationCollectionView.register(UINib(nibName: "RegistrationAccountCreationCell", bundle: nil), forCellWithReuseIdentifier: "registrationAccountCreationCell")
        registrationCollectionView.register(UINib(nibName: "RegistrationProfilePicCell", bundle: nil), forCellWithReuseIdentifier: "registrationProfilePicCell")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        nextButton.isEnabled = true
    }
    
    //MARK: - Configuring the Progress Bars
    
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
    
    
    //MARK: - Validation of User Entries
    
    private func validateEntries () {
        
        if selectedIndex == 0 {
            
            validateName { (validated) in
                
                if validated {
                    
                    self.moveToNextRow()
                }
                
                else {
                    
                    self.nextButton.isEnabled = true
                }
            }
        }
        
        else if selectedIndex == 1 {
            
            validateUsername { (validated) in
                
                if validated {
                    
                    self.moveToNextRow()
                }
                
                else {
                    
                    self.nextButton.isEnabled = true
                }
            }
        }
        
        else if selectedIndex == 2 {
            
            //Validation of a the user's account info and the creation of their account
            validateAccountInfoAndCreateUser { (validated, userID) in
                
                if let userID = userID, validated {
                    
                    self.createNewUser(userID: userID) {
                        
                        self.moveToNextRow()
                    }
                }
                
                else {
                    
                    self.nextButton.isEnabled = true
                }
            }
        }
    }

    
    //MARK: - Saving New User to Database
    
    private func createNewUser (userID: String, completion: @escaping (() -> Void)) {
        
        userAuth.createNewUser(userID: userID, newUser: newUser) {
            
            completion()
        }
    }
    
    
    //MARK: - CollectionView Navigation Functions
    
    private func moveToNextRow () {
        
        selectedIndex += 1
        
        progressBarWidthConstraint.constant = ((trackBar.frame.width - 6) / 3) * CGFloat(selectedIndex)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.layoutIfNeeded()
            
            //If the user has completed the registration process
            if self.selectedIndex == 3 {
                
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
        
        progressBarWidthConstraint.constant = ((trackBar.frame.width - 6) / 3) * CGFloat(selectedIndex)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.layoutIfNeeded()
            
        })
        
        if selectedIndex == 0 {
            
            prevButton.setTitleColor(UIColor(hexString: "AAAAAA"), for: .normal)
            prevButton.isEnabled = false
        }
        
        registrationCollectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    
    //MARK: - Buttons
    
    @IBAction func startButton(_ sender: Any) {
        
        gifViewLeadingAnchor.constant = 125
        gifViewTrailingAnchor.constant = 125
        gifViewHeightConstraint.constant = 75
        
        collectionViewTopAnchor.constant = 125 // set to a value that will work on all phones later
        
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
    }
    
    
    @IBAction func backToSignInButton(_ sender: Any) {
        
        navigationController?.popToRootViewController(animated: false)
    }
    
    @objc func dismissKeyboard () {
        
        view.endEditing(true)
    }
}


//MARK: - Registration View Extensions

extension RegistrationViewController2: NameEntered {
    
    func firstNameEntered (firstName: String) {
        
        newUser.firstName = firstName
    }
    
    func lastNameEntered (lastName: String) {
        
        newUser.lastName = lastName
    }
}

extension RegistrationViewController2: UsernameEntered {
    
    func usernameEntered(username: String) {
        
        newUser.username = username
    }
}

extension RegistrationViewController2: AccountLogInInfoEntered {
    
    func emailEntered (email: String) {
        
        newUser.email = email
    }
    
    func passwordEntered(password: String) {
        
        newUser.password = password
    }
    
    func passwordReentryEntered(passwordReentry: String) {
        
        newUser.passwordReentry = passwordReentry
    }
}

extension RegistrationViewController2: AddProfilePicture, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func skipButtonPressed() {
        
        performSegue(withIdentifier: "moveToHomeView", sender: self)
    }
    
    
    func presentImagePickerController () {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        //If the user edited the picture
        if let editedImage = info[.editedImage] {
            
            selectedImageFromPicker = editedImage as? UIImage
        }
        
        //If the user selected an unedited picture
        else if let originalImage = info[.originalImage] {
            
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            let firebaseStorage = FirebaseStorage()
            firebaseStorage.saveProfilePictureToStorage(selectedImage)
            
            if let cell = registrationCollectionView.cellForItem(at: IndexPath(item: 3, section: 0)) as? RegistrationProfilePicCell {
                
                cell.profileImage.image = selectedImage
                cell.skipButton.setTitle("Finish", for: .normal)
            }
            
            else {
                
                dismiss(animated: true, completion: nil)
                ProgressHUD.showError("Sorry, something went wrong saving your profile picture")
            }
        }

        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
}
