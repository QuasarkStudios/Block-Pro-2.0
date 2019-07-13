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
    
    var docRef: DocumentReference!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    let dataToSave: [String : String] = ["quote": "You can do it!!!", "author": "Nimat Azeez"]
    
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
       // testFirebase()
        
        performSegue(withIdentifier: "moveToLogIn", sender: self)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Jan. 1 2019"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCollabCell", for: indexPath) as! UpcomingCollabTableCell
        
        if indexPath.row == 1 {
            cell.collabNameLabel.text = "Beach Day "
        }
        else {
           cell.collabNameLabel.text = "Do Homework "
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        fetchData()
        //performSegue(withIdentifier: "moveToCollabBlockView", sender: self)
    }
    
    func testFirebase () {
        docRef.setData(dataToSave) { (error) in
            
            if let error = error {
                print("Oh no! Got an error: \(error.localizedDescription)")
            }
            else {
                print ("Data has been saved")
            }
            
        }
    }
    
    func fetchData () {
        
        docRef.getDocument { (docSnapshop, error) in
            guard let docSnapshot = docSnapshop, docSnapshot.exists else { return }
                let myData = docSnapshot.data()
            let latestQuote = myData!["quote"] as? String ?? ""
            let quoteAuthor = myData!["author"] as? String ?? "(none)"
                print ("\(latestQuote) - \(quoteAuthor)")
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

extension CollabViewController: UserSignIn {
    
    func attachListener() {
        
        //ProgressHUD.dismiss()
        //ProgressHUD.showSuccess("Logged In!")
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if let user = user {
                let uid = user.uid
                let email = user.email

                
                print (uid, email)
            }
            else {
                print("damn")
            }
        }
    }
}

extension CollabViewController: UserRegistration {
    
    func newUser(_ firstName: String, _ lastName: String) {
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if let user = user {
                let uid = user.uid
                let email = user.email
                
                self.docRef = Firestore.firestore().collection("Users").document(uid)
                self.docRef.setData(["first name" : firstName, "last name" : lastName])
                
                print (uid, email)
            }
            else {
                print("damn")
            }
        }
        
    }
}
