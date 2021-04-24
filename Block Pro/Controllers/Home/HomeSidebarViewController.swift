//
//  HomeSidebarViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/17/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class HomeSidebarViewController: UIViewController {

    let sidebar = UIView()
    
    lazy var profilePicture = ProfilePicture(profilePic: currentUser.profilePictureImage, shadowRadius: 2.5, shadowColor: UIColor.white.cgColor, shadowOpacity: 0.5, borderColor: UIColor(hexString: "F4F4F4")!.withAlphaComponent(0.05).cgColor, borderWidth: 1)
    lazy var profilePictureProgressView = iProgressView(self, 100, .circleStrokeSpin)
    let profilePictureButton = UIButton()
    
    let nameLabelContainer = UIView()
    let nameLabel = UILabel()
    
    let exitButton = UIButton()
    
    let homeButton = UIButton(type: .system)
    let profileButton = UIButton(type: .system)
    let friendsButton = UIButton(type: .system)
    let privacyButton = UIButton(type: .system)
    let signOutButton = UIButton(type: .system)
    
    lazy var buttonsForSidebar: [UIButton] = [homeButton, profileButton, friendsButton, privacyButton, signOutButton]
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var buttonAnimationCompleted: Bool = false
    
    var sidebarLeadingAnchor: NSLayoutConstraint?
    
    weak var sidebarDelegate: SidebarProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureExitButton()
        
        configureSidebar()
        configureProfilePicture()
        configureProfilePictureProgressView()
        configureProfilePictureButton()
        
        configureNameLabelContainer()
        configureNameLabel()
        
        configureHomeButton()
        configureProfileButton()
        configureFriendsButton()
        configurePrivacyButton()
        configureSignOutButton()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        exitButton.addGestureRecognizer(pan)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateSidebar(toValue: -10)
    }
    
    
    //MARK: - Configure Exit Button
    
    private func configureExitButton () {
        
        self.view.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            exitButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            exitButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            exitButton.topAnchor.constraint(equalTo: self.view.topAnchor),
            exitButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        ].forEach({ $0.isActive = true })
        
        exitButton.addTarget(self, action: #selector(exitButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Sidebar
    
    private func configureSidebar () {
        
        self.view.addSubview(sidebar)
        sidebar.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            sidebar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            sidebar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            sidebar.widthAnchor.constraint(equalToConstant: 290)
        
        ].forEach({ $0.isActive = true })
        
        sidebarLeadingAnchor = sidebar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -290)
        sidebarLeadingAnchor?.isActive = true
        
        sidebar.backgroundColor = UIColor(hexString: "222222", withAlpha: 0.99)
    }
    
    
    //MARK: - Configure Profile Picture
    
    private func configureProfilePicture () {
        
        self.view.addSubview(profilePicture)
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            profilePicture.topAnchor.constraint(equalTo: self.view.topAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40),
            profilePicture.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25/*35*/),
            profilePicture.widthAnchor.constraint(equalToConstant: 60),
            profilePicture.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach({ $0.isActive = true })
        
        retrieveProfilePicture()
    }
    
    
    //MARK: - Configure Profile Picture Progress View

    private func configureProfilePictureProgressView () {

        if !currentUser.profilePictureRetrieved {
            
            self.view.addSubview(profilePictureProgressView)
            profilePictureProgressView.translatesAutoresizingMaskIntoConstraints = false

            [

                profilePictureProgressView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40),
                profilePictureProgressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
                profilePictureProgressView.widthAnchor.constraint(equalToConstant: 60),
                profilePictureProgressView.heightAnchor.constraint(equalToConstant: 60)

            ].forEach({ $0.isActive = true })

            profilePictureProgressView.backgroundColor = UIColor.black.withAlphaComponent(0.3)

            profilePictureProgressView.layer.cornerRadius = 30
            profilePictureProgressView.clipsToBounds = true
        }
    }
    
    
    //MARK: - Configure Profile Picture Button
    
    private func configureProfilePictureButton () {
        
        self.view.addSubview(profilePictureButton)
        profilePictureButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            profilePictureButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40),
            profilePictureButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25/*35*/),
            profilePictureButton.widthAnchor.constraint(equalToConstant: 60),
            profilePictureButton.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach({ $0.isActive = true })
        
        profilePictureButton.addTarget(self, action: #selector(exitButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Name Label Container
    
    private func configureNameLabelContainer () {
        
        self.view.addSubview(nameLabelContainer)
        nameLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabelContainer.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 25),
            nameLabelContainer.centerYAnchor.constraint(equalTo: profilePicture.centerYAnchor, constant: 0),
            nameLabelContainer.widthAnchor.constraint(equalToConstant: 170),
            nameLabelContainer.heightAnchor.constraint(equalToConstant: 60)
        
        ].forEach({ $0.isActive = true })
        
        nameLabelContainer.clipsToBounds = true
    }
    
    
    //MARK: - Configure Name Label
    
    private func configureNameLabel() {
        
        nameLabelContainer.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 125),
            nameLabel.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor, constant: -10),
            nameLabel.centerYAnchor.constraint(equalTo: nameLabelContainer.centerYAnchor, constant: 0),
            nameLabel.heightAnchor.constraint(equalToConstant: 50)
        
        ].forEach({ $0.isActive = true })
        
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 23)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .left
        
        nameLabel.text = currentUser.firstName
    }
    
    
    //MARK: - Configure Home Button
    
    private func configureHomeButton () {
        
        sidebar.addSubview(homeButton)
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            homeButton.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 35),
            homeButton.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor, constant: -15),
            homeButton.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 65),
            homeButton.heightAnchor.constraint(equalToConstant: 45)
        
        ].forEach({ $0.isActive = true })
        
        homeButton.tag = 1
        
        homeButton.backgroundColor = .white
        homeButton.tintColor = UIColor(hexString: "222222")
        homeButton.layer.cornerRadius = 8
        homeButton.clipsToBounds = true
        
        homeButton.contentHorizontalAlignment = .left

        homeButton.setImage(UIImage(systemName: "house.fill"), for: .normal)
        homeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        homeButton.setTitle("Home", for: .normal)
        homeButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 18)
        homeButton.titleEdgeInsets = UIEdgeInsets(top: 1, left: 40, bottom: -1, right: 0)
        
        homeButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        homeButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Profile Button
    
    private func configureProfileButton () {
        
        sidebar.addSubview(profileButton)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            profileButton.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 35),
            profileButton.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor, constant: -15),
            profileButton.topAnchor.constraint(equalTo: homeButton.bottomAnchor, constant: 30),
            profileButton.heightAnchor.constraint(equalToConstant: 45)
        
        ].forEach({ $0.isActive = true })
        
        profileButton.tag = 2
        
        profileButton.backgroundColor = .clear
        profileButton.tintColor = .white
        profileButton.layer.cornerRadius = 8
        profileButton.clipsToBounds = true
        
        profileButton.contentHorizontalAlignment = .left

        profileButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
        profileButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        profileButton.setTitle("Profile", for: .normal)
        profileButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 18)
        profileButton.titleEdgeInsets = UIEdgeInsets(top: 1, left: 49, bottom: -1, right: 0)
        
        profileButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        profileButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        profileButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
  
    //MARK: - Configure Friends Button
    
    private func configureFriendsButton () {
        
        sidebar.addSubview(friendsButton)
        friendsButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            friendsButton.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 35),
            friendsButton.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor, constant: -15),
            friendsButton.topAnchor.constraint(equalTo: profileButton.bottomAnchor, constant: 30),
            friendsButton.heightAnchor.constraint(equalToConstant: 45)
        
        ].forEach({ $0.isActive = true })
        
        friendsButton.tag = 3
        
        friendsButton.backgroundColor = .clear
        friendsButton.tintColor = .white
        friendsButton.layer.cornerRadius = 8
        friendsButton.clipsToBounds = true
        
        friendsButton.contentHorizontalAlignment = .left

        friendsButton.setImage(UIImage(systemName: "person.and.person.fill"), for: .normal)
        friendsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        friendsButton.setTitle("Friends", for: .normal)
        friendsButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 18)
        friendsButton.titleEdgeInsets = UIEdgeInsets(top: 1, left: 38, bottom: -1, right: 0)
        
        friendsButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        friendsButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        friendsButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Privacy Button
    
    private func configurePrivacyButton () {
        
        sidebar.addSubview(privacyButton)
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            privacyButton.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 35),
            privacyButton.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor, constant: -15),
            privacyButton.topAnchor.constraint(equalTo: friendsButton.bottomAnchor, constant: 30),
            privacyButton.heightAnchor.constraint(equalToConstant: 45)
        
        ].forEach({ $0.isActive = true })
        
        privacyButton.tag = 4
        
        privacyButton.backgroundColor = .clear
        privacyButton.tintColor = .white
        privacyButton.layer.cornerRadius = 8
        privacyButton.clipsToBounds = true
        
        privacyButton.contentHorizontalAlignment = .left

        privacyButton.setImage(UIImage(systemName: "lock.fill"), for: .normal)
        privacyButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        privacyButton.setTitle("Privacy", for: .normal)
        privacyButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 18)
        privacyButton.titleEdgeInsets = UIEdgeInsets(top: 1, left: 49.5, bottom: -1, right: 0)
        
        privacyButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        privacyButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        privacyButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Sign Out Button
    
    private func configureSignOutButton () {
        
        sidebar.addSubview(signOutButton)
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            signOutButton.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 35),
            signOutButton.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor, constant: -15),
            signOutButton.bottomAnchor.constraint(equalTo: sidebar.bottomAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? -40 : -25),
            signOutButton.heightAnchor.constraint(equalToConstant: 45)
        
        ].forEach({ $0.isActive = true })
        
        signOutButton.tag = 5
        
        signOutButton.backgroundColor = .clear
        signOutButton.tintColor = .white
        signOutButton.layer.cornerRadius = 8
        signOutButton.clipsToBounds = true
        
        signOutButton.contentHorizontalAlignment = .left

        signOutButton.setImage(UIImage(systemName: "return"), for: .normal)
        signOutButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 18)
        signOutButton.titleEdgeInsets = UIEdgeInsets(top: -3, left: 44, bottom: 3, right: 0)
        
        signOutButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        signOutButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        
        signOutButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    
    //MARK: - Animate Sidebar
    
    private func animateSidebar (toValue: CGFloat, completion: (() -> Void)? = nil) {
        
        sidebarLeadingAnchor?.constant = toValue
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.view.backgroundColor = (toValue == -10) ? UIColor.black.withAlphaComponent(0.2) : .clear
            
        } completion: { (finished: Bool) in
            
            guard let completion = completion else { return }
            
                completion()
        }
    }
    
    
    //MARK: - Handle Pan
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            moveWithPan(sender: sender)
            
        case .ended:
            
            if (sidebar.frame.maxX) > (view.frame.width / 2) {
                
                returnToOrigin()
            }
            
            else {
                
                dismissView()
            }
            
        default:
            break
        }
    }
    
    
    //MARK: - Move with Pan
    
    private func moveWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        if (sidebarLeadingAnchor?.constant ?? 0) + translation.x < -10 {
            
            sidebarLeadingAnchor?.constant += translation.x
            
            view.backgroundColor = UIColor.black.withAlphaComponent(0.2 - (0.2 / 290) * abs(sidebarLeadingAnchor?.constant ?? 0))
            
            sender.setTranslation(CGPoint.zero, in: view)
        }
        
        else {
            
            sidebarLeadingAnchor?.constant = -10
        }
    }
    
    
    //MARK: - Return to Origin
    
    private func returnToOrigin () {
        
        animateSidebar(toValue: -10, completion: nil)
    }
    
    
    //MARK: - Dismiss View
    
    private func dismissView () {

        animateSidebar(toValue: -290) {
            
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    
    //MARK: - Retrieve Profile Picture
    
    private func retrieveProfilePicture () {
        
        if let profilePic = currentUser.profilePictureImage {
            
            profilePicture.profilePic = profilePic
        }
        
        else {
            
            firebaseStorage.retrieveUserProfilePicFromStorage(userID: currentUser.userID) { [weak self] (profilePic, _) in
                
                if self != nil {
                    
                    UIView.transition(with: self!.profilePicture, duration: 0.3, options: .transitionCrossDissolve) {
                        
                        self?.profilePicture.profilePic = profilePic
                    }
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        self?.profilePictureProgressView.backgroundColor = .clear
                    }
                }
                
                self?.profilePictureProgressView.dismissProgress()
            }
        }
    }
    
    
    //MARK: - Button Touch Down
    
    @objc private func buttonTouchDown (sender: UIButton) {
        
        //Home Button
        if sender.tag == 1 {
            
            return
        }
        
        //Sign Out Button
        else if sender.tag == 5 {
            
            signOutButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 0)
        }
        
        UIView.transition(with: homeButton, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.homeButton.backgroundColor = .clear
            self.homeButton.tintColor = .white
        }
        
        UIView.transition(with: buttonsForSidebar[sender.tag - 1], duration: 0.3, options: .transitionCrossDissolve) {
            
            self.buttonsForSidebar[sender.tag - 1].backgroundColor = .white
            self.buttonsForSidebar[sender.tag - 1].tintColor = UIColor(hexString: "222222")
            
        } completion: { (finished: Bool) in
            
            self.buttonAnimationCompleted = true
        }
    }
    
    
    //MARK: - Button Touch Drag Exit
    
    @objc private func buttonTouchDragExit (sender: UIButton) {
        
        buttonAnimationCompleted = false
        
        //Home Button
        if sender.tag == 1 {
            
            return
        }
        
        //Sign Out Button
        else if sender.tag == 5 {
            
            signOutButton.titleEdgeInsets = UIEdgeInsets(top: -3, left: 44/*45*/, bottom: 3, right: 0)
        }
        
        UIView.transition(with: homeButton, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.homeButton.backgroundColor = .white
            self.homeButton.tintColor = UIColor(hexString: "222222")
        }
        
        UIView.transition(with: buttonsForSidebar[sender.tag - 1], duration: 0.3, options: .transitionCrossDissolve) {
            
            self.buttonsForSidebar[sender.tag - 1].backgroundColor = .clear
            self.buttonsForSidebar[sender.tag - 1].tintColor = .white
        }
    }
    
    
    //MARK: - Button Touch Up Inside
    
    @objc private func buttonTouchUpInside (sender: UIButton) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (sender.tag == 1 || buttonAnimationCompleted ? 0.15 : 0.3)) {
            
            self.animateSidebar(toValue: -290) {
                
                self.dismiss(animated: false, completion: nil)
                
                //Profile Button
                if sender.tag == 2 {
                    
                    self.sidebarDelegate?.moveToProfileView()
                }
                
                //Friends Button
                else if sender.tag == 3 {
                    
                    self.sidebarDelegate?.moveToFriendsView()
                }
                
                //Privacy Button
                else if sender.tag == 4 {
                    
                    self.sidebarDelegate?.moveToPrivacyView()
                }
                
                //Sign Out Button
                else if sender.tag == 5 {
                    
                    self.sidebarDelegate?.userSignedOut()
                }
            }
        }
    }
    
    
    //MARK: - Exit Button Pressed
    
    @objc private func exitButtonPressed () {
        
        animateSidebar(toValue: -290) {
            
            self.dismiss(animated: false, completion: nil)
        }
    }
}
