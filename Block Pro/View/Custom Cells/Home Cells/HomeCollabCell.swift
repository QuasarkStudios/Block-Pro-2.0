//
//  HomeCollabCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/9/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class HomeCollabCell: UITableViewCell {

//    let borderView = UIView()
    let collabContainer = UIView()
    let detailsContainer = UIView()
    
    var coverPhoto = ProfilePicture(profilePic: UIImage(named: "Mountains"), shadowColor: UIColor.clear.cgColor, borderWidth: 0)
    
    let nameLabel = UILabel()
    let deadlineLabel = UILabel()
    
    var memberStackView = UIStackView()
    
    let progressCircle = ProgressCircles(radius: 20, lineWidth: 6, trackLayerStrokeColor: UIColor.white.cgColor, strokeColor: UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor, strokeEnd: 0.62)
    let progressLabel = UILabel()
    
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
        }
    }
    
    var nameLabelLeadingConstraintWithContainer: NSLayoutConstraint?
    var nameLabelLeadingConstraintWithCoverPhoto: NSLayoutConstraint?
    
    var deadlineLabelLeadingConstraintWithContainer: NSLayoutConstraint?
    var deadlineLabelLeadingConstraintWithCoverPhoto: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "homeCollabCell")
        
//        configureBorderView()
        configureDetailsContainer()
        configureCollabContainer()
        
        configureCoverPhoto()
        configureNameLabel()
        configureDeadlineLabel()
        
        configureProgressCircle()
        configureProgressLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    private func configureBorderView () {
//
//        self.contentView.addSubview(borderView)
//        borderView.translatesAutoresizingMaskIntoConstraints = false
//
//        [
//
//            borderView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
//            borderView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
//            borderView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
//            borderView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
//
//        ].forEach({ $0.isActive = true })
//
//        borderView.backgroundColor = UIColor(hexString: "D8D8D8")
//
//        borderView.layer.cornerRadius = 10
//        borderView.layer.cornerCurve = .continuous
//        borderView.clipsToBounds = true
//    }
    


    private func configureDetailsContainer () {
        
        self.contentView.addSubview(detailsContainer)
        detailsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            detailsContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            detailsContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            detailsContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            detailsContainer.heightAnchor.constraint(equalToConstant: 110)
        
        ].forEach({ $0.isActive = true })
        
        detailsContainer.backgroundColor = .white
        
        detailsContainer.layer.borderWidth = 1
        detailsContainer.layer.borderColor = UIColor(hexString: "222222")?.cgColor
        
        detailsContainer.layer.cornerRadius = 15
        detailsContainer.layer.cornerCurve = .continuous
        detailsContainer.clipsToBounds = true
    }
    
    private func configureCollabContainer () {
        
        self.contentView.insertSubview(collabContainer, belowSubview: detailsContainer)
        collabContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            collabContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            collabContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            collabContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            
        ].forEach({ $0.isActive = true })
        
        
        collabContainer.backgroundColor = UIColor(hexString: "222222")

        collabContainer.layer.cornerRadius = 15
        collabContainer.layer.cornerCurve = .continuous
