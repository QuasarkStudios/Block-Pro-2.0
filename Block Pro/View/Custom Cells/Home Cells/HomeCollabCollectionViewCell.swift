//
//  HomeCollabCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/12/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import BEMCheckBox

class HomeCollabCollectionViewCell: UICollectionViewCell {
    
    let collabContainer = UIView()
    
    var coverPhoto = ProfilePicture(profilePic: UIImage(named: "Mountains"), shadowColor: UIColor.clear.cgColor, borderWidth: 0)
    
    let nameLabel = UILabel()
    let deadlineLabel = UILabel()
    
    let membersLabel = UILabel()
    var memberStackView = UIStackView()
    
    lazy var progressCircle: ProgressCircles = ProgressCircles(radius: 38.5, lineWidth: 7, strokeColor: calcCollabProgress() != 1 ? UIColor(hexString: "222222")!.cgColor : UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor, strokeEnd: calcCollabProgress())
    let progressLabel = UILabel()
    let checkBox = BEMCheckBox()
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var formatter: DateFormatter?
    
    var collab: Collab? {
        didSet {
            
            configureCoverPhoto()
            
            nameLabel.text = collab?.name
            setDeadlineText()
            
            configureMemberStackView()
            setMembersText()
        }
    }
    
    var nameLabelLeadingConstraintWithContainer: NSLayoutConstraint?
    var nameLabelLeadingConstraintWithCoverPhoto: NSLayoutConstraint?
    
    var deadlineLabelLeadingConstraintWithContainer: NSLayoutConstraint?
    var deadlineLabelLeadingConstraintWithCoverPhoto: NSLayoutConstraint?
    
    var membersLabelLeadingConstraintWithContainer: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCollabContainer()
        
        configureCoverPhoto()
        configureNameLabel()
        configureDeadlineLabel()
        
        configureProgressCircle()
        configureProgressLabel()
        configureCheckBox()
        
        configureMembersLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollabContainer () {
        
        self.contentView.addSubview(collabContainer)
        collabContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            collabContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            collabContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            collabContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            
        ].forEach({ $0.isActive = true })

