//
//  CollabCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/8/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol CellSelected: AnyObject {
    
    func cellSelected ()
}

class CollabCell: UICollectionViewCell, UITextFieldDelegate {

    @IBOutlet weak var cellBackground: UIView!
    
    @IBOutlet weak var collabName: UILabel!
    
    @IBOutlet weak var deadlineLabel: UILabel!
    
    @IBOutlet weak var reminder: UIImageView!
    
    @IBOutlet weak var addMember: UIImageView!
    
    @IBOutlet weak var imageContainer1: UIView!
    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageContainer2: UIView!
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBOutlet weak var imageContainer3: UIView!
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var imageContainer4: UIView!
    @IBOutlet weak var extraMembersLabel: UILabel!
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var messageContainer: UIView!
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var textFieldContainer: UIView!
    
    @IBOutlet weak var send: UIImageView!
    
    @IBOutlet weak var trackBar: UIView!
    
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var progressBarTrailingAnchor: NSLayoutConstraint!
    
    var firebaseCollab = FirebaseCollab.sharedInstance
    var collab: Collab? {
        didSet {
            
            configureCell()
        }
    }
    
    var reminderSelected: Bool = false
    var addMemberSelected: Bool = false
    var seeAdditionalMembersSelected: Bool = false
    var sendSelected = false
    var cellSelected: Bool = false
    
