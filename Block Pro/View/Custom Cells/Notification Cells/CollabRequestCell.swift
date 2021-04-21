//
//  CollabRequestCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/2/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

class CollabRequestCell: UITableViewCell {
    
    let coverPhoto = ProfilePicture(profilePic: UIImage(named: "Mountains")!, shadowRadius: 0, shadowOpacity: 0.35, borderColor: UIColor(hexString: "F4F4F4", withAlpha: 0.1)!.cgColor, borderWidth: 0)
    
    let nameLabel = UILabel()
    let deadlineLabel = UILabel()
    
    let requestSentOnLabel = UILabel()
    
    let membersLabel = UILabel()
    var memberStackView = UIStackView()
    
    let acceptButton = UIButton(type: .system)
    let declineButton = UIButton(type: .system)
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var formatter: DateFormatter?
    
    var collabRequest: Collab? {
        didSet {
            
            configureCoverPhoto()
            
            nameLabel.text = collabRequest?.name
            
            setRequestSentOnLabel(requestSentOn: collabRequest?.requestSentOn?[currentUser.userID])
            
            setDeadlineText()
            
            setMembersText()
            configureMemberStackView()
        }
    }
    
    var nameLabelLeadingConstraintWithContainer: NSLayoutConstraint?
    var nameLabelLeadingConstraintWithCoverPhoto: NSLayoutConstraint?
    
    var deadlineLabelLeadingConstraintWithContainer: NSLayoutConstraint?
    var deadlineLabelLeadingConstraintWithCoverPhoto: NSLayoutConstraint?
    
    var membersLabelLeadingConstraintWithContainer: NSLayoutConstraint?
    var membersLabelLeadingConstraintWithCoverPhoto: NSLayoutConstraint?
    
    var acceptButtonWidthConstraint: NSLayoutConstraint?
    var declineButtonWidthConstraint: NSLayoutConstraint?
    
