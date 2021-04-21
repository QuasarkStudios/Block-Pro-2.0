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
    
    let coverPhoto = ProfilePicture(profilePic: UIImage(named: "Mountains")!, shadowRadius: 0, shadowOpacity: 0.35, borderColor: UIColor(hexString: "F4F4F4", withAlpha: 0.1)!.cgColor, borderWidth: 0)
    
    let nameLabel = UILabel()
    let deadlineLabel = UILabel()
    
    let membersLabel = UILabel()
    var memberStackView = UIStackView()
    
    var progressCircle: ProgressCircles?
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
            
            configureProgressCircle()
            configureProgressLabel()
            configureCheckBox()
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
        
        configureMembersLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Collab Container
    
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
    
    
    //MARK: - Configure Cover Photo
    
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
        
        //If there is a cover photo for this collab
        if let collab = collab, collab.coverPhotoID != nil {
            
            coverPhoto.alpha = 1
            
            nameLabelLeadingConstraintWithContainer?.isActive = false
            nameLabelLeadingConstraintWithCoverPhoto?.isActive = true
            
            deadlineLabelLeadingConstraintWithContainer?.isActive = false
            deadlineLabelLeadingConstraintWithCoverPhoto?.isActive = true
            
            membersLabelLeadingConstraintWithContainer?.constant = 22.5
            
            retrieveCoverPhoto(collab)
        }
        
        //If there is not a cover photo for this collab
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
    
    
    //MARK: - Configure Name Label
    
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
    
    
    //MARK: - Configure Deadline Label
    
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
    
    
    //MARK: - Configure Members Label
    
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
    
    
    //MARK: - Configure Members StackView
    
    private func configureMemberStackView () {
        
        memberStackView.removeFromSuperview()
        
        if var members = collab?.currentMembersIDs {
            
            //If the currentUser isn't the only member in this collab
            if members.count > 1 {
                
                members.removeAll(where: { $0 == currentUser.userID })
            }
            
            let stackViewWidth = (members.count * 38) - ((members.count - 1) * 19)
            
            memberStackView = UIStackView(frame: CGRect(x: 20, y: 140, width: CGFloat(stackViewWidth), height: 38))
            memberStackView.alignment = .center
            memberStackView.distribution = .fillProportionally
            memberStackView.axis = .horizontal
            memberStackView.spacing = -19 //Half the size of the profilePicOutline
            
            var memberCount = 0
            
            for member in members {
                
                let profilePicOutline = UIView()
                profilePicOutline.backgroundColor = memberCount == 0 ? .clear : .white
                profilePicOutline.layer.cornerRadius = 0.5 * 38
                profilePicOutline.clipsToBounds = true
                
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
                
                retrieveMembersProfilePic(member) { (profilePic) in
                    
                    profilePicture.profilePic = profilePic
                }
                
                memberCount += 1
            }
            
            collabContainer.addSubview(memberStackView)
        }
    }
    
    
    //MARK: - Configure Progress Circle
    
    private func configureProgressCircle () {
        
        if progressCircle?.superview == nil {
            
            progressCircle = ProgressCircles(radius: 38.5, lineWidth: 7, strokeColor: calcCollabProgress() != 1 ? UIColor(hexString: "222222")!.cgColor : UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor, strokeEnd: calcCollabProgress())
            
            collabContainer.addSubview(progressCircle!)
            progressCircle?.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                progressCircle?.trailingAnchor.constraint(equalTo: collabContainer.trailingAnchor, constant: -15),
                progressCircle?.topAnchor.constraint(equalTo: coverPhoto.bottomAnchor, constant: 22.5),
                progressCircle?.widthAnchor.constraint(equalToConstant: 77),
                progressCircle?.heightAnchor.constraint(equalToConstant: 77)
            
            ].forEach({ $0?.isActive = true })
        }
        
        else {
            
            progressCircle?.shapeLayer.strokeColor = calcCollabProgress() != 1 ? UIColor(hexString: "222222")!.cgColor : UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor
            progressCircle?.shapeLayer.strokeEnd = calcCollabProgress()
        }
    }
    
    
    //MARK: - Configure Progress Label
    
    private func configureProgressLabel () {
        
        if let circle = progressCircle, progressLabel.superview == nil {
            
            collabContainer.addSubview(progressLabel)
            progressLabel.translatesAutoresizingMaskIntoConstraints = false



            [

                progressLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor, constant: 0),
                progressLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 0),
                progressLabel.widthAnchor.constraint(equalToConstant: 40),
                progressLabel.heightAnchor.constraint(equalToConstant: 40)

            ].forEach({ $0.isActive = true })
            
            progressLabel.font = UIFont(name: "Poppins-SemiBoldItalic", size: 20)
            progressLabel.adjustsFontSizeToFitWidth = true
            progressLabel.textColor = .black
            progressLabel.textAlignment = .center
        }
        
        setProgressLabelText()
    }
    
    
    //MARK: - Configure Check Box
    
    private func configureCheckBox () {
            
        if let circle = progressCircle, checkBox.superview == nil {
            
            collabContainer.addSubview(checkBox)
            checkBox.translatesAutoresizingMaskIntoConstraints = false
            
            [

                checkBox.centerXAnchor.constraint(equalTo: circle.centerXAnchor, constant: 0),
                checkBox.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 0),
                checkBox.widthAnchor.constraint(equalToConstant: 50),
                checkBox.heightAnchor.constraint(equalToConstant: 50)

            ].forEach({ $0.isActive = true })
            
            checkBox.isUserInteractionEnabled = false
            
            checkBox.hideBox = true
            checkBox.on = true
            
            checkBox.lineWidth = 6
            checkBox.tintColor = .clear
            checkBox.onCheckColor = UIColor(hexString: "7BD293") ?? .green
        }
    }
    
    
    //MARK: - Retrieve Cover Photo
    
    private func retrieveCoverPhoto (_ collab: Collab) {
        
        if let collabIndex = firebaseCollab.collabs.firstIndex(where: { $0.collabID == collab.collabID }) {
            
            if let cover = firebaseCollab.collabs[collabIndex].coverPhoto {
                
                coverPhoto.profilePic = cover
                coverPhoto.layer.shadowRadius = 2
                coverPhoto.layer.borderWidth = 1
            }
            
            else {
                
                coverPhoto.profilePic = UIImage(named: "Mountains")
                coverPhoto.layer.shadowRadius = 0
                coverPhoto.layer.borderWidth = 0
                
                firebaseStorage.retrieveCollabCoverPhoto(collabID: collab.collabID) { [weak self] (cover, error) in
                    
                    if error != nil {
                        
                        print(error as Any)
                    }
                    
                    else {
                        
                        //If false, this cell was likely reused for another collab before the cover picture was finished being retrieved for it's previous collab
                        if collab.collabID == self?.collab?.collabID {
                            
                            self?.coverPhoto.profilePic = cover
                            self?.coverPhoto.layer.shadowRadius = 2
                            self?.coverPhoto.layer.borderWidth = 1
                            
                            self?.firebaseCollab.collabs[collabIndex].coverPhoto = cover
                        }
                        
                        else {
                            
                            //Caching the cover photo for the previous collab
                            if let previousCollabIndex = self?.firebaseCollab.collabs.firstIndex(where: { $0.collabID == collab.collabID }) {
                                
                                self?.firebaseCollab.collabs[previousCollabIndex].coverPhoto = cover
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - Set Daedline Text
    
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
    
    
    //MARK: - Set Members Text
    
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
    
    //MARK: - Retrieve Profile Pic
    
    private func retrieveMembersProfilePic (_ member: String, completion: @escaping (( _ profilePic: UIImage?) -> Void)) {
    
        if member == currentUser.userID {
            
            if let profilePic = currentUser.profilePictureImage {
                
                completion(profilePic)
            }
            
            else {
                
                firebaseStorage.retrieveUserProfilePicFromStorage(userID: currentUser.userID) { (profilePic, _) in
                    
                    completion(profilePic)
                }
            }
        }
        
        else if let friend = firebaseCollab.friends.first(where: { $0.userID == member }) {
            
            if let profilePic = friend.profilePictureImage {
                
                completion(profilePic)
            }
            
            else {
                
                firebaseStorage.retrieveUserProfilePicFromStorage(userID: friend.userID) { [weak self] (profilePic, userID) in
                    
                    completion(profilePic)
                    
                    if let friendIndex = self?.firebaseCollab.friends.firstIndex(where: { $0.userID == userID }) {
                        
                        self?.firebaseCollab.friends[friendIndex].profilePictureImage = profilePic
                    }
                }
            }
        }

        else if let profilePic = firebaseCollab.membersProfilePics[member] {
            
            completion(profilePic)
        }

        else {

            firebaseStorage.retrieveUserProfilePicFromStorage(userID: member) { [weak self] (profilePic, userID) in
                
                completion(profilePic)

                self?.firebaseCollab.cacheMemberProfilePics(userID: member, profilePic: profilePic)
            }
        }
    }
    
    
    //MARK: - Set Progress Label Text
    
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
    
    
    //MARK: - Calc Collab Progress
    
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
    
    
    //MARK: - Expand Cell
    
    func expandCell (animate: Bool = true) {
    
        progressCircle?.shapeLayer.strokeColor = calcCollabProgress() != 1 ? UIColor(hexString: "222222")!.cgColor : UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor
        progressCircle?.shapeLayer.strokeEnd = calcCollabProgress()
        
        setProgressLabelText()
        
        UIView.animate(withDuration: animate ? 0.3 : 0, delay: 0, options: .curveEaseInOut) {
            
            self.membersLabel.alpha = 1
            self.memberStackView.alpha = 1
            
            self.progressCircle?.alpha = 1
            self.progressLabel.alpha = self.calcCollabProgress() == 1 ? 0 : 1
            self.checkBox.alpha = self.calcCollabProgress() == 1 ? 1 : 0
        }
    }
    
    
    //MARK: - Shrink Cell
    
    func shrinkCell (animate: Bool = true) {
        
        UIView.animate(withDuration: animate ? 0.3 : 0, delay: 0, options: .curveEaseInOut) {
            
            self.membersLabel.alpha = 0
            self.memberStackView.alpha = 0

            self.progressCircle?.alpha = 0
            self.progressLabel.alpha = 0
            self.checkBox.alpha = 0
        }
    }
}
