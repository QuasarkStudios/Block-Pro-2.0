//
//  ConvoMemberInfoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/17/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol ConversateWithMemberProtcol: AnyObject {
    
    func conversateWithMember (_ member: Friend)
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
    
    weak var conversateWithMemberDelegate: ConversateWithMemberProtcol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureProfilePicImageView()
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
    
    @IBAction func messageButton(_ sender: Any) {
        
        guard member != nil else { return }
        
            if let friend = firebaseCollab.friends.first(where: { $0.userID == member!.userID }) {
                    
                    conversateWithMemberDelegate?.conversateWithMember(friend)
            }
    }
}
