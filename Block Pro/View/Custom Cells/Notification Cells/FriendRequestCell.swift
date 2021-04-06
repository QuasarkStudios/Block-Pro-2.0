//
//  FriendRequestCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/25/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class FriendRequestCell: UITableViewCell {

    let profilePicture = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic")!, shadowRadius: 2, shadowOpacity: 0.35, borderColor: UIColor(hexString: "F4F4F4", withAlpha: 0.1)!.cgColor)
    let nameLabel = UILabel()
    let requestSentOnLabel = UILabel()
    let requestLabel = UILabel()
    
    let acceptButton = UIButton(type: .system)
    let declineButton = UIButton(type: .system)
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var formatter: DateFormatter?
    
    var friendRequest: Friend? {
        didSet {
            
            setProfilePicture()
            
            if let firstName = friendRequest?.firstName, let lastName = friendRequest?.lastName {
                
                nameLabel.text = firstName + " " + lastName
            }
            
            setRequestSentOnLabel(requestSentOn: friendRequest?.requestSentOn)
        }
    }
    
    weak var friendRequestDelegate: FriendRequestProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "friendRequestCell")
        
        self.contentView.clipsToBounds = true
        
        configureProfilePicture()
        configureNameLabel()
        configureRequestSentOnLabel()
        configureRequestLabel()
        
        configureAcceptButton()
        configureDeclineButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -97.5),
            nameLabel.topAnchor.constraint(equalTo: self.profilePicture.topAnchor, constant: 0),
            nameLabel.heightAnchor.constraint(equalToConstant: 26.5)
            
        ].forEach({ $0.isActive = true })
        
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
    
    
    //MARK: - Configure Request Label
    
    private func configureRequestLabel () {
        
        self.contentView.addSubview(requestLabel)
        requestLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            requestLabel.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 17),
            requestLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -17),
            requestLabel.bottomAnchor.constraint(equalTo: self.profilePicture.bottomAnchor, constant: 0),
            requestLabel.heightAnchor.constraint(equalToConstant: 26.5)
        
        ].forEach({ $0.isActive = true })
        
        requestLabel.font = UIFont(name: "Poppins-MediumItalic", size: 15)
        requestLabel.textAlignment = .left
        requestLabel.textColor = .lightGray
        
        requestLabel.text = "Sent you a friend request"
    }
    
    
    //MARK: - Configure Accept Button
    
    private func configureAcceptButton () {
        
        self.contentView.addSubview(acceptButton)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            acceptButton.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 17),
            acceptButton.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 15),
            acceptButton.widthAnchor.constraint(equalToConstant: ((UIScreen.main.bounds.width - 87) / 2) - 20),
            acceptButton.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        acceptButton.alpha = 0
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
            declineButton.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 15),
            declineButton.widthAnchor.constraint(equalToConstant: ((UIScreen.main.bounds.width - 87) / 2) - 20),
            declineButton.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        declineButton.alpha = 0
        declineButton.backgroundColor = .flatRed()
        
        declineButton.layer.cornerRadius = 17.5
        declineButton.layer.cornerCurve = .continuous
        declineButton.clipsToBounds = true
        
        declineButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        declineButton.tintColor = .white
        declineButton.setTitle("Decline", for: .normal)
        
        declineButton.addTarget(self, action: #selector(declineButtonPressed), for: .touchUpInside)
    }
    
    //MARK: - Set Profile Picture
    
    private func setProfilePicture () {
        
        if let friend = friendRequest {
            
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
    
    
    //MARK: - Animate Buttons
    
    func animateButtons (animate: Bool, hide: Bool) {
        
        UIView.animate(withDuration: animate ? 0.25 : 0, delay: 0, options: .curveEaseInOut) {
            
            self.acceptButton.alpha = hide ? 0 : 1
            self.declineButton.alpha = hide ? 0 : 1
        }
    }
    
    
    //MARK: - Accept Button Pressed
    
    @objc private func acceptButtonPressed () {
        
        if let request = friendRequest {

            friendRequestDelegate?.acceptFriendRequest(request)
        }
    }
    
    
    //MARK: - Decline Button Pressed
    
    @objc private func declineButtonPressed () {
        
        if let request = friendRequest {

            friendRequestDelegate?.declineFriendRequest(request)
        }
    }
}
