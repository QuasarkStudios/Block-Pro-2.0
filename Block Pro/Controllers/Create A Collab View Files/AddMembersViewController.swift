//
//  AddMembersViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/12/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol MembersAdded: AnyObject {
    
    func membersAdded (members: [Friend])
}

class AddMembersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var membersCountLabel: UILabel!
    
    @IBOutlet weak var addMembersTableView: UITableView!
    
    var friends: [Friend] = []
    
    var previouslyAddedMembers: [Friend]?
    
    var newlyAddedMembers: [Int : Friend] = [:]
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    
    weak var membersAddedDelegate: MembersAdded?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        
        configureTableView()
        
        friends = firebaseCollab.friends
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        previouslyAddedMembers = nil
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friends.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "membersTableViewCell", for: indexPath) as! MembersTableViewCell
            
            cell.nameLabel.text = friends[indexPath.row / 2].firstName + " " + friends[indexPath.row / 2].lastName
            cell.profilePicImageView.configureProfileImageView(profileImage: friends[indexPath.row / 2].profilePictureImage)
            
            if let addedMembers = previouslyAddedMembers {
                
                for member in addedMembers {
                    
                    if friends[indexPath.row / 2].friendID == member.friendID {
                        
                        cell.addedIndicator.isHidden = false
                        
                        newlyAddedMembers[indexPath.row / 2] = member
                        
                        membersCountLabel.text = "\(newlyAddedMembers.count)/5"
                    }
                }
            }
            
            return cell
        }
        
        else {
            
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            return 70
        }
        
        else {
            
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! MembersTableViewCell
        cell.isSelected = false
        
        if newlyAddedMembers.count < 5 {
            
            cell.addedIndicator.isHidden = !cell.addedIndicator.isHidden
            
            if cell.addedIndicator.isHidden {
                
                newlyAddedMembers.removeValue(forKey: indexPath.row / 2)
            }
            
            else {
                
                newlyAddedMembers[indexPath.row / 2] = friends[indexPath.row / 2]
            }
        }
        
        else {
            
            if !cell.addedIndicator.isHidden {
                
                newlyAddedMembers.removeValue(forKey: indexPath.row / 2)
                
                cell.addedIndicator.isHidden = true
            }
            
            else {
                
                ProgressHUD.showError("Sorry, only 5 members can be added")
            }
        }
        
        membersCountLabel.text = "\(newlyAddedMembers.count)/5"
    }
    
    private func configureNavBar () {
        
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = .clear
        
        navBar.tintColor = .black
    }
    
    private func configureTableView () {
        
        addMembersTableView.dataSource = self
        addMembersTableView.delegate = self
        
        addMembersTableView.separatorStyle = .none
        addMembersTableView.showsVerticalScrollIndicator = false
        
        addMembersTableView.register(UINib(nibName: "MembersTableViewCell", bundle: nil), forCellReuseIdentifier: "membersTableViewCell")
        
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
        
        if newlyAddedMembers.count == 0 {
            
            ProgressHUD.showError("Please add at least 1 member")
        }
        
        else {
            
            friends.removeAll()
            
            for member in newlyAddedMembers {
                
                friends.append(member.value)
            }
            
            membersAddedDelegate?.membersAdded(members: friends)
            
            dismiss(animated: true, completion: nil)
        }
    }
}
