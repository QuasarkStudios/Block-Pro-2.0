//
//  CollabMemberCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/11/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabMemberCollectionViewCell: UICollectionViewCell {

    let profilePic = ProfilePicture(shadowRadius: 2.5, shadowColor: UIColor.white.cgColor, shadowOpacity: 0.5)
    
    let nameLabel = UILabel()
    
    let moreImage = UIImageView()
    
    let activityLabel = UILabel()
    
    let roleLabel = UILabel()
    
    var progressCircles: ProgressCircles?
    
    let progressLabel = UILabel()
    let progressTrackLayer = CAShapeLayer()
    let progressShapeLayer = CAShapeLayer()
    
    let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var member: Member? {
        didSet{
            
            retrieveProfilePic(member: member!)
            
            nameLabel.text = member!.firstName
            setRoleLabel(member!.role)
        }
    }
    
    var memberActivity: Any? {
        didSet {
            
            setActivityLabel(memberActivity)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCell()
        configureProfilePic()
        configureMoreImage() //Call this before "configureNameLabel"
        configureNameLabel()
        configureActivityLabel()
        configureRoleLabel()
        configureProgressLabel()
        configureProgressCircles()
    }
    
    private func configureCell () {
        
        self.contentView.backgroundColor = UIColor(hexString: "222222")
        
        self.contentView.layer.cornerRadius = 15
        self.contentView.layer.cornerCurve = .continuous
        self.contentView.clipsToBounds = true
    }
    
    private func configureProfilePic() {
        
        self.contentView.addSubview(profilePic)
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            profilePic.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            profilePic.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12),
            profilePic.widthAnchor.constraint(equalToConstant: 38),
            profilePic.heightAnchor.constraint(equalToConstant: 38)
        
        ].forEach({ $0.isActive = true })
    }
    
    private func configureNameLabel () {
        
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.leadingAnchor.constraint(equalTo: profilePic.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: moreImage.leadingAnchor, constant: 0),
            nameLabel.centerYAnchor.constraint(equalTo: profilePic.centerYAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 21)
            
        ].forEach({ $0.isActive = true })
        
        nameLabel.font = UIFont(name: "Poppins-Medium", size: 15)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
    }
    
    private func configureMoreImage () {
        
        self.contentView.addSubview(moreImage)
        moreImage.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            moreImage.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            moreImage.centerYAnchor.constraint(equalTo: profilePic.centerYAnchor),
            moreImage.widthAnchor.constraint(equalToConstant: 20),
            moreImage.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        moreImage.contentMode = .scaleAspectFill
        moreImage.image = UIImage(named: "more")?.withRenderingMode(.alwaysTemplate)
        moreImage.tintColor = .white
    }
    
    private func configureActivityLabel () {
        
        self.contentView.addSubview(activityLabel)
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            activityLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            activityLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            activityLabel.topAnchor.constraint(equalTo: self.profilePic.bottomAnchor, constant: 13),
            activityLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        activityLabel.font = UIFont(name: "Poppins-Italic", size: 12)
        activityLabel.adjustsFontSizeToFitWidth = true
        activityLabel.textColor = .white
        activityLabel.textAlignment = .left
    }
    
    private func configureRoleLabel () {
        
        self.contentView.addSubview(roleLabel)
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            roleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            roleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            roleLabel.topAnchor.constraint(equalTo: self.activityLabel.bottomAnchor, constant: 13),
            roleLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
    }
    
    private func configureProgressLabel () {
        
        self.contentView.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            progressLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            progressLabel.topAnchor.constraint(equalTo: self.roleLabel.bottomAnchor, constant: 13),
            progressLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        progressLabel.font = UIFont(name: "Poppins-Medium", size: 13)
        progressLabel.text = "Progress:"
        progressLabel.textColor = .white
        progressLabel.textAlignment = .left
    }
    
    private func configureProgressCircles () {
        
        progressCircles = ProgressCircles(radius: 11.5, lineWidth: 6, strokeColor: UIColor(hexString: "5065A0")!.withAlphaComponent(80).cgColor, strokeEnd: 0.6)
        
        self.contentView.addSubview(progressCircles!)
        progressCircles?.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            progressCircles?.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            progressCircles?.centerYAnchor.constraint(equalTo: progressLabel.centerYAnchor),
            progressCircles?.widthAnchor.constraint(equalToConstant: 35),
            progressCircles?.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0?.isActive = true })
    }
    
//    private func configureProgressAnimation () {
//
//        progressAnimation.fromValue = 0
//        progressAnimation.toValue = 0.6
//        progressAnimation.duration = 0
//        progressAnimation.fillMode = CAMediaTimingFillMode.forwards
//        progressAnimation.isRemovedOnCompletion = false
//
//        progressAnimation.speed = 1
//
//        progressShapeLayer.add(progressAnimation, forKey: nil)
//    }
    
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
    
    private func setRoleLabel (_ role: String) {
        
        let semiBoldText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 13) as Any, NSAttributedString.Key.foregroundColor : UIColor.white]
        let italicText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Italic", size: 12) as Any, NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        
        attributedString.append(NSAttributedString(string: "Role: ", attributes: semiBoldText))
        attributedString.append(NSAttributedString(string: role, attributes: italicText))
        roleLabel.attributedText = attributedString
    }

}
