//
//  ConvoMemberInfoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/17/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol ConversateWithFriendProtcol: AnyObject {
    
    func conversateWithFriend (_ friend: Friend)
}

class ConvoMemberInfoCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var activeLabel: UILabel!
    
    @IBOutlet weak var messageButton: UIButton!
    
    var profilePicImageView: ProfilePicture?
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var member: Member? {
        didSet {
            
            retrieveProfilePic(member: member!)
            
            nameLabel.text = member!.firstName
        }
    }
    
    var memberActivity: Any? {
        didSet {
            
            setActivityLabel(memberActivity)
        }
    }
    
    weak var conversateWithFriendDelegate: ConversateWithFriendProtcol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureProfilePicImageView()
        
        activeLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func configureProfilePicImageView () {
        
        profilePicImageView = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic"), shadowRadius: 2, shadowColor: UIColor(hexString: "39434A")!.cgColor, shadowOpacity: 0.35)
        
        self.addSubview(profilePicImageView!)
        
        profilePicImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            profilePicImageView?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            profilePicImageView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            profilePicImageView?.widthAnchor.constraint(equalToConstant: 50),
            profilePicImageView?.heightAnchor.constraint(equalToConstant: 50)
        
        ].forEach({ $0?.isActive = true })

    }
    
    private func retrieveProfilePic (member: Member) {
        
        if let friendIndex = firebaseCollab.friends.firstIndex(where: { $0.userID == member.userID }) {
            
            profilePicImageView?.profilePic = firebaseCollab.friends[friendIndex].profilePictureImage
        }
        
        else if let memberProfilePic = firebaseCollab.membersProfilePics[member.userID] {
                
            profilePicImageView?.profilePic = memberProfilePic
        }
        
        else {
            
            firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { (profilePic, userID) in
                
                self.profilePicImageView?.profilePic = profilePic
                
                self.firebaseCollab.cacheMemberProfilePics(userID: member.userID, profilePic: profilePic)
            }
        }
    }
    
    private func setActivityLabel (_ activity: Any?) {
        
        let calendar = Calendar.current
        
        if activity != nil {
            
            if activity as? Date != nil {
                
                if calendar.dateComponents([.year], from: activity as! Date, to: Date()).year ?? 0 > 0 {
                    
                    activeLabel.text = "Active over a year ago"
                }
                
                else if calendar.dateComponents([.month], from: activity as! Date, to: Date()).month ?? 0 > 0 {
                    
                    if calendar.dateComponents([.month], from: activity as! Date, to: Date()).month == 1 {
                        
                        activeLabel.text = "Active a month ago"
                    }
                    
                    else {
                        
                        let monthsAgoActive = calendar.dateComponents([.month], from: activity as! Date, to: Date()).month
                        activeLabel.text = "Active \(monthsAgoActive!) months ago"
                    }
                }
                
                else if calendar.dateComponents([.day], from: activity as! Date, to: Date()).day ?? 0 > 0 {

                    if calendar.dateComponents([.day], from: activity as! Date, to: Date()).day == 1 {
                        
                        activeLabel.text = "Active yesterday"
                    }
                    
                    else {
                        
                        let daysAgoActive = calendar.dateComponents([.day], from: activity as! Date, to: Date()).day
                        activeLabel.text = "Active \(daysAgoActive!) days ago"
                    }
                }
                
                else if calendar.dateComponents([.hour], from: activity as! Date, to: Date()).hour ?? 0 > 0 {
                    
                    if calendar.dateComponents([.hour], from: activity as! Date, to: Date()).hour == 1 {
                        
                        activeLabel.text = "Active an hour ago"
                    }
                    
                    else {
                        
                        let hoursAgoActive = calendar.dateComponents([.hour], from: activity as! Date, to: Date()).hour
                        activeLabel.text = "Active \(hoursAgoActive!) hours ago"
                    }
                }
                
                else {
                    
                    if calendar.dateComponents([.minute], from: activity as! Date, to: Date()).minute ?? 0 < 2 {
                        
                        activeLabel.text = "Active a minute ago"
                    }
                    
                    else {
                        
                        let minutesAgoActive = calendar.dateComponents([.minute], from: activity as! Date, to: Date()).minute
                        activeLabel.text = "Active \(minutesAgoActive!) minutes ago"
                    }
                }
            }
            
            else if activity as? String != nil {
                
                activeLabel.text = "Active \(activity!)"
            }
        }
        
        else {
            
            activeLabel.text = "Never active"
        }
    }
    
    @IBAction func messageButton(_ sender: Any) {
        
        guard member != nil else { return }
        
            if let friend = firebaseCollab.friends.first(where: { $0.userID == member!.userID }) {
                    
                    conversateWithFriendDelegate?.conversateWithFriend(friend)
            }
    }
}
