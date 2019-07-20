//
//  CollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/7/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

class CollabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var friendsButton: UIBarButtonItem!
    @IBOutlet weak var createCollabButton: UIBarButtonItem!
    @IBOutlet weak var upcomingCollabTableView: UITableView!
    
    lazy var db = Firestore.firestore()
    var handle: AuthStateDidChangeListenerHandle?

    let currentUser = UserData.singletonUser
    
    var collabObjectArray: [UpcomingCollab] = [UpcomingCollab]()
    
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        upcomingCollabTableView.delegate = self
        upcomingCollabTableView.dataSource = self
        
        upcomingCollabTableView.register(UINib(nibName: "UpcomingCollabTableCell", bundle: nil), forCellReuseIdentifier: "UpcomingCollabCell")
        
        upcomingCollabTableView.rowHeight = 105
        
        //docRef = Firestore.firestore().collection("sampleData").document("inspiration")
//        //Can also do
//        //docRef = Firestore.firestore().document("sampleData/inspiration")
//
        
        performSegue(withIdentifier: "moveToLogIn", sender: self)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Jan. 1 2019"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return collabObjectArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCollabCell", for: indexPath) as! UpcomingCollabTableCell
        let collabWithText = collabObjectArray[indexPath.row].collaborator!["firstName"]! + " " + collabObjectArray[indexPath.row].collaborator!["lastName"]!
        
        cell.collabWithLabel.text = "Collab with " + collabWithText
        cell.collabNameLabel.text = collabObjectArray[indexPath.row].collabName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "moveToCollabBlockView", sender: self)
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

                        print("Upcoming Collab: ", document.data())

                        let upcomingCollab = UpcomingCollab()

                        upcomingCollab.collabID = document.data()["collabID"] as! String
                        upcomingCollab.collabName = document.data()["collabName"] as! String
                        upcomingCollab.collabDate = document.data()["collabDate"] as! String
                        upcomingCollab.collaborator = (document.data()["with"] as! [String : String])

                        self.collabObjectArray.append(upcomingCollab)
                    }
                    self.upcomingCollabTableView.reloadData()
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToLogIn" {
            
            let login_registerVC = segue.destination as! LogInViewController
            login_registerVC.attachListenerDelegate = self
            login_registerVC.registerUserDelegate = self
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



