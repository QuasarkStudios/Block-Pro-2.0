//
//  UserViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/3/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

class UserSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var settingsTableView: UITableView!
    
    lazy var db =  Firestore.firestore()
    var signedInUser: User?
    let defaults = UserDefaults.standard
    
    let currentUser = UserData.singletonUser
       
    let sectionHeaderArray = [nil, "Free Time", "Pomodoro", "Time Block", "Collab", "Privacy"]
    var selectedInfo: String = ""
    var friends: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {

        //Call to function that checks if the user is logged in, then checks to see how many friends they have
        getUserData {
            
            self.friends.removeAll()
            
            self.db.collection("Users").document(self.signedInUser!.uid).collection("Friends").getDocuments { (snapshot, error) in
                
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
                else {
                    
                    if snapshot!.isEmpty {
                        print("you aint got no friends")
                    }
                    
                    else {
                        
                        for document in snapshot!.documents {
                            
                            var friendID: String = ""
                            friendID = document.data()["friendID"] as! String
                            
                            self.friends.append(friendID)
                        }
                    }
                }
                
                self.settingsTableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //If a user is signed in and the currentUser singleton has been populated with that users info
        if signedInUser != nil && currentUser.userID != "" {
            return 6
        }
            
        //If a user hasn't signed in yet
        else {
            return 5
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //If a user is signed in and the currentUser singleton has been populated with that users info
        if signedInUser != nil  && currentUser.userID != "" {
            
            return sectionHeaderArray[section]
        }
        
        //If a user hasn't signed in yet
        else {
            
            return sectionHeaderArray[section + 1]
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //If a user is signed in and the currentUser singleton has been populated with that users info
        if signedInUser != nil  && currentUser.userID != "" {
            
            //Profile, Time Block, and Privacy sections
            if section == 0 || section == 3 || section == 5 {
                return 1
            }
                
            //Collab section
            else if section == 4 {
                return 4
            }
                
            //Free Time and Pomodoro sections
            else {
                return 2
            }
        }
         
        //If a user hasn't signed in yet
        else {
            
            //Free Time and Pomodoro sections
            if section < 2 {
                return 2
            }
            
            //Time Block, Collab, and Privacy
            else {
                return 1
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //If a user is signed in and the currentUser singleton has been populated with that users info
        if signedInUser != nil  && currentUser.userID != "" {
            
            //If the profile cell should be used
            if indexPath.section == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
                cell.selectionStyle = .none
                
                cell.initialContainer.layer.cornerRadius = 0.5 * cell.initialContainer.bounds.size.width
                cell.initialContainer.clipsToBounds = true
                
                let firstNameArray = Array(currentUser.firstName)
                
                cell.initialLabel.text = "\(firstNameArray[0].uppercased())"
                cell.initialLabel.layer.cornerRadius = 0.5 * cell.initialLabel.bounds.size.width
                cell.initialLabel.clipsToBounds = true
                
                cell.nameLabel.adjustsFontSizeToFitWidth = true
                cell.nameLabel.text = currentUser.firstName + " " + currentUser.lastName
                cell.nameLabel.layer.cornerRadius = 0.1 * cell.nameLabel.bounds.size.width
                cell.nameLabel.clipsToBounds = true
                
                var boldText = "Username: \n"
                let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
                var attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
                
                var normalText = currentUser.username
                var normalString = NSMutableAttributedString(string: normalText)
                
                attributedString.append(normalString)
                
                cell.usernameLabel.adjustsFontSizeToFitWidth = true
                
                cell.usernameLabel.attributedText = attributedString
                  
                /////////////////////////////////////////////////////////////////////////////////////
                
                boldText = "\(friends.count) "
                attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
                
                normalText = "Friends"
                normalString = NSMutableAttributedString(string: normalText)
                
                attributedString.append(normalString)
                
                cell.friendCountLabel.adjustsFontSizeToFitWidth = true
                
                cell.friendCountLabel.attributedText = attributedString
                
                /////////////////////////////////////////////////////////////////////////////////////
                
                boldText = "Joined on: \n"
                attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
                
                normalText = currentUser.createdOn
                normalString = NSMutableAttributedString(string: normalText)
                
                attributedString.append(normalString)
                
                cell.accountCreatedLabel.adjustsFontSizeToFitWidth = true
                
                cell.accountCreatedLabel.attributedText = attributedString
                
                return cell
            }
            
            //Free Time Section
            else if indexPath.section == 1 {

                //Free Time settings cell
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
                    cell.selectionStyle = .none
                    
                    cell.setting = "autoDeleteTasks"
                    
                    cell.settingLabel.text = "Auto Delete Completed Tasks"
                    cell.settingLabel.adjustsFontSizeToFitWidth = true
                    
                    cell.settingLabelLeadingAnchor.constant = cell.separatorInset.left
                    
                    cell.settingSwitch.isOn = defaults.value(forKey: "autoDeleteTasks") as? Bool ?? false
                    
                    return cell
                }
                
                //Free Time info cell
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    
                    cell.selectionStyle = .default
                    cell.backgroundColor = .white
                    cell.accessoryType = .detailDisclosureButton
                    
                    cell.textLabel?.text = "Free Time Cards Info"
                    cell.textLabel?.textColor = .black
                    
                    return cell
                }
            }
            
            //Pomodoro Section
            else if indexPath.section == 2 {
                
                //Pomodoro Settings cell
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
                    cell.selectionStyle = .none
                    
                    cell.setting = "playPomodoroSoundEffects"
                    
                    cell.settingLabel.adjustsFontSizeToFitWidth = true
                    cell.settingLabel.text = "Enable Timer Sound Effects"
                    
                    cell.settingLabelLeadingAnchor.constant = cell.separatorInset.left
                    
                    cell.settingSwitch.isOn = defaults.value(forKey: "playPomodoroSoundEffects") as? Bool ?? true
                    
                    return cell
                }
                
                //Pomodoro info cell
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    
                    cell.selectionStyle = .default
                    cell.backgroundColor = .white
                    cell.accessoryType = .detailDisclosureButton
                    
                    cell.textLabel?.text = "Pomodoro Info"
                    cell.textLabel?.textColor = .black
                    
                    return cell
                }
            }
            
            //Time Block Section info cell
            else if indexPath.section == 3 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                
                cell.selectionStyle = .default
                cell.backgroundColor = .white
                cell.accessoryType = .detailDisclosureButton
                
                cell.textLabel?.text = "Time Block Info"
                cell.textLabel?.textColor = .black
                
                return cell
            }
            
            //Collab Section
            else if indexPath.section == 4 {
                
                //Collab info cell
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    
                    cell.selectionStyle = .default
                    cell.backgroundColor = .white
                    cell.accessoryType = .detailDisclosureButton
                    
                    cell.textLabel?.text = "Collab Info"
                    cell.textLabel?.textColor = .black
                    
                    return cell
                }
                
                //Log Out cell
                else if indexPath.row == 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    
                    cell.selectionStyle = .default
                    cell.backgroundColor = .white
                    cell.accessoryType = .none
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                    
                    cell.textLabel?.text = "Log Out"
                    cell.textLabel?.textColor = .systemBlue
                    
                    return cell
                }
            
                //Separator cell
                else if indexPath.row == 2 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    
                    cell.selectionStyle = .none
                    cell.backgroundColor = UIColor(hexString: "F2F2F2")
                    cell.accessoryType = .none
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                    
                    cell.textLabel?.text = ""
                    
                    return cell
                }
            
                //Delete Account cell
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    
                    cell.selectionStyle = .default
                    cell.backgroundColor = .white
                    cell.accessoryType = .none
                    
                    cell.textLabel?.text = "Delete Account"
                    cell.textLabel?.textColor = .systemRed
                    
                    return cell
                }
            }
        
            //Privacy Section info cell
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                
                cell.selectionStyle = .default
                cell.backgroundColor = .white
                cell.accessoryType = .detailDisclosureButton
                
                cell.textLabel?.text = "Privacy Policy"
                cell.textLabel?.textColor = .black
                
                return cell
            }
        }
           
        //If the user hasn't signed in yet
        else {
            
            //Free Time section
            if indexPath.section == 0 {
                
                //Free Time settings cell
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
                    cell.selectionStyle = .none
                    
                    cell.setting = "autoDeleteTasks"
                    
                    cell.settingLabel.adjustsFontSizeToFitWidth = true
                    cell.settingLabel.text = "Auto Delete Completed Tasks"
                    
                    cell.settingLabelLeadingAnchor.constant = cell.separatorInset.left
                    
                    cell.settingSwitch.isOn = defaults.value(forKey: "autoDeleteTasks") as? Bool ?? false
                    
                    return cell
                }
                
                //Free Time info cell
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    
                    cell.selectionStyle = .default
                    cell.backgroundColor = .white
                    cell.accessoryType = .detailDisclosureButton
                    
                    cell.textLabel?.text = "Free Time Cards Info"
                    cell.textLabel?.textColor = .black
                    
                    return cell
                }
            }
        
            //Pomodoro Section
            else if indexPath.section == 1 {
                
                //Pomodoro settings cell
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
                    cell.selectionStyle = .none
                    
                    cell.setting = "playPomodoroSoundEffects"
                    
                    cell.settingLabel.adjustsFontSizeToFitWidth = true
                    cell.settingLabel.text = "Enable Timer Sound Effects"
                    
                    cell.settingLabelLeadingAnchor.constant = cell.separatorInset.left
                    
                    cell.settingSwitch.isOn = defaults.value(forKey: "playPomodoroSoundEffects") as? Bool ?? true
                    
                    return cell
                }
                
                //Pomodoro info cell
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                                        
                    cell.selectionStyle = .default
                    cell.backgroundColor = .white
                    cell.accessoryType = .detailDisclosureButton
                    
                    cell.textLabel?.text = "Pomodoro Info"
                    cell.textLabel?.textColor = .black
                    
                    return cell
                }
            }
              
            //Time Block section info cell
            else if indexPath.section == 2 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                
                cell.selectionStyle = .default
                cell.backgroundColor = .white
                cell.accessoryType = .detailDisclosureButton
                
                cell.textLabel?.text = "Time Block Info"
                cell.textLabel?.textColor = .black
                
                return cell
            }
            
            //Collab section info cell
            else if indexPath.section == 3 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                                    
                cell.selectionStyle = .default
                cell.backgroundColor = .white
                cell.accessoryType = .detailDisclosureButton
                
                cell.textLabel?.text = "Collab Info"
                cell.textLabel?.textColor = .black
                
                return cell
            }
        
            //Privacy section info cell
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                                
                cell.selectionStyle = .default
                cell.backgroundColor = .white
                cell.accessoryType = .detailDisclosureButton
                
                cell.textLabel?.text = "Privacy Policy"
                cell.textLabel?.textColor = .black
                
                if UIScreen.main.bounds.width == 414.0 {

                    cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
                }

                else {

                    cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                }

                return cell
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //If a user is signed in and the currentUser singleton has been populated with that users info
        if signedInUser != nil  && currentUser.userID != "" {
            
            //Profile cell
            if indexPath.section == 0 {
                return 200
            }
            
            //Separator cell in the Collab section
            else if indexPath.section == 4 && indexPath.row == 2 {
                return 10
            }
               
            //Every other cell
            else {
                return 50
            }
        }
            
        //User hasn't signed in yet
        else {
            return 50
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //If a user is signed in and the currentUser singleton has been populated with that users info
        if signedInUser != nil && currentUser.userID != "" {
            
            //Free Time info cell selected
            if indexPath.section == 1 && indexPath.row == 1 {
                
                selectedInfo = "Free Time Cards"
                performSegue(withIdentifier: "moveToInfo", sender: self)
            }
            
            //Pomodoro info cell selected
            else if indexPath.section == 2 && indexPath.row == 1 {
                
                selectedInfo = "Pomodoro"
                performSegue(withIdentifier: "moveToInfo", sender: self)
            }
            
            //Time Block info cell selected
            else if indexPath.section == 3 {
                
                selectedInfo = "Time Block"
                performSegue(withIdentifier: "moveToInfo", sender: self)
            }
            
            
            else if indexPath.section == 4 {
                
                //Collab info cell selected
                if indexPath.row == 0 {
                    
                    selectedInfo = "Collab"
                    performSegue(withIdentifier: "moveToInfo", sender: self)
                }
                
                //Log Out cell selected
                else if indexPath.row == 1 {
                    logOutUser()
                }
                
                //Delete Account cell selected
                else if indexPath.row == 3 {
                    
                    deleteUser()
                }
            }
            
            //Free Time info cell selected
            else if indexPath.section == 5 {
                
                selectedInfo = "Privacy Policy"
                performSegue(withIdentifier: "moveToInfo", sender: self)
            }
            
        }
        
        //If a user hasn't signed in yet
        else {
            
            //Free Time info cell selected
            if indexPath.section == 0 && indexPath.row == 1 {
                
                selectedInfo = "Free Time Cards"
                performSegue(withIdentifier: "moveToInfo", sender: self)
            }
            
            //Pomodoro info cell selected
            else if indexPath.section == 1 && indexPath.row == 1 {
                
                selectedInfo = "Pomodoro"
                performSegue(withIdentifier: "moveToInfo", sender: self)
            }
            
            //Time Block info cell selected
            else if indexPath.section == 2 {
                
                selectedInfo = "Time Block"
                performSegue(withIdentifier: "moveToInfo", sender: self)
            }
            
            //Collab info cell selected
            else if indexPath.section == 3 {
                
                selectedInfo = "Collab"
                performSegue(withIdentifier: "moveToInfo", sender: self)
            }
            
            //Privacy info cell selected
            else if indexPath.section == 4 {
                
                selectedInfo = "Privacy Policy"
                performSegue(withIdentifier: "moveToInfo", sender: self)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tweakSeperator (_ cell: UITableViewCell) -> UITableViewCell {
        
        if UIScreen.main.bounds.width == 414.0 {
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }
        
        else {

            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        }
        
        return cell
    }
    
    //Function that helps verify is a user is signed in
    func getUserData (completion: @escaping () -> ()) {
        
        Auth.auth().addStateDidChangeListener { (auth, user) in

            if user != nil {

                self.signedInUser = user
                
                completion()
            }
        }
    }
    
    
    func logOutUser () {
        
        ProgressHUD.show()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            do {

                try Auth.auth().signOut()
                
                self.signedInUser = nil
                self.currentUser.userID = ""
                self.settingsTableView.reloadData()

                ProgressHUD.dismiss()
                print("user signed out")

            } catch let signOutError as NSError {

                ProgressHUD.showError(signOutError.localizedDescription)

                print(signOutError.localizedDescription)
            }
        }
    }
    
    
    func deleteUser () {
        
        let deleteAlert = UIAlertController(title: "Delete Account", message: "Are you sure you would like to delete your Collaboration account? The data associated with your account will also be deleted.", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (delete) in
            
            ProgressHUD.show()
            
            //Craetion of a write batch which will help perform the multiple writes needed to delete this user from their friends collections
            let batch = self.db.batch()
            
            //Loop that adds which documents need to be deleted to the batch
            for friend in self.friends {
                
                let friendRef = self.db.collection("Users").document(friend).collection("Friends").document(self.currentUser.userID)
                
                batch.deleteDocument(friendRef)
            }
            
            //Gets the pending friend requests of the current user
            self.db.collection("Users").document(self.currentUser.userID).collection("PendingFriends").getDocuments { (snapshot, error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                }
                
                else {
                    
                    if snapshot?.isEmpty != true {
                        
                        //Uses the pending friend request of this user to get and add the friend requests that should be deleted to the batch
                        for pending in snapshot!.documents {
                            
                            let pendingFriend = pending.data()["friendID"] as! String
                            
                            let pendingFriendRef = self.db.collection("Users").document(pendingFriend).collection("FriendRequests").document(self.currentUser.userID)
                            
                            batch.deleteDocument(pendingFriendRef)
                        }
                    }
                }
                
                
                
                batch.commit() //Commits all the writes
            }
            
            //Deleting the user from the "Users" collection
            self.db.collection("Users").document(self.currentUser.userID).delete()
            
            //Deletes the account of the user
            self.signedInUser?.delete(completion: { (error) in
                
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                }
                
                else {
                    
                    self.signedInUser = nil
                    self.settingsTableView.reloadData()
                    
                    ProgressHUD.showSuccess("Your Acount Has Been Deleted!")
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToInfo" {
            
            let infoVC = segue.destination as! InfoViewController
            infoVC.selectedInfo = selectedInfo
        }
    }
}