    weak var cellSelectedDelegate: CellSelected?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //configureCell()
    }
    
    private func configureCell () {
        
        cellBackground.backgroundColor = .white
        
        cellBackground.layer.shadowRadius = 2
        cellBackground.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        cellBackground.layer.shadowOffset = CGSize(width: 0, height: 0)
        cellBackground.layer.shadowOpacity = 0.35
        
        cellBackground.layer.borderWidth = 1
        cellBackground.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        cellBackground.layer.cornerRadius = 20
        cellBackground.layer.masksToBounds = false
        
        collabName.text = collab?.name
        
        setDeadlineText(deadline: (collab?.dates["deadline"])!)
        
        configureProfilePics()
        
        //rotateButtons()
        
        textFieldContainer.backgroundColor = .clear
        textFieldContainer.layer.borderWidth = 1
        textFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        textFieldContainer.layer.cornerRadius = 17.5
        textFieldContainer.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            textFieldContainer.layer.cornerCurve = .continuous
        }
        
        messageTextField.delegate = self
        
        messageTextField.borderStyle = .none
        
        configureProgressBars()
    }
    
    private func setDeadlineText (deadline: Date) {
        
        let formatter = DateFormatter()
        
        let semiBoldText = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 14)]
        let standardText = [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 12)]
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        
        var deadlineText: NSAttributedString!
        
        deadlineText = NSAttributedString(string: "Next Deadline: ", attributes: semiBoldText as [NSAttributedString.Key : Any])
        attributedString.append(deadlineText)
        
        formatter.dateFormat = "MMMM d"
        deadlineText = NSAttributedString(string: formatter.string(from: deadline), attributes: standardText as [NSAttributedString.Key : Any])
        attributedString.append(deadlineText)
        
        let daySuffix = deadline.daySuffix()
        deadlineText = NSAttributedString(string: daySuffix, attributes: standardText as [NSAttributedString.Key : Any])
        attributedString.append(deadlineText)
        
        formatter.dateFormat = "h:mm a"
        deadlineText = NSAttributedString(string: ", \(formatter.string(from: deadline))", attributes: standardText as [NSAttributedString.Key : Any])
        attributedString.append(deadlineText)
        
        deadlineLabel.attributedText = attributedString
    }

    private func rotateButtons () {
        
        //UIBezierPath(arcCenter: testView.center, radius: 100, startAngle:  (-CGFloat.pi * 3) / 4, endAngle: -CGFloat.pi / 4, clockwise: false)
        
        //reminderButton.transform = CGAffineTransform(rotationAngle: 2 * CGFloat.pi / 3)
    }
    
    private func configureProfilePics () {
        
        var profilePics: [UIImage?] = []
        
        if let collabMembers = collab?.members, collabMembers.count > 0 {
            
            for member in collabMembers {
                
                for friend in firebaseCollab.friends {
                    
                    if member.userID == friend.userID {
                        
                        //profilePics.insert(friend.profilePictureImage, at: profilePics.count)
                        profilePics.append(friend.profilePictureImage)
                        break
                    }
                }
                
                if profilePics.last == nil {
                    
                    //profilePics.insert(UIImage(named: "DefaultProfilePic"), at: profilePics.count)
                    profilePics.append(UIImage(named: "DefaultProfilePic"))
                }
            }
        }
        
        else {
            
            imageContainer1.isHidden = true
            imageContainer2.isHidden = true
            imageContainer3.isHidden = true
            imageContainer4.isHidden = true
            
            return
        }
        
        var count: Int = 0
        
        while count < 6 {
            
            if count == 0 {
                
                imageContainer1.alpha = 1
                imageContainer1.configureProfilePicContainer()
                imageView1.configureProfileImageView(profileImage: profilePics[count])
            }
            
            else if count == 1 {
                
                if count < profilePics.count {
                    
                    imageContainer2.alpha = 1
                    imageContainer2.configureProfilePicContainer()
                    imageView2.configureProfileImageView(profileImage: profilePics[count])
                }
                
                else {
                    
                    imageContainer2.alpha = 0
                }
            }
            
            else if count == 2 {
                
                if count < profilePics.count {
                    
                    imageContainer3.alpha = 1
                    imageContainer3.configureProfilePicContainer()
                    imageView3.configureProfileImageView(profileImage: profilePics[count])
                }
                
                else {
                    
                    imageContainer3.alpha = 0
                }
            }
            
            else if count == 3 {
                
                if count < profilePics.count {
                    
                    if profilePics.count == 4 {
                        
                        imageContainer4.alpha = 1
                        imageContainer4.configureProfilePicContainer()
                        imageView4.configureProfileImageView(profileImage: profilePics[count])
                    }
                    
                    else if profilePics.count == 5 {
                        
                        imageContainer4.alpha = 1
                        imageContainer4.configureProfilePicContainer(clip: true)
                        imageContainer4.backgroundColor = .black
                        extraMembersLabel.text = "+2"
                        extraMembersLabel.textColor = .white
                        
                        break
                    }
                }
                
                else {
                    
                    imageContainer4.alpha = 0
                }
            }
            
            count += 1
        }
        
//        if let collab = collab {
//
//            if collab.members.count > 0 {
//
//                var count: Int = 0
//
//                while count <= 5 {
//
//                    if count == 0 && count < collab.members.count {
//
//                        imageContainer1.configureProfilePicContainer()
//
//                        for friend in firebaseCollab.friends {
//
//                            if friend.userID == collab.members[count].userID {
//
//                                imageView1.configureProfileImageView(profileImage: friend.profilePictureImage)
//                            }
//
//                            else {
//
//                            }
//                        }
//                    }
//
//
//                    if count == 1 && count < collab.members.count {
//
//                        imageContainer2.configureProfilePicContainer()
//
//                        for friend in firebaseCollab.friends {
//
//                            if friend.userID == collab.members[count].userID {
//
//                                imageView2.configureProfileImageView(profileImage: friend.profilePictureImage)
//                            }
//
//                            else {
//
//
//                            }
//                        }
//                    }
//
//                    count += 1
//                }
//            }
//        }
        
        
        
        
//        imageContainer1.configureProfilePicContainer()
//        imageView1.configureProfileImageView(profileImage: UIImage(named: "ProfilePic-1")!)
        
//        imageContainer2.configureProfilePicContainer()
//        imageView2.configureProfileImageView(profileImage: UIImage(named: "ProfilePic-2")!)
        
//        imageContainer3.configureProfilePicContainer()
//        imageView3.configureProfileImageView(profileImage: UIImage(named: "ProfilePic-3")!)
//
//        imageContainer4.configureProfilePicContainer(clip: true)
//        extraMembersLabel.text = "+3"
//        extraMembersLabel.textColor = .white
//        extraMembersLabel.backgroundColor = .black
        //imageView4.configureImageView(profileImage: UIImage(named: "ProfilePic-4")!)
        //extraMembersLabel.isHidden = true
    }
    
    private func configureProgressBars () {
        
        trackBar.layer.cornerRadius = 3
        trackBar.clipsToBounds = true
        
        progressBar.layer.cornerRadius = 2.5
        progressBar.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            
            trackBar.layer.cornerCurve = .continuous
            progressBar.layer.cornerCurve = .continuous
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        guard let point = touch?.location(in: cellBackground) else { return }
        
            if reminder.frame.contains(point) {
                
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.reminder.alpha = 0.3
                    
                })
                
                reminderSelected = true
            }
        
            else if addMember.frame.contains(point) {
            
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.addMember.alpha = 0.3
                    
                })
                
                addMemberSelected = true
            }
            
            else if send.frame.contains(point) {
                
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.send.alpha = 0.3
                    
                })
                
                sendSelected = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        guard let point = touch?.location(in: cellBackground) else { return }
        
        if reminderSelected {
            
            let safeArea = CGRect(x: reminder.frame.origin.x - 10, y: reminder.frame.origin.y - 10, width: reminder.frame.width + 5, height: reminder.frame.height + 5)
            
            if !safeArea.contains(point) {
                
                UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
                    
                    self.reminder.alpha = 1
                })
                
                reminderSelected = false
            }
        }
        
        else if addMemberSelected {
            
            let safeArea = CGRect(x: addMember.frame.origin.x - 10, y: addMember.frame.origin.y - 10, width: addMember.frame.width + 5, height: addMember.frame.height + 5)
            
            if !safeArea.contains(point) {
                
                UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
                    
                    self.addMember.alpha = 1
                })
                
                addMemberSelected = false
            }
        }
        
        else if sendSelected {
            
            let safeArea = CGRect(x: send.frame.origin.x - 10, y: send.frame.origin.y - 10, width: send.frame.width + 5, height: send.frame.height + 5)
            
            if !safeArea.contains(point) {
                
                
                UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
                    
                    self.send.alpha = 1
                })
                
                sendSelected = false
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if reminderSelected {
            
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
                
                self.reminder.alpha = 1
                
            })
            
            reminderSelected = false
        }
        
        else if addMemberSelected {
            
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
                
                self.addMember.alpha = 1
                
            })
            
            addMemberSelected = false
        }
        
        else if sendSelected {
            
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
                
                self.send.alpha = 1
                
            })
            
            sendSelected = false
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if reminderSelected {
            
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
                
                self.reminder.alpha = 1
                
            }) { (finished: Bool) in
                
            }
            
            reminderSelected = false
        }
        
        else if addMemberSelected {
            
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
                
                self.addMember.alpha = 1
                
            }) { (finished: Bool) in
                
            }
            
            addMemberSelected = false
        }
        
        else if sendSelected {
            
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
                
                self.send.alpha = 1
                
            }) { (finished: Bool) in
                
            }
            
            sendSelected = false
        }
            
        else {
            
            cellSelectedDelegate?.cellSelected()
         }
    }
}

extension UIView {
    
//    func configureProfilePicContainer (clip: Bool = false) {
//
//        layer.shadowRadius = 2.5
//        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 0)
//        layer.shadowOpacity = 0.75
//
//        layer.borderWidth = 1
//        layer.borderColor = UIColor(hexString: "F4F4F4", withAlpha: 0.05)?.cgColor
//
//        layer.cornerRadius = 0.5 * self.bounds.width
//        layer.masksToBounds = false
//        clipsToBounds = clip
//    }
}

extension UIImageView {
    
//    func configureProfileImageView (profileImage: UIImage) {
//
//        image = profileImage
//
//        layer.cornerRadius = 0.5 * self.bounds.width
//        layer.masksToBounds = false
//        clipsToBounds = true
//    }
}