        collabContainer.layer.borderWidth = 1
        collabContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        collabContainer.layer.cornerRadius = 10
        collabContainer.layer.cornerCurve = .continuous
        collabContainer.clipsToBounds = true
    }
    
    private func configureCoverPhoto () {
        
        if coverPhoto.superview == nil {
            
            collabContainer.addSubview(coverPhoto)
            coverPhoto.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                coverPhoto.leadingAnchor.constraint(equalTo: collabContainer.leadingAnchor, constant: 20),
                coverPhoto.topAnchor.constraint(equalTo: collabContainer.topAnchor, constant: 22.5),
                coverPhoto.widthAnchor.constraint(equalToConstant: 55),
                coverPhoto.heightAnchor.constraint(equalToConstant: 55)
            
            ].forEach({ $0.isActive = true })
        }
        
        if let collab = collab, collab.coverPhotoID != nil {
            
            coverPhoto.alpha = 1
            
            nameLabelLeadingConstraintWithContainer?.isActive = false
            nameLabelLeadingConstraintWithCoverPhoto?.isActive = true
            
            deadlineLabelLeadingConstraintWithContainer?.isActive = false
            deadlineLabelLeadingConstraintWithCoverPhoto?.isActive = true
            
            membersLabelLeadingConstraintWithContainer?.constant = 22.5
            
            retrieveCoverPhoto(collab)
        }
        
        else {
            
            coverPhoto.alpha = 0
            
            nameLabelLeadingConstraintWithCoverPhoto?.isActive = false
            nameLabelLeadingConstraintWithContainer?.isActive = true
            
            deadlineLabelLeadingConstraintWithCoverPhoto?.isActive = false
            deadlineLabelLeadingConstraintWithContainer?.isActive = true
            
            membersLabelLeadingConstraintWithContainer?.constant = 20
            
            coverPhoto.profilePic = UIImage(named: "Mountains")
            coverPhoto.layer.shadowColor = UIColor.clear.cgColor
            coverPhoto.layer.borderWidth = 0
        }
    }
    
    private func configureNameLabel () {
        
        collabContainer.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.trailingAnchor.constraint(equalTo: collabContainer.trailingAnchor, constant: -20),
            nameLabel.centerYAnchor.constraint(equalTo: coverPhoto.centerYAnchor, constant: -12.5),
            nameLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        nameLabelLeadingConstraintWithContainer = nameLabel.leadingAnchor.constraint(equalTo: collabContainer.leadingAnchor, constant: 20)
        nameLabelLeadingConstraintWithCoverPhoto = nameLabel.leadingAnchor.constraint(equalTo: coverPhoto.trailingAnchor, constant: 20)
        
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .left
    }
    
    private func configureDeadlineLabel () {
        
        collabContainer.addSubview(deadlineLabel)
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            deadlineLabel.trailingAnchor.constraint(equalTo: collabContainer.trailingAnchor, constant: -20),
            deadlineLabel.centerYAnchor.constraint(equalTo: coverPhoto.centerYAnchor, constant: 12.5),
            deadlineLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        deadlineLabelLeadingConstraintWithContainer = deadlineLabel.leadingAnchor.constraint(equalTo: collabContainer.leadingAnchor, constant: 20)
        deadlineLabelLeadingConstraintWithCoverPhoto = deadlineLabel.leadingAnchor.constraint(equalTo: coverPhoto.trailingAnchor, constant: 20)
    }
    
    private func configureMembersLabel () {
        
        collabContainer.addSubview(membersLabel)
        membersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            membersLabel.topAnchor.constraint(equalTo: collabContainer.topAnchor, constant: 105),
            membersLabel.widthAnchor.constraint(equalToConstant: 100),
            membersLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        membersLabelLeadingConstraintWithContainer = membersLabel.leadingAnchor.constraint(equalTo: collabContainer.leadingAnchor, constant: 20)
        membersLabelLeadingConstraintWithContainer?.isActive = true
        
        membersLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
        membersLabel.textAlignment = .left
        membersLabel.textColor = .black
    }
    
    private func configureMemberStackView () {
        
        memberStackView.removeFromSuperview()
        
        if var members = collab?.currentMembersIDs {
            
            if members.count > 1 {
                
                members.removeAll(where: { $0 == currentUser.userID })
            }
            
//            memberStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
            
            let stackViewWidth = (members.count * 38) - ((members.count - 1) * 19)
            
            /*let*/ memberStackView = UIStackView(frame: CGRect(x: 20, y: 140, width: CGFloat(stackViewWidth), height: 38))
            memberStackView.alignment = .center
            memberStackView.distribution = .fillProportionally
            memberStackView.axis = .horizontal
            memberStackView.spacing = -19 //Half the size of the profilePicOutline
            
            var memberCount = 0
            
            for member in members {
                
                let profilePicOutline = UIView()
                profilePicOutline.layer.cornerRadius = 0.5 * 38
                profilePicOutline.clipsToBounds = true
                
                profilePicOutline.backgroundColor = memberCount == 0 ? .clear : .white
                
                var profilePicture: ProfilePicture
                
                if memberCount == 0 {
                    
                    profilePicture = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic"), shadowRadius: 2.5, shadowColor: UIColor.white.cgColor, shadowOpacity: 0.5, borderColor: UIColor(hexString: "F4F4F4")!.withAlphaComponent(0.05).cgColor, borderWidth: 1)
                }
                
                else {
                    
                    profilePicture = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic"), shadowRadius: 0, shadowColor: UIColor.clear.cgColor, shadowOpacity: 0, borderColor: UIColor.clear.cgColor, borderWidth: 0)
                }
                
                profilePicOutline.addSubview(profilePicture)
                memberStackView.addArrangedSubview(profilePicOutline)
                
                profilePicOutline.translatesAutoresizingMaskIntoConstraints = false
                profilePicture.translatesAutoresizingMaskIntoConstraints = false
                
                [
                    // 19 is half the size of the profilePicOutline
                    profilePicOutline.topAnchor.constraint(equalTo: profilePicOutline.superview!.topAnchor, constant: 0),
                    profilePicOutline.leadingAnchor.constraint(equalTo: profilePicOutline.superview!.leadingAnchor, constant: CGFloat(memberCount * 19)),
                    profilePicOutline.widthAnchor.constraint(equalToConstant: 38),
                    profilePicOutline.heightAnchor.constraint(equalToConstant: 38),
                    
                    profilePicture.centerXAnchor.constraint(equalTo: profilePicture.superview!.centerXAnchor),
                    profilePicture.centerYAnchor.constraint(equalTo: profilePicture.superview!.centerYAnchor),
                    profilePicture.widthAnchor.constraint(equalToConstant: 34),
                    profilePicture.heightAnchor.constraint(equalToConstant: 34)
                
                ].forEach({ $0.isActive = true })
                
                //Setting the profile picture image
                if member == currentUser.userID {
                    
                    if currentUser.profilePictureImage != nil {
                        
                        profilePicture.profilePic = currentUser.profilePictureImage
                    }
                    
                    else {
                        
                        firebaseStorage.retrieveUserProfilePicFromStorage(userID: currentUser.userID) { (profilePic, _) in
                            
                            profilePicture.profilePic = profilePic
                        }
                    }
                }
                
                else if let friend = firebaseCollab.friends.first(where: { $0.userID == member }) {
                    
                    if friend.profilePictureImage != nil {
                        
                        profilePicture.profilePic = friend.profilePictureImage
                    }
                    
                    else {
                        
                        firebaseStorage.retrieveUserProfilePicFromStorage(userID: friend.userID) { [weak self] (profilePic, userID) in
                            
                            profilePicture.profilePic = profilePic
                            
                            if let friendIndex = self?.firebaseCollab.friends.firstIndex(where: { $0.userID == userID }) {
                                
                                self?.firebaseCollab.friends[friendIndex].profilePictureImage = profilePic
                            }
                        }
                    }
                }

                else if let memberProfilePic = firebaseCollab.membersProfilePics[member] {
                    
                    profilePicture.profilePic = memberProfilePic
                }

                else {

                    firebaseStorage.retrieveUserProfilePicFromStorage(userID: member) { [weak self] (retrievedProfilePic, userID) in
                        
                        profilePicture.profilePic = retrievedProfilePic

                        self?.firebaseCollab.cacheMemberProfilePics(userID: member, profilePic: retrievedProfilePic)
                    }
                }
                
                memberCount += 1
            }
            
            collabContainer.addSubview(memberStackView)
        }
    }
    
    private func configureProgressCircle () {
        
        self.collabContainer.addSubview(progressCircle)
        progressCircle.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressCircle.trailingAnchor.constraint(equalTo: collabContainer.trailingAnchor, constant: -15),
            progressCircle.topAnchor.constraint(equalTo: coverPhoto.bottomAnchor, constant: 22.5),
            progressCircle.widthAnchor.constraint(equalToConstant: 77),
            progressCircle.heightAnchor.constraint(equalToConstant: 77)
        
        ].forEach({ $0.isActive = true })
        
        progressCircle.alpha = 0
        
