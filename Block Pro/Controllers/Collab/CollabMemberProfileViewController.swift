//
//  CollabMemberProfileViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/22/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import BEMCheckBox
import SVProgressHUD

class CollabMemberProfileViewController: UIViewController {
    
    let profileView = UIView()
    
    let zoomingProfilePicture = UIImageView()
    let profileViewProfilePicture = ProfilePicture(shadowColor: UIColor.clear.cgColor, shadowOpacity: 0.25, borderColor: UIColor.clear.cgColor)
    
    let addFriendButton = UIButton(type: .system)
    let friendCheckBox = BEMCheckBox()
    
    let nameLabel = UILabel()
    let roleLabel = UILabel()
    let activityLabel = UILabel()
    
    let blocksCompletedContainer = UIView()
    let blocksCompletedLabel = UILabel()
    lazy var progressCircle = ProgressCircles(radius: 20, lineWidth: 6, strokeColor: progressLayerStrokeColor ?? UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor, strokeEnd: progressLayerStrokeEnd ?? 0.0025)
    let progressLabel = UILabel()
    let progressCheckBox = BEMCheckBox()
    
    var memberCellProfilePicture: ProfilePicture?
    var memberCellProfilePictureFrame: CGRect?
    
    var memberContainerView: UIView?
    var memberContainerViewFrame: CGRect?
    
    var memberCellProgressCircle: ProgressCircles?
    var memberCellProgressCircleFrame: CGRect?
    
    var memberCellProgressLabel: UILabel?
    var memberCellProgressLabelFrame: CGRect?
    
    var memberCellCheckBox: BEMCheckBox?
    var memberCellCheckBoxFrame: CGRect?
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var member: Member? {
        didSet {
            
            retrieveProfilePic(member: member!)
            
            //Hides addFriendButton if this member is already friends with the currentUser
            addFriendButton.isHidden = firebaseCollab.friends.contains(where: { $0.userID == member?.userID })
            
            //Hides friendCheckBox if this member isn't already friends with the currentUser
            friendCheckBox.isHidden = !firebaseCollab.friends.contains(where: { $0.userID == member?.userID })
            
            //Turn on the friendCheckBox if this member is already friends with the currentUser
            friendCheckBox.on = firebaseCollab.friends.contains(where: { $0.userID == member?.userID })
        }
    }
    
    var memberActivity: Any? {
        didSet{
            
            setActivityLabel(memberActivity)
        }
    }
    
    var blocks: [Block]? {
        didSet {
            
            calculateProgress()
        }
    }
    
    var progressLayerStrokeColor: CGColor?
    var progressLayerStrokeEnd: CGFloat?
    