    weak var collabRequestDelegate: CollabRequestProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "collabRequestCell")
        
        self.contentView.clipsToBounds = true
        
        configureCoverPhoto()
        configureNameLabel()
        configureRequestSentOnLabel()
        configureDeadlineLabel()
        configureMembersLabel()
        
        configureDeclineButton() //Call first
        configureAcceptButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //Handles the cell backgroundColor animation when the cell is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.backgroundColor = UIColor(hexString: "D8D8D8")?.lighten(byPercentage: 0.1)
        
        //Changing the background color of the profilePicture outlines
        for arrangedSubview in memberStackView.arrangedSubviews {
            
            if arrangedSubview.tag > 0 {
                
                arrangedSubview.backgroundColor = UIColor(hexString: "D8D8D8")?.lighten(byPercentage: 0.1)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        self.backgroundColor = nil
        
        //Changing the background color of the profilePicture outlines
        for arrangedSubview in memberStackView.arrangedSubviews {
            
            if arrangedSubview.tag > 0 {
                
                arrangedSubview.backgroundColor = .white
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
            
            self.backgroundColor = nil
            
            //Changing the background color of the profilePicture outlines
            for arrangedSubview in self.memberStackView.arrangedSubviews {
                
                if arrangedSubview.tag > 0 {
                    
                    arrangedSubview.backgroundColor = .white
                }
            }
        })
    }
    
    
    //MARK: - Configure Cover Photo
    
    private func configureCoverPhoto () {
        
        if coverPhoto.superview == nil {
            
            self.contentView.addSubview(coverPhoto)
            coverPhoto.translatesAutoresizingMaskIntoConstraints = false
            
            [

                coverPhoto.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 13.5),
                coverPhoto.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 17),
                coverPhoto.widthAnchor.constraint(equalToConstant: 53),
                coverPhoto.heightAnchor.constraint(equalToConstant: 53)
                
            ].forEach( { $0.isActive = true } )
        }
        
        if let collab = collabRequest, collab.coverPhotoID != nil {
            
            coverPhoto.alpha = 1
            
            nameLabelLeadingConstraintWithContainer?.isActive = false
            nameLabelLeadingConstraintWithCoverPhoto?.isActive = true
            
            deadlineLabelLeadingConstraintWithContainer?.isActive = false
            deadlineLabelLeadingConstraintWithCoverPhoto?.isActive = true
            
            membersLabelLeadingConstraintWithContainer?.isActive = false
            membersLabelLeadingConstraintWithCoverPhoto?.isActive = true
            
            acceptButtonWidthConstraint?.constant = ((UIScreen.main.bounds.width - 87) / 2) - 20
            declineButtonWidthConstraint?.constant = ((UIScreen.main.bounds.width - 87) / 2) - 20
            
            retrieveCoverPhoto(collab)
        }
        
        else {
            
            coverPhoto.alpha = 0
            
            nameLabelLeadingConstraintWithCoverPhoto?.isActive = false
            nameLabelLeadingConstraintWithContainer?.isActive = true
            
            deadlineLabelLeadingConstraintWithCoverPhoto?.isActive = false
            deadlineLabelLeadingConstraintWithContainer?.isActive = true
            
            membersLabelLeadingConstraintWithCoverPhoto?.isActive = false
            membersLabelLeadingConstraintWithContainer?.isActive = true
            
            acceptButtonWidthConstraint?.constant = ((UIScreen.main.bounds.width - 34) / 2) - 20
            declineButtonWidthConstraint?.constant = ((UIScreen.main.bounds.width - 34) / 2) - 20
            
            coverPhoto.profilePic = UIImage(named: "Mountains")
            coverPhoto.layer.shadowColor = UIColor.clear.cgColor
            coverPhoto.layer.borderWidth = 0
        }
    }
    
    
    //MARK: Configure Name Label
    
    private func configureNameLabel () {
        
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.topAnchor.constraint(equalTo: self.coverPhoto.topAnchor, constant: 0),
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -97.5),
            nameLabel.heightAnchor.constraint(equalToConstant: 26.5)
            
        ].forEach({ $0.isActive = true })
        
        nameLabelLeadingConstraintWithContainer = nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 35)
        nameLabelLeadingConstraintWithCoverPhoto = nameLabel.leadingAnchor.constraint(equalTo: coverPhoto.trailingAnchor, constant: 17)
        
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        nameLabel.textAlignment = .left
        nameLabel.textColor = .black
    }
    
    
    //MARK: - Configure Request Sent on Label
    
    private func configureRequestSentOnLabel () {
        
        self.contentView.addSubview(requestSentOnLabel)
        requestSentOnLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            requestSentOnLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -17),
            requestSentOnLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            requestSentOnLabel.widthAnchor.constraint(equalToConstant: 70),
            requestSentOnLabel.heightAnchor.constraint(equalToConstant: 27.5)
        
        ].forEach({ $0.isActive = true })
        
        requestSentOnLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
        requestSentOnLabel.textColor = .lightGray
        requestSentOnLabel.textAlignment = .right
    }
    
    
    //MARK: - Configure Deadline Label
    
    private func configureDeadlineLabel () {
        
        self.contentView.addSubview(deadlineLabel)
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            deadlineLabel.bottomAnchor.constraint(equalTo: coverPhoto.bottomAnchor, constant: 0),
            deadlineLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -97.5),
            deadlineLabel.heightAnchor.constraint(equalToConstant: 26.5)
        
        ].forEach({ $0.isActive = true })
        
        deadlineLabelLeadingConstraintWithContainer = deadlineLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 35)
        deadlineLabelLeadingConstraintWithCoverPhoto = deadlineLabel.leadingAnchor.constraint(equalTo: coverPhoto.trailingAnchor, constant: 17)
    }
    
    
    //MARK: - Configure Members Label
    
    private func configureMembersLabel () {
        
        self.contentView.addSubview(membersLabel)
        membersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            membersLabel.topAnchor.constraint(equalTo: coverPhoto.bottomAnchor, constant: 12.5),
            membersLabel.widthAnchor.constraint(equalToConstant: 100),
            membersLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        membersLabelLeadingConstraintWithContainer = membersLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 35)
        membersLabelLeadingConstraintWithCoverPhoto = membersLabel.leadingAnchor.constraint(equalTo: coverPhoto.trailingAnchor, constant: 17)
        
        membersLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
        membersLabel.textAlignment = .left
        membersLabel.textColor = .black
    }
    
    
    //MARK: - Configure Members StackView
    
    private func configureMemberStackView () {
        
        memberStackView.removeFromSuperview()
        
        if var members = collabRequest?.currentMembersIDs {
            
            if members.count > 1 {
                
                members.removeAll(where: { $0 == currentUser.userID })
            }
            
            let stackViewWidth = (members.count * 38) - ((members.count - 1) * 19)
            
            memberStackView = UIStackView(frame: CGRect(x: membersLabelLeadingConstraintWithContainer?.isActive ?? true ? 35 : 87, y: 114, width: CGFloat(stackViewWidth), height: 38))
            memberStackView.alignment = .center
            memberStackView.distribution = .fillProportionally
            memberStackView.axis = .horizontal
            memberStackView.spacing = -19 //Half the size of the profilePicOutline
            
            var memberCount = 0
            
            for member in members {
                
                let profilePicOutline = UIView()
                profilePicOutline.tag = memberCount //Will be used to change the background color of the outline when the cell is selected
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
                
                retrieveMembersProfilePic(member) { (profilePic) in
                    
                    profilePicture.profilePic = profilePic
                }
                
                memberCount += 1
            }
            
            self.contentView.addSubview(memberStackView)
        }
    }
    
    
    //MARK: - Configure Accept Button
    
    private func configureAcceptButton () {
        
        self.contentView.addSubview(acceptButton)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            acceptButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 174.5),
            acceptButton.trailingAnchor.constraint(equalTo: declineButton.leadingAnchor, constant: -20),
            acceptButton.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        acceptButtonWidthConstraint = acceptButton.widthAnchor.constraint(equalToConstant: ((UIScreen.main.bounds.width - 87) / 2) - 20)
        acceptButtonWidthConstraint?.isActive = true
        
        acceptButton.backgroundColor = UIColor(hexString: "222222")
        
        acceptButton.layer.cornerRadius = 17.5
        acceptButton.layer.cornerCurve = .continuous
        acceptButton.clipsToBounds = true
        
        acceptButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        acceptButton.tintColor = .white
        acceptButton.setTitle("Accept", for: .normal)
        
        acceptButton.addTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Decline Button
    
    private func configureDeclineButton () {
        
        self.contentView.addSubview(declineButton)
        declineButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            declineButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -17),
            declineButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 174.5),
            declineButton.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        declineButtonWidthConstraint = declineButton.widthAnchor.constraint(equalToConstant: ((UIScreen.main.bounds.width - 87) / 2) - 20)
        declineButtonWidthConstraint?.isActive = true
        
        declineButton.backgroundColor = .flatRed()
        
        declineButton.layer.cornerRadius = 17.5
        declineButton.layer.cornerCurve = .continuous
        declineButton.clipsToBounds = true
        
        declineButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        declineButton.tintColor = .white
        declineButton.setTitle("Decline", for: .normal)
        
        declineButton.addTarget(self, action: #selector(declineButtonPressed), for: .touchUpInside)
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
                        if collab.collabID == self?.collabRequest?.collabID {
                            
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
    
    
    //MARK: - Set Request Sent On Label

    private func setRequestSentOnLabel (requestSentOn: Date?) {
        
        let calendar = Calendar.current

        if let date = requestSentOn, let formatter = formatter {
            
            if calendar.isDateInToday(date) {

                formatter.dateFormat = "h:mm a"
                requestSentOnLabel.text = formatter.string(from: date)
            }

            else if calendar.isDateInYesterday(date) {

                requestSentOnLabel.text = "Yesterday"
            }

            else {

                formatter.dateFormat = "M/d/yy"
                requestSentOnLabel.text = formatter.string(from: date)
            }
        }
    }
    
    
    //MARK: - Set Deadline Text
    
    private func setDeadlineText () {
        
        if let deadline = collabRequest?.dates["deadline"], let formatter = formatter {
            
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
        
        if let members = collabRequest?.currentMembersIDs {
            
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
    
    
    //MARK: - Retrieve Profile Pics
    
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
    
    
    //MARK: - Animate Hidden Views
    
    func animateHiddenViews (animate: Bool, hide: Bool) {
        
        UIView.animate(withDuration: animate ? 0.25 : 0, delay: 0, options: .curveEaseInOut) {
            
            self.membersLabel.alpha = hide ? 0 : 1
            self.memberStackView.alpha = hide ? 0 : 1
            
            self.acceptButton.alpha = hide ? 0 : 1
            self.declineButton.alpha = hide ? 0 : 1
        }
    }
    
    
    //MARK: - Accept Button Pressed
    
    @objc private func acceptButtonPressed () {
        
        if let request = collabRequest {
            
            collabRequestDelegate?.acceptCollabRequest(request)
        }
    }
    
    
    //MARK: - Decline Button Pressed
    
    @objc private func declineButtonPressed () {
        
        if let request = collabRequest {
            
            collabRequestDelegate?.declineCollabRequest(request)
        }
    }
}
