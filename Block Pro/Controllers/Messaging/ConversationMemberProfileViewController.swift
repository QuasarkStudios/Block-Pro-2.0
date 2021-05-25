//
//  ConversationMemberProfileViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/24/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import BEMCheckBox
import SVProgressHUD

class ConversationMemberProfileViewController: UIViewController {

    let profileView = UIView()
    
    let zoomingProfilePicture = UIImageView()
    let profileViewProfilePicture = ProfilePicture(shadowColor: UIColor.clear.cgColor, shadowOpacity: 0.25, borderColor: UIColor.clear.cgColor)
    
    let addFriendButton = UIButton(type: .system)
    let friendCheckBox = BEMCheckBox()
    
    let nameLabel = UILabel()
    let activityLabel = UILabel()
    
    var memberCell: ConvoMemberInfoCell?
    var memberCellProfilePictureFrame: CGRect?
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var member: Member? {
        didSet {
            
            retrieveProfilePic(member: member!)
            
            determineVisibilityOfAddButtonAndCheckBox()
        }
    }
    
    var memberActivity: Any? {
        didSet{
            
            setActivityLabel(memberActivity)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackgroundCancelButton()
        configureProfileView()
        configureCancelButton()
        configureProfilePicture()
        configureAddButton()
        configureFriendCheckBox()
        configureNameLabel()
        configureActivityLabel()
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
        
        zoomingProfilePicture.frame = memberCellProfilePictureFrame ?? .zero
        zoomingProfilePicture.contentMode = .scaleAspectFill
        zoomingProfilePicture.image = profilePic ?? UIImage(named: "DefaultProfilePic")
        zoomingProfilePicture.layer.cornerRadius = 35
        zoomingProfilePicture.clipsToBounds = true
    }
    
    
    //MARK: - Configure Profile Picture
    
    private func configureProfilePicture () {

        profileView.addSubview(profileViewProfilePicture)
        profileViewProfilePicture.translatesAutoresizingMaskIntoConstraints = false

        [

            profileViewProfilePicture.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 25),
            profileViewProfilePicture.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 40/*50*/),
            profileViewProfilePicture.widthAnchor.constraint(equalToConstant: 125),
            profileViewProfilePicture.heightAnchor.constraint(equalToConstant: 125)

        ].forEach({ $0.isActive = true })
        
