//
//  MemberConfigurationCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/9/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class MemberConfigurationCollectionViewCell: UICollectionViewCell {
    
    let cancelButton = UIButton(type: .system)
    var profilePicImageView: ProfilePicture?
    let nameLabel = UILabel()
    
    var member: Any? {
        didSet {
            
            setProfilePicture()
            setNameLabelText()
        }
    }
    
    var showCancelButton: Bool = true
    
    weak var memberConfigurationDelegate: MemberConfigurationProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureCell()
        configureCancelButton()
        configureProfilePicImageView()
        configureNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell () {
        
        self.layer.cornerRadius = 10
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
    }
    
    private func configureCancelButton () {
        
        if showCancelButton {
            
            self.contentView.addSubview(cancelButton)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                cancelButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4),
                cancelButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -4),
                cancelButton.widthAnchor.constraint(equalToConstant: 23),
                cancelButton.heightAnchor.constraint(equalToConstant: 23)
            
            ].forEach({ $0.isActive = true })
            
            cancelButton.tintColor = UIColor(hexString: "222222")
            cancelButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            
            cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        }
    }
    
    private func configureProfilePicImageView () {
        
        profilePicImageView = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic"), shadowRadius: 2, shadowColor: UIColor(hexString: "39434A")!.cgColor, shadowOpacity: 0.35)
        
        self.contentView.addSubview(profilePicImageView!)
        profilePicImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            profilePicImageView?.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: 0),
            profilePicImageView?.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -2),
            profilePicImageView?.widthAnchor.constraint(equalToConstant: 55),
            profilePicImageView?.heightAnchor.constraint(equalToConstant: 55)
        
        ].forEach({ $0?.isActive = true })
    }
    
    private func configureNameLabel () {
        
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -3),
            nameLabel.heightAnchor.constraint(equalToConstant: 17)
        
        ].forEach({ $0.isActive = true })
        
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .black
    }
    
    private func setProfilePicture () {
        
        if let member = member as? Member {
            
            if let profilePicture = member.profilePictureImage {
                
                profilePicImageView?.profilePic = profilePicture
            }
        }
        
        else if let member = member as? Friend {
            
            if let profilePicture = member.profilePictureImage {
                
                profilePicImageView?.profilePic = profilePicture
            }
        }
    }
    
    private func setNameLabelText () {
        
        if let member = member as? Member {
            
            nameLabel.text = member.firstName
        }
        
        else if let member = member as? Friend {
            
            nameLabel.text = member.firstName
        }
    }
    
    @objc private func cancelButtonPressed () {
        
        if let member = member as? Member {
            
            memberConfigurationDelegate?.memberDeleted(member.userID)
        }
        
        else if let member = member as? Friend {
            
            memberConfigurationDelegate?.memberDeleted(member.userID)
        }
    }
}