//        collabContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        collabContainer.clipsToBounds = true
    }
    
    private func configureCoverPhoto () {
        
        if coverPhoto.superview == nil {
            
            detailsContainer.addSubview(coverPhoto)
            coverPhoto.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                coverPhoto.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 20),
                coverPhoto.centerYAnchor.constraint(equalTo: detailsContainer.centerYAnchor, constant: 0),
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
            
            retrieveCoverPhoto(collab)
        }
        
        else {
            
            coverPhoto.alpha = 0
            
            nameLabelLeadingConstraintWithCoverPhoto?.isActive = false
            nameLabelLeadingConstraintWithContainer?.isActive = true
            
            deadlineLabelLeadingConstraintWithCoverPhoto?.isActive = false
            deadlineLabelLeadingConstraintWithContainer?.isActive = true
            
            coverPhoto.profilePic = UIImage(named: "Mountains")
            coverPhoto.layer.shadowColor = UIColor.clear.cgColor
            coverPhoto.layer.borderWidth = 0
        }
    }
    
    private func configureNameLabel () {
        
        detailsContainer.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.trailingAnchor.constraint(equalTo: detailsContainer.trailingAnchor, constant: -20),
            nameLabel.centerYAnchor.constraint(equalTo: coverPhoto.centerYAnchor, constant: -12.5),
            nameLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        nameLabelLeadingConstraintWithContainer = nameLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 20)
        nameLabelLeadingConstraintWithCoverPhoto = nameLabel.leadingAnchor.constraint(equalTo: coverPhoto.trailingAnchor, constant: 20)
        
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .left
    }
    
    private func configureDeadlineLabel () {
        
        detailsContainer.addSubview(deadlineLabel)
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            deadlineLabel.trailingAnchor.constraint(equalTo: detailsContainer.trailingAnchor, constant: -20),
            deadlineLabel.centerYAnchor.constraint(equalTo: coverPhoto.centerYAnchor, constant: 12.5),
            deadlineLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        deadlineLabelLeadingConstraintWithContainer = deadlineLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 20)
        deadlineLabelLeadingConstraintWithCoverPhoto = deadlineLabel.leadingAnchor.constraint(equalTo: coverPhoto.trailingAnchor, constant: 20)
    }
    
    private func configureMemberStackView () {
        
        memberStackView.removeFromSuperview()
        
        if var members = collab?.currentMembersIDs {
            
            if members.count > 1 {
                
                members.removeAll(where: { $0 == currentUser.userID })
            }
            
//            memberStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
            
            let stackViewWidth = (members.count * 38) - ((members.count - 1) * 19)
            
            /*let*/ memberStackView = UIStackView(frame: CGRect(x: 15, y: 118.5, width: CGFloat(stackViewWidth), height: 38))
            memberStackView.alignment = .center
            memberStackView.distribution = .fillProportionally
            memberStackView.axis = .horizontal
            memberStackView.spacing = -19 //Half the size of the profilePicOutline
            
            var memberCount = 0
            
            for member in members {
                
                let profilePicOutline = UIView()
                profilePicOutline.layer.cornerRadius = 0.5 * 38
                profilePicOutline.clipsToBounds = true
                
                profilePicOutline.backgroundColor = memberCount == 0 ? .clear : UIColor(hexString: "222222")
                
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
                    
                    profilePicture.profilePic = friend.profilePictureImage
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
            progressCircle.bottomAnchor.constraint(equalTo: collabContainer.bottomAnchor, constant: -8),
            progressCircle.widthAnchor.constraint(equalToConstant: 40),
            progressCircle.heightAnchor.constraint(equalToConstant: 40)
        
        ].forEach({ $0.isActive = true })
    }
    
    //MARK: - Configure Progress Label
    
    private func configureProgressLabel () {
        
        collabContainer.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        [
        
            progressLabel.centerXAnchor.constraint(equalTo: progressCircle.centerXAnchor, constant: 0),
            progressLabel.centerYAnchor.constraint(equalTo: progressCircle.centerYAnchor, constant: 0),
            progressLabel.widthAnchor.constraint(equalToConstant: 25),
            progressLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        progressLabel.tag = 1
        progressLabel.font = UIFont(name: "Poppins-Italic", size: 13.5)
        progressLabel.textColor = .white
        progressLabel.textAlignment = .center
        
        progressLabel.text = "62%"
        
//        if let circle = progressCircle {
//
//            containerView.addSubview(progressLabel)
//            progressLabel.translatesAutoresizingMaskIntoConstraints = false
//
//
//
//            [
//
//                progressLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor, constant: 0),
//                progressLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 0),
//                progressLabel.widthAnchor.constraint(equalToConstant: 25),
//                progressLabel.heightAnchor.constraint(equalToConstant: 25)
//
//            ].forEach({ $0.isActive = true })
//
//            progressLabel.tag = 1
//            progressLabel.font = UIFont(name: "Poppins-Italic", size: 13.5)
//            progressLabel.textColor = .white
//            progressLabel.textAlignment = .center
//        }
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
            
            let semiBoldText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 16) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
            let mediumText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 16) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
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
}