//        if progressCircle == nil {
//
//            progressCircle = ProgressCircles(radius: 38.5, lineWidth: 7, strokeColor: calcCollabProgress() != 1 ? UIColor(hexString: "222222")!.cgColor : UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor, strokeEnd: calcCollabProgress())
//
//            self.collabContainer.addSubview(progressCircle!)
//            progressCircle!.translatesAutoresizingMaskIntoConstraints = false
//
//            [
//
//                progressCircle!.trailingAnchor.constraint(equalTo: collabContainer.trailingAnchor, constant: -15),
//                progressCircle!.topAnchor.constraint(equalTo: coverPhoto.bottomAnchor, constant: 22.5),
//                progressCircle!.widthAnchor.constraint(equalToConstant: 77),
//                progressCircle!.heightAnchor.constraint(equalToConstant: 77)
//
//            ].forEach({ $0.isActive = true })
//
//            progressCircle!.alpha = 0
//        }
//
//        else {
//
//            progressCircle?.shapeLayer.strokeColor = calcCollabProgress() != 1 ? UIColor(hexString: "222222")!.cgColor : UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor
//            progressCircle?.shapeLayer.strokeEnd = calcCollabProgress()
//        }
    }
    
    //MARK: - Configure Progress Label
    
    private func configureProgressLabel () {
        
        collabContainer.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false



        [

            progressLabel.centerXAnchor.constraint(equalTo: progressCircle.centerXAnchor, constant: 0),
            progressLabel.centerYAnchor.constraint(equalTo: progressCircle.centerYAnchor, constant: 0),
            progressLabel.widthAnchor.constraint(equalToConstant: 40),
            progressLabel.heightAnchor.constraint(equalToConstant: 40)

        ].forEach({ $0.isActive = true })

        progressLabel.alpha = 0
        progressLabel.font = UIFont(name: "Poppins-SemiBoldItalic", size: 20)
        progressLabel.textColor = .black
        progressLabel.textAlignment = .center

        progressLabel.text = "62%"
        
//        if let circle = progressCircle, progressLabel.superview == nil {
//
//            collabContainer.addSubview(progressLabel)
//            progressLabel.translatesAutoresizingMaskIntoConstraints = false
//
//
//
//            [
//
//                progressLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor, constant: 0),
//                progressLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 0),
//                progressLabel.widthAnchor.constraint(equalToConstant: 40),
//                progressLabel.heightAnchor.constraint(equalToConstant: 40)
//
//            ].forEach({ $0.isActive = true })
//
//            progressLabel.alpha = 0
//            progressLabel.font = UIFont(name: "Poppins-SemiBoldItalic", size: 20)
//            progressLabel.textColor = .black
//            progressLabel.textAlignment = .center
//        }
    }
    
    private func configureCheckBox () {
            
        collabContainer.addSubview(checkBox)
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        
        [

            checkBox.centerXAnchor.constraint(equalTo: progressCircle.centerXAnchor, constant: 0),
            checkBox.centerYAnchor.constraint(equalTo: progressCircle.centerYAnchor, constant: 0),
            checkBox.widthAnchor.constraint(equalToConstant: 50),
            checkBox.heightAnchor.constraint(equalToConstant: 50)

        ].forEach({ $0.isActive = true })
        
        checkBox.alpha = 0
        checkBox.hideBox = true
        checkBox.on = true
        
        checkBox.lineWidth = 6
        checkBox.tintColor = .clear
        checkBox.onCheckColor = UIColor(hexString: "7BD293") ?? .green
        
        checkBox.isUserInteractionEnabled = false
    }
    
    private func retrieveCoverPhoto (_ collab: Collab) {
        
        if let collabIndex = firebaseCollab.collabs.firstIndex(where: { $0.collabID == collab.collabID }) {
            
            if let cover = firebaseCollab.collabs[collabIndex].coverPhoto {
                
                coverPhoto.profilePic = cover
                coverPhoto.layer.shadowColor = UIColor(hexString: "39434A")!.cgColor
                coverPhoto.layer.borderWidth = 1
            }
            
            else {
                
                firebaseStorage.retrieveCollabCoverPhoto(collabID: collab.collabID) { [weak self] (cover, error) in
                    
                    if error != nil {
                        
                        print(error as Any)
                    }
                    
                    else {
                        
                        self?.coverPhoto.profilePic = cover
                        self?.coverPhoto.layer.shadowColor = UIColor(hexString: "39434A")!.cgColor
                        self?.coverPhoto.layer.borderWidth = 1
                        
                        self?.firebaseCollab.collabs[collabIndex].coverPhoto = cover
                    }
                }
            }
        }
    }
    
    private func setDeadlineText () {
        
        if let deadline = collab?.dates["deadline"], let formatter = formatter {
            
            let semiBoldText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 16) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
            let mediumText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 16) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
            let attributedString = NSMutableAttributedString(string: "")
            
            attributedString.append(NSAttributedString(string: "Deadline: ", attributes: semiBoldText))
            
            formatter.dateFormat = "MMMM d"
            attributedString.append(NSAttributedString(string: formatter.string(from: deadline), attributes: mediumText))
            
            attributedString.append(NSAttributedString(string: deadline.daySuffix() + ", ", attributes: mediumText))
            
            formatter.dateFormat = "yyyy"
            attributedString.append(NSAttributedString(string: formatter.string(from: deadline), attributes: mediumText))
            
            deadlineLabel.attributedText = attributedString
        }
    }
    
    private func setMembersText () {
        
        if let members = collab?.currentMembersIDs {
            
            if members.count == 1 {
                
                membersLabel.text = "Just You"
            }
            
            else if members.count == 2 {
                
                membersLabel.text = "Member"
            }
            
            else {
                
                membersLabel.text = "Members"
            }
        }
    }
    
    private func setProgressLabelText () {
        
        if calcCollabProgress() == 0.0025 {
            
            progressLabel.isHidden = false
            progressLabel.text = "0%"
        }
        
        else if calcCollabProgress() == 1 {
            
            progressLabel.isHidden = true
        }
        
        else {
            
            progressLabel.isHidden = false
            
            let completedPercentage = round(calcCollabProgress() * 100)
            
            progressLabel.text = "\(Int(completedPercentage))%"
        }
    }
    
    private func calcCollabProgress () -> CGFloat {
        
        if let startTime = collab?.dates["startTime"], let deadline = collab?.dates["deadline"], let collabDuration = Calendar.current.dateComponents([.second], from: startTime, to: deadline).second {
            
            let timeRemaining = Calendar.current.dateComponents([.second], from: Date(), to: deadline).second
            
            if Double(collabDuration - timeRemaining!) / Double(collabDuration) >= 0.0025 {
                
                if Double(collabDuration - timeRemaining!) / Double(collabDuration) >= 1 {
                    
                    return 1
                }
                
                else {
                    
                    return CGFloat(collabDuration - timeRemaining!) / CGFloat(collabDuration)
                }
            }
            
            //If the stroke would normally animate to a stroke less than 0.0025; likely 0
            else {
                
                return 0.0025
            }
        }
        
        else {
            
            return 0.0025
        }
    }
    
    func expandCell () {
    
        progressCircle.shapeLayer.strokeColor = calcCollabProgress() != 1 ? UIColor(hexString: "222222")!.cgColor : UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor
        progressCircle.shapeLayer.strokeEnd = calcCollabProgress()
        
        setProgressLabelText()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.membersLabel.alpha = 1
            self.memberStackView.alpha = 1
            
            self.progressCircle.alpha = 1
            self.progressLabel.alpha = self.calcCollabProgress() == 1 ? 0 : 1
            self.checkBox.alpha = self.calcCollabProgress() == 1 ? 1 : 0
        }
    }
    
    func shrinkCell () {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {

            self.membersLabel.alpha = 0
            self.memberStackView.alpha = 0

            self.progressCircle.alpha = 0
            self.progressLabel.alpha = 0
            self.checkBox.alpha = 0
        }
    }
}
