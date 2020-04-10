//
//  CollabCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/8/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

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
    
    var reminderSelected: Bool = false
    var addMemberSelected: Bool = false
    var seeAdditionalMembersSelected: Bool = false
    var sendSelected = false
    var cellSelected: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCell()
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
        
        setDeadlineText()
        
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
    
    private func setDeadlineText () {
        
        let semiBoldText = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 14)]
        let standardText = [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 12)]
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        
        var deadlineText: NSAttributedString!
        
        deadlineText = NSAttributedString(string: "Next Deadline: ", attributes: semiBoldText)
        attributedString.append(deadlineText)
        
        deadlineText = NSAttributedString(string: "April 4th, 7:00 PM", attributes: standardText)
        attributedString.append(deadlineText)
        
        deadlineLabel.attributedText = attributedString
    }

    private func rotateButtons () {
        
        //UIBezierPath(arcCenter: testView.center, radius: 100, startAngle:  (-CGFloat.pi * 3) / 4, endAngle: -CGFloat.pi / 4, clockwise: false)
        
        //reminderButton.transform = CGAffineTransform(rotationAngle: 2 * CGFloat.pi / 3)
    }
    
    private func configureProfilePics () {
        
        imageContainer1.configureProfilePicContainer()
        imageView1.configureImageView(profileImage: UIImage(named: "ProfilePic-1")!)
        
        imageContainer2.configureProfilePicContainer()
        imageView2.configureImageView(profileImage: UIImage(named: "ProfilePic-2")!)
        
        imageContainer3.configureProfilePicContainer()
        imageView3.configureImageView(profileImage: UIImage(named: "ProfilePic-3")!)
        
        imageContainer4.configureProfilePicContainer(clip: true)
        extraMembersLabel.text = "+3"
        extraMembersLabel.textColor = .white
        extraMembersLabel.backgroundColor = .black
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
    }
}

extension UIView {
    
    func configureProfilePicContainer (clip: Bool = false) {
        
        layer.shadowRadius = 2.5
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.75
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(hexString: "F4F4F4", withAlpha: 0.05)?.cgColor
        
        layer.cornerRadius = 0.5 * self.bounds.width
        layer.masksToBounds = false
        clipsToBounds = clip
    }
}

extension UIImageView {
    
    func configureImageView (profileImage: UIImage) {
        
        image = profileImage
        
        layer.cornerRadius = 0.5 * self.bounds.width
        layer.masksToBounds = false
        clipsToBounds = true
    }
}
