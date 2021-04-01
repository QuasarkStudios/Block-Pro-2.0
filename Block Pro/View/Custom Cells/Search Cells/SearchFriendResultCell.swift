//
//  SearchFriendResultCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/21/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import BEMCheckBox
import SVProgressHUD

class SearchFriendResultCell: UITableViewCell {

    let profilePicture = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic")!, shadowRadius: 2, shadowOpacity: 0.35, borderColor: UIColor(hexString: "F4F4F4", withAlpha: 0.1)!.cgColor)
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    let addButton = UIButton(type: .system)
    let checkBox = BEMCheckBox()
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var searchResult: FriendSearchResult? {
        didSet {
            
            setProfilePicture()
            
            setNameAndUsernameLabel()
            
            reconfigureButtonAndCheckBox()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "searchFriendResultCell")
        
        configureProfilePicture()
        configureNameLabel()
        configureUsernameLabel()
        configureAddButton()
        configureCheckBox()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Profile Picture
    
    private func configureProfilePicture () {
        
        self.contentView.addSubview(profilePicture)
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        
        [

            profilePicture.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            profilePicture.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 17),
            profilePicture.widthAnchor.constraint(equalToConstant: 53),
            profilePicture.heightAnchor.constraint(equalToConstant: 53)
            
        ].forEach( { $0.isActive = true } )
    }
    
    
    //MARK: Configure Name Label
    
    private func configureNameLabel () {
        
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 17),
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -114),
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
        
            usernameLabel.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 17),
            usernameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -114),
            usernameLabel.bottomAnchor.constraint(equalTo: self.profilePicture.bottomAnchor, constant: 0),
            usernameLabel.heightAnchor.constraint(equalToConstant: 26.5)
        
        ].forEach({ $0.isActive = true })
        
        usernameLabel.font = UIFont(name: "Poppins-MediumItalic", size: 15)
        usernameLabel.textAlignment = .left
        usernameLabel.textColor = .lightGray
    }
    
    
    //MARK: - Configure Add Button
    
    private func configureAddButton () {
        
        self.contentView.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            addButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -17),
            addButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0),
            addButton.widthAnchor.constraint(equalToConstant: 80),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        addButton.backgroundColor = UIColor(hexString: "222222")
        addButton.layer.cornerRadius = 15
        
        addButton.tintColor = .white
        
        addButton.setTitle("Add", for: .normal)
        addButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 15)
        
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Check Box
    
    private func configureCheckBox () {

        self.contentView.insertSubview(checkBox, belowSubview: addButton)
        checkBox.translatesAutoresizingMaskIntoConstraints = false

        [

            checkBox.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -17),
            checkBox.centerYAnchor.constraint(equalTo: addButton.centerYAnchor, constant: 0),
            checkBox.widthAnchor.constraint(equalToConstant: 30),
            checkBox.heightAnchor.constraint(equalToConstant: 30)

        ].forEach({ $0.isActive = true })
        
        checkBox.isHidden = true

        checkBox.tintColor = UIColor(hexString: "222222") ?? .black //Off tint color
        checkBox.offFillColor = UIColor(hexString: "222222") ?? .black
        
        checkBox.onTintColor = UIColor(hexString: "222222") ?? .black
        checkBox.onFillColor = UIColor(hexString: "222222") ?? .black
        checkBox.onCheckColor = .white

        checkBox.lineWidth = 3

        checkBox.onAnimationType = .bounce
        checkBox.offAnimationType = .bounce

        checkBox.isUserInteractionEnabled = false
    }
    
    
    //MARK: - Set Profile Picture
    
    private func setProfilePicture () {
        
        if let result = searchResult {
            
            if let profilePic = firebaseCollab.friends.first(where: { $0.userID == result.userID })?.profilePictureImage {
                
                profilePicture.profilePic = profilePic
            }
            
            else if let profilePic = firebaseCollab.membersProfilePics[result.userID] {
                
                profilePicture.profilePic = profilePic
            }
            
            else {
                
                profilePicture.profilePic = nil
                
                firebaseStorage.retrieveUserProfilePicFromStorage(userID: result.userID) { (profilePic, userID) in
                    
                    self.profilePicture.profilePic = profilePic
                    
                    self.firebaseCollab.membersProfilePics[userID] = profilePic
                }
            }
        }
    }
    
    
    //MARK: - Set Name and Username
    
    private func setNameAndUsernameLabel () {
        
        if let firstName = searchResult?.firstName, let lastName = searchResult?.lastName {
            
            nameLabel.text = firstName + " " + lastName
        }
        
        if let username = searchResult?.username {
            
            usernameLabel.text = "@" + username
        }
    }
    
    
    //MARK: - Reconfigure Button and Check Box
    
    private func reconfigureButtonAndCheckBox () {
        
        if firebaseCollab.friends.contains(where: { $0.userID == searchResult?.userID }) {
            
            addButton.isHidden = true
            
            checkBox.isHidden = false
            checkBox.on = true
        }
        
        else {
            
            addButton.isHidden = false
            addButton.tintColor = .white
            
            addButton.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .width {
                    
                    constraint.constant = 80
                }
                
                else if constraint.firstAttribute == .height {
                    
                    constraint.constant = 30
                }
            }
            
            checkBox.isHidden = true
            checkBox.on = false
        }
    }
    
    
    //MARK: - Animate Button Selection
    
    private func animateButtonSelection () {
        
        addButton.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                
                constraint.constant = 32
            }
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.layoutIfNeeded()
            
        } completion: { (finished: Bool) in
            
            self.checkBox.isHidden = false
            self.addButton.isHidden = true
        }
        
        UIView.transition(with: addButton, duration: 0.2, options: [.transitionCrossDissolve]) {

            self.addButton.tintColor = .clear
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            
            self.checkBox.setOn(true, animated: true)
        }
    }
    
    
    //MARK: - Add Button Pressed
    
    @objc private func addButtonPressed () {
        
        if let result = searchResult {
            
            animateButtonSelection()
            
            firebaseCollab.sendFriendRequest(result)
            
            SVProgressHUD.showSuccess(withStatus: "Friend request sent to \(result.firstName)!")
        }
    }
}