        profileViewProfilePicture.isHidden = true
    }
    
    
    //MARK: - Configure Add Button
    
    private func configureAddButton () {
        
        profileView.addSubview(addFriendButton)
        addFriendButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            addFriendButton.topAnchor.constraint(equalTo: profileViewProfilePicture.bottomAnchor, constant: 5),
            addFriendButton.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -20),
            addFriendButton.widthAnchor.constraint(equalToConstant: 90),
            addFriendButton.heightAnchor.constraint(equalToConstant: 30),
        
        ].forEach({ $0.isActive = true })
        
        addFriendButton.alpha = 0
        addFriendButton.backgroundColor = UIColor(hexString: "222222")
        addFriendButton.tintColor = .white
        
        addFriendButton.layer.cornerRadius = 15
        addFriendButton.layer.cornerCurve = .continuous
        addFriendButton.clipsToBounds = true
        
        addFriendButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        addFriendButton.setTitle("Add", for: .normal)
        
        addFriendButton.addTarget(self, action: #selector(addFriendPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Friend Check Box
    
    private func configureFriendCheckBox () {

        profileView.addSubview(friendCheckBox)
        friendCheckBox.translatesAutoresizingMaskIntoConstraints = false

        [

            friendCheckBox.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -31),
            friendCheckBox.centerYAnchor.constraint(equalTo: addFriendButton.centerYAnchor, constant: 0),
            friendCheckBox.widthAnchor.constraint(equalToConstant: 30),
            friendCheckBox.heightAnchor.constraint(equalToConstant: 30)

        ].forEach({ $0.isActive = true })

        friendCheckBox.alpha = 0

        friendCheckBox.tintColor = UIColor(hexString: "222222") ?? .black //Off tint color
        friendCheckBox.offFillColor = UIColor(hexString: "222222") ?? .black
        
        friendCheckBox.onTintColor = UIColor(hexString: "222222") ?? .black
        friendCheckBox.onFillColor = UIColor(hexString: "222222") ?? .black
        friendCheckBox.onCheckColor = .white

        friendCheckBox.lineWidth = 3

        friendCheckBox.onAnimationType = .bounce
        friendCheckBox.offAnimationType = .bounce

        friendCheckBox.isUserInteractionEnabled = false
    }
    
    
    //MARK: - Configure Name Label
    
    private func configureNameLabel () {
        
        profileView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 32),
            nameLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -32),
            nameLabel.topAnchor.constraint(equalTo: addFriendButton.bottomAnchor, constant: 5),
            nameLabel.heightAnchor.constraint(equalToConstant: 48)
        
        ].forEach({ $0.isActive = true })
        
        nameLabel.alpha = 0
        nameLabel.numberOfLines = 2
        
        let nameText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let usernameText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        
        let attributedString = NSMutableAttributedString(string: "")
        
        if let firstName = member?.firstName, let lastName = member?.lastName, let username = member?.username {
            
            attributedString.append(NSAttributedString(string: firstName + " " + lastName, attributes: nameText))
            attributedString.append(NSAttributedString(string: "\n"))
            attributedString.append(NSAttributedString(string: "@" + username, attributes: usernameText))
            
            nameLabel.attributedText = attributedString
        }
    }
    
    
    //MARK: - Configure Activity Label
    
    private func configureActivityLabel () {
        
        profileView.addSubview(activityLabel)
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            activityLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 32),
            activityLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -32),
            activityLabel.topAnchor.constraint(equalTo: addFriendButton.bottomAnchor, constant: 68),
            activityLabel.heightAnchor.constraint(equalToConstant: 48)
        
        ].forEach({ $0.isActive = true })
        
        activityLabel.alpha = 0
        activityLabel.numberOfLines = 2
        activityLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    //MARK: - Presentation Animation
    
    func performZoomPresentationAnimation () {
        
        if let profilePicture = memberCell?.profilePicImageView, let profilePictureStartingFrame = profilePicture.superview?.convert(profilePicture.frame, to: self.view) {
            
            memberCellProfilePictureFrame = profilePictureStartingFrame
            
            configureZoomingProfilePicture(profilePicture.profilePic)
            
            //Hiding the memberCellProfilePicture
            profilePicture.isHidden = true
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1, options: .curveEaseInOut) {
                
                self.view.layoutIfNeeded()
                
                self.zoomingProfilePicture.layer.cornerRadius = 62.5
                
            } completion: { (finished: Bool) in
                
                self.zoomingProfilePicture.isHidden = true
                self.profileViewProfilePicture.isHidden = false
                
                //Animates the shadow of the profilePicture and the border of the profilePicture
                self.animateShadowsAndBorder()
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.profileView.alpha = 1
            self.addFriendButton.alpha = 1
            self.friendCheckBox.alpha = 1
            self.nameLabel.alpha = 1
            self.activityLabel.alpha = 1
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
    
    
    //MARK: - Add Button Animation
    
    private func animateButtonSelection () {
        
        //Resetting the trailing constraint of the addFriend button
        profileView.constraints.forEach { (constraint) in
            
            if constraint.firstItem as? UIButton != nil && constraint.firstAttribute == .trailing {
                
                constraint.constant = -31
            }
        }
        
        //Resetting the width and height of the addFriendButton
        addFriendButton.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                
                //2 points larger than the checkBox width and height to improve transition during animation
                constraint.constant = 32
            }
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .transitionCrossDissolve]) {
            
            self.view.layoutIfNeeded()
            
            self.addFriendButton.layer.cornerRadius = 16
            self.addFriendButton.setTitle("", for: .normal)
        }

        //Delaying slightly improves animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            UIView.transition(from: self.addFriendButton, to: self.friendCheckBox, duration: 0.3, options: [.transitionCrossDissolve, .showHideTransitionViews]) { (finished: Bool) in

                self.friendCheckBox.setOn(true, animated: true)
            }
        }
    }
    
    
    //MARK: - Animate Dismissal of View
    
    private func animateDismissalOfView (completion: @escaping (() -> Void)) {
        
        if let profilePictureStartingFrame = memberCellProfilePictureFrame {
            
            zoomingProfilePicture.constraints.forEach({ $0.isActive = false })
            
            profileViewProfilePicture.isHidden = true
            zoomingProfilePicture.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {
                
                self.view.backgroundColor = .clear
                self.profileView.alpha = 0
                
                self.zoomingProfilePicture.frame = profilePictureStartingFrame
                self.zoomingProfilePicture.layer.cornerRadius = 25
                
            } completion: { (finished: Bool) in
                
                self.memberCell?.profilePicImageView?.isHidden = false
                
                //Animated the shadow back in the friendCellProfilePicture
                let profilePictureShadowAnimation = CABasicAnimation(keyPath: "shadowColor")
                profilePictureShadowAnimation.fromValue = UIColor.clear.cgColor
                profilePictureShadowAnimation.toValue = UIColor(hexString: "39434A")!.cgColor
                profilePictureShadowAnimation.duration = 0.3
                self.memberCell?.profilePicImageView?.layer.add(profilePictureShadowAnimation, forKey: nil)
                self.memberCell?.profilePicImageView?.layer.shadowColor = UIColor(hexString: "39434A")!.cgColor
                
                completion()
            }
        }
    }
    
    
    //MARK: - Retrieve Profile Pic
    
    private func retrieveProfilePic (member: Member) {
        
        if let friendIndex = firebaseCollab.friends.firstIndex(where: { $0.userID == member.userID }) {
            
            profileViewProfilePicture.profilePic = firebaseCollab.friends[friendIndex].profilePictureImage
        }
        
        else if let memberProfilePic = firebaseCollab.membersProfilePics[member.userID] {
            
            profileViewProfilePicture.profilePic = memberProfilePic
        }
        
        else {
            
            firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { [weak self] (profilePic, userID) in
                
                self?.profileViewProfilePicture.profilePic = profilePic
                
                self?.firebaseCollab.cacheMemberProfilePics(userID: member.userID, profilePic: profilePic)
            }
        }
    }
    
    
    //MARK: - Determine Visibility of Add Button and Check Box
    
    private func determineVisibilityOfAddButtonAndCheckBox () {
        
        if member?.userID != currentUser.userID {
            
            //If the user is currently friends with the member, regardless of whether or not they have accepted each others friend request
            if let friend = firebaseCollab.friends.first(where: { $0.userID == member?.userID }) {
                
                //If the current user sent the friend request of the friend request has been accepted
                if friend.requestSentBy == currentUser.userID || friend.accepted == true {
                    
                    addFriendButton.isHidden = true
                    friendCheckBox.isHidden = false
                    friendCheckBox.on = true
                }
                
                else {
                    
                    addFriendButton.isHidden = false
                    friendCheckBox.isHidden = true
                    friendCheckBox.on = false
                }
            }
            
            //If the user isn't currently friend with the member
            else {
                
                addFriendButton.isHidden = false
                friendCheckBox.isHidden = true
                friendCheckBox.on = false
            }
        }
        
        //If the member is the current user
        else {
            
            addFriendButton.isHidden = true
            friendCheckBox.isHidden = true
        }
    }
    
    
    //MARK: - Set Activity Label
    
    private func setActivityLabel (_ activity: Any?) {
        
        let titleText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let activityText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Italic", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        
        let attributedString = NSMutableAttributedString(string: "")
        
        attributedString.append(NSAttributedString(string: "Active:", attributes: titleText))
        attributedString.append(NSAttributedString(string: "\n"))
        
        let calendar = Calendar.current
        
        if activity != nil {
            
            if activity as? Date != nil {
                
                if calendar.dateComponents([.year], from: activity as! Date, to: Date()).year ?? 0 > 0 {
                    
                    attributedString.append(NSAttributedString(string: "Over a year ago", attributes: activityText))
                }
                
                else if calendar.dateComponents([.month], from: activity as! Date, to: Date()).month ?? 0 > 0 {
                    
                    if calendar.dateComponents([.month], from: activity as! Date, to: Date()).month == 1 {
                        
                        attributedString.append(NSAttributedString(string: "A month ago", attributes: activityText))
                    }
                    
                    else {
                        
                        let monthsAgoActive = calendar.dateComponents([.month], from: activity as! Date, to: Date()).month
                        attributedString.append(NSAttributedString(string: "\(monthsAgoActive!) months ago", attributes: activityText))
                    }
                }
                
                else if calendar.dateComponents([.day], from: activity as! Date, to: Date()).day ?? 0 > 0 {

                    if calendar.dateComponents([.day], from: activity as! Date, to: Date()).day == 1 {
                        
                        attributedString.append(NSAttributedString(string: "Yesterday", attributes: activityText))
                    }
                    
                    else {
                        
                        let daysAgoActive = calendar.dateComponents([.day], from: activity as! Date, to: Date()).day
                        attributedString.append(NSAttributedString(string: "\(daysAgoActive!) days ago", attributes: activityText))
                    }
                }
                
                else if calendar.dateComponents([.hour], from: activity as! Date, to: Date()).hour ?? 0 > 0 {
                    
                    if calendar.dateComponents([.hour], from: activity as! Date, to: Date()).hour == 1 {
                        
                        attributedString.append(NSAttributedString(string: "An hour ago", attributes: activityText))
                    }
                    
                    else {
                        
                        let hoursAgoActive = calendar.dateComponents([.hour], from: activity as! Date, to: Date()).hour
                        attributedString.append(NSAttributedString(string: "\(hoursAgoActive!) hours ago", attributes: activityText))
                    }
                }
                
                else {
                    
                    if calendar.dateComponents([.minute], from: activity as! Date, to: Date()).minute ?? 0 < 2 {
                        
                        attributedString.append(NSAttributedString(string: "A minute ago", attributes: activityText))
                    }
                    
                    else {
                        
                        let minutesAgoActive = calendar.dateComponents([.minute], from: activity as! Date, to: Date()).minute
                        attributedString.append(NSAttributedString(string: "\(minutesAgoActive!) minutes ago", attributes: activityText))
                    }
                }
            }
            
            else if activity as? String != nil {
                
                attributedString.append(NSAttributedString(string: "Now", attributes: activityText))
            }
        }
        
        else {
            
            attributedString.append(NSAttributedString(string: "Never", attributes: activityText))
        }
        
        activityLabel.attributedText = attributedString
    }
    
    
    //MARK: - Add Friend Pressed
    
    @objc private func addFriendPressed () {
        
        if let member = member {
            
            //If the user is already friends with the member, signifying that the
            //current user hasn't accepted a friend request that has been sent to them by the member
            if let friend = firebaseCollab.friends.first(where: { $0.userID == member.userID }) {

                firebaseCollab.acceptFriendRequest(friend)

                SVProgressHUD.showSuccess(withStatus: "You've accepted \(member.firstName)'s friend request!")
            }

            //If the user isn't already friends with the member
            else {

                firebaseCollab.sendFriendRequest(member)

                SVProgressHUD.showSuccess(withStatus: "Friend request sent to \(member.firstName)!")
            }
            
            animateButtonSelection()
        }
    }
    
    
    //MARK: - Cancel Button Pressed
    
    @objc private func cancelButtonPressed () {
        
        animateDismissalOfView {
            
            self.dismiss(animated: false)
            
            if let navigationController = self.presentingViewController as? UINavigationController, let conversationInfoVC = navigationController.viewControllers.first(where: { $0 as? ConversationInfoViewController != nil }) as? ConversationInfoViewController {
                
                conversationInfoVC.monitorPersonalConversation()
                conversationInfoVC.monitorCollabConversation()
            }
        }
    }
}