    weak var collabViewController: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackgroundCancelButton()
        configureProfileView()
        configureCancelButton()
        configureProfilePicture()
        configureAddButton()
        configureFriendCheckBox()
        configureNameLabel()
        configureRoleLabel()
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
            profileView.heightAnchor.constraint(equalToConstant: 450)
        
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
            zoomingProfilePicture.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 40/*50*/),
            zoomingProfilePicture.widthAnchor.constraint(equalToConstant: 125),
            zoomingProfilePicture.heightAnchor.constraint(equalToConstant: 125)

        ].forEach({ $0.isActive = true })
        
        zoomingProfilePicture.frame = memberCellProfilePictureFrame ?? .zero
        zoomingProfilePicture.contentMode = .scaleAspectFill
        zoomingProfilePicture.image = profilePic
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
        
            addFriendButton.topAnchor.constraint(equalTo: profileViewProfilePicture.bottomAnchor, constant: -20),
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
            nameLabel.topAnchor.constraint(equalTo: profileViewProfilePicture.bottomAnchor, constant: 12.5/*15*/),
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
    
    
    //MARK: - Configure Role Label
    
    private func configureRoleLabel () {
        
        profileView.addSubview(roleLabel)
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            roleLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 32),
            roleLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -32),
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12.5/*15*/),
            roleLabel.heightAnchor.constraint(equalToConstant: 48)
            
        ].forEach({ $0.isActive = true })
        
        roleLabel.alpha = 0
        roleLabel.numberOfLines = 2
        
        let titleText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let roleText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Italic", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        
        let attributedString = NSMutableAttributedString(string: "")
        
        if let role = member?.role {
            
            attributedString.append(NSAttributedString(string: "Role:", attributes: titleText))
            attributedString.append(NSAttributedString(string: "\n"))
            attributedString.append(NSAttributedString(string: role, attributes: roleText))
            
            roleLabel.attributedText = attributedString
        }
    }
    
    
    //MARK: - Configure Activity Label
    
    private func configureActivityLabel () {
        
        profileView.addSubview(activityLabel)
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            activityLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 32),
            activityLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -32),
            activityLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 12.5/*15*/),
            activityLabel.heightAnchor.constraint(equalToConstant: 48)
        
        ].forEach({ $0.isActive = true })
        
        activityLabel.alpha = 0
        activityLabel.numberOfLines = 2
        activityLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    //MARK: - Configure Blocks Completed Container
    
    private func configureBlocksCompletedContainer () {
        
        self.view.insertSubview(blocksCompletedContainer, belowSubview: zoomingProfilePicture)
        blocksCompletedContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            blocksCompletedContainer.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 20),
            blocksCompletedContainer.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -20),
            blocksCompletedContainer.bottomAnchor.constraint(equalTo: profileView.bottomAnchor, constant: -20),
            blocksCompletedContainer.heightAnchor.constraint(equalToConstant: 70)
        
        ].forEach({ $0.isActive = true })
        
        //Setting to it's initial frame in the memberCell before it is animated
        blocksCompletedContainer.frame = memberContainerViewFrame ?? .zero
        
        blocksCompletedContainer.backgroundColor = UIColor(hexString: "222222")
        
        blocksCompletedContainer.layer.cornerRadius = 15
        blocksCompletedContainer.layer.cornerCurve = .continuous
        
        blocksCompletedContainer.layer.shadowColor = UIColor.clear.cgColor
        blocksCompletedContainer.layer.shadowOffset = CGSize(width: 1, height: 2)
        blocksCompletedContainer.layer.shadowRadius = 2
        blocksCompletedContainer.layer.shadowOpacity = 0.35
    }
    
    
    //MARK: - Configure Blocks Completed Label
    
    private func configureBlocksCompletedLabel () {
        
        blocksCompletedContainer.addSubview(blocksCompletedLabel)
        
        //Setting it's frame instead of constraints prevents it's overanimation when the view is being presented
        blocksCompletedLabel.frame = CGRect(x: 15, y: 0, width: UIScreen.main.bounds.width - 20 - 40 - 15 - 70, height: 70)
        
        blocksCompletedLabel.alpha = 0
        blocksCompletedLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
        blocksCompletedLabel.textColor = .white
        blocksCompletedLabel.textAlignment = .left
        blocksCompletedLabel.text = "Blocks Completed:"
        blocksCompletedLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    //MARK: - Configure Progress Circle
    
    private func configureProgressCircle () {
        
        self.view.addSubview(progressCircle)
        progressCircle.translatesAutoresizingMaskIntoConstraints = false

        [

            progressCircle.trailingAnchor.constraint(equalTo: blocksCompletedContainer.trailingAnchor, constant: -15),
            progressCircle.bottomAnchor.constraint(equalTo: blocksCompletedContainer.bottomAnchor, constant: -15),
            progressCircle.widthAnchor.constraint(equalToConstant: 40),
            progressCircle.heightAnchor.constraint(equalToConstant: 40)

        ].forEach({ $0?.isActive = true })
        
        //Setting to it's initial frame in the memberCell before it is animated
        progressCircle.frame = memberCellProgressCircleFrame ?? .zero
    }
    
    
    //MARK: - Configure Progress Label
    
    private func configureProgressLabel () {
        
        self.view.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressLabel.centerXAnchor.constraint(equalTo: progressCircle.centerXAnchor, constant: 0),
            progressLabel.centerYAnchor.constraint(equalTo: progressCircle.centerYAnchor, constant: 0),
            progressLabel.widthAnchor.constraint(equalToConstant: 25),
            progressLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        //Setting to it's initial frame in the memberCell before it is animated
        progressLabel.frame = memberCellProgressLabelFrame ?? .zero
        
        progressLabel.font = UIFont(name: "Poppins-Italic", size: 13.5)
        progressLabel.textColor = .white
        progressLabel.textAlignment = .center
    }
    
    
    //MARK: - Configure Check Box
    
    private func configureCheckBox () {
        
        self.view.addSubview(progressCheckBox)
        progressCheckBox.translatesAutoresizingMaskIntoConstraints = false
        
        [

            progressCheckBox.centerXAnchor.constraint(equalTo: progressCircle.centerXAnchor, constant: 0),
            progressCheckBox.centerYAnchor.constraint(equalTo: progressCircle.centerYAnchor, constant: 0),
            progressCheckBox.widthAnchor.constraint(equalToConstant: 30),
            progressCheckBox.heightAnchor.constraint(equalToConstant: 30)

        ].forEach({ $0.isActive = true })
        
        //Setting to it's initial frame in the memberCell before it is animated
        progressCheckBox.frame = memberCellCheckBoxFrame ?? .zero
        
        progressCheckBox.isUserInteractionEnabled = false
        progressCheckBox.hideBox = true
        
        progressCheckBox.lineWidth = 4
        progressCheckBox.tintColor = .clear
        progressCheckBox.onCheckColor = UIColor(hexString: "7BD293") ?? .green
    }
    
    
    //MARK: - Presentation Animation
    
    func performZoomPresentationAnimation () {
        
        memberCellProfilePicture = memberContainerView?.subviews.first(where: { $0 as? ProfilePicture != nil }) as? ProfilePicture
        memberCellProgressCircle = memberContainerView?.subviews.first(where: { $0 as? ProgressCircles != nil }) as? ProgressCircles
        memberCellProgressLabel = memberContainerView?.subviews.first(where: { $0 as? UILabel != nil && $0.tag == 1}) as? UILabel
        memberCellCheckBox = memberContainerView?.subviews.first(where: { $0 as? BEMCheckBox != nil }) as? BEMCheckBox
        
        if let profilePicture = memberCellProfilePicture, let profilePictureStartingFrame = profilePicture.superview?.convert(profilePicture.frame, to: self.view), let containerView = memberContainerView, let memberContainerStartingFrame = memberContainerView?.superview?.convert(containerView.frame, to: self.view), let progressCircle = memberCellProgressCircle, let progressCircleStartingFrame = progressCircle.superview?.convert(progressCircle.frame, to: self.view), let progressLabel = memberCellProgressLabel, let progressLabelStartingFrame = progressLabel.superview?.convert(progressLabel.frame, to: self.view), let checkBox = memberCellCheckBox, let checkBoxStartingFrame = checkBox.superview?.convert(checkBox.frame, to: self.view)  {
            
            memberCellProfilePictureFrame = profilePictureStartingFrame
            memberContainerViewFrame = memberContainerStartingFrame
            memberCellProgressCircleFrame = progressCircleStartingFrame
            memberCellProgressLabelFrame = progressLabelStartingFrame
            memberCellCheckBoxFrame = checkBoxStartingFrame
            
            configureZoomingProfilePicture(profilePicture.profilePic)
            
            configureBlocksCompletedContainer()
            configureBlocksCompletedLabel()
            configureProgressCircle()
            configureProgressLabel()
            configureCheckBox()
            
            //Hiding the memberCellProfilePicture and memberCellContainerView
            profilePicture.isHidden = true
            containerView.isHidden = true
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1, options: .curveEaseInOut) {
                
                self.view.layoutIfNeeded()
                
                self.zoomingProfilePicture.layer.cornerRadius = 62.5
                
            } completion: { (finished: Bool) in
                
                self.zoomingProfilePicture.isHidden = true
                self.profileViewProfilePicture.isHidden = false
                
                //Animates the shadow of the profilePicture and the blocksCompletedContainer and animates the border of the profilePicture
                self.animateShadowsAndBorder()
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                self.profileView.alpha = 1
                self.addFriendButton.alpha = 1
                self.friendCheckBox.alpha = 1
                self.nameLabel.alpha = 1
                self.roleLabel.alpha = 1
                self.activityLabel.alpha = 1
            }
            
            UIView.animate(withDuration: 0.4, delay: 0, options: .transitionCrossDissolve) {
                
                self.blocksCompletedLabel.alpha = 1
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
        
        let blocksCompletedContainerShadowAnimation = CABasicAnimation(keyPath: "shadowColor")
        blocksCompletedContainerShadowAnimation.fromValue = UIColor.clear.cgColor
        blocksCompletedContainerShadowAnimation.toValue = UIColor(hexString: "39434A")!.cgColor
        blocksCompletedContainerShadowAnimation.duration = 0.3
        blocksCompletedContainer.layer.add(blocksCompletedContainerShadowAnimation, forKey: nil)
        blocksCompletedContainer.layer.shadowColor = UIColor(hexString: "39434A")!.cgColor
        
        let profilePictureBorderAnimation = CABasicAnimation(keyPath: "borderColor")
        profilePictureBorderAnimation.fromValue = UIColor.clear.cgColor
        profilePictureBorderAnimation.toValue = UIColor(hexString: "F4F4F4")?.withAlphaComponent(0.05).cgColor
        profilePictureBorderAnimation.duration = 0.3
        profileViewProfilePicture.layer.add(profilePictureBorderAnimation, forKey: nil)
        profileViewProfilePicture.layer.borderColor = UIColor(hexString: "F4F4F4")?.withAlphaComponent(0.05).cgColor
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
            
            firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { (profilePic, userID) in
                
                self.profileViewProfilePicture.profilePic = profilePic
                
                self.firebaseCollab.cacheMemberProfilePics(userID: member.userID, profilePic: profilePic)
            }
        }
    }
    
    
    //MARK: - Calculate Progress
    
    private func calculateProgress () {
        
        var filteredBlocks = blocks
        filteredBlocks?.removeAll(where: { $0.members?.contains(where: { $0.userID == member?.userID }) != true })
        
        var completedBlockCount: Int = 0
        
        for block in filteredBlocks ?? [] {
            
            //If a block is completed
            if let status = block.status, status == .completed {
                
                completedBlockCount += 1
            }
        }
        
        //If there are blocks assigned to this user
        if let blockCount = filteredBlocks?.count, blockCount > 0 {
            
            let completedPercentage = round((Double(completedBlockCount) / Double(blockCount)) * 100)
            
            //If no blocks have been completed
            if completedPercentage == 0 {
                
                progressLayerStrokeEnd = 0.0025
                progressLayerStrokeColor = UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor
                
                progressCircle.shapeLayer.strokeEnd = 0.0025
                progressCircle.shapeLayer.strokeColor = UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor
                progressLabel.isHidden = false
                progressCheckBox.on = false
            }
            
            //If less than 100% have been completed
            else if completedPercentage < 100 {
                
                progressLayerStrokeEnd = CGFloat(completedBlockCount) / CGFloat(blockCount)
                progressLayerStrokeColor = UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor
                
                progressCircle.shapeLayer.strokeEnd = CGFloat(completedBlockCount) / CGFloat(blockCount)
                progressCircle.shapeLayer.strokeColor = UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor
                progressLabel.isHidden = false
                progressCheckBox.on = false
            }
            
            //If all the blocks have been completed
            else if completedPercentage == 100 {
                
                progressLayerStrokeEnd = 1
                progressLayerStrokeColor = UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor
                
                progressCircle.shapeLayer.strokeEnd = 1
                progressCircle.shapeLayer.strokeColor = UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor
                progressLabel.isHidden = true
                progressCheckBox.on = true
            }
            
            progressLabel.text = "\(Int(completedPercentage))%"
        }
        
        //If there are not blocks assigned to this user
        else {
            
            progressCircle.shapeLayer.strokeEnd = 0.0025
            progressCircle.shapeLayer.strokeColor = UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor
            progressLabel.isHidden = false
            progressCheckBox.on = false
            
            progressLabel.text = "0%"
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
                
                if let name = self.member?.firstName {
                    
                    SVProgressHUD.showSuccess(withStatus: "You've sent a friend request to \(name)!")
                }
            }
        }
    }
    
    
    //MARK: - Cancel Button Pressed
    
    @objc private func cancelButtonPressed () {
        
        let tabBar = CustomTabBar.sharedInstance

        SVProgressHUD.dismiss()
        
        if let profilePictureStartingFrame = memberCellProfilePictureFrame, let containerViewStartingFrame = memberContainerViewFrame, let progressCircleStartingFrame = memberCellProgressCircleFrame, let progressLabelStartingFrame = memberCellProgressLabelFrame, let checkBoxStartingFrame = memberCellCheckBoxFrame {
            
            zoomingProfilePicture.constraints.forEach({ $0.isActive = false }) //Don't know why, but only deactivating these constraints is neccasary
            
            profileViewProfilePicture.isHidden = true
            zoomingProfilePicture.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {

                self.view.backgroundColor = .clear
                self.profileView.alpha = 0
                
                //Animating them back to their original positions in the memberCell
                self.zoomingProfilePicture.frame = profilePictureStartingFrame
                self.blocksCompletedContainer.frame = containerViewStartingFrame
                self.progressCircle.frame = progressCircleStartingFrame
                self.progressLabel.frame = progressLabelStartingFrame
                self.progressCheckBox.frame = checkBoxStartingFrame
                
                self.zoomingProfilePicture.layer.cornerRadius = 35 //Corner radius of the memberCellProfilePicture
                self.blocksCompletedLabel.alpha = 0
                
                tabBar.alpha = 1
                
            } completion: { (finished: Bool) in

                tabBar.shouldHide = false
            }

            //Delaying improves animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {

                if let containerView = self.memberContainerView {

                    UIView.transition(from: self.blocksCompletedContainer, to: containerView, duration: 0.3, options: [.transitionCrossDissolve, .showHideTransitionViews]) { (finished: Bool) in

                        self.memberCellProfilePicture?.isHidden = false
                        self.zoomingProfilePicture.isHidden = true

                        let profilePictureShadowAnimation = CABasicAnimation(keyPath: "shadowColor")
                        profilePictureShadowAnimation.fromValue = UIColor.clear.cgColor
                        profilePictureShadowAnimation.toValue = UIColor.white.cgColor
                        profilePictureShadowAnimation.duration = 0.3
                        self.memberCellProfilePicture?.layer.add(profilePictureShadowAnimation, forKey: nil)
                        self.memberCellProfilePicture?.layer.shadowColor = UIColor.white.cgColor
                        
                        self.dismiss(animated: false) {
                            
                            if let viewController = self.collabViewController as? CollabViewController {
                                
                                viewController.memberProfileVC = nil
                            }
                        }
                    }
                }
            }
        }
    }
}
