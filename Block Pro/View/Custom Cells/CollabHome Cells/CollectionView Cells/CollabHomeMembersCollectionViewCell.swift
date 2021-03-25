//
//  CollabHomeMembersCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/21/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import BEMCheckBox

class CollabHomeMembersCollectionViewCell: UICollectionViewCell {
    
    let containerView = UIView()
    
    let profilePic = ProfilePicture(shadowRadius: 2.5, shadowColor: UIColor.white.cgColor, shadowOpacity: 0.5, borderWidth: 0)
    
    let nameLabel = UILabel()
    let activityLabel = UILabel()
    let roleLabel = UILabel()
    
    var progressCircle: ProgressCircles?
    let progressLabel = UILabel()
    
    let checkBox = BEMCheckBox()
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var member: Member? {
        didSet {
            
            retrieveProfilePic(member: member!)
            
            nameLabel.text = member?.userID != currentUser.userID ? member!.firstName : "Just You"
            roleLabel.text = member!.role
        }
    }
    
    var memberActivity: Any? {
        didSet {
            
            setActivityLabel(memberActivity)
        }
    }
    
    var blocks: [Block]? {
        didSet {
            
            calculateProgress()
        }
    }
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureContainerView()
        configureProfilePic()
        
        configureNameLabel()
        configureRoleLabel()
        configureActivityLabel()
        
