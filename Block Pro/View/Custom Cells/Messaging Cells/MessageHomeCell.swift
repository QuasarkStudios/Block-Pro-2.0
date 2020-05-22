//
//  MessageHomeCell2.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/19/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class MessageHomeCell: UITableViewCell {

    @IBOutlet weak var profilePicContainer: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var messagesTitleLabel: UILabel!
    
    @IBOutlet weak var messagePreviewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var messagePreview: UILabel!
    
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    @IBOutlet weak var unreadMessageIndicator: UIView!
    
    var convoMembers: [Member] = []
    var profilePicContainers: [UIView] = []
    
    var count: Int? {
        didSet {
            
            configureProfilePics()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        configureCell()


        //configureProfilePics()



    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutSubviews()
        
        //configureMessagePreview()
    }

    private func configureCell () {
        
        //profilePicContainer.configureProfilePicContainer()
        //profilePicImageView.configureProfileImageView(profileImage: UIImage(named: "ProfilePic-2"))
        
        lastMessageDateLabel.text = "7:28 PM"
        unreadMessageIndicator.layer.cornerRadius = 0.5 * unreadMessageIndicator.bounds.size.width
        unreadMessageIndicator.clipsToBounds = true
    }
    
    
    
    func configureProfilePics () {
        
        for container in profilePicContainers {
            
            container.removeFromSuperview()
        }
        
        if /*convoMembers.*/count == 0 {
            
            let profilePic = ProfilePicture.init(profilePic: UIImage(named: "ProfilePic-2")!)
            self.addSubview(profilePic)
            configureProfilePicContainerConstraints(profilePic, top: 25, leading: 17, width: 50, height: 50)
            
            profilePicContainers.append(profilePic)
            
            
        }
        
        else if /*convoMembers.*/count == 1 {
            
            let profilePic1 = ProfilePicture.init(profilePic: UIImage(named: "ProfilePic-1")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic1)
            configureProfilePicContainerConstraints(profilePic1, top: 25, leading: 15, width: 35, height: 35)
            
            let profilePic2 = ProfilePicture.init(profilePic: UIImage(named: "ProfilePic-2")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic2)
            configureProfilePicContainerConstraints(profilePic2, top: 35, leading: 34, width: 35, height: 35)
            
        }
        
        else if count == 2 {

            let profilePic1 = ProfilePicture.init(profilePic: UIImage(named: "ProfilePic-1")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic1)
            configureProfilePicContainerConstraints(profilePic1, top: 15, leading: 24.5, width: 35, height: 35)
            
            let profilePic2 = ProfilePicture.init(profilePic: UIImage(named: "ProfilePic-2")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic2)
            configureProfilePicContainerConstraints(profilePic2, top: 40, leading: 9, width: 35, height: 35)
            
            let profilePic3 = ProfilePicture.init(profilePic: UIImage(named: "ProfilePic-3")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic3)
            configureProfilePicContainerConstraints(profilePic3, top: 40, leading: 38, width: 35, height: 35)
        }
        
        else if count ?? 0 >= 3 {
            
            let profilePic1 = ProfilePicture.init(profilePic: UIImage(named: "ProfilePic-1")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic1)
            configureProfilePicContainerConstraints(profilePic1, top: 15, leading: 24.5, width: 35, height: 35)
            
            let profilePic2 = ProfilePicture.init(profilePic: UIImage(named: "ProfilePic-2")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic2)
            configureProfilePicContainerConstraints(profilePic2, top: 40, leading: 9, width: 35, height: 35)
            
            let profilePic3 = ProfilePicture.init(borderColor: UIColor.white.withAlphaComponent(0.75).cgColor, extraMembers: 2)
            self.addSubview(profilePic3)
            configureProfilePicContainerConstraints(profilePic3, top: 40, leading: 38, width: 35, height: 35)
        }
    }
    
    func configureProfilePicContainerConstraints (_ container: UIView, top: CGFloat, leading: CGFloat, width: CGFloat, height: CGFloat) {
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        [

            container.topAnchor.constraint(equalTo: self.topAnchor, constant: top),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading),
            container.widthAnchor.constraint(equalToConstant: width),
            container.heightAnchor.constraint(equalToConstant: height)
            
        ].forEach( { $0.isActive = true } )
    }
    
    private func configureMessagePreview () {

        if messagePreview.frame.height > 20 {

            messagePreviewTopAnchor.constant = 5//2.5
        }

        else {

            messagePreviewTopAnchor.constant = 9
        }
    }
    
}
