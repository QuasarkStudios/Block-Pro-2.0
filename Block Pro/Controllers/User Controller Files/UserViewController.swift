//
//  UserViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/3/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var settingsTableView: UITableView!
    
    
    var signedInUser: User?
    
    let currentUser = UserData.singletonUser
    
//    
//    let defaults = UserDefaults.standard
    
    let sectionHeaderArray = [nil, "Free Time", "Pomodoro", "Time Block", "Collab"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        Auth.auth().addStateDidChangeListener { (auth, user) in

            if user != nil {
                
                self.signedInUser = user
                self.settingsTableView.reloadData()
                
                print(user?.email)
            }

        }
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//
//        Auth.auth().addStateDidChangeListener { (auth, user) in
//
//            if user != nil {
//                self.signedInUser = user
//                self.logOutButton.setTitleColor(.red, for: .normal)
//                print(user?.email)
//            }
//            else {
//                self.logOutButton.setTitleColor(.gray, for: .normal)
//
//            }
//
//        }
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if signedInUser != nil {
            
            return 5
        }
        else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if signedInUser != nil {
            
            return sectionHeaderArray[section]
        }
            
        else {
            
            return sectionHeaderArray[section + 1]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if signedInUser != nil {
            
            if section == 0 || section == 3 {
                return 1
            }
            else {
                return 2
            }
        }
        else {
            
            if section < 2 || section == 3 {
                return 2
            }
            else {
                return 1
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if signedInUser != nil {
            
            if indexPath.section == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
                
                let firstNameArray = Array(currentUser.firstName)
                
                cell.initialLabel.text = "\(firstNameArray[0].uppercased())"
                
                cell.nameLabel.adjustsFontSizeToFitWidth = true
                cell.nameLabel.text = "Name: \n" + currentUser.firstName + " " + currentUser.lastName
                
                cell.usernameLabel.adjustsFontSizeToFitWidth = true
                cell.usernameLabel.text = "Username: \n" + currentUser.username
                
                cell.accountCreatedLabel.adjustsFontSizeToFitWidth = true
                cell.accountCreatedLabel.text = "Joined on: \n" + currentUser.createdOn

                cell.initialContainer.layer.cornerRadius = 0.5 * cell.initialContainer.bounds.size.width
                cell.initialContainer.clipsToBounds = true
                
                cell.initialLabel.layer.cornerRadius = 0.5 * cell.initialLabel.bounds.size.width
                cell.initialLabel.clipsToBounds = true
                
                return cell
            }
            
            else if indexPath.section == 1 {
                
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
                    
                    cell.settingLabel.adjustsFontSizeToFitWidth = true
                    cell.settingLabel.text = "Automatically Delete Completed Tasks"
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                    cell.textLabel?.text = "Free Time Cards Info"
                    return cell
                }
            }
            
            else if indexPath.section == 2 {
                
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
                    
                    cell.settingLabel.adjustsFontSizeToFitWidth = true
                    cell.settingLabel.text = "Enable Timer Sound Effects"
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                    cell.textLabel?.text = "Pomodoro Info"
                    return cell
                }
            }
                
            else if indexPath.section == 3 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                cell.textLabel?.text = "Time Block Info"
                return cell
            }
                
            else {
                
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                    cell.textLabel?.text = "Collab Info"
                    return cell
                }
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    cell.textLabel?.text = "Log Out"
                    cell.textLabel?.textColor = .red
                    
                    return cell
                }
            }
        }
            
        else {
            
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
                    
                    cell.settingLabel.adjustsFontSizeToFitWidth = true
                    cell.settingLabel.text = "Automatically Delete Completed Tasks"
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                    cell.textLabel?.text = "Free Time Cards Info"
                    return cell
                }
            }
            
            else if indexPath.section == 1 {
                
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
                    
                    cell.settingLabel.adjustsFontSizeToFitWidth = true
                    cell.settingLabel.text = "Enable Timer Sound Effects"
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                    cell.textLabel?.text = "Pomodoro Info"
                    return cell
                }
            }
                
            else if indexPath.section == 2 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                cell.textLabel?.text = "Time Block Info"
                return cell
            }
                
            else {
                
                 if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                    cell.textLabel?.text = "Collab Info"
                    return cell
                }
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    cell.textLabel?.text = "Log Out"
                    cell.textLabel?.textColor = .red
                    
                    return cell
                }
            }
        
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if signedInUser != nil {
            
            if indexPath.section == 0 {
                return 200
            }
            else {
                return 50
            }
        }
        else {
            
            return 50
        }
    }
    
    
    
    
    //        if defaults.value(forKey: "playPomodoroSoundEffects") as? Bool ?? true == true {
    //            soundEffectsSwitch.isOn = true
    //        }
    //        else {
    //            soundEffectsSwitch.isOn = false
    //        }
    
    
    
    
//    if soundEffectsSwitch.isOn {
//
//        defaults.set(true, forKey: "playPomodoroSoundEffects")
//    }
//    else {
//
//        defaults.set(false, forKey: "playPomodoroSoundEffects")
//    }

//    do {
//
//        try Auth.auth().signOut()
//        print("user signed out")
//
//    } catch let signOutError as NSError {
//
//        print("Error signing out", signOutError.localizedDescription)
//    }
//
//    print(Auth.auth().currentUser)

}
