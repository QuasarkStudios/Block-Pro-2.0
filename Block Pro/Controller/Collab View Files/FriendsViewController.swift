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
    var pendingFriendsListener: ListenerRegistration?
    var friendsListener: ListenerRegistration?
    
    var pendingObjectArray: [PendingFriend] = [PendingFriend]()
    var friendObjectArray: [Friend] = [Friend]()
    
    var allFriends: [Friend] = [Friend]()
    var selectedFriend: Friend?
    
    var collabID: String = ""
    var collabName: String = ""
    var collabDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        searchBar.delegate = self
        
        friendsTableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendCell")
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
        
        pendingFriendsListener?.remove()
        friendsListener?.remove()
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
            let firstNameArray = Array(friendObjectArray[indexPath.row].firstName)
            
            cell.friendName.text = friendObjectArray[indexPath.row].firstName + " " + friendObjectArray[indexPath.row].lastName
            cell.friendInitial.text = "\(firstNameArray[0])"
            return cell
        }
            
        else {
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = pendingObjectArray[indexPath.row].pendingFirstName + " " + pendingObjectArray[indexPath.row].pendingLastName
                return cell
            }
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
                let firstNameArray = Array(friendObjectArray[indexPath.row].firstName)
                
                cell.friendName.text = friendObjectArray[indexPath.row].firstName + " " + friendObjectArray[indexPath.row].lastName
                cell.friendInitial.text = "\(firstNameArray[0])"
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if pendingObjectArray.count == 0 {
            
            //Catches a lil bug that causes the friendObjectArray to go out of bounds
            if indexPath.row < friendObjectArray.count {
                selectedFriend = friendObjectArray[indexPath.row]
                performSegue(withIdentifier: "moveToSelectedFriend", sender: self)
            }
        }
        
        else {
            if indexPath.section == 0 {
                
                rescindFriendRequest(indexPath)
            }
            else {
                
                //Catches a lil bug that causes the friendObjectArray to go out of bounds
                if indexPath.row < friendObjectArray.count {
                    selectedFriend = friendObjectArray[indexPath.row]
                    performSegue(withIdentifier: "moveToSelectedFriend", sender: self)
                }
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
                }
                else if friend.lastName.localizedCaseInsensitiveContains(searchBar.text!) == true {
                    filteredFriends.append(friend)
                }
            }
            
            friendObjectArray = filteredFriends.sorted(by: {$0.lastName < $1.lastName})
            friendsTableView.reloadData()
        }
    }
    
    
    func getPendingFriends (completion: @escaping () -> ()) {
        
        pendingFriendsListener = db.collection("Users").document(Auth.auth().currentUser!.uid).collection("PendingFriends").addSnapshotListener { (snapshot, error) in
            
            self.pendingObjectArray.removeAll()
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    print ("no pending requests ")
                    completion()
                }
                
                else {
                    
                    for document in snapshot!.documents {
                        
                        let pendingFriend = PendingFriend()
                        
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
                    self.friendsTableView.reloadData()
                    completion()
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
        
        friendsListener = db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Friends").addSnapshotListener { (snapshot, error) in
            
            self.friendObjectArray.removeAll()
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    print ("you have no friends")
                    
                    self.friendsTableView.reloadData()
                }
                
                else {
                    
                    for document in snapshot!.documents {
                       
                        let friend = Friend()
                        
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
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        getPendingFriends {
            self.getFriends()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToSelectedFriend" {
            
            let selectedFriendVC = segue.destination as! SelectedFriendViewController
            selectedFriendVC.selectedFriend = selectedFriend
            
            selectedFriendVC.collabBlocksDelegate = self
            selectedFriendVC.friendDeletedDelegate = self
            
        }
            
        else if segue.identifier == "moveToAddNewFriend" {
            
            let addFriendVC = segue.destination as! AddFriendViewController
            
            addFriendVC.pendingFriends = pendingObjectArray
            addFriendVC.friends = friendObjectArray
        }
        
        else if segue.identifier == "moveToCollabBlockView" {
            
            let collabBlockVC = segue.destination as! CollabBlockViewController
            collabBlockVC.collabID = collabID
            collabBlockVC.collabName = collabName
            collabBlockVC.collabDate = collabDate
        }
    }
    
}

extension FriendsViewController: CollabView {
    
    func performSegue (_ collabID: String, _ collabName: String, _ collabDate: String) {
        
        self.collabID = collabID
        self.collabName = collabName
        self.collabDate = collabDate
        performSegue(withIdentifier: "moveToCollabBlockView", sender: self)
    }
}

extension FriendsViewController: FriendDeleted {
    
    func reloadFriends() {
        
        friendObjectArray.removeAll()
        getFriends()
        friendsTableView.reloadData()
        
        ProgressHUD.showSuccess(selectedFriend!.firstName + " " + selectedFriend!.lastName + " has been deleted")
    }
}