        configureProgressCircle()
        configureProgressLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        configureCheckBox() //Call here to avoid constraints breaking for no reason
    }
    
    
    //MARK: - Configure Container View
    
    private func configureContainerView () {
        
        self.contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        containerView.backgroundColor = UIColor(hexString: "222222")
        
        containerView.layer.cornerRadius = 15
        containerView.layer.cornerCurve = .continuous
    
        containerView.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOpacity = 0.35
    }
    
    
    //MARK: - Configure Profile Pic
    
    private func configureProfilePic () {
        
        containerView.addSubview(profilePic)
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            profilePic.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 17.5),
            profilePic.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0),
            profilePic.widthAnchor.constraint(equalToConstant: 70),
            profilePic.heightAnchor.constraint(equalToConstant: 70)
        
        ].forEach({ $0.isActive = true })
    }
    
    
    //MARK: - Configure Name Label
    
    private func configureNameLabel () {
        
        containerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.leadingAnchor.constraint(equalTo: profilePic.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            nameLabel.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 19)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .left
    }
    
    
    //MARK: - Configure Role Label
    
    private func configureRoleLabel () {
        
        containerView.addSubview(roleLabel)
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            roleLabel.leadingAnchor.constraint(equalTo: profilePic.trailingAnchor, constant: 22),
            roleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -80),
            roleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -36),
            roleLabel.heightAnchor.constraint(equalToConstant: 21)
        
        ].forEach({ $0.isActive = true })
        
        roleLabel.font = UIFont(name: "Poppins-Italic", size: 14)
        roleLabel.textColor = .white
        roleLabel.textAlignment = .left
    }
    
    
    //MARK: - Configure Activity Label
    
    private func configureActivityLabel () {
        
        containerView.addSubview(activityLabel)
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            activityLabel.leadingAnchor.constraint(equalTo: profilePic.trailingAnchor, constant: 22),
            activityLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -80/*-20*/),
            activityLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            activityLabel.heightAnchor.constraint(equalToConstant: 21)
        
        ].forEach({ $0.isActive = true })
        
        activityLabel.font = UIFont(name: "Poppins-Italic", size: 14)
        activityLabel.textColor = .white
        activityLabel.textAlignment = .left
    }
    
    
    //MARK: - Configure Progress Circle
    
    private func configureProgressCircle () {
        
        progressCircle = ProgressCircles(radius: 20, lineWidth: 6, strokeColor: UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor, strokeEnd: 0)
        
        containerView.addSubview(progressCircle!)
        progressCircle!.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressCircle?.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            progressCircle?.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            progressCircle?.widthAnchor.constraint(equalToConstant: 40),
            progressCircle?.heightAnchor.constraint(equalToConstant: 40)
        
        ].forEach({ $0?.isActive = true })
    }
    
    
    //MARK: - Configure Progress Label
    
    private func configureProgressLabel () {
        
        if let circle = progressCircle {
            
            containerView.addSubview(progressLabel)
            progressLabel.translatesAutoresizingMaskIntoConstraints = false
            
            
            
            [
            
                progressLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor, constant: 0),
                progressLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 0),
                progressLabel.widthAnchor.constraint(equalToConstant: 25),
                progressLabel.heightAnchor.constraint(equalToConstant: 25)
            
            ].forEach({ $0.isActive = true })
            
            progressLabel.tag = 1
            progressLabel.font = UIFont(name: "Poppins-Italic", size: 13.5)
            progressLabel.adjustsFontSizeToFitWidth = true
            progressLabel.textColor = .white
            progressLabel.textAlignment = .center
        }
    }
    
    
    //MARK: - Configure Check Box
    
    private func configureCheckBox () {
        
        if let circle = progressCircle {
            
            containerView.addSubview(checkBox)
            checkBox.translatesAutoresizingMaskIntoConstraints = false
            
            [

                checkBox.centerXAnchor.constraint(equalTo: circle.centerXAnchor, constant: 0),
                checkBox.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 0),
                checkBox.widthAnchor.constraint(equalToConstant: 30),
                checkBox.heightAnchor.constraint(equalToConstant: 30)

            ].forEach({ $0.isActive = true })
            
            checkBox.isUserInteractionEnabled = false
            checkBox.hideBox = true
            checkBox.on = false
            
            checkBox.lineWidth = 4
            checkBox.tintColor = .clear
            checkBox.onCheckColor = UIColor(hexString: "7BD293") ?? .green
        }
    }
    
    
    //MARK: - Retrieve Profile Pic
    
    private func retrieveProfilePic (member: Member) {
        
        if let friendIndex = firebaseCollab.friends.firstIndex(where: { $0.userID == member.userID }) {
            
            profilePic.profilePic = firebaseCollab.friends[friendIndex].profilePictureImage
        }
        
        else if let memberProfilePic = firebaseCollab.membersProfilePics[member.userID] {
            
            profilePic.profilePic = memberProfilePic
        }
        
        else {
            
            firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { (profilePic, userID) in
                
                self.profilePic.profilePic = profilePic
                
                self.firebaseCollab.cacheMemberProfilePics(userID: member.userID, profilePic: profilePic)
            }
        }
    }
    
    
    //MARK: - Set Activity Label
    
    private func setActivityLabel (_ activity: Any?) {
        
        let calendar = Calendar.current
        
        if activity != nil {
            
            if activity as? Date != nil {
                
                if calendar.dateComponents([.year], from: activity as! Date, to: Date()).year ?? 0 > 0 {
                    
                    activityLabel.text = "Active over a year ago"
                }
                
                else if calendar.dateComponents([.month], from: activity as! Date, to: Date()).month ?? 0 > 0 {
                    
                    if calendar.dateComponents([.month], from: activity as! Date, to: Date()).month == 1 {
                        
                        activityLabel.text = "Active a month ago"
                    }
                    
                    else {
                        
                        let monthsAgoActive = calendar.dateComponents([.month], from: activity as! Date, to: Date()).month
                        activityLabel.text = "Active \(monthsAgoActive!) months ago"
                    }
                }
                
                else if calendar.dateComponents([.day], from: activity as! Date, to: Date()).day ?? 0 > 0 {

                    if calendar.dateComponents([.day], from: activity as! Date, to: Date()).day == 1 {
                        
                        activityLabel.text = "Active yesterday"
                    }
                    
                    else {
                        
                        let daysAgoActive = calendar.dateComponents([.day], from: activity as! Date, to: Date()).day
                        activityLabel.text = "Active \(daysAgoActive!) days ago"
                    }
                }
                
                else if calendar.dateComponents([.hour], from: activity as! Date, to: Date()).hour ?? 0 > 0 {
                    
                    if calendar.dateComponents([.hour], from: activity as! Date, to: Date()).hour == 1 {
                        
                        activityLabel.text = "Active an hour ago"
                    }
                    
                    else {
                        
                        let hoursAgoActive = calendar.dateComponents([.hour], from: activity as! Date, to: Date()).hour
                        activityLabel.text = "Active \(hoursAgoActive!) hours ago"
                    }
                }
                
                else {
                    
                    if calendar.dateComponents([.minute], from: activity as! Date, to: Date()).minute ?? 0 < 2 {
                        
                        activityLabel.text = "Active a minute ago"
                    }
                    
                    else {
                        
                        let minutesAgoActive = calendar.dateComponents([.minute], from: activity as! Date, to: Date()).minute
                        activityLabel.text = "Active \(minutesAgoActive!) minutes ago"
                    }
                }
            }
            
            else if activity as? String != nil {
                
                activityLabel.text = "Active \(activity!)"
            }
        }
        
        else {
            
            activityLabel.text = "Never active"
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
                
                progressCircle?.shapeLayer.strokeEnd = 0.0025
                progressCircle?.shapeLayer.strokeColor = UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor
                progressLabel.isHidden = false
                checkBox.on = false
            }
            
            //If less than 100% have been completed
            else if completedPercentage < 100 {
                
                progressCircle?.shapeLayer.strokeEnd = CGFloat(completedBlockCount) / CGFloat(blockCount)
                progressCircle?.shapeLayer.strokeColor = UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor
                progressLabel.isHidden = false
                checkBox.on = false
            }
            
            //If all the blocks have been completed
            else if completedPercentage == 100 {
                
                progressCircle?.shapeLayer.strokeEnd = 1
                progressCircle?.shapeLayer.strokeColor = UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor
                progressLabel.isHidden = true
                checkBox.on = true
            }
            
            progressLabel.text = "\(Int(completedPercentage))%"
        }
        
        //If there are not blocks assigned to this user
        else {
            
            progressCircle?.shapeLayer.strokeEnd = 0.0025
            progressCircle?.shapeLayer.strokeColor = UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor
            progressLabel.isHidden = false
            checkBox.on = false
            
            progressLabel.text = "0%"
        }
    }
}
