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
    
    let formatter = DateFormatter()
    
    var pendingCollabObjectArray: [PendingCollab] = [PendingCollab]()
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        if currentUser.userID != "" {
            addHistoricCollabs(completion: {
                self.getCollabs()
                self.getCollabRequests()
                
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if pendingCollabObjectArray.count > 0 {
            
            if collabObjectArray.count > 0 {
                return sectionDateArray.count + 1
            }
            else {
                return 2
            }
        }
            
        else {
            if collabObjectArray.count > 0 {
                return sectionDateArray.count
            }
            else {
                return 1
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if pendingCollabObjectArray.count > 0 {
            
            if collabObjectArray.count > 0 {
                
                if section == 0 {
                    return "Collab Requests"
                }
                else {
                    return sectionDateArray[section - 1]
                }
            }
            else {
                if section == 0 {
                    return "Collab Requests"
                }
                else {
                    return "Upcoming Collabs"
                }
            }
        }
        
        else {
            if collabObjectArray.count > 0 {
                return sectionDateArray[section]
            }
            else {
                return "Upcoming Collabs"
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if pendingCollabObjectArray.count > 0 {
            if section == 0 {
                return pendingCollabObjectArray.count
            }
            else {
                
                if collabObjectArray.count > 0 {
                    
                    if let sectionCount = sectionContentArray?[section - 1].count {
                        return sectionCount
                    }
                    else {
                        return 0
                    }
                }
                
                else {
                    return 1
                }
            }
        }
        
        else {
            
            if collabObjectArray.count > 0 {
                
                print("sectionContent :", sectionContentArray)
                
                if let sectionCount = sectionContentArray?[section].count {
                    print("sectionCount: ", sectionCount)
//                    print(sectionContentArray![section])
                    return sectionCount
                }
                else {
                    return 0
                }
            }
            else {
                
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if pendingCollabObjectArray.count > 0 {

            if indexPath.section == 0 {

                let collaboratorName = pendingCollabObjectArray[indexPath.row].collaborator!["firstName"]! + " " + pendingCollabObjectArray[indexPath.row].collaborator!["lastName"]!
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

                cell.textLabel!.text = pendingCollabObjectArray[indexPath.row].collabName + " with " + collaboratorName
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                cell.isUserInteractionEnabled = true
                
                return cell
            }

            else {

                if collabObjectArray.count > 0 {
                
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCollabCell", for: indexPath) as! UpcomingCollabTableCell

                    let collabWithText = sectionContentArray![indexPath.section - 1][indexPath.row].collaborator!["firstName"]! + " " + sectionContentArray![indexPath.section - 1][indexPath.row].collaborator!["lastName"]!

                    cell.collabWithLabel.text = "Collab with " + collabWithText
                    cell.collabNameLabel.text = sectionContentArray![indexPath.section - 1][indexPath.row].collabName

                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    cell.textLabel?.text = "You have no Upcoming Collabs"
                    cell.isUserInteractionEnabled = false
                    return cell
                }
            }
        }
        else {
            
            if collabObjectArray.count > 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCollabCell", for: indexPath) as! UpcomingCollabTableCell
                
                let collabWithText = sectionContentArray![indexPath.section][indexPath.row].collaborator!["firstName"]! + " " + sectionContentArray![indexPath.section][indexPath.row].collaborator!["lastName"]!
                
                cell.collabWithLabel.text = "Collab with " + collabWithText
                cell.collabNameLabel.text = sectionContentArray![indexPath.section][indexPath.row].collabName
                
                return cell
            }
                
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "You have no Upcoming Collabs"
                cell.isUserInteractionEnabled = false
                return cell
            }

        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if pendingCollabObjectArray.count > 0 {
            
            if indexPath.section == 0 {
                return 45
            }
            else {
                return 105
            }
        }
        else {
            return 105
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if pendingCollabObjectArray.count > 0 {
            
            if indexPath.section == 0 {
                presentRequestAlert(indexPath.row)
            }
            else {
              performSegue(withIdentifier: "moveToCollabBlockView", sender: self)
            }
        }
        else {
            performSegue(withIdentifier: "moveToCollabBlockView", sender: self)
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchCollabs(searchBar)
    }
    
    func searchCollabs (_ searchBar: UISearchBar) {
        
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
            
            var count: Int = -1
            
            for collabArray in sectionContentArray! {
                
                for collab in collabArray {
                    
                    if collab.collabName.localizedCaseInsensitiveContains(searchBar.text!) {
                        if filteredSectionDates.contains(collab.collabDate) == false {
                            
                            filteredSectionDates.append(collab.collabDate)
                            
                            filteredSectionContent.append([collab])
                            count += 1
                        }
                        else {
                            filteredSectionContent[count].append(collab)
                        }
                        
                    }
                    
                    else if collab.collaborator!["firstName"]!.localizedCaseInsensitiveContains(searchBar.text!) == true {
                        if filteredSectionDates.contains(collab.collabDate) == false {
                            
                            filteredSectionDates.append(collab.collabDate)
                            
                            filteredSectionContent.append([collab])
                            count += 1
                        }
                        else {

                            filteredSectionContent[count].append(collab)
                        }
                        
                    }
                    
                    else if collab.collaborator!["lastName"]!.localizedCaseInsensitiveContains(searchBar.text!) == true {
                        if filteredSectionDates.contains(collab.collabDate) == false {
                            
                            filteredSectionDates.append(collab.collabDate)
                            
                            filteredSectionContent.append([collab])
                            count += 1
                        }
                        else {
                            filteredSectionContent[count].append(collab)
                        }
                        
                    }
                    
                }
                
                
                
            }
            
            sectionDateArray = filteredSectionDates
            sectionContentArray = filteredSectionContent
            upcomingCollabTableView.reloadData()
            
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
                currentUser.firstName = snapshot?.data()!["firstName"] as! String
                currentUser.lastName = snapshot?.data()!["lastName"] as! String
                currentUser.username = snapshot?.data()!["username"] as! String
                
                completion()
                
                }
            }
    }
    
    func getCollabs () {
        
        collabObjectArray.removeAll()
        
        formatter.dateFormat = "MMMM dd, yyyy"
        
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
                    
                    //self.collabObjectArray = self.collabObjectArray.sorted(by: {$0.collabDate < $1.collabDate})
                    self.collabObjectArray = self.collabObjectArray.sorted(by: {self.formatter.date(from: $0.collabDate)! < self.formatter.date(from: $1.collabDate)!})
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
    
    func getCollabRequests () {
        
        pendingCollabObjectArray.removeAll()
        
        db.collection("Users").document(currentUser.userID).collection("PendingCollabs").getDocuments { (snapshot, error) in
            
            if error != nil {
                print (error as Any)
            }
            
            else {
                
                if snapshot?.isEmpty == true {
                    print("no upcoming collabs")
                }
                else {
                    
                    for document in snapshot!.documents {
                        
                        let pendingCollab = PendingCollab()
                        
                        print(document.data())
                        
                        pendingCollab.collabID = document.data()["collabID"] as! String
                        pendingCollab.collabName = document.data()["collabName"] as! String
                        pendingCollab.collabDate = document.data()["collabDate"] as! String
                        pendingCollab.collaborator = (document.data()["with"] as! [String : String])
                        
                        self.pendingCollabObjectArray.append(pendingCollab)
                    }
                    self.pendingCollabObjectArray = self.pendingCollabObjectArray.sorted(by: {$0.collabDate < $1.collabDate})
                    self.upcomingCollabTableView.reloadData()
                }
            }
        }
        ProgressHUD.dismiss()
        
    }
    
    func addHistoricCollabs (completion: @escaping () -> ()) {
        
        formatter.dateFormat = "MMMM dd, yyyy"
        
        let currentDate: Date = formatter.date(from: formatter.string(from: Date()))!
        
        db.collection("Users").document(currentUser.userID).collection("UpcomingCollabs").getDocuments { (snapshot, error) in
            
            if error != nil {
                print (error as Any)
            }
            
            else {
                
                if snapshot?.isEmpty == true {
                    print ("no collabs")
                }
                else {
                    
                    for document in snapshot!.documents {
                        
                        var collabData: [String : Any] = [:]
                        
                        collabData["collabID"] = document.data()["collabID"] as! String
                        collabData["collabName"] = document.data()["collabName"] as! String
                        collabData["collabDate"] = document.data()["collabDate"] as! String
                        collabData["with"] = (document.data()["with"] as! [String : String])
                        
                        if self.formatter.date(from: collabData["collabDate"] as! String)! < currentDate {
                            
                            self.db.collection("Users").document(self.currentUser.userID).collection("CollabHistory").document(collabData["collabID"] as! String).setData(collabData)
                            
                            self.db.collection("Users").document(self.currentUser.userID).collection("UpcomingCollabs").document(collabData["collabID"] as! String).delete()
                            
                        }
                    }
                }
                completion()
            }
        }
    }
    
    func presentRequestAlert (_ selectedRequest: Int) {
        
        let handleRequestAlert = UIAlertController(title: "Collab Request", message: "Would you like to accept or decline this request?", preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { (acceptAction) in
            self.acceptRequest(selectedRequest)
            print("accepted")
        }
        
        let declineAction = UIAlertAction(title: "Decline", style: .destructive) { (declineAction) in
            self.declineRequest(selectedRequest)
            print("decline")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        handleRequestAlert.addAction(acceptAction)
        handleRequestAlert.addAction(declineAction)
        handleRequestAlert.addAction(cancelAction)
        
        present(handleRequestAlert, animated: true, completion: nil)
    }
    
    func acceptRequest (_ selectedRequest: Int) {
   
        let newCollab: [String : Any] = ["collabID" : pendingCollabObjectArray[selectedRequest].collabID, "collabName" : pendingCollabObjectArray[selectedRequest].collabName, "collabDate" : pendingCollabObjectArray[selectedRequest].collabDate, "with" : pendingCollabObjectArray[selectedRequest].collaborator as Any]
        
        
        db.collection("Users").document(currentUser.userID).collection("UpcomingCollabs").document(pendingCollabObjectArray[selectedRequest].collabID).setData(newCollab)
        
        db.collection("Users").document(currentUser.userID).collection("PendingCollabs").document(pendingCollabObjectArray[selectedRequest].collabID).delete()
        
        getCollabRequests()
        getCollabs()
        
    }
    
    func declineRequest (_ selectedRequest: Int) {
        
        db.collection("Users").document(currentUser.userID).collection("PendingCollabs").document(pendingCollabObjectArray[selectedRequest].collabID).delete()
        
        getCollabRequests()
        getCollabs()
        
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        addHistoricCollabs(completion: {
            self.getCollabs()
            self.getCollabRequests()

        })
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
                    self.addHistoricCollabs(completion: {
                        self.getCollabs()
                        self.getCollabRequests()
                        
                    })
                })
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

