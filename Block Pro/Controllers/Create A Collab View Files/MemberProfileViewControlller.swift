//
//  FriendProfileViewControlller.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol RemoveMemberFromCollab: AnyObject {
    
    func removeMember (member: Friend)
}

class MemberProfileViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var profilePicContainer: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendUsernameLabel: UILabel!
    
    var selectedFriend: Friend?
    
    weak var removeMemberDelegate: RemoveMemberFromCollab?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.configureNavBar()
        configureView()
    }
    
    private func configureView () {
        
        profilePicContainer.configureProfilePicContainer()
        
        if let friend = selectedFriend {
            
            friendNameLabel.text = friend.firstName + " " + friend.lastName
            friendUsernameLabel.text = friend.username
            
            profilePicImageView.configureProfileImageView(profileImage: friend.profilePictureImage)
        }
        
        else {
            
            dismiss(animated: true) {
                
                ProgressHUD.showError("Sorry, an error occured while loading your Friend's profile")
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeFromCollabButton(_ sender: Any) {
        
        if let friend = selectedFriend {
            
            removeMemberDelegate?.removeMember(member: friend)
        }
        
        dismiss(animated: true, completion: nil)
    }

}
