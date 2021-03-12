//
//  ProfilePopoverViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/22/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol MoveToProfile: AnyObject {
    
    func moveToProfileView ()
}

class ProfileSidebarViewController: UIViewController {

    @IBOutlet weak var profileSidebar: UIView!
    @IBOutlet weak var sidebarLeadingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageContainer: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    let firebaseAuthentication = FirebaseAuthentication()
    let currentUser = CurrentUser.sharedInstance
    
    var viewInitiallyLoaded: Bool = false
    
    weak var moveToProfileDelegate: MoveToProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
        configureSideBar()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        
        dismissButton.addGestureRecognizer(pan)
        
        //If the profile picture hasn't finished downloading from Firebase
        if currentUser.profilePictureURL != nil && currentUser.profilePictureImage == nil {
            
            //Adds an observor watching for when the profile pic finishes loading
            NotificationCenter.default.addObserver(self, selector: #selector(profilePicLoaded), name: .didDownloadProfilePic, object: nil)
        }
        
        else if let profilePic = currentUser.profilePictureImage {
            
            profileImage.image = profilePic
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        if viewInitiallyLoaded == false {
            
            animateSideBar(toValue: -10) {
                
                UIView.animate(withDuration: 0.4) {

                    self.profileImageContainer.alpha = 1
                }
            }
            
            viewInitiallyLoaded = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: .didDownloadProfilePic, object: nil)
    }
    
    private func configureSideBar () {
        
        profileSidebar.backgroundColor = UIColor(hexString: "262626", withAlpha: 0.99)
        
        sidebarLeadingAnchor.constant = -290
        
        profileImageContainer.alpha = 0
        
        profileImageContainer.layer.cornerRadius = 0.5 * profileImageContainer.frame.size.width
        
        profileImageContainer.layer.shadowRadius = 4
        profileImageContainer.layer.shadowColor = UIColor.white.cgColor
        profileImageContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        profileImageContainer.layer.shadowOpacity = 1
        
        profileImageContainer.clipsToBounds = false
        profileImageContainer.layer.masksToBounds = false
        
        profileImage.layer.cornerRadius = 0.5 * profileImage.frame.size.width
        profileImage.clipsToBounds = true
        

    }

    private func animateSideBar (toValue: CGFloat, completion: (() -> Void)? = nil) {
        
        sidebarLeadingAnchor.constant = toValue
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            
            self.view.layoutIfNeeded()
            
            self.view.backgroundColor = (toValue == -10) ? UIColor.black.withAlphaComponent(0.2) : .clear
            
        }) { (finished: Bool) in
            
            guard let completion = completion else { return }
            
                completion()
        }
    }
    
    @objc private func profilePicLoaded () {
        
        guard let profilePic = currentUser.profilePictureImage else { return }
        
            profileImage.image = profilePic
    }
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
        
            moveWithPan(sender: sender)
            
        case .ended:
            
            if (profileSidebar.frame.maxX) > (view.frame.width / 2) {
                
                returnToOrigin()
            }
            
            else {
                
                dismissView()
            }
            
        default:
            break
        }
    }
    
    private func moveWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        if (sidebarLeadingAnchor.constant + translation.x) < -10 {
            
            sidebarLeadingAnchor.constant += translation.x
            
            view.backgroundColor = UIColor.black.withAlphaComponent(0.2 - (0.2 / 290) * abs(sidebarLeadingAnchor.constant))
            
            sender.setTranslation(CGPoint.zero, in: view)
        }
        
        else {
            
            sidebarLeadingAnchor.constant = -10
        }
    }
    
    private func returnToOrigin () {
        
        animateSideBar(toValue: -10, completion: nil)
    }
    
    private func dismissView () {

        animateSideBar(toValue: -290) {
            
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func profileButton(_ sender: Any) {
        
        animateSideBar(toValue: -290) {
            
            self.moveToProfileDelegate?.moveToProfileView()
        }
    }
    
    
    @IBAction func signOutButton(_ sender: Any) {
        
        ProgressHUD.show()
        
        firebaseAuthentication.logOutUser { (error) in
            
            if error != nil {
                
                ProgressHUD.showError(error?.localizedDescription)
            }
            
            else {
                
                ProgressHUD.showSuccess("Signed Out")
            }
        }
        
//        do {
//
//            try Auth.auth().signOut()
//
//            ProgressHUD.showSuccess("Signed Out")
//            //print("user signed out")
//
//        } catch let signOutError as NSError {
//
//            ProgressHUD.showError(signOutError.localizedDescription)
//
//            print(signOutError.localizedDescription)
//        }
    }
    
    
    @IBAction func exitButton(_ sender: Any) {

        animateSideBar(toValue: -290) {
            
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
}
