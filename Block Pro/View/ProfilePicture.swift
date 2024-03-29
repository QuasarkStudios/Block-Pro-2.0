//
//  ProfilePicture.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/19/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ProfilePicture: UIView {
    
    let profilePicImageView = UIImageView()
    var profilePic: UIImage? {
        didSet {
            
            profilePicImageView.configureProfileImageView(profileImage: profilePic)
        }
    }
    
    var shadowRadius: CGFloat
    var shadowColor: CGColor
    var shadowOffset = CGSize(width: 0, height: 0)
    var shadowOpacity: Float

    var borderColor: CGColor
    var borderWidth: CGFloat
    
    var extraMembers: Int
    
    var intiallyConfiguredConstraints: Bool = false
    
    init(profilePic: UIImage? = nil, shadowRadius: CGFloat = 2.5, shadowColor: CGColor = UIColor(hexString: "39434A")!.cgColor, shadowOpacity: Float = 0.75, borderColor: CGColor = UIColor(hexString: "F4F4F4", withAlpha: 0.05)!.cgColor, borderWidth: CGFloat = 1, extraMembers: Int = 0) {
        
        self.profilePic = profilePic
        
        self.shadowRadius = shadowRadius
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
        
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        
        self.extraMembers = extraMembers
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if !intiallyConfiguredConstraints {
            
            self.configureProfilePicContainer2()

            intiallyConfiguredConstraints = true
        }
        
        super.updateConstraints()
    }
    
    private func configureProfilePicImageView () {
        
        self.addSubview(profilePicImageView)
        
        profilePicImageView.translatesAutoresizingMaskIntoConstraints = false
        
        [

            profilePicImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            profilePicImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            profilePicImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            profilePicImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)

        ].forEach( { $0.isActive = true } )
        
        profilePicImageView.configureProfileImageView(profileImage: profilePic)
    }
    
    private func configureExtraMembersLabel () {
        
        let extraMembersLabel = UILabel()
        extraMembersLabel.backgroundColor = .black
        extraMembersLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        extraMembersLabel.textColor = .white
        extraMembersLabel.textAlignment = .center
        extraMembersLabel.text = "+\(extraMembers)"
        
        self.addSubview(extraMembersLabel)
        
        extraMembersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [

            extraMembersLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            extraMembersLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            extraMembersLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            extraMembersLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)

        ].forEach( { $0.isActive = true } )
        
        extraMembersLabel.superview?.constraints.forEach({ (constraint) in
            
            if constraint.firstAttribute == .width {
                
                extraMembersLabel.layer.cornerRadius = 0.5 * constraint.constant
                extraMembersLabel.clipsToBounds = true
            }
        })
    }
}

extension ProfilePicture {
    
    func configureProfilePicContainer2 () {
        
        layer.shadowRadius = shadowRadius
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor
        
        self.constraints.forEach({ (constraint) in
            
            if constraint.firstAttribute == .width {
                
                layer.cornerRadius = 0.5 * constraint.constant
            }
        })
        
        layer.masksToBounds = false
        clipsToBounds = false
        
        if profilePic != nil {
            
            configureProfilePicImageView()
        }
        
        else if profilePic == nil && extraMembers == 0 {
            
            configureProfilePicImageView()
        }
        
        else {
            
            configureExtraMembersLabel()
        }
    }
}

extension UIImageView {
    
    func configureProfileImageView (profileImage: UIImage?) {
        
        contentMode = .scaleAspectFill
        
        image = profileImage ?? UIImage(named: "DefaultProfilePic")
        
        self.superview?.constraints.forEach({ (constraint) in
            
            if constraint.firstAttribute == .width {
                
                layer.cornerRadius = 0.5 * constraint.constant
            }
        })
        
        layer.masksToBounds = false
        clipsToBounds = true
    }
}

