//
//  ScheduleMessageCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/19/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class ScheduleMessageCell: UITableViewCell {

    let profilePicture = ProfilePicture(profilePic: UIImage(named: "DefaultProfilPic"), shadowRadius: 2, shadowColor: UIColor(hexString: "39434A")!.cgColor, shadowOpacity: 0.75, borderColor: UIColor(hexString: "F4F4F4", withAlpha: 0.05)!.cgColor, borderWidth: 1)
    let nameLabel = UILabel()
    let scheduleContainer = UIView()
    let scheduleImageView = UIImageView(image: UIImage(named: "schedule-1"))
    let scheduleLabel = UILabel()
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var formatter: DateFormatter?
    
    var members: [Member]?
    
    var previousMessage: Message?
    var message: Message? {
        didSet {
            
            reconfigureCell()
        }
    }
    
    var scheduleContainerLeadingAnchor: NSLayoutConstraint?
    var scheduleContainerTrailingAnchor: NSLayoutConstraint?
    var scheduleContainerTopAnchor: NSLayoutConstraint?
    
    weak var scheduleDelegate: ScheduleProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "scheduleMessageCell")
        
        configureProfilePicture()
        configureNameLabel()
        configureScheduleContainer()
        configureScheduleImageView()
        configureScheduleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Profile Picture
    
    private func configureProfilePicture () {
        
        self.contentView.addSubview(profilePicture)
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            profilePicture.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            profilePicture.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
            profilePicture.widthAnchor.constraint(equalToConstant: 28),
            profilePicture.heightAnchor.constraint(equalToConstant: 28)
        
        ].forEach({ $0.isActive = true })
    }
    
    
    //MARK: - Configure Name Label
    
    private func configureNameLabel () {
        
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 15),
            nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            nameLabel.widthAnchor.constraint(equalToConstant: 150),
            nameLabel.heightAnchor.constraint(equalToConstant: 15)
        
        ].forEach({ $0.isActive = true })
        
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 12)
        nameLabel.textAlignment = .left
    }
    
    
    //MARK: - Configure Schedule Container
    
    private func configureScheduleContainer () {
        
        self.contentView.addSubview(scheduleContainer)
        scheduleContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            scheduleContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            scheduleContainer.widthAnchor.constraint(equalToConstant: 165)
            
        ].forEach({ $0.isActive = true })
        
        scheduleContainerLeadingAnchor = scheduleContainer.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 10)
        scheduleContainerTrailingAnchor = scheduleContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10)
        scheduleContainerTopAnchor = scheduleContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0)
        
        scheduleContainerTopAnchor?.isActive = true
        
        scheduleContainer.backgroundColor = .white
        
        scheduleContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        scheduleContainer.layer.borderWidth = 1

        scheduleContainer.layer.cornerRadius = 10
        scheduleContainer.layer.cornerCurve = .continuous
        scheduleContainer.clipsToBounds = true
        
        scheduleContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped)))
    }
    
    
    //MARK: - Configure Schedule Image View
    
    private func configureScheduleImageView () {
        
        scheduleContainer.addSubview(scheduleImageView)
        scheduleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            scheduleImageView.topAnchor.constraint(equalTo: scheduleContainer.topAnchor, constant: 10),
            scheduleImageView.centerXAnchor.constraint(equalTo: scheduleContainer.centerXAnchor, constant: 0),
            scheduleImageView.widthAnchor.constraint(equalToConstant: 105),
            scheduleImageView.heightAnchor.constraint(equalToConstant: 80)
            
        ].forEach({ $0.isActive = true })
        
        scheduleImageView.isUserInteractionEnabled = false
        scheduleImageView.contentMode = .scaleAspectFit
    }
    
    
    //MARK: - Configure Schedule Label
    
    private func configureScheduleLabel () {
        
        scheduleContainer.addSubview(scheduleLabel)
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            scheduleLabel.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 5),
            scheduleLabel.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -5),
            scheduleLabel.topAnchor.constraint(equalTo: scheduleImageView.bottomAnchor, constant: 0),
            scheduleLabel.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: -10)
            
        ].forEach({ $0.isActive = true })
        
        scheduleLabel.isUserInteractionEnabled = false
        scheduleLabel.numberOfLines = 0
        scheduleLabel.font = UIFont(name: "Poppins-Medium", size: 14)
        scheduleLabel.textAlignment = .center
    }
    
    
    //MARK: - Reconfigure Cell
    
    private func reconfigureCell () {
        
        if message?.sender == currentUser.userID {
            
            nameLabel.isHidden = true
            profilePicture.isHidden = true
            
            scheduleContainerLeadingAnchor?.isActive = false
            scheduleContainerTrailingAnchor?.isActive = true
            scheduleContainerTopAnchor?.constant = 0
        }
        
        else if previousMessage?.sender == message?.sender {
            
            if previousMessage?.memberJoiningConversation == nil && previousMessage?.memberUpdatedConversationCover == nil && previousMessage?.memberUpdatedConversationName == nil {
                
                nameLabel.isHidden = true
                profilePicture.isHidden = true
                
                scheduleContainerTrailingAnchor?.isActive = false
                scheduleContainerLeadingAnchor?.isActive = true
                scheduleContainerTopAnchor?.constant = 0
            }
            
            else {
                
                nameLabel.isHidden = false
                profilePicture.isHidden = false
                
                scheduleContainerTrailingAnchor?.isActive = false
                scheduleContainerLeadingAnchor?.isActive = true
                scheduleContainerTopAnchor?.constant = 15
            }
        }
        
        else {
            
            nameLabel.isHidden = false
            profilePicture.isHidden = false
            
            scheduleContainerTrailingAnchor?.isActive = false
            scheduleContainerLeadingAnchor?.isActive = true
            scheduleContainerTopAnchor?.constant = 15
        }
        
        if !profilePicture.isHidden {
            
            retrieveProfilePic()
        }
        
        if !nameLabel.isHidden {
            
            setNameLabelText()
        }
        
        setScheduleLabelText()
    }
    
    
    //MARK: - Retrieve Profile Pic
    
    private func retrieveProfilePic () {
        
        if let friendIndex = firebaseCollab.friends.firstIndex(where: { $0.userID == message?.sender }) {
            
            profilePicture.profilePic = firebaseCollab.friends[friendIndex].profilePictureImage
        }
        
        else if let memberProfilePic = firebaseCollab.membersProfilePics[message?.sender ?? ""] {
            
            profilePicture.profilePic = memberProfilePic
        }
        
        else {
            
            firebaseStorage.retrieveUserProfilePicFromStorage(userID: message?.sender ?? "") { (profilePic, userID) in
                
                self.profilePicture.profilePic = profilePic
                
                self.firebaseCollab.cacheMemberProfilePics(userID: self.message?.sender ?? "", profilePic: profilePic)
            }
        }
    }
    
    
    //MARK: - Set Name Label Text
    
    private func setNameLabelText () {
        
        if let member = members?.first(where: { $0.userID == message?.sender }) {
            
            nameLabel.text = member.firstName
            
            //Checks to see if there is another member in the conversation with the same first name as this messages sender
            if members?.contains(where: { $0.firstName == member.firstName && $0.userID != member.userID }) ?? false {
                
                let lastInitial = Array(member.lastName)
                
                nameLabel.text = "\(member.firstName) \(lastInitial[0])"
            }
        }
    }
    
    
    //MARK: - Set Schedule Label Text
    
    private func setScheduleLabelText () {
        
        if let formatter = formatter, let dateForBlocks = message?.dateForBlocks {
            
            scheduleLabel.text = message?.sender == currentUser.userID ? "Here's my schedule for " : "Here's \(members?.first(where: { $0.userID == message?.sender })?.firstName ?? "")'s schedule for "
            
            formatter.dateFormat = "EEEE, MMMM d"
            scheduleLabel.text! += formatter.string(from: dateForBlocks)
            
            scheduleLabel.text! += dateForBlocks.daySuffix() + ", "
            
            formatter.dateFormat = "yyyy"
            scheduleLabel.text! += formatter.string(from: dateForBlocks)
        }
    }
    
    @objc private func containerTapped () {
        
        if let message = message {
            
            scheduleDelegate?.moveToScheduleView(message: message)
        }
    }
}
