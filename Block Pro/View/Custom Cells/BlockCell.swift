//
//  BlockCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/29/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class BlockCell: UITableViewCell {

    let startTimeLabel = UILabel()
    let endTimeLabel = UILabel()
    
    let statusIndicatorBubbleContainer = UIView()
    let statusIndicatorBubble = UIView()
    
    let line = UIView()
    
    let nameLabel = UILabel()
    
    let statusLabelContainer = UIView()
    let statusLabel = UILabel()
    
    let membersStackView = UIStackView()
    let noMembersLabel = UILabel()
    
    var formatter: DateFormatter?
    var block: Block? {
        didSet {
            
            configureStartTimeLabel()
            configureStatusIndicatorBubble()
            configureLine()
            configureNameLabel()
            configureEndTimeLabel()
            configureStatusLabel()
            
            if block?.members?.count ?? 0 > 0 {
                
                if membersStackView.superview == nil {
                    
                    configureMembersStackView()
                    setMembers()
                }
                
                else {
                    
                    setMembers()
                }
            }
            
            else {
                
                if noMembersLabel.superview == nil {
                    
                    configureNoMembersLabel()
                }
            }
        }
    }
    
    let statusColors: [BlockStatus : UIColor?] = [.notStarted : UIColor(hexString: "AAAAAA", withAlpha: 0.75), .inProgress : UIColor(hexString: "5065A0", withAlpha: 0.75), .completed : UIColor(hexString: "2ECC70", withAlpha: 0.80), .needsHelp : UIColor(hexString: "FFCC02", withAlpha: 0.75), .late : UIColor(hexString: "E84D3C", withAlpha: 0.75)]
    
    var stackViewWidthConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "blockCell")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureStartTimeLabel () {
        
        self.contentView.addSubview(startTimeLabel)
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            startTimeLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 17),
            startTimeLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            startTimeLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            startTimeLabel.heightAnchor.constraint(equalToConstant: 23)
        
        ].forEach({ $0.isActive = true })
        
        startTimeLabel.font = UIFont(name: "Poppins-SemiBold", size: 16)
        startTimeLabel.textColor = .black
        startTimeLabel.textAlignment = .left
        
        if let starts = block?.starts {
            
            formatter?.dateFormat = "h:mm a"
            
            startTimeLabel.text = formatter?.string(from: starts)
        }
    }
    
    private func configureStatusIndicatorBubble () {
        
        self.contentView.addSubview(statusIndicatorBubbleContainer)
        statusIndicatorBubbleContainer.translatesAutoresizingMaskIntoConstraints = false
        
        statusIndicatorBubbleContainer.addSubview(statusIndicatorBubble)
        statusIndicatorBubble.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            statusIndicatorBubbleContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 28),
            statusIndicatorBubbleContainer.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 25),
            statusIndicatorBubbleContainer.widthAnchor.constraint(equalToConstant: 19),
            statusIndicatorBubbleContainer.heightAnchor.constraint(equalToConstant: 19),
            
            statusIndicatorBubble.centerXAnchor.constraint(equalTo: statusIndicatorBubbleContainer.centerXAnchor),
            statusIndicatorBubble.centerYAnchor.constraint(equalTo: statusIndicatorBubbleContainer.centerYAnchor),
            statusIndicatorBubble.widthAnchor.constraint(equalToConstant: 11),
            statusIndicatorBubble.heightAnchor.constraint(equalToConstant: 11)
        
        ].forEach({ $0.isActive = true })
        
        statusIndicatorBubbleContainer.layer.borderWidth = 2
        statusIndicatorBubbleContainer.layer.cornerRadius = 9.5
        statusIndicatorBubbleContainer.layer.cornerCurve = .continuous
        statusIndicatorBubbleContainer.clipsToBounds = true
        
        statusIndicatorBubble.layer.cornerRadius = 11 * 0.5
        statusIndicatorBubble.layer.cornerCurve = .continuous
        statusIndicatorBubble.clipsToBounds = true
        
        if let status = block?.status, let statusColor = statusColors[status] {
            
            statusIndicatorBubbleContainer.layer.borderColor = statusColor?.cgColor
            statusIndicatorBubble.backgroundColor = statusColor
        }
        
        else if let starts = block?.starts, let ends = block?.ends {
            
            if Date().isBetween(startDate: starts, endDate: ends) {
                
                //In Progress
                statusIndicatorBubbleContainer.layer.borderColor = UIColor(hexString: "5065A0", withAlpha: 0.75)?.cgColor
                statusIndicatorBubble.backgroundColor = UIColor(hexString: "5065A0", withAlpha: 0.75)
            }
            
            else if Date() < starts {
                
                //Not Started
                statusIndicatorBubbleContainer.layer.borderColor = UIColor(hexString: "AAAAAA", withAlpha: 0.75)?.cgColor
                statusIndicatorBubble.backgroundColor = UIColor(hexString: "AAAAAA", withAlpha: 0.75)
            }
            
            else if Date() > ends {
                 
                //Late
                statusIndicatorBubbleContainer.layer.borderColor = UIColor(hexString: "E84D3C", withAlpha: 0.75)?.cgColor
                statusIndicatorBubble.backgroundColor = UIColor(hexString: "E84D3C", withAlpha: 0.75)
            }
        }
    }
    
    private func configureLine () {
        
        self.contentView.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            line.topAnchor.constraint(equalTo: statusIndicatorBubbleContainer.bottomAnchor, constant: 13.5),
            line.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -13.5),
            line.centerXAnchor.constraint(equalTo: statusIndicatorBubbleContainer.centerXAnchor),
            line.widthAnchor.constraint(equalToConstant: 2)
        
        ].forEach({ $0.isActive = true })
        
        line.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.70)
        line.layer.cornerRadius = 1
        line.layer.cornerCurve = .continuous
        line.clipsToBounds = true
    }
    
    private func configureNameLabel () {
        
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.leadingAnchor.constraint(equalTo: statusIndicatorBubbleContainer.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            nameLabel.centerYAnchor.constraint(equalTo: statusIndicatorBubbleContainer.centerYAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 25)
            
        ].forEach({ $0.isActive = true })
        
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 19)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .left
        nameLabel.text = block?.name
    }
    
    private func configureEndTimeLabel () {
        
        self.contentView.addSubview(endTimeLabel)
        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            endTimeLabel.leadingAnchor.constraint(equalTo: statusIndicatorBubbleContainer.trailingAnchor, constant: 20),
            endTimeLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            endTimeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            endTimeLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let semiBoldText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 15) as Any, NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.paragraphStyle : paragraphStyle]
        let regularText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 14) as Any, NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.paragraphStyle : paragraphStyle]
        
        let attributedString = NSMutableAttributedString(string: "")
        
        if let ends = block?.ends, formatter != nil {
            
            attributedString.append(NSAttributedString(string: "Ends:  ", attributes: semiBoldText))
            
            formatter?.dateFormat = "MMMM dd"
            attributedString.append(NSAttributedString(string: formatter!.string(from: ends), attributes: regularText))
            
            attributedString.append(NSAttributedString(string: ends.daySuffix() + ", ", attributes: regularText))
            
            formatter?.dateFormat = "h:mm a"
            attributedString.append(NSAttributedString(string: formatter!.string(from: ends), attributes: regularText))
            
            endTimeLabel.attributedText = attributedString
        }
    }
    
    private func configureStatusLabel () {
        
        self.contentView.addSubview(statusLabelContainer)
        statusLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabelContainer.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            statusLabelContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
            statusLabelContainer.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 7.5),
            statusLabelContainer.widthAnchor.constraint(equalToConstant: 80),
            statusLabelContainer.heightAnchor.constraint(equalToConstant: 26),
            
            statusLabel.leadingAnchor.constraint(equalTo: statusLabelContainer.leadingAnchor, constant: 5),
            statusLabel.trailingAnchor.constraint(equalTo: statusLabelContainer.trailingAnchor, constant: -5),
            statusLabel.centerYAnchor.constraint(equalTo: statusLabelContainer.centerYAnchor, constant: 0),
            statusLabel.heightAnchor.constraint(equalToConstant: 26)
        
        ].forEach({ $0.isActive = true })
        
        statusLabelContainer.layer.cornerRadius = 13//11
        statusLabelContainer.layer.cornerCurve = .continuous
        statusLabelContainer.clipsToBounds = true
        
        statusLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.adjustsFontSizeToFitWidth = true
        
        let statusText: [BlockStatus : String] = [.notStarted : "Not Started", .inProgress : "In Progress", .completed : "Completed", .needsHelp : "Needs Help", .late : "Late"]
        
        if let status = block?.status, let statusColor = statusColors[status], let statusText = statusText[status] {
            
            statusLabelContainer.backgroundColor = statusColor
            statusLabel.text = statusText
        }
        
        else if let starts = block?.starts, let ends = block?.ends {
            
            if Date().isBetween(startDate: starts, endDate: ends) {
                
                //In Progress
                statusLabelContainer.backgroundColor = UIColor(hexString: "5065A0", withAlpha: 0.75)
                statusLabel.text = "In Progress"
            }
            
            else if Date() < starts {
                
                //Not Started
                statusLabelContainer.backgroundColor = UIColor(hexString: "AAAAAA", withAlpha: 0.75)
                statusLabel.text = "Not Started"
            }
            
            else if Date() > ends {
                 
                //Late
                statusLabelContainer.backgroundColor = UIColor(hexString: "E84D3C", withAlpha: 0.75)
                statusLabel.text = "Late"
            }
        }
    }
    
    private func configureMembersStackView () {
        
        noMembersLabel.removeFromSuperview()
        membersStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        self.contentView.addSubview(membersStackView)
        membersStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            membersStackView.leadingAnchor.constraint(equalTo: statusIndicatorBubbleContainer.trailingAnchor, constant: 17),
            membersStackView.topAnchor.constraint(equalTo: statusLabelContainer.bottomAnchor, constant: 0),
            membersStackView.heightAnchor.constraint(equalToConstant: 40)
        
        ].forEach({ $0.isActive = true })
        
        if stackViewWidthConstraint == nil {
        
            stackViewWidthConstraint = membersStackView.widthAnchor.constraint(equalToConstant: 0)
            stackViewWidthConstraint?.isActive = true
        }
        
        membersStackView.alignment = .center
        membersStackView.distribution = .fillProportionally
        membersStackView.axis = .horizontal
        membersStackView.spacing = -20 //Half the size of the profilePicOutline
    }
    
    private func configureNoMembersLabel () {
        
        membersStackView.removeFromSuperview()
        
        self.contentView.addSubview(noMembersLabel)
        noMembersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noMembersLabel.leadingAnchor.constraint(equalTo: statusIndicatorBubbleContainer.trailingAnchor, constant: 20),
            noMembersLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            noMembersLabel.topAnchor.constraint(equalTo: statusLabelContainer.bottomAnchor, constant: 7.5),
            noMembersLabel.heightAnchor.constraint(equalToConstant: 15)
        
        ].forEach({ $0.isActive = true })
        
        noMembersLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        noMembersLabel.textColor = .black
        noMembersLabel.textAlignment = .left
        noMembersLabel.text = "No Members Yet"
    }
    
    private func setMembers () {

        membersStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })

        if var members = block?.members {

            let currentUser = CurrentUser.sharedInstance
            let firebaseCollab = FirebaseCollab.sharedInstance
            let firebaseStorage = FirebaseStorage()

            stackViewWidthConstraint?.constant = CGFloat((members.count * 40) - ((members.count - 1) * 20))
            
            members = members.sorted(by: { $0.firstName < $1.firstName })

            var memberCount: Int = 0

            for member in members {

                let profilePicOutline = UIView()
                profilePicOutline.backgroundColor = memberCount == 0 ? .clear : .white
                profilePicOutline.layer.cornerRadius = 0.5 * 40
                profilePicOutline.clipsToBounds = true

                var profilePic: ProfilePicture

                if memberCount == 0 {

                    profilePic = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic"), shadowRadius: 2, shadowOpacity: 0.2, borderColor: UIColor.clear.cgColor, borderWidth: 0)
                }

                else {

                    profilePic = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic"), shadowRadius: 0, shadowColor: UIColor.clear.cgColor, shadowOpacity: 0, borderColor: UIColor.clear.cgColor, borderWidth: 0)
                }

                profilePicOutline.addSubview(profilePic)
                membersStackView.addArrangedSubview(profilePicOutline)

                profilePicOutline.translatesAutoresizingMaskIntoConstraints = false
                profilePic.translatesAutoresizingMaskIntoConstraints = false

                [
                    // 20 is half the size of the profilePicOutline
                    profilePicOutline.topAnchor.constraint(equalTo: profilePicOutline.superview!.topAnchor, constant: 0),
                    profilePicOutline.leadingAnchor.constraint(equalTo: profilePicOutline.superview!.leadingAnchor, constant: CGFloat(memberCount * 20)),
                    profilePicOutline.widthAnchor.constraint(equalToConstant: 40),
                    profilePicOutline.heightAnchor.constraint(equalToConstant: 40),

                    profilePic.centerXAnchor.constraint(equalTo: profilePic.superview!.centerXAnchor),
                    profilePic.centerYAnchor.constraint(equalTo: profilePic.superview!.centerYAnchor),
                    profilePic.widthAnchor.constraint(equalToConstant: 36),
                    profilePic.heightAnchor.constraint(equalToConstant: 36)

                ].forEach({ $0.isActive = true })

                //Setting the profile picture image
                if member.userID == currentUser.userID {

                    profilePic.profilePic = currentUser.profilePictureImage
                }

                else if let friend = firebaseCollab.friends.first(where: { $0.userID == member.userID }) {

                    profilePic.profilePic = friend.profilePictureImage
                }

                else if let memberProfilePic = firebaseCollab.membersProfilePics[member.userID] {

                    profilePic.profilePic = memberProfilePic
                }

                else {

                    firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { (retrievedProfilePic, userID) in

                        profilePic.profilePic = retrievedProfilePic

                        firebaseCollab.cacheMemberProfilePics(userID: member.userID, profilePic: retrievedProfilePic)
                    }
                }

                memberCount += 1
            }
        }
    }
}
