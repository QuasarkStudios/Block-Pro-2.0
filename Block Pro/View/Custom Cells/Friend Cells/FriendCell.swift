//
//  FriendCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/16/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {

    let profilePicture = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic")!, shadowRadius: 2, shadowOpacity: 0.35, borderColor: UIColor(hexString: "F4F4F4", withAlpha: 0.1)!.cgColor)
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var friend: Friend? {
        didSet {
            
            setProfilePicture()
            
            setNameAndUsernameLabel()
        }
    }
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "friendCell")
        
        self.contentView.clipsToBounds = true
        
        configureProfilePicture()
        configureNameLabel()
        configureUsernameLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder) has not been implemented")
    }
    
    //Handles the cell backgroundColor animation when the cell is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.backgroundColor = UIColor(hexString: "D8D8D8")?.lighten(byPercentage: 0.1)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        self.backgroundColor = nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
            
            self.backgroundColor = nil
        })
    }
    
    
    //MARK: - Configure Profile Picture
    
    private func configureProfilePicture () {
        
        self.contentView.addSubview(profilePicture)
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        
        [

            profilePicture.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 13.5),
            profilePicture.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            profilePicture.widthAnchor.constraint(equalToConstant: 53),
            profilePicture.heightAnchor.constraint(equalToConstant: 53)
            
        ].forEach( { $0.isActive = true } )
    }
    
    
    //MARK: Configure Name Label
    
    private func configureNameLabel () {
        
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -17),
            nameLabel.topAnchor.constraint(equalTo: self.profilePicture.topAnchor, constant: 0),
            nameLabel.heightAnchor.constraint(equalToConstant: 26.5)
            
        ].forEach({ $0.isActive = true })
        
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        nameLabel.textAlignment = .left
        nameLabel.textColor = .black
    }
    
    
    //MARK: - Configure Username Label
    
    private func configureUsernameLabel () {
        
        self.contentView.addSubview(usernameLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            usernameLabel.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -17),
            usernameLabel.bottomAnchor.constraint(equalTo: self.profilePicture.bottomAnchor, constant: 0),
            usernameLabel.heightAnchor.constraint(equalToConstant: 26.5)
        
        ].forEach({ $0.isActive = true })
        
        usernameLabel.font = UIFont(name: "Poppins-MediumItalic", size: 15)
        usernameLabel.textAlignment = .left
        usernameLabel.textColor = .lightGray
    }
    
    
    //MARK: - Set Profile Picture
    
    private func setProfilePicture () {
        
        if let friend = friend {
            
            if let profilePic = firebaseCollab.friends.first(where: { $0.userID == friend.userID })?.profilePictureImage {
                
                profilePicture.profilePic = profilePic
            }
            
            else if let profilePic = firebaseCollab.membersProfilePics[friend.userID] {
                
                profilePicture.profilePic = profilePic
            }
            
            else {
                
                profilePicture.profilePic = nil
                
                firebaseStorage.retrieveUserProfilePicFromStorage(userID: friend.userID) { (profilePic, userID) in
                    
                    self.profilePicture.profilePic = profilePic
                    
                    self.firebaseCollab.membersProfilePics[userID] = profilePic
                }
            }
        }
    }
    
    
    //MARK: - Set Name and Username
    
    private func setNameAndUsernameLabel () {
        
        if let firstName = friend?.firstName, let lastName = friend?.lastName {
            
            nameLabel.text = firstName + " " + lastName
        }
        
        if let username = friend?.username {
            
            usernameLabel.text = "@" + username
        }
    }
}
