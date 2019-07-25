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
    
    var handle: AuthStateDidChangeListenerHandle?
    
    var resultsObjectArray: [SearchResult] = [SearchResult]() 
    var requestsObjectArray: [FriendRequest] = [FriendRequest]()
    var searchedUsername: String = ""
    
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
        
        resultsTableView.register(UINib(nibName: "AddFriendTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchedFriend")
        
        findFriendRequests()
        
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
                cell.isUserInteractionEnabled = false
                
                return cell
            }
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchedFriend", for: indexPath) as! AddFriendTableViewCell
                let firstNameArray = Array(requestsObjectArray[indexPath.row].requesterFirstName)
                
                cell.searchedFriendName.text = requestsObjectArray[indexPath.row].requesterFirstName + " " + requestsObjectArray[indexPath.row].requesterLastName
                cell.friendInitial.text = "\(firstNameArray[0])"
                
                return cell
            }
        }
        
        else {
            
            if resultsObjectArray.count == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                
                if searchButtonTapped == true {
                    cell.textLabel?.text = "No Users Found"
                }
                else {
                    cell.textLabel?.text = ""
                    cell.isUserInteractionEnabled = false
                }
            
                cell.accessoryType = .none
                return cell
            }
                
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchedFriend", for: indexPath) as! AddFriendTableViewCell
                let firstNameArray = Array(resultsObjectArray[indexPath.row].firstName)
                
                cell.searchedFriendName.text = resultsObjectArray[indexPath.row].firstName + " " + resultsObjectArray[indexPath.row].lastName
                cell.friendInitial.text = "\(firstNameArray[0])"
                
                cell.accessoryType = .none
                return cell
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
    
    func findFriendRequests () {
        
        requestsObjectArray.removeAll()
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).collection("FriendRequests").getDocuments { (snapshot, error) in
            
            if error != nil {
                print (error as Any)
            }
            
            else {
               
                if snapshot?.isEmpty == true {
                    print("you have no new friends :/")
                }
                
                else {
                    
                    for document in snapshot!.documents {
                        
                        let friendRequest = FriendRequest()
                        
                        print("Friend Requests: ", document.data())
                        
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
                print(error as Any)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    print ("that nigga dont exist smh")
                    self.tableViewTracker = "Results"
                    self.resultsTableView.reloadData()
                }
                
                else {
                    
                    let friendSearchResults = SearchResult()
                    
                    for document in snapshot!.documents {
                        
                        //print("Search Results: ", document.data())
                        
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
        
        db.collection("Users").document(requestsObjectArray[selectedRequest].requesterID).collection("PendingFriends").whereField("friendID", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snapshot, error) in
            
            if error != nil {
                print (error as Any)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    
                    self.db.collection("Users").document(Auth.auth().currentUser!.uid).collection("FriendRequests").document(friendDict["friendID"]!).delete()
                    
                    ProgressHUD.showError("Sorry, this friend request was rescinded")
                    
                    self.findFriendRequests()
                }
                else {
                    self.db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Friends").document(friendDict["friendID"]!).setData(friendDict)
            
                    self.db.collection("Users").document(Auth.auth().currentUser!.uid).collection("FriendRequests").document(friendDict["friendID"]!).delete()
            
                    self.db.collection("Users").document(self.requestsObjectArray[selectedRequest].requesterID).collection("PendingFriends").document(Auth.auth().currentUser!.uid).setData(["accepted" : "true"], mergeFields: ["accepted"])
            
                    self.findFriendRequests()
                }
            }
        }
    }
    
    func declineRequest (_ selectedRequest: Int) {
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).collection("FriendRequests").document(requestsObjectArray[selectedRequest].requesterID).delete()
        
        db.collection("Users").document(requestsObjectArray[selectedRequest].requesterID).collection("PendingFriends").document(Auth.auth().currentUser!.uid).setData(["accepted" : "false"], mergeFields: ["accepted"])
        
        findFriendRequests()
        
    }
    
    func sendRequest (_ indexPath: IndexPath) {
        
        let pendingFriendDict: [String: String] = ["friendID" : resultsObjectArray[indexPath.row].userID, "firstName" : resultsObjectArray[indexPath.row].firstName, "lastName" : resultsObjectArray[indexPath.row].lastName, "username" : resultsObjectArray[indexPath.row].username, "accepted" : ""]
        
        db.collection("Users").whereField("userID", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snapshot, error) in
            
            if error != nil {
                print (error as Any)
            }
            
            else {
                
                for document in snapshot!.documents {
                                        let userFirstName = document.data()["firstName"] as! String
                    let userLastName = document.data()["lastName"] as! String
                    let username = document.data()["username"] as! String
                    let userID = document.data()["userID"] as! String
                    
                    let requestDict: [String : String] = [ "userID" : userID, "firstName" : userFirstName, "lastName" : userLastName, "username" : username]
                    
                    self.db.collection("Users").document(self.resultsObjectArray[indexPath.row].userID).collection("FriendRequests").document(Auth.auth().currentUser!.uid).setData(requestDict)
                    
                    self.db.collection("Users").document(Auth.auth().currentUser!.uid).collection("PendingFriends").document(pendingFriendDict["friendID"]!).setData(pendingFriendDict)
                    
                    ProgressHUD.showSuccess("Friend Request Sent!")
                }
                
            }
        }
    }
}

