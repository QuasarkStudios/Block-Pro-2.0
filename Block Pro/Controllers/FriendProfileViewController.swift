//
//  FriendProfileViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/9/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class FriendProfileViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    
    var friend: Friend? {
        didSet {
            
            navBar.topItem?.title = friend?.firstName
        }
    }
    
    var member: Member?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.configureNavBar()
        
        configureView()
    }
    
    private func configureView () {
        
        navBar.topItem?.title = member?.firstName
        
        profileImageView.layer.cornerRadius = 0.5 * profileImageView.bounds.width
        profileImageView.clipsToBounds = true
        
        if let friendIndex = firebaseCollab.friends.firstIndex(where: { $0.userID == member?.userID }) {
            
            profileImageView.image = firebaseCollab.friends[friendIndex].profilePictureImage
        }
        
        else if let memberProfilePic = firebaseCollab.membersProfilePics[member?.userID ?? ""] {
                
            profileImageView.image = memberProfilePic
        }
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}
