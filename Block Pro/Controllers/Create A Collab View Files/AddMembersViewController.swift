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

class AddMembersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var membersCountLabel: UILabel!
    
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var addMembersTableView: UITableView!
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    
    lazy var friends: [Friend] = firebaseCollab.friends
    var filteredFriends: [Friend] = []
    
    var previouslyAddedFriends: [Friend]?
    var newlyAddedFriends: [String : Friend] = [:]
    
    var previouslyAddedMembers: [Member]? {
        didSet {
            
            previouslyAddedMembers?.removeAll(where: { $0.userID == currentUser.userID })
            
            for member in previouslyAddedMembers ?? [] {
                
                friends.removeAll(where: { $0.userID == member.userID })
            }
        }
    }
    
    weak var membersAddedDelegate: MembersAdded?
    
    var headerLabelText: String = ""
    
    var searchBeingConducted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.configureNavBar()
        
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.text = headerLabelText
        
        membersCountLabel.text = "\(previouslyAddedMembers?.count ?? 0)/5"
        
        configureSearchBar()
        
        configureTableView()
        
        //friends = firebaseCollab.friends
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dimissKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        previouslyAddedFriends = nil
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !searchBeingConducted {
            
            return friends.count * 2
        }
        
        else {
            
            return filteredFriends.count * 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            if !searchBeingConducted {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "membersTableViewCell", for: indexPath) as! MembersTableViewCell
                
                cell.memberUserID = friends[indexPath.row / 2].userID
                cell.nameLabel.text = friends[indexPath.row / 2].firstName + " " + friends[indexPath.row / 2].lastName
                cell.profilePicImageView.configureProfileImageView(profileImage: friends[indexPath.row / 2].profilePictureImage)
                
                if let addedMembers = previouslyAddedFriends {
                    
                    for member in addedMembers {
                        
                        if friends[indexPath.row / 2].userID == member.userID {
                            
                            cell.addedIndicator.isHidden = false
                            
                            newlyAddedFriends[member.userID] = member
                            
                            membersCountLabel.text = "\(newlyAddedFriends.count)/5"
                        }
                    }
                }
                
                else {
                    
                    if newlyAddedFriends[friends[indexPath.row / 2].userID] != nil {
                        
                        cell.addedIndicator.isHidden = false
                    }
                    
                    else {
                        
                        cell.addedIndicator.isHidden = true
                    }
                    
                }
                
                return cell
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "membersTableViewCell", for: indexPath) as! MembersTableViewCell
                
                cell.memberUserID = filteredFriends[indexPath.row / 2].userID
                cell.nameLabel.text = filteredFriends[indexPath.row / 2].firstName + " " + filteredFriends[indexPath.row / 2].lastName
                cell.profilePicImageView.configureProfileImageView(profileImage: filteredFriends[indexPath.row / 2].profilePictureImage)
                
                if let addedMembers = previouslyAddedFriends {
                    
                    for member in addedMembers {
                        
                        if filteredFriends[indexPath.row / 2].userID == member.userID {
                            
                            cell.addedIndicator.isHidden = false
                            
                            newlyAddedFriends[member.userID] = member
                            
                            membersCountLabel.text = "\(newlyAddedFriends.count)/5"
                        }
                    }
                }
                
                else {
                    
                    if newlyAddedFriends[filteredFriends[indexPath.row / 2].userID] != nil {
                        
                        cell.addedIndicator.isHidden = false
                    }
                    
                    else {
                        
                        cell.addedIndicator.isHidden = true
                    }
                }
                
                return cell
            }
            
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (newlyAddedFriends.count + (previouslyAddedMembers?.count ?? 0)) < 5 {
            
            cell.addedIndicator.isHidden = !cell.addedIndicator.isHidden
            
            if cell.addedIndicator.isHidden {
                
                newlyAddedFriends.removeValue(forKey: cell.memberUserID)
            }
            
            else {
                
                if !searchBeingConducted {
                    
                    newlyAddedFriends[cell.memberUserID] = friends[indexPath.row / 2]
                }
                
                else {
                    
                    newlyAddedFriends[cell.memberUserID] = filteredFriends[indexPath.row / 2]
                }
            }
        }
        
        else {
            
            if !cell.addedIndicator.isHidden {
                
                cell.addedIndicator.isHidden = true
                
                newlyAddedFriends.removeValue(forKey: cell.memberUserID)
            }
            
            else {
                
                ProgressHUD.showError("Sorry, only 5 members can be added")
            }
        }
        
        if let membersCount = previouslyAddedMembers?.count{
            
            membersCountLabel.text = "\(newlyAddedFriends.count + membersCount)/5"
        }
        
        else {
            
            membersCountLabel.text = "\(newlyAddedFriends.count)/5"
        }
    }
    
    private func configureSearchBar () {
        
        searchBarContainer.backgroundColor = .white
        searchBarContainer.layer.cornerRadius = 18
        searchBarContainer.clipsToBounds = true
        searchBarContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        searchBarContainer.layer.borderWidth = 1
        
        if #available(iOS 13.0, *) {
            searchBarContainer.layer.cornerCurve = .continuous
        }
        
        searchTextField.delegate = self
        searchTextField.borderStyle = .none
    }
    
    private func configureTableView () {
        
        addMembersTableView.dataSource = self
        addMembersTableView.delegate = self
        
        addMembersTableView.separatorStyle = .none
        addMembersTableView.showsVerticalScrollIndicator = false
        
        addMembersTableView.register(UINib(nibName: "MembersTableViewCell", bundle: nil), forCellReuseIdentifier: "membersTableViewCell")
    }
    
    @IBAction func searchTextChanged(_ sender: Any) {
        
        filteredFriends.removeAll()
        
        if searchTextField.text!.leniantValidationOfTextEntered() {
            
            searchBeingConducted = true
            
            for friend in friends {
                
                if friend.firstName.localizedCaseInsensitiveContains(searchTextField.text!) {
                    
                    filteredFriends.append(friend)
                }
                
                else if friend.lastName.localizedCaseInsensitiveContains(searchTextField.text!) {
                    
                    filteredFriends.append(friend)
                }
            }
        }
        
        else {
            
            searchBeingConducted = false
        }
        
        addMembersTableView.reloadData()
    }

    @IBAction func cancelButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
        
        if newlyAddedFriends.count == 0 {
            
            ProgressHUD.showError("Please add at least 1 member")
        }
        
        else {
            
            friends.removeAll()
            
            for member in newlyAddedFriends {
                
                friends.append(member.value)
            }
            
            membersAddedDelegate?.membersAdded(members: friends)
        }
    }
    
    @objc private func dimissKeyboard () {
        
        searchTextField.endEditing(true)
    }
}
