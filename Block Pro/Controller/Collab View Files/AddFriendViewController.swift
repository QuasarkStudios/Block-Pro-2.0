//
//  AddFriendViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/13/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase


class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    let db = Firestore.firestore()
    var friendRequestsListener: ListenerRegistration?
    var handle: AuthStateDidChangeListenerHandle?
    
    let currentUser = UserData.singletonUser
    
    var resultsObjectArray: [SearchResult] = [SearchResult]() 
    var requestsObjectArray: [FriendRequest] = [FriendRequest]()
    var searchedUsername: String = ""
    
    var pendingFriends: [PendingFriend] = [PendingFriend]()
    var friends: [Friend] = [Friend]()
    
    var tableViewTracker: String = "Requests" //Variable that tracks what data the tableView should display
    var searchButtonTapped: Bool = false
    
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addStateDidChangeListener()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.rowHeight = 55
        
        searchBar.delegate = self
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        searchBar.spellCheckingType = .no
        
        //resultsTableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendCell")
        
        getFriendRequests()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        friendRequestsListener?.remove()
    }
    
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if tableViewTracker == "Requests" {
            return "Friend Requests"
        }
        else {
            return "Search Results"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableViewTracker == "Requests" {
            
            if requestsObjectArray.count > 0 {
                return requestsObjectArray.count
            }
            else {
                return 1
            }
        }
            
        else {
            
            if resultsObjectArray.count > 0 {
                return resultsObjectArray.count
            }
            else {
                return 1
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableViewTracker == "Requests" {
            
            if requestsObjectArray.count == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "No Friend Requests Found"
                cell.textLabel?.textColor = UIColor.lightGray
                cell.isUserInteractionEnabled = false
                
                return cell
            }
            else {
                
                //let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
                let firstNameArray = Array(requestsObjectArray[indexPath.row].requesterFirstName)
                
                cell.friendName.text = requestsObjectArray[indexPath.row].requesterFirstName + " " + requestsObjectArray[indexPath.row].requesterLastName
                cell.friendInitial.text = "\(firstNameArray[0])"
                
                return cell
            }
        }
        
        else {
            
            if resultsObjectArray.count == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                
                if searchButtonTapped == true {
                    cell.textLabel?.text = "No Users Found"
                    cell.textLabel?.textColor = UIColor.lightGray
                }
                else {
                    cell.textLabel?.text = ""
                    cell.isUserInteractionEnabled = false
                }
            
                cell.accessoryType = .none
                return cell
            }
                
            else {
                
                var friendAdded: Bool = false
                var friendPending: Bool = false
                    
                for friend in friends {
                    
                    if friend.friendID == resultsObjectArray[indexPath.row].userID {
                        friendAdded = true
                        break
                    }
                }
                
                for friend in pendingFriends {
                    
                    if friend.pendingID == resultsObjectArray[indexPath.row].userID {
                        friendPending = true
                        break
                    }
                }
                
                if friendAdded == true {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    cell.textLabel?.text = "You already have this friend added"
                    cell.textLabel?.textColor = UIColor.lightGray
                    cell.isUserInteractionEnabled = false

                    return cell
                }
                
                else if friendPending == true {
                    
                    //let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
                    let firstNameArray = Array(resultsObjectArray[indexPath.row].firstName)
                    
                    cell.friendName.text = resultsObjectArray[indexPath.row].firstName + " " + resultsObjectArray[indexPath.row].lastName
                    cell.friendInitial.text = "\(firstNameArray[0])"
                    
                    cell.initialContainer.layer.cornerRadius = 0.5 * cell.initialContainer.bounds.size.width
                    cell.initialContainer.clipsToBounds = true
                    
                    cell.accessoryType = .checkmark
                    
                    return cell
                }
                    
                else if resultsObjectArray[indexPath.row].userID == currentUser.userID {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    cell.textLabel?.text = "Sorry, you can't add yourself as a friend"
                    cell.textLabel?.textColor = UIColor.lightGray
                    cell.isUserInteractionEnabled = false
                    
                    return cell
                }
                
                else {
                   
                    //let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
                    let firstNameArray = Array(resultsObjectArray[indexPath.row].firstName)
                    
                    cell.friendName.text = resultsObjectArray[indexPath.row].firstName + " " + resultsObjectArray[indexPath.row].lastName
                    cell.friendInitial.text = "\(firstNameArray[0])"
                    
                    cell.initialContainer.layer.cornerRadius = 0.5 * cell.initialContainer.bounds.size.width
                    cell.initialContainer.clipsToBounds = true
                    
                    cell.accessoryType = .none
                    
                    return cell
                }
            }
        }
    }
    
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if tableViewTracker == "Requests" {
            
            presentRequestAlert(indexPath.row)
            
        }
        
        else {
            
            if cell.accessoryType != .checkmark {
                cell.accessoryType = .checkmark
                sendRequest(indexPath)
            }
            else {
                ProgressHUD.showSuccess("You've already sent \(resultsObjectArray[indexPath.row].firstName) a friend request!")
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    //MARK: - SearchBar Delegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchButtonTapped = true
        searchedUsername = searchBar.text!
        queryUsers(searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            resultsObjectArray.removeAll()
            tableViewTracker = "Requests"
            resultsTableView.reloadData()
        }
        
        else if searchBar.text!.count > 0 && tableViewTracker == "Requests" {
            
            searchButtonTapped = false
            tableViewTracker = "Results"
            resultsTableView.reloadData()
        }
    }
    
    func addStateDidChangeListener () {
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            if let user = user {
                let uid = user.uid
                let email = user.email
            }
        })
    }
    
    func getFriendRequests () {
        
        friendRequestsListener = db.collection("Users").document(currentUser.userID).collection("FriendRequests").addSnapshotListener { (snapshot, error) in
            
            self.requestsObjectArray.removeAll()
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            
            else {
               
                if snapshot?.isEmpty == true {
                    print("you have no new friends :/")
                }
                
                else {
                    
                    for document in snapshot!.documents {
                        
                        let friendRequest = FriendRequest()
                        
                        friendRequest.requesterID = document.data()["userID"] as! String
                        friendRequest.requesterFirstName = document.data()["firstName"] as! String
                        friendRequest.requesterLastName = document.data()["lastName"] as! String
                        friendRequest.requesterUsername = document.data()["username"] as! String
                        
                        self.requestsObjectArray.append(friendRequest)
                        
                    }
                }
                self.resultsTableView.reloadData()
            }
        }
    }
    
    func queryUsers (_ searchEntry: String) {
        
        resultsObjectArray.removeAll()
        
        db.collection("Users").whereField("username", isEqualTo: searchEntry).getDocuments { (snapshot, error) in

            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    //print ("that nigga dont exist smh")
                    self.tableViewTracker = "Results"
                    self.resultsTableView.reloadData()
                }
                
                else {
                    
                    let friendSearchResults = SearchResult()
                    
                    for document in snapshot!.documents {
                        
                        let friendFirstName = document.data()["firstName"] as! String
                        let friendLastName = document.data()["lastName"] as! String
                        let friendID = document.data()["userID"] as! String
                        
                        friendSearchResults.userID = friendID
                        friendSearchResults.firstName = friendFirstName
                        friendSearchResults.lastName = friendLastName
                        friendSearchResults.username = self.searchedUsername
                        
                        self.resultsObjectArray.append(friendSearchResults)
                    }
                    self.resultsTableView.reloadData()
                }
            }
        }
    }
    
    func presentRequestAlert (_ selectedRequest: Int) {
        
        let handleRequestAlert = UIAlertController(title: "Friend Request", message: "Would you like to accept or decline this request?", preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { (acceptAction) in
            
            self.acceptRequest(selectedRequest)
        }
        
        let declineAction = UIAlertAction(title: "Decline", style: .destructive) { (declineAlert) in
            
            self.declineRequest(selectedRequest)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        handleRequestAlert.addAction(acceptAction)
        handleRequestAlert.addAction(declineAction)
        handleRequestAlert.addAction(cancelAction)
        
        present(handleRequestAlert, animated: true, completion: nil)
    }
    
    func acceptRequest (_ selectedRequest: Int) {
        
        let friendDict: [String : String] = ["friendID" : requestsObjectArray[selectedRequest].requesterID, "firstName" : requestsObjectArray[selectedRequest].requesterFirstName, "lastName" : requestsObjectArray[selectedRequest].requesterLastName, "username" : requestsObjectArray[selectedRequest].requesterUsername]
        
        db.collection("Users").document(requestsObjectArray[selectedRequest].requesterID).collection("PendingFriends").whereField("friendID", isEqualTo: currentUser.userID).getDocuments { (snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    
                    self.db.collection("Users").document(self.currentUser.userID).collection("FriendRequests").document(friendDict["friendID"]!).delete()
                    
                    ProgressHUD.showError("Sorry, this friend request was rescinded")
                    
                    //self.findFriendRequests()
                }
                else {
                    self.db.collection("Users").document(self.currentUser.userID).collection("Friends").document(friendDict["friendID"]!).setData(friendDict)
            
                    self.db.collection("Users").document(self.currentUser.userID).collection("FriendRequests").document(friendDict["friendID"]!).delete()
            
                    self.db.collection("Users").document(self.requestsObjectArray[selectedRequest].requesterID).collection("PendingFriends").document(self.currentUser.userID).setData(["accepted" : "true"], mergeFields: ["accepted"])
            
                    //self.findFriendRequests()
                }
            }
        }
    }
    
    func declineRequest (_ selectedRequest: Int) {
        
        db.collection("Users").document(currentUser.userID).collection("FriendRequests").document(requestsObjectArray[selectedRequest].requesterID).delete()
        
        db.collection("Users").document(requestsObjectArray[selectedRequest].requesterID).collection("PendingFriends").document(currentUser.userID).setData(["accepted" : "false"], mergeFields: ["accepted"])
        
        //findFriendRequests()
        
    }
    
    func sendRequest (_ indexPath: IndexPath) {
        
        let pendingFriendDict: [String: String] = ["friendID" : resultsObjectArray[indexPath.row].userID, "firstName" : resultsObjectArray[indexPath.row].firstName, "lastName" : resultsObjectArray[indexPath.row].lastName, "username" : resultsObjectArray[indexPath.row].username, "accepted" : ""]

        let requestDict: [String : String] = [ "userID" : currentUser.userID, "firstName" : currentUser.firstName, "lastName" : currentUser.lastName, "username" : currentUser.username]
        
        db.collection("Users").document(resultsObjectArray[indexPath.row].userID).collection("FriendRequests").document(currentUser.userID).setData(requestDict)
        
        db.collection("Users").document(currentUser.userID).collection("PendingFriends").document(pendingFriendDict["friendID"]!).setData(pendingFriendDict)
        
        let pendingFriend = PendingFriend()
        
        pendingFriend.pendingID = resultsObjectArray[indexPath.row].userID
        pendingFriend.pendingFirstName = resultsObjectArray[indexPath.row].firstName
        pendingFriend.pendingLastName = resultsObjectArray[indexPath.row].lastName
        pendingFriend.pendingUsername = resultsObjectArray[indexPath.row].username
        
        pendingFriends.append(pendingFriend)
        
        ProgressHUD.showSuccess("Friend Request Sent!")
        
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        //findFriendRequests()
    }
}

