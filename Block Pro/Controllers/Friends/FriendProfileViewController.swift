//
//  FriendProfileViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/17/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class FriendProfileViewController: UIViewController {

    let profileView = UIView()
    
    let zoomingProfilePicture = UIImageView()
    let profileViewProfilePicture = ProfilePicture(shadowColor: UIColor.clear.cgColor, shadowOpacity: 0.25, borderColor: UIColor.clear.cgColor)
    
    let addFriendButton = UIButton(type: .system)
    
    let nameLabel = UILabel()
    let delete_RescindButton = UIButton(type: .system)
    let dateLabel = UILabel()
    
    let zoomingOutNameLabel = UILabel()
    let zoomingOutUsernameLabel = UILabel()
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var friendCell: FriendCell? {
        didSet {
            
            retrieveProfilePic()
            
            if let friend = firebaseCollab.friends.first(where: { $0.userID == friendCell?.friend?.userID }), friend.accepted == true {
                
                delete_RescindButton.setTitle("Delete", for: .normal)
            }
            
            else {
                
                delete_RescindButton.setTitle("Rescind", for: .normal)
            }
            
            setDateLabelText()
        }
    }
    
    var friendCellProfilePictureFrame: CGRect?
    var friendCellNameLabelFrame: CGRect?
    var friendCellUsernameLabelFrame: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackgroundCancelButton()
        configureProfileView()
        configureCancelButton()
        configureProfilePicture()
        configureDelete_RescindButton()
        configureDateLabel()
        
        configureZoomingOutNameLabel()
        configureZoomingOutUsernameLabel()
    }
    
    
    //MARK: - Configure Background Cancel Button
    
    private func configureBackgroundCancelButton () {
        
        let backgroundCancelButton = UIButton()
        backgroundCancelButton.frame = self.view.frame
        backgroundCancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        
        self.view.addSubview(backgroundCancelButton)
    }
    
    
    //MARK: - Configure Profile View
    
    private func configureProfileView () {
        
        self.view.addSubview(profileView)
        profileView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            profileView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            profileView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            profileView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            profileView.heightAnchor.constraint(equalToConstant: 342)
        
        ].forEach({ $0.isActive = true })
        
        profileView.alpha = 0
        profileView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        
        profileView.layer.cornerRadius = 15
        profileView.clipsToBounds = true
    }
    
    
    //MARK: - Configure Cancel Button
    
    private func configureCancelButton () {
        
        //Can't use a normal button because it will interfere with the view dismissal animations for unknown reasons
        let cancelButton = UIView()
        
        let cancelImageBackground = UIView()
        let cancelImage = UIImageView(image: UIImage(systemName: "xmark.circle")?.withRenderingMode(.alwaysTemplate))
        
        profileView.addSubview(cancelButton)
        cancelButton.addSubview(cancelImageBackground)
        cancelImageBackground.addSubview(cancelImage)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelImageBackground.translatesAutoresizingMaskIntoConstraints = false
        cancelImage.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            cancelButton.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 15),
            cancelButton.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -15),
            cancelButton.widthAnchor.constraint(equalToConstant: 32.5),
            cancelButton.heightAnchor.constraint(equalToConstant: 32.5),
            
            cancelImageBackground.centerXAnchor.constraint(equalTo: cancelButton.centerXAnchor, constant: 0),
            cancelImageBackground.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor, constant: 0),
            cancelImageBackground.widthAnchor.constraint(equalToConstant: 22.5),
            cancelImageBackground.heightAnchor.constraint(equalToConstant: 22.5),
            
            cancelImage.centerXAnchor.constraint(equalTo: cancelButton.centerXAnchor, constant: 0),
            cancelImage.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor, constant: 0),
            cancelImage.widthAnchor.constraint(equalToConstant: 35),
            cancelImage.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        cancelButton.backgroundColor = UIColor(hexString: "222222")
        cancelButton.layer.cornerRadius = 32.5 * 0.5
        cancelButton.clipsToBounds = true
        
        cancelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelButtonPressed)))
        
        cancelImageBackground.backgroundColor = .clear
        cancelImageBackground.layer.cornerRadius = 22.5 * 0.5
        cancelImageBackground.clipsToBounds = true
        
        cancelImage.backgroundColor = .clear
        cancelImage.tintColor = .white
    }
    
    
    //MARK: - Configure Zooming Profile Picture
    
    private func configureZoomingProfilePicture (_ profilePic: UIImage?) {

        self.view.addSubview(zoomingProfilePicture)
        zoomingProfilePicture.translatesAutoresizingMaskIntoConstraints = false

        [

            zoomingProfilePicture.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 25),
            zoomingProfilePicture.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 40),
            zoomingProfilePicture.widthAnchor.constraint(equalToConstant: 125),
            zoomingProfilePicture.heightAnchor.constraint(equalToConstant: 125)

        ].forEach({ $0.isActive = true })
        
        zoomingProfilePicture.frame = friendCellProfilePictureFrame ?? .zero
        zoomingProfilePicture.contentMode = .scaleAspectFill
        zoomingProfilePicture.image = profilePic ?? UIImage(named: "DefaultProfilePic")
        zoomingProfilePicture.layer.cornerRadius = 26.5
        zoomingProfilePicture.clipsToBounds = true
    }
    
    
    //MARK: - Configure Profile Picture
    
    private func configureProfilePicture () {

        profileView.addSubview(profileViewProfilePicture)
        profileViewProfilePicture.translatesAutoresizingMaskIntoConstraints = false

        [

            profileViewProfilePicture.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 25),
            profileViewProfilePicture.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 40),
            profileViewProfilePicture.widthAnchor.constraint(equalToConstant: 125),
            profileViewProfilePicture.heightAnchor.constraint(equalToConstant: 125)

        ].forEach({ $0.isActive = true })
        
        profileViewProfilePicture.isHidden = true
    }
    
    
    //MARK: - Configure Delete/Rescind Button
    
    private func configureDelete_RescindButton () {
        
        profileView.addSubview(delete_RescindButton)
        delete_RescindButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            delete_RescindButton.topAnchor.constraint(equalTo: profileViewProfilePicture.bottomAnchor, constant: 5),
            delete_RescindButton.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -20),
            delete_RescindButton.widthAnchor.constraint(equalToConstant: 90),
            delete_RescindButton.heightAnchor.constraint(equalToConstant: 30),
        
        ].forEach({ $0.isActive = true })
        
        delete_RescindButton.alpha = 0
        delete_RescindButton.backgroundColor = .flatRed()
        delete_RescindButton.tintColor = .white
        
        delete_RescindButton.layer.cornerRadius = 15
        delete_RescindButton.layer.cornerCurve = .continuous
        delete_RescindButton.clipsToBounds = true
        
        delete_RescindButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        
        delete_RescindButton.addTarget(self, action: #selector(presentDelete_RescindAlert), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Name Label
    
    private func configureNameLabel() {
        
        self.view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 32),
            nameLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -32),
            nameLabel.topAnchor.constraint(equalTo: delete_RescindButton.bottomAnchor, constant: 5),
            nameLabel.heightAnchor.constraint(equalToConstant: 48)
        
        ].forEach({ $0.isActive = true })
        
        nameLabel.frame = CGRect(x: friendCellNameLabelFrame?.minX ?? 0, y: friendCellNameLabelFrame?.minY ?? 0, width: friendCellNameLabelFrame?.width ?? 0, height: 48)
        nameLabel.numberOfLines = 2
        
        let nameText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let usernameText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-MediumItalic", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        
        let attributedString = NSMutableAttributedString(string: "")
        
        if let firstName = friendCell?.friend?.firstName, let lastName = friendCell?.friend?.lastName, let username = friendCell?.friend?.username {
            
            attributedString.append(NSAttributedString(string: firstName + " " + lastName, attributes: nameText))
            attributedString.append(NSAttributedString(string: "\n"))
            attributedString.append(NSAttributedString(string: "@" + username, attributes: usernameText))
            
            nameLabel.attributedText = attributedString
        }
    }
    
    
    //MARK: - Configure Date Label
    
    private func configureDateLabel () {
        
        profileView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            dateLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 32),
            dateLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -32),
            dateLabel.topAnchor.constraint(equalTo: delete_RescindButton.bottomAnchor, constant: 68),
            dateLabel.heightAnchor.constraint(equalToConstant: 48)
            
        ].forEach({ $0.isActive = true })
        
        dateLabel.alpha = 0
        dateLabel.numberOfLines = 2
    }
    
    
    //MARK: Configure Zooming Out Name Label
    
    private func configureZoomingOutNameLabel () {
        
        self.view.addSubview(zoomingOutNameLabel)
        zoomingOutNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            zoomingOutNameLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 32),
            zoomingOutNameLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -32),
            zoomingOutNameLabel.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 205),
            zoomingOutNameLabel.heightAnchor.constraint(equalToConstant: 26.5)
            
        ].forEach({ $0.isActive = true })
        
        zoomingOutNameLabel.isHidden = true
        zoomingOutNameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        zoomingOutNameLabel.textAlignment = .left
        zoomingOutNameLabel.textColor = .black
        
        if let friend = friendCell?.friend {
            
            zoomingOutNameLabel.text = friend.firstName + " " + friend.lastName
        }
    }
    
    
    //MARK: - Configure Zooming Out Username Label
    
    private func configureZoomingOutUsernameLabel () {
        
        self.view.addSubview(zoomingOutUsernameLabel)
        zoomingOutUsernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            zoomingOutUsernameLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 32),
            zoomingOutUsernameLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -32),
            zoomingOutUsernameLabel.bottomAnchor.constraint(equalTo: zoomingOutNameLabel.bottomAnchor, constant: 0),
            zoomingOutUsernameLabel.heightAnchor.constraint(equalToConstant: 26.5)
        
        ].forEach({ $0.isActive = true })
        
        zoomingOutUsernameLabel.isHidden = true
        zoomingOutUsernameLabel.font = UIFont(name: "Poppins-MediumItalic", size: 15)
        zoomingOutUsernameLabel.textAlignment = .left
        zoomingOutUsernameLabel.textColor = .lightGray
        
        if let username = friendCell?.friend?.username {
            
            zoomingOutUsernameLabel.text = "@\(username)"
        }
    }
    
    
    //MARK: - Perform Zoom Presentation Animation
    
    func performZoomPresentationAnimation () {
        
        if let profilePicture = friendCell?.profilePicture, let profilePictureStartingFrame = profilePicture.superview?.convert(profilePicture.frame, to: self.view), let cellNameLabel = friendCell?.nameLabel, let cellNameLabelStartingFrame = cellNameLabel.superview?.convert(cellNameLabel.frame, to: self.view), let cellUsernameLabel = friendCell?.usernameLabel, let cellUsernameLabelStartingFrame = cellUsernameLabel.superview?.convert(cellUsernameLabel.frame, to: self.view)  {
            
            friendCellProfilePictureFrame = profilePictureStartingFrame
            friendCellNameLabelFrame = cellNameLabelStartingFrame
            friendCellUsernameLabelFrame = cellUsernameLabelStartingFrame
            
            configureZoomingProfilePicture(profilePicture.profilePic)
            configureNameLabel()
            
            //Hiding the subviews of the friendCell
            profilePicture.isHidden = true
            friendCell?.nameLabel.isHidden = true
            friendCell?.usernameLabel.isHidden = true
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1, options: .curveEaseInOut) {
                
                self.view.layoutIfNeeded()
                
                self.zoomingProfilePicture.layer.cornerRadius = 62.5
                
            } completion: { (finished: Bool) in
                
                self.zoomingProfilePicture.isHidden = true
                self.profileViewProfilePicture.isHidden = false
                
                //Animated the shadow and the border of the profileViewProfilePicture
                self.animateShadowsAndBorder()
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                self.profileView.alpha = 1
                self.delete_RescindButton.alpha = 1
                self.dateLabel.alpha = 1
            }
        }
    }
    
    
    //MARK: - Shadow and Border Animation
    
    private func animateShadowsAndBorder () {
        
        let profilePictureShadowAnimation = CABasicAnimation(keyPath: "shadowColor")
        profilePictureShadowAnimation.fromValue = UIColor.clear.cgColor
        profilePictureShadowAnimation.toValue = UIColor(hexString: "39434A")!.cgColor
        profilePictureShadowAnimation.duration = 0.3
        profileViewProfilePicture.layer.add(profilePictureShadowAnimation, forKey: nil)
        profileViewProfilePicture.layer.shadowColor = UIColor(hexString: "39434A")!.cgColor
        
        let profilePictureBorderAnimation = CABasicAnimation(keyPath: "borderColor")
        profilePictureBorderAnimation.fromValue = UIColor.clear.cgColor
        profilePictureBorderAnimation.toValue = UIColor(hexString: "F4F4F4")?.withAlphaComponent(0.05).cgColor
        profilePictureBorderAnimation.duration = 0.3
        profileViewProfilePicture.layer.add(profilePictureBorderAnimation, forKey: nil)
        profileViewProfilePicture.layer.borderColor = UIColor(hexString: "F4F4F4")?.withAlphaComponent(0.05).cgColor
    }
    
    
    //MARK: - Retrieve Profile Pic
    
    private func retrieveProfilePic () {
        
        if let profilePic = firebaseCollab.friends.first(where: { $0.userID == friendCell?.friend?.userID })?.profilePictureImage {
            
            profileViewProfilePicture.profilePic = profilePic
        }
        
        else {
            
            firebaseStorage.retrieveUserProfilePicFromStorage(userID: friendCell?.friend?.userID ?? "") { [weak self] (profilePic, _) in
                
                self?.profileViewProfilePicture.profilePic = profilePic
            }
        }
    }
    
    
    //MARK: - Set Date Label Text
    
    private func setDateLabelText () {
        
        let titleText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let dateText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Italic", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]

        let attributedString = NSMutableAttributedString(string: "")

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        
        if let friend = firebaseCollab.friends.first(where: { $0.userID == friendCell?.friend?.userID }) {
            
            if friend.accepted == true, let dateOfFriendship = friend.dateOfFriendship {
                
                attributedString.append(NSAttributedString(string: "Friends Since:", attributes: titleText))
                attributedString.append(NSAttributedString(string: "\n"))
                attributedString.append(NSAttributedString(string: formatter.string(from: dateOfFriendship), attributes: dateText))
            }
            
            else if let requestSentOn = friend.requestSentOn {
                
                attributedString.append(NSAttributedString(string: "Request Sent On:", attributes: titleText))
                attributedString.append(NSAttributedString(string: "\n"))
                attributedString.append(NSAttributedString(string: formatter.string(from: requestSentOn), attributes: dateText))
            }
            
            dateLabel.attributedText = attributedString
        }
    }
    
    
    //MARK: - Delete Friend
    
    private func deleteFriend () {
       
        if let friend = friendCell?.friend {
            
            firebaseCollab.deleteFriend(friend)
            
            cancelButtonPressed()
        }
    }
    
    
    //MARK: - Animate Dismissal of View
    
    private func animateDismissalOfView (completion: @escaping (() -> Void)) {
        
        if let profilePictureStartingFrame = friendCellProfilePictureFrame, let nameLabelStartingFrame = friendCellNameLabelFrame, let usernameLabelStartingFrame = friendCellUsernameLabelFrame {
            
            zoomingProfilePicture.constraints.forEach({ $0.isActive = false }) //Don't know why, but only deactivating these constraints is neccasary
            
            profileViewProfilePicture.isHidden = true
            zoomingProfilePicture.isHidden = false
            
            zoomingOutNameLabel.isHidden = false
            zoomingOutUsernameLabel.isHidden = false
            nameLabel.isHidden = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {
                
                self.view.backgroundColor = .clear
                self.profileView.alpha = 0
                
                //Animating them back to their original positions in the friendCell
                self.zoomingProfilePicture.frame = profilePictureStartingFrame
                self.zoomingOutNameLabel.frame = nameLabelStartingFrame
                self.zoomingOutUsernameLabel.frame = usernameLabelStartingFrame
                
                self.zoomingProfilePicture.layer.cornerRadius = 26.5 //Corner radius of the friendCellProfilePicture
                
            } completion: { (finished: Bool) in
                
                let tabBar = CustomTabBar.sharedInstance
                keyWindow?.addSubview(tabBar)
                
                self.friendCell?.profilePicture.isHidden = false
                self.friendCell?.nameLabel.isHidden = false
                self.friendCell?.usernameLabel.isHidden = false
                
                self.zoomingProfilePicture.isHidden = true
                self.zoomingOutNameLabel.isHidden = true
                self.zoomingOutUsernameLabel.isHidden = true
                
                //Animated the shadow back in the friendCellProfilePicture
                let profilePictureShadowAnimation = CABasicAnimation(keyPath: "shadowColor")
                profilePictureShadowAnimation.fromValue = UIColor.clear.cgColor
                profilePictureShadowAnimation.toValue = UIColor(hexString: "39434A")!.cgColor
                profilePictureShadowAnimation.duration = 0.3
                self.friendCell?.profilePicture.layer.add(profilePictureShadowAnimation, forKey: nil)
                self.friendCell?.profilePicture.layer.shadowColor = UIColor(hexString: "39434A")!.cgColor
                
                completion()
            }
        }
    }
    
    
    //MARK: - Present Delete/Rescind Alert
    
    @objc private func presentDelete_RescindAlert () {
        
        let title = friendCell?.friend?.accepted ?? false ? "Are you sure you would like to delete \(friendCell?.friend?.firstName ?? "") from your friends?" : "Are you sure you would like to rescind your friend request sent to \(friendCell?.friend?.firstName ?? "")?"
        
        let delete_RescindAlert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (_) in
            
            self?.deleteFriend()
        }
        
        let rescindAction = UIAlertAction(title: "Rescind", style: .destructive) { [weak self] (_) in
            
            self?.deleteFriend()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        delete_RescindAlert.addAction(friendCell?.friend?.accepted ?? false ? deleteAction : rescindAction)
        delete_RescindAlert.addAction(cancelAction)
        
        present(delete_RescindAlert, animated: true)
    }
    
    
    //MARK: - Cancel Button Pressed
    
    @objc private func cancelButtonPressed () {
        
        animateDismissalOfView {
        
            self.dismiss(animated: false)
            
            if let navigationController = self.presentingViewController as? UINavigationController, let friendsVC = navigationController.viewControllers.first(where: { $0 as? FriendsViewController != nil }) as? FriendsViewController {
                
                friendsVC.addObservors()
                
                //Prevents flashing from occuring
                DispatchQueue.main.async {
                    
                    friendsVC.friendsUpdated()
                }
            }
        }
    }
}
