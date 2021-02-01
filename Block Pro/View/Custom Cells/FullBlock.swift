//
//  FullBlock.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/17/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import ChameleonFramework

class FullBlock: UIView {

    let nameLabel = UILabel()
    let timeLabel = UILabel()
    
    var collab: Collab?
    var block: Block? {
        didSet {
            
            configureBlock()
        }
    }
    
    weak var blockSelectedDelegate: BlockSelectedProtocol?
    
    var formatter: DateFormatter?
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(blockTapped))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureBlock () {
        
        self.setCollabBlockColor(block)
        
        nameLabel.text = block?.name
        nameLabel.textColor = .white
        nameLabel.addCharacterSpacing(kernValue: 1.69)
        
        if let formatter = formatter, let starts = block?.starts, let ends = block?.ends {
            
            formatter.dateFormat = "h:mm a"
            
            timeLabel.text = formatter.string(from: starts)
            timeLabel.text! += "  -  "
            timeLabel.text! += formatter.string(from: ends)
        }
        
        timeLabel.textColor = .white
        timeLabel.addCharacterSpacing(kernValue: 1.06)

        layer.cornerCurve = .continuous
        clipsToBounds = true
        
        switch frame.height {
        
        //5 min block
        case 7.5:
            
            layer.cornerRadius = 3
        
        //10 min block
        case 15.0:
            
            layer.cornerRadius = 6
            
            nameLabel.frame = CGRect(x: 15, y: 0, width: frame.width - 20, height: 15)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
            
            addSubview(nameLabel)
        
        //15 min block
        case 22.5:
            
            layer.cornerRadius = 9
            
            nameLabel.frame = CGRect(x: 15, y: 0, width: frame.width - 20, height: 22.5)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
            
            addSubview(nameLabel)
        
        //20 min block
        case 30:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 15, y: 0, width: frame.width - 20, height: 30)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)

            addSubview(nameLabel)
           
        //25 min block
        case 37.5:
            
            layer.cornerRadius = 12
            
            nameLabel.frame = CGRect(x: 15, y: 0, width: frame.width - 20, height: 37.5)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)

            addSubview(nameLabel)
         
        //30 min block
        case 45:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 15, y: 0, width: frame.width - 20, height: 45)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)

            addSubview(nameLabel)
        
        //35 min block
        case 52.5:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 15, y: 0, width: frame.width - 20, height: 52.5)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
            
            addSubview(nameLabel)
            
        //40 min block
        case 60:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 15, y: 7, width: frame.width - 20, height: 25)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
            
            addSubview(nameLabel)
            
            timeLabel.frame = CGRect(x: 16.5, y: 30, width: 185, height: 25)
            timeLabel.font = UIFont(name: "Poppins-Medium", size: 12)

            addSubview(timeLabel)

        //45 min block
        case 67.5:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 15, y: 7, width: frame.width - 20, height: 28.75)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
            
            addSubview(nameLabel)
            
            timeLabel.frame = CGRect(x: 16.5, y: 33.75, width: 185, height: 28.75)
            timeLabel.font = UIFont(name: "Poppins-Medium", size: 13)

            addSubview(timeLabel)
        
        //50 min block
        case 75:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 15, y: 5, width: frame.width - 20, height: 35)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
            
            addSubview(nameLabel)
            
            timeLabel.frame = CGRect(x: 16.5, y: 37.5, width: 185, height: 25)
            timeLabel.font = UIFont(name: "Poppins-Medium", size: 13)

            addSubview(timeLabel)
         
        //55 min block
        case 82.5:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 15, y: 5, width: frame.width - 20, height: 35)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
            
            addSubview(nameLabel)
            
            timeLabel.frame = CGRect(x: 16.5, y: 40, width: 185, height: 25)
            timeLabel.font = UIFont(name: "Poppins-Medium", size: 13)

            addSubview(timeLabel)
          
        //1 hour to 1 hour and 25 min block
        case 90 ... 127.5:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 15, y: 5, width: frame.width - 20, height: 35)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 19)
            
            addSubview(nameLabel)
            
            timeLabel.frame = CGRect(x: 16.5, y: 40, width: 185, height: 25)
            timeLabel.font = UIFont(name: "Poppins-Medium", size: 14)

            addSubview(timeLabel)
        
            
        //1.5 hour block; 135
        default:
            
            layer.cornerRadius = 11
            
            nameLabel.frame = CGRect(x: 15, y: 5, width: frame.width - 20, height: 35)
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 19)
            
            addSubview(nameLabel)
            
            timeLabel.frame = CGRect(x: 16.5, y: 40, width: 185, height: 25)
            timeLabel.font = UIFont(name: "Poppins-Medium", size: 14)

            addSubview(timeLabel)
            
            configureMemberStackView()
        }
    }
    
    private func configureMemberStackView () {
        
        if var members = block?.members {
            
            let currentUser = CurrentUser.sharedInstance
            let firebaseCollab = FirebaseCollab.sharedInstance
            let firebaseStorage = FirebaseStorage()
            
            members = members.sorted(by: { $0.firstName < $1.firstName })
            
            let stackViewWidth = (members.count * 38) - ((members.count - 1) * 19)
            
            let memberStackView = UIStackView(frame: CGRect(x: self.frame.width - CGFloat(stackViewWidth + 12), y: self.frame.height - 50, width: CGFloat(stackViewWidth), height: 38))
            memberStackView.alignment = .center
            memberStackView.distribution = .fillProportionally
            memberStackView.axis = .horizontal
            memberStackView.spacing = -19 //Half the size of the profilePicOutline
            
            var memberCount: Int = 0
            
            for member in members {
                
                let profilePicOutline = UIView()
                profilePicOutline.layer.cornerRadius = 0.5 * 38
                profilePicOutline.clipsToBounds = true
                
                if memberCount == 0 {
                    
                    profilePicOutline.backgroundColor = .clear
                }

                else {
                    
                    switch block?.status {
            
                        case .completed:
            
                            profilePicOutline.backgroundColor = UIColor(hexString: "7BD293")
            
                        case .inProgress:
            
                            profilePicOutline.backgroundColor = UIColor(hexString: "7E8CB4")
            
                        case .needsHelp:
            
                            profilePicOutline.backgroundColor = UIColor(hexString: "FAD95F")
            
                        case .late:
            
                            profilePicOutline.backgroundColor = UIColor(hexString: "E07F72")
            
                        default:
            
                            profilePicOutline.backgroundColor = UIColor(hexString: "BFBFBF")
                    }
                }
                
                var profilePic: ProfilePicture
                    
                //If this is the first profile picture
                if memberCount == 0 {
                    
                    profilePic = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic"), shadowColor: UIColor.clear.cgColor, borderColor: UIColor.clear.cgColor, borderWidth: 0)
                }
                
                else {
                    
                    profilePic = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic"), shadowRadius: 0, shadowColor: UIColor.clear.cgColor, shadowOpacity: 0, borderColor: UIColor.clear.cgColor, borderWidth: 0)
                }
                
                profilePicOutline.addSubview(profilePic)
                memberStackView.addArrangedSubview(profilePicOutline)
                
                profilePicOutline.translatesAutoresizingMaskIntoConstraints = false
                profilePic.translatesAutoresizingMaskIntoConstraints = false
                
                [
                    // 19 is half the size of the profilePicOutline
                    profilePicOutline.topAnchor.constraint(equalTo: profilePicOutline.superview!.topAnchor, constant: 0),
                    profilePicOutline.leadingAnchor.constraint(equalTo: profilePicOutline.superview!.leadingAnchor, constant: CGFloat(memberCount * 19)),
                    profilePicOutline.widthAnchor.constraint(equalToConstant: 38),
                    profilePicOutline.heightAnchor.constraint(equalToConstant: 38),
                    
                    profilePic.centerXAnchor.constraint(equalTo: profilePic.superview!.centerXAnchor),
                    profilePic.centerYAnchor.constraint(equalTo: profilePic.superview!.centerYAnchor),
                    profilePic.widthAnchor.constraint(equalToConstant: 34),
                    profilePic.heightAnchor.constraint(equalToConstant: 34)
                
                ].forEach({ $0.isActive = true })
                
                //Setting the profile picture image
                if member.userID == currentUser.userID {
                    
                    profilePic.profilePic = currentUser.profilePictureImage
                }
                
                else if let friend = firebaseCollab.friends.first(where: { $0.userID == member.userID }) {
                    
                    profilePic.profilePic = friend.profilePictureImage
                }

                else if let memberProfilePic = firebaseCollab.membersProfilePics[member.userID] {
                    
                    profilePic.profilePic = memberProfilePic
                }

                else {

                    firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { (retrievedProfilePic, userID) in
                        
                        profilePic.profilePic = retrievedProfilePic

                        firebaseCollab.cacheMemberProfilePics(userID: member.userID, profilePic: retrievedProfilePic)
                    }
                }
                
                memberCount += 1
            }
            
            self.addSubview(memberStackView)
        }
    }
    
    @objc private func blockTapped () {
        
        if let block = block {
            
            blockSelectedDelegate?.blockSelected(block)
        }
    }
}
