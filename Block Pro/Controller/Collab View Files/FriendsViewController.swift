//
//  FriendsViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/8/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var db = Firestore.firestore()
    
    var pendingObjectArray: [PendingFriend] = [PendingFriend]()
    var friendObjectArray: [Friend] = [Friend]()
    
    var allFriends: [Friend] = [Friend]()
    var selectedFriend: Friend?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        searchBar.delegate = self
        
        friendsTableView.register(UINib(nibName: "FriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendsCell")
        friendsTableView.rowHeight = 55
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPendingFriends {
            self.getFriends()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pendingObjectArray.removeAll()
        friendObjectArray.removeAll()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if pendingObjectArray.count > 0 {
            return 2
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if pendingObjectArray.count == 0 {
            return "Friends"
        }
        else {
            if section == 0 {
               return "Pending Friends"
            }
            else {
                return "Friends"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if pendingObjectArray.count == 0 {
            if friendObjectArray.count == 0 {
                return 0
            }
            else {
                return friendObjectArray.count
            }
        }
        
        else {
            if section == 0 {
                return pendingObjectArray.count
            }
            else {
                if friendObjectArray.count == 0 {
                    return 0
                }
                else {
                    return friendObjectArray.count
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if pendingObjectArray.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsTableViewCell
            cell.friendsName.text = friendObjectArray[indexPath.row].firstName + " " + friendObjectArray[indexPath.row].lastName
            return cell
        }
            
        else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = pendingObjectArray[indexPath.row].pendingFirstName + " " + pendingObjectArray[indexPath.row].pendingLastName
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsTableViewCell
                cell.friendsName.text = friendObjectArray[indexPath.row].firstName + " " + friendObjectArray[indexPath.row].lastName
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if pendingObjectArray.count == 0 {
            
            selectedFriend = friendObjectArray[indexPath.row]
            performSegue(withIdentifier: "moveToSelectedFriend", sender: self)
        }
        
        else {
            if indexPath.section == 0 {
                rescindFriendRequest(indexPath)
            }
            else {
                selectedFriend = friendObjectArray[indexPath.row]
                performSegue(withIdentifier: "moveToSelectedFriend", sender: self)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            
            friendObjectArray = allFriends
            friendsTableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
        else {
            
            var filteredFriends: [Friend] = [Friend]()
            
            friendObjectArray = allFriends
            
            for friend in friendObjectArray {
                if friend.firstName.localizedCaseInsensitiveContains(searchBar.text!) == true {
                    filteredFriends.append(friend)
                    print ("first name check", friend.firstName)
                }
                else if friend.lastName.localizedCaseInsensitiveContains(searchBar.text!) == true {
                    filteredFriends.append(friend)
                    print ("last name check", friend.lastName)
                }
            }
            
            friendObjectArray = filteredFriends.sorted(by: {$0.lastName < $1.lastName})
            friendsTableView.reloadData()
        }
    }
    
    
    func getPendingFriends (completion: @escaping () -> ()) {
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).collection("PendingFriends").getDocuments { (snapshot, error) in
            
            if error != nil {
                print (error as Any)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    print ("no pending requests ")
                    completion()
                }
                
                else {
                    
                    for document in snapshot!.documents {
                        
                        let pendingFriend = PendingFriend()
                        
                        print("Pending Friend: ", document.data())
                        
                        if let pendingID = document.data()["friendID"] as? String {
                            
                            pendingFriend.pendingID = pendingID
                            pendingFriend.pendingFirstName = document.data()["firstName"] as! String
                            pendingFriend.pendingLastName = document.data()["lastName"] as! String
                            pendingFriend.pendingUsername = document.data()["username"] as! String
                            pendingFriend.accepted = document.data()["accepted"] as! String
                            
                            if pendingFriend.accepted == "true" {
                                self.friendRequestAccepted(pendingFriend)
                            }
                            else if pendingFriend.accepted == "false" {
                                self.friendRequestDeclined(pendingFriend)
                            }
                            else {
                                self.pendingObjectArray.append(pendingFriend)
                            }
                        }
                        else {
                            self.db.collection("Users").document(Auth.auth().currentUser!.uid).collection("PendingFriends").document(document.documentID).delete()
                            
                        }
                        
                    }
                    self.pendingObjectArray = self.pendingObjectArray.sorted(by: {$0.pendingLastName < $1.pendingLastName})
                    completion()
                    //self.friendsTableView.reloadData()
                }
            }
        }
        
    }
    
    func friendRequestAccepted (_ pendingFriend: PendingFriend) {
       
        let newFriend: [String : String] = ["friendID" : pendingFriend.pendingID, "firstName" : pendingFriend.pendingFirstName, "lastName" : pendingFriend.pendingLastName, "username" : pendingFriend.pendingUsername]
       
        db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Friends").document(newFriend["friendID"]!).setData(newFriend, merge: true)
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).collection("PendingFriends").document(pendingFriend.pendingID).delete()
    }
    
    func friendRequestDeclined (_ pendingFriend: PendingFriend) {
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).collection("PendingFriends").document(pendingFriend.pendingID).delete()
        
    }
    
    func getFriends () {
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Friends").getDocuments { (snapshot, error) in
            
            if error != nil {
                print (error as Any)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    print ("you have no friends")
                }
                
                else {
                    
                    for document in snapshot!.documents {
                       
                        let friend = Friend()
                        
                        print("Friend: ", document.data())
                        
                        friend.friendID = document.data()["friendID"] as! String
                        friend.firstName = document.data()["firstName"] as! String
                        friend.lastName = document.data()["lastName"] as! String
                        friend.username = document.data()["username"] as! String
                        
                        self.friendObjectArray.append(friend)
                    }
                    self.friendObjectArray = self.friendObjectArray.sorted(by: {$0.lastName < $1.lastName})
                    self.allFriends = self.friendObjectArray
                    self.friendsTableView.reloadData()
                }
            }
        }
    }
    
    func rescindFriendRequest (_ indexPath: IndexPath) {
        
        let rescindRequestAlert = UIAlertController(title: "Pending Request", message: "Would you like to rescind your request?", preferredStyle: .alert)
        
        let rescindAction = UIAlertAction(title: "Rescind", style: .destructive) { (rescindAction) in
            self.db.collection("Users").document(self.pendingObjectArray[indexPath.row].pendingID).collection("FriendRequests").document(Auth.auth().currentUser!.uid).delete()
            self.db.collection("Users").document(Auth.auth().currentUser!.uid).collection("PendingFriends").document(self.pendingObjectArray[indexPath.row].pendingID).delete()
            
                self.pendingObjectArray.removeAll()
                self.friendObjectArray.removeAll()
            
                self.getPendingFriends {
                    self.getFriends()
                }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        rescindRequestAlert.addAction(rescindAction)
        rescindRequestAlert.addAction(cancelAction)
        
        present(rescindRequestAlert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToSelectedFriend" {
            
            let selectedFriendVC = segue.destination as! SelectedFriendViewController
            selectedFriendVC.selectedFriend = selectedFriend
            selectedFriendVC.collabSelectedDelegate = self
        }
    }
    
}

extension FriendsViewController: CollabSelected {
    
    func performSegue () {
        
        performSegue(withIdentifier: "moveToCollabBlockView", sender: self)
    }
}