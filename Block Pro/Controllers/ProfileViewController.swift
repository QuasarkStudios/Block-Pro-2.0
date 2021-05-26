//
//  ProfileViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/14/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileViewController: UIViewController {
    
    let profileView = UIView()
    
    let zoomingProfilePicture = UIImageView()
    let profileViewProfilePicture = ProfilePicture(shadowColor: UIColor.clear.cgColor, shadowOpacity: 0.25, borderColor: UIColor.clear.cgColor)
    
    let editButton = UIButton(type: .system)
    
    let nameLabel = UILabel()
    let dateJoinedLabel = UILabel()
    let friendsLabel = UILabel()
    
    var headerViewProfilePicture: ProfilePicture?
    var headerViewProfilePictureFrame: CGRect?
    
    var headerViewProfilePictureProgressView: UIView?
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    weak var profileDelegate: ProfileProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackgroundCancelButton()
        configureProfileView()
        configureCancelButton()
        configureProfilePicture()
        configureEditButton()
        configureNameLabel()
        configureDateJoinedLabel()
        configureFriendsLabel()
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
            profileView.heightAnchor.constraint(equalToConstant: 405)
        
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
        
        zoomingProfilePicture.frame = headerViewProfilePictureFrame ?? .zero
        zoomingProfilePicture.contentMode = .scaleAspectFill
        zoomingProfilePicture.image = profilePic ?? UIImage(named: "DefaultProfilePic")
        zoomingProfilePicture.layer.cornerRadius = 30
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
        
        profileViewProfilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentProfilePictureAlert(sender:))))
        
        retrieveProfilePic()
    }
    
    
    //MARK: - Configure Edit Button
    
    private func configureEditButton () {
        
        profileView.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            editButton.topAnchor.constraint(equalTo: profileViewProfilePicture.bottomAnchor, constant: 5),
            editButton.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -20),
            editButton.widthAnchor.constraint(equalToConstant: 90),
            editButton.heightAnchor.constraint(equalToConstant: 30),
        
        ].forEach({ $0.isActive = true })
        
        editButton.alpha = 0
        editButton.backgroundColor = UIColor(hexString: "222222")
        editButton.tintColor = .white
        
        editButton.layer.cornerRadius = 15
        editButton.layer.cornerCurve = .continuous
        editButton.clipsToBounds = true
        
        editButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        editButton.setTitle("Edit", for: .normal)
        
        editButton.addTarget(self, action: #selector(presentProfilePictureAlert), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Name Label
    
    private func configureNameLabel () {
        
        profileView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 32),
            nameLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -32),
            nameLabel.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 5),
            nameLabel.heightAnchor.constraint(equalToConstant: 48)
        
        ].forEach({ $0.isActive = true })
        
        nameLabel.alpha = 0
        nameLabel.numberOfLines = 2
        
        let nameText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let usernameText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        
        let attributedString = NSMutableAttributedString(string: "")
        
        attributedString.append(NSAttributedString(string: currentUser.firstName + " " + currentUser.lastName, attributes: nameText))
        attributedString.append(NSAttributedString(string: "\n"))
        attributedString.append(NSAttributedString(string: "@" + currentUser.username, attributes: usernameText))
        
        nameLabel.attributedText = attributedString
    }
    
    
    //MARK: - Configure Date Joined Label
    
    private func configureDateJoinedLabel () {
        
        profileView.addSubview(dateJoinedLabel)
        dateJoinedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            dateJoinedLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 32),
            dateJoinedLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -32),
            dateJoinedLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            dateJoinedLabel.heightAnchor.constraint(equalToConstant: 48)
            
        ].forEach({ $0.isActive = true })
        
        dateJoinedLabel.alpha = 0
        dateJoinedLabel.numberOfLines = 2
        
        let titleText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let dateText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Italic", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        
        let attributedString = NSMutableAttributedString(string: "")
        
        if let dateJoined = currentUser.accountCreated {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            
            attributedString.append(NSAttributedString(string: "Date Joined:", attributes: titleText))
            attributedString.append(NSAttributedString(string: "\n"))
            attributedString.append(NSAttributedString(string: formatter.string(from: dateJoined), attributes: dateText))
            
            dateJoinedLabel.attributedText = attributedString
        }
    }
    
    
    //MARK: - Configure Friends Label
    
    private func configureFriendsLabel () {
        
        profileView.addSubview(friendsLabel)
        friendsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            friendsLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 32),
            friendsLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -32),
            friendsLabel.topAnchor.constraint(equalTo: dateJoinedLabel.bottomAnchor, constant: 15),
            friendsLabel.heightAnchor.constraint(equalToConstant: 48)
        
        ].forEach({ $0.isActive = true })
        
        friendsLabel.isUserInteractionEnabled = true
        friendsLabel.alpha = 0
        friendsLabel.numberOfLines = 2
        friendsLabel.adjustsFontSizeToFitWidth = true
        
        let firebaseCollab = FirebaseCollab.sharedInstance
        var friendsCount: Int = 0
        firebaseCollab.friends.forEach({ if $0.accepted == true { friendsCount += 1 } })
        
        let titleText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let roleText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Italic", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        
        let attributedString = NSMutableAttributedString(string: "")
        
        attributedString.append(NSAttributedString(string: "Friends:", attributes: titleText))
        attributedString.append(NSAttributedString(string: "\n"))
        attributedString.append(NSAttributedString(string: "\(friendsCount)", attributes: roleText))
        
        friendsLabel.attributedText = attributedString
        
        friendsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentFriends)))
    }
    
    
    //MARK: - Perform Zoom Presentation Animation
    
    func performZoomPresentationAnimation () {
        
        if let profilePicture = headerViewProfilePicture, let profilePictureProgressView = headerViewProfilePictureProgressView, let profilePictureStartingFrame = profilePicture.superview?.convert(profilePicture.frame, to: self.view) {
            
            headerViewProfilePictureFrame = profilePictureStartingFrame
            
            configureZoomingProfilePicture(profilePicture.profilePic)
            
            //Hiding the profile picture in the headerView
            profilePicture.isHidden = true
            profilePictureProgressView.isHidden = true
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1, options: .curveEaseInOut) {
                
                self.view.layoutIfNeeded()
                
                self.zoomingProfilePicture.layer.cornerRadius = 62.5
                
            } completion: { (finished: Bool) in
                
                self.zoomingProfilePicture.isHidden = true
                self.profileViewProfilePicture.isHidden = false
                
                //Animates the shadow of the profilePicture
                self.animateShadowsAndBorder()
            }

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                self.profileView.alpha = 1
                self.editButton.alpha = 1
                self.nameLabel.alpha = 1
                self.dateJoinedLabel.alpha = 1
                self.friendsLabel.alpha = 1
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
        
        if let profilePic = currentUser.profilePictureImage {
            
            zoomingProfilePicture.image = profilePic
            profileViewProfilePicture.profilePic = profilePic
        }
        
        else {
            
            firebaseStorage.retrieveUserProfilePicFromStorage(userID: currentUser.userID) { [weak self] (profilePic, _) in
                
                self?.zoomingProfilePicture.image = profilePic ?? UIImage(named: "DefaultProfilePic")
                self?.profileViewProfilePicture.profilePic = profilePic
            }
        }
    }
    
    
    //MARK: - Present Profile Picture Alert
    
    @objc private func presentProfilePictureAlert (sender: Any) {
        
        //If the user tapped on the profilePicture
        if sender as? UITapGestureRecognizer != nil {
            
            let vibrationMethods = VibrateMethods()
            vibrationMethods.warningVibration()
        }
        
        let profilePictureAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "    Take a Photo", style: .default) { [weak self] (takePhotoAction) in

            self?.presentImagePicker(sourceType: .camera)
        }

        let cameraImage = UIImage(named: "camera2")
        takePhotoAction.setValue(cameraImage, forKey: "image")
        takePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment") //Aligning text to the left

        let choosePhotoAction = UIAlertAction(title: "    Choose a Photo", style: .default) { [weak self] (choosePhotoAction) in

            self?.presentImagePicker(sourceType: .photoLibrary)
        }

        let photoImage = UIImage(named: "image")
        choosePhotoAction.setValue(photoImage, forKey: "image")
        choosePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment") //Aligning text to the left
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        profilePictureAlert.addAction(takePhotoAction)
        profilePictureAlert.addAction(choosePhotoAction)
        profilePictureAlert.addAction(cancelAction)
        
        self.present(profilePictureAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - Present Image Picker
    
    private func presentImagePicker (sourceType: UIImagePickerController.SourceType) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true)
    }
    
    
    //MARK: - Present Friends
    
    @objc private func presentFriends () {
        
        cancelButtonPressed()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.profileDelegate?.presentFriends()
        }
    }
    
    
    //MARK: - Cancel Button Pressed
    
    @objc private func cancelButtonPressed () {
        
        if let profilePictureStartingFrame = headerViewProfilePictureFrame {
            
            zoomingProfilePicture.constraints.forEach({ $0.isActive = false }) //Don't know why, but only deactivating these constraints is neccasary
            
            profileViewProfilePicture.isHidden = true
            zoomingProfilePicture.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {
                
                self.view.backgroundColor = .clear
                self.profileView.alpha = 0
                
                //Animating the profilePicture back to it's original position in the headerView
                self.zoomingProfilePicture.frame = profilePictureStartingFrame
                
                //Corner radius of the headerView profilePicture
                self.zoomingProfilePicture.layer.cornerRadius = 30
                
            } completion: { (finished: Bool) in
                
                let tabBar = CustomTabBar.sharedInstance
                keyWindow?.addSubview(tabBar)
            }

            //Delaying improves animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {

                if let profilePicture = self.headerViewProfilePicture {
                    
                    UIView.transition(from: self.zoomingProfilePicture, to: profilePicture, duration: 0.3, options: [.transitionCrossDissolve, .showHideTransitionViews]) { (finished: Bool) in
                        
                        profilePicture.isHidden = false
                        self.headerViewProfilePictureProgressView?.isHidden = false
                        self.zoomingProfilePicture.isHidden = true
                        
                        let profilePictureShadowAnimation = CABasicAnimation(keyPath: "shadowColor")
                        profilePictureShadowAnimation.fromValue = UIColor.clear.cgColor
                        profilePictureShadowAnimation.toValue = UIColor(hexString: "39434A")!.cgColor
                        profilePictureShadowAnimation.duration = 0.3
                        profilePicture.layer.add(profilePictureShadowAnimation, forKey: nil)
                        profilePicture.layer.shadowColor = UIColor(hexString: "39434A")!.cgColor
                        
                        self.dismiss(animated: false)
                    }
                }
            }
        }
    }
}


//MARK: - UIImagePickerControllerDelegate Extension

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            
            selectedImage = editedImage
        }
        
        else if let originalImage = info[.originalImage] as? UIImage {
            
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            
            firebaseStorage.saveProfilePictureToStorage(image)
            
            profileViewProfilePicture.profilePic = image
            zoomingProfilePicture.image = image
            
            profileDelegate?.profilePictureEdited(profilePic: image)
        }
        
        else {
            
            SVProgressHUD.showError(withStatus: "Sorry, something went wrong saving your profile picture")
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}
