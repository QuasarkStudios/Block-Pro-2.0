//
//  CollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/7/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

class CollabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var friendsButton: UIBarButtonItem!
    @IBOutlet weak var createCollabButton: UIBarButtonItem!
    @IBOutlet weak var upcomingCollabTableView: UITableView!
    
    lazy var db = Firestore.firestore()
    var handle: AuthStateDidChangeListenerHandle?

    let currentUser = UserData.singletonUser
    
    var collabObjectArray: [UpcomingCollab] = [UpcomingCollab]()
    
    var sectionDateArray: [String] = [String]()
    var sectionContentArray: [[UpcomingCollab]]?
    
    var allSectionDates: [String] = [String]()
    var allSectionContent: [[UpcomingCollab]] = [[UpcomingCollab]]()
    var selectedCollab: UpcomingCollab?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        upcomingCollabTableView.delegate = self
        upcomingCollabTableView.dataSource = self
        
        searchBar.delegate = self
        
        upcomingCollabTableView.register(UINib(nibName: "UpcomingCollabTableCell", bundle: nil), forCellReuseIdentifier: "UpcomingCollabCell")
        
        upcomingCollabTableView.rowHeight = 105
        
        //docRef = Firestore.firestore().collection("sampleData").document("inspiration")
//        //Can also do
//        //docRef = Firestore.firestore().document("sampleData/inspiration")
//
        
        performSegue(withIdentifier: "moveToLogIn", sender: self)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDateArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sectionDateArray[section]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section < sectionDateArray.count {
            return sectionContentArray![section].count
        }
        else {
           return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCollabCell", for: indexPath) as! UpcomingCollabTableCell
        
        let collabWithText = sectionContentArray![indexPath.section][indexPath.row].collaborator!["firstName"]! + " " + sectionContentArray![indexPath.section][indexPath.row].collaborator!["lastName"]!
        
        cell.collabWithLabel.text = "Collab with " + collabWithText
        cell.collabNameLabel.text = sectionContentArray![indexPath.section][indexPath.row].collabName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "moveToCollabBlockView", sender: self)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            
            sortCollabs()
            upcomingCollabTableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
        else {
            
            sectionDateArray = allSectionDates
            sectionContentArray = allSectionContent
            
            var filteredSectionDates: [String] = [String]()
            var filteredSectionContent: [[UpcomingCollab]] = [[UpcomingCollab]]()
            
            for dates in sectionContentArray! {
                
                for collab in dates {
                    
                    if collab.collabName.localizedCaseInsensitiveContains(searchText) == true {
                        
                        if filteredSectionDates.contains(collab.collabDate) == false {
                            filteredSectionDates.append(collab.collabDate)
                        }
                        
                        filteredSectionContent.append([collab])
                    }
                    
                    else if collab.collaborator!["firstName"]!.localizedCaseInsensitiveContains(searchText) == true {
                        
                        if filteredSectionDates.contains(collab.collabDate) == false {
                            filteredSectionDates.append(collab.collabDate)
                        }
                        
                        filteredSectionContent.append([collab])
                    }
                    
                    else if collab.collaborator!["lastName"]!.localizedCaseInsensitiveContains(searchText) == true {
                        
                        if filteredSectionDates.contains(collab.collabDate) == false {
                            filteredSectionDates.append(collab.collabDate)
                        }
                        
                        filteredSectionContent.append([collab])
                    }
                    
                }
            }
            
            sectionDateArray = filteredSectionDates
            sectionContentArray = filteredSectionContent
            upcomingCollabTableView.reloadData()
            
//            print(filteredSectionDates)
//            print(filteredSectionContent[0][0].collabName)
        }
        
    }
    
    
    func getUserData (_ uid: String, completion: @escaping () -> ()) {

        db.collection("Users").document(uid).getDocument { (snapshot, error) in

            if error != nil {
                print ("try again")
            }
            else {
                
                let currentUser = UserData.singletonUser
                
                currentUser.userID = snapshot?.data()!["userID"] as! String
                currentUser.firstName = snapshot?.data()!["first name"] as! String
                currentUser.lastName = snapshot?.data()!["last name"] as! String
                currentUser.username = snapshot?.data()!["username"] as! String
                
                completion()
                
                }
            }
    }
    
    func getCollabs () {
        
        collabObjectArray.removeAll()
        
        db.collection("Users").document(currentUser.userID).collection("UpcomingCollabs").getDocuments { (snapshot, error) in

            if error != nil {
                print (error as Any)
            }
                
            else {

                if snapshot?.isEmpty == true {
                    print("no collabs")
                }
                else {

                    for document in snapshot!.documents {

                        //print("Upcoming Collab: ", document.data())

                        let upcomingCollab = UpcomingCollab()

                        upcomingCollab.collabID = document.data()["collabID"] as! String
                        upcomingCollab.collabName = document.data()["collabName"] as! String
                        upcomingCollab.collabDate = document.data()["collabDate"] as! String
                        upcomingCollab.collaborator = (document.data()["with"] as! [String : String])

                        self.collabObjectArray.append(upcomingCollab)
                    }
                    self.collabObjectArray = self.collabObjectArray.sorted(by: {$0.collabDate < $1.collabDate})
                    self.sortCollabs()
                    self.upcomingCollabTableView.reloadData()
                }
            }
        }
    }
    
    func sortCollabs () {
        
        sectionDateArray.removeAll()
        sectionContentArray?.removeAll()
        
        for collab in collabObjectArray {
            
            if sectionDateArray.contains(collab.collabDate) == false {
                sectionDateArray.append(collab.collabDate)
            }
        }
    
        sectionContentArray = Array(repeating: Array(repeating: collabObjectArray[0], count: 0), count: sectionDateArray.count)
        
        for collab in collabObjectArray {
            
            if let index = sectionDateArray.firstIndex(of: collab.collabDate) {
                sectionContentArray![index].append(collab)
            }
        }
        
        allSectionDates = sectionDateArray
        
        guard let sectionContent = sectionContentArray else { return }
        
        allSectionContent = sectionContent
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToLogIn" {
            
            let login_registerVC = segue.destination as! LogInViewController
            login_registerVC.attachListenerDelegate = self
            login_registerVC.registerUserDelegate = self
        }
        
        else if segue.identifier == "moveToCreateCollab" {
            
            let newCollabVC = segue.destination as! NewCollabViewController
            newCollabVC.getCollabDelegate = self
        }
    }
}

extension CollabViewController: UserRegistration {
    
    func newUser(_ firstName: String, _ lastName: String, _ username: String) {
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if let user = user {
                let uid = user.uid
                let email = user.email
                
                self.getUserData(uid, completion: {})
                
                self.db.collection("Users").document(uid).setData(["userID" : uid, "firstName" : firstName, "lastName" : lastName, "username" : username])
                
                print (uid, email)
            }
            else {
                print("damn")
            }
        }
        
    }
}

extension CollabViewController: UserSignIn {
    
    func attachListener() {
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if let user = user {
                let uid = user.uid
                let email = user.email
                
                self.getUserData(uid, completion: {
                    self.getCollabs()
                })
                //self.getCollabs()
                //self.getFriends()
                print (uid, email)
            }
            else {
                print("damn")
            }
        }
    }
}

extension CollabViewController: GetNewCollab {
    
    func getNewCollab () {
        getCollabs()
        
        DispatchQueue.main.async {
            self.searchBar.resignFirstResponder()
        }
        
        searchBar.text = ""
    }
}

