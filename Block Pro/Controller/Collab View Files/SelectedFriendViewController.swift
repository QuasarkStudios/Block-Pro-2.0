//
//  SelectedFriendViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/8/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

//Protocol neccasary to move user to Collab Blocks view
protocol CollabView {
    
    func performSegue (_ collabID: String, _ collabName: String, _ collabDate: String)
}

//Protocol required to delete a friend
protocol FriendDeleted {
    
    func reloadFriends ()
}

class SelectedFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var upcoming_historyTableView: UITableView!
    
    @IBOutlet weak var friendView: UIView!
    @IBOutlet weak var friendNameContainer: UIView!
    @IBOutlet weak var friendName: UILabel!
    
    @IBOutlet weak var newCollabButton: UIButton!
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var deleteFriendButton: UIButton!
    
    @IBOutlet weak var dismissTableViewIndicator: UIButton!
    @IBOutlet weak var dismissGestureView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    
    var db = Firestore.firestore()
    
    let formatter = DateFormatter()
    
    let currentUser = UserData.singletonUser
    
    var selectedFriend: Friend?
    
    var collabObjectArray: [UpcomingCollab] = [UpcomingCollab]()
    var sectionDateArray: [String] = [String]()
    var sectionContentArray: [[UpcomingCollab]]?

    var tableViewIndicator: String = ""
    
    var collabBlocksDelegate: CollabView?
    var friendDeletedDelegate: FriendDeleted?
    
    var gradientLayer: CAGradientLayer!
    
    var timer: Timer?
    
    var dismissViewOrigin: CGPoint! //Variable that holds the original position of the "dismissView"
    var dismissIndicatorOrigin: CGPoint! //Variable that holds the original position of the "dismissIndicator"
    var tableViewOrigin: CGPoint! //Variable that holds the original position of the "tableView"
    
    var animateButtonTracker: Bool = true
    var animateDown: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        upcoming_historyTableView.delegate = self
        upcoming_historyTableView.dataSource = self
        upcoming_historyTableView.register(UINib(nibName: "UpcomingCollabTableCell", bundle: nil), forCellReuseIdentifier: "UpcomingCollabCell")
        
        upcoming_historyTableView.frame = CGRect(x: 0, y: 550, width: 306, height: 370)
        
        upcoming_historyTableView.rowHeight = 80
        
        friendView.layer.cornerRadius = 0.1 * friendView.bounds.size.width
        friendView.clipsToBounds = true
        
        newCollabButton.backgroundColor = UIColor(hexString: "#e35d5b")?.lighten(byPercentage: 0.05)
        newCollabButton.layer.cornerRadius = 0.068 * newCollabButton.bounds.size.width
        newCollabButton.clipsToBounds = true
        
        upcomingButton.backgroundColor = UIColor(hexString: "#e35d5b")?.lighten(byPercentage: 0.05)
        upcomingButton.layer.cornerRadius = 0.068 * upcomingButton.bounds.size.width
        upcomingButton.clipsToBounds = true
        
        historyButton.backgroundColor = UIColor(hexString: "#e35d5b")?.lighten(byPercentage: 0.05)
        historyButton.layer.cornerRadius = 0.068 * historyButton.bounds.size.width
        historyButton.clipsToBounds = true
        
        deleteFriendButton.backgroundColor = UIColor(hexString: "#e35d5b")?.lighten(byPercentage: 0.05)
        deleteFriendButton.layer.cornerRadius = 0.068 * deleteFriendButton.bounds.size.width
        deleteFriendButton.clipsToBounds = true
        
        dismissTableViewIndicator.frame.origin.y = 525
        
        exitButton.layer.cornerRadius = 0.5 * exitButton.bounds.size.width
        exitButton.clipsToBounds = true
        
        addPanGesture(view: dismissGestureView) //Function that adds the pan gesture to the "dismissGestureView"
        
        friendName.text = selectedFriend!.firstName + " " + selectedFriend!.lastName

        gradientLayer = CAGradientLayer()
        gradientLayer.frame = friendNameContainer.bounds
        gradientLayer.colors = [UIColor(hexString: "#e35d5b")?.cgColor as Any, UIColor(hexString: "#e53935")?.cgColor as Any]
        
        friendNameContainer.layer.addSublayer(gradientLayer)
        friendNameContainer.bringSubviewToFront(friendName)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if sectionDateArray.count > 0 {
            return sectionDateArray.count
        }
        else {
            return 1
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if sectionDateArray.count > 0 {
            return sectionDateArray[section]
        }
        else {
            
            if tableViewIndicator == "upcoming" {
                return "Upcoming Collabs"
            }
            else if tableViewIndicator == "history" {
                return "Historic Collabs"
            }
            else {
                return nil
            }
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sectionDateArray.count > 0 {
            
            guard let sectionContent = sectionContentArray?[section] else { return 0 }
            
                return sectionContent.count
        }
        
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if sectionDateArray.count > 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCollabCell", for: indexPath) as! UpcomingCollabTableCell
            
            reconfigureCollabCell(cell: cell)
            
            let collabWithText = sectionContentArray![indexPath.section][indexPath.row].collaborator!["firstName"]! + " " + sectionContentArray![indexPath.section][indexPath.row].collaborator!["lastName"]!
            
            cell.collabWithLabel.text = "Collab with " + collabWithText
            cell.collabNameLabel.text = sectionContentArray![indexPath.section][indexPath.row].collabName
            
            return cell
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            if tableViewIndicator == "upcoming" {
                cell.textLabel!.text = "No Upcoming Collabs"
            }
            else if tableViewIndicator == "history" {
                cell.textLabel!.text = "No Historic Collabs"
            }
            
            cell.isUserInteractionEnabled = false
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        animateButtonTracker = false
        timer?.invalidate()
        
        dismiss(animated: true) { 
            
            guard let collabData = self.sectionContentArray?[indexPath.section][indexPath.row] else { return }
            
                self.collabBlocksDelegate?.performSegue(collabData.collabID, collabData.collabName, collabData.collabDate)
            
        }
        
    }
    
    func reconfigureCollabCell (cell: UpcomingCollabTableCell) {
        
        cell.collabContainer.frame = CGRect(x: 5, y: 5, width: 296, height: 70)
        
        cell.collabWithLabel.frame.origin.y = 8
        cell.collabWithLabel.font = UIFont(name: ".SFUIText-Bold", size: 13)
        cell.collabWithLabel.adjustsFontSizeToFitWidth = true
        
        cell.seperatorView.frame.origin.y = 32
        
        cell.collabNameLabel.frame.origin.y = 32
        cell.collabNameLabel.font = UIFont(name: ".SFUIText-Bold", size: 20)
        cell.collabNameLabel.adjustsFontSizeToFitWidth = true
    }
    
    func getUpcomingCollabs () {
        
        collabObjectArray.removeAll()
        
        formatter.dateFormat = "MMMM dd, yyyy"
        
        db.collection("Users").document(currentUser.userID).collection("UpcomingCollabs").whereField("with.userID", isEqualTo: selectedFriend!.friendID).getDocuments { (snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            
            else {
                if snapshot!.isEmpty {
                    print ("no collabs")
                    
                    self.sectionDateArray.removeAll()
                    self.sectionContentArray?.removeAll()
                    self.upcoming_historyTableView.reloadData()
                }
                else {
                    
                    for document in snapshot!.documents {
                        
                        let upcomingCollab = UpcomingCollab()
                        
                        upcomingCollab.collabID = document.data()["collabID"] as! String
                        upcomingCollab.collabName = document.data()["collabName"] as! String
                        upcomingCollab.collabDate = document.data()["collabDate"] as! String
                        upcomingCollab.collaborator = (document.data()["with"] as! [String : String])
                        
                        self.collabObjectArray.append(upcomingCollab)
                    }
                    
                    self.collabObjectArray = self.collabObjectArray.sorted(by: {self.formatter.date(from: $0.collabDate)! < self.formatter.date(from: $1.collabDate)!})
                    self.sortCollabs()
                    self.upcoming_historyTableView.reloadData()
                    
                }
            }
            
        }
    }
    
    func getHistoricCollabs () {
        
        collabObjectArray.removeAll()
        
        formatter.dateFormat = "MMMM dd, yyyy"
        
        db.collection("Users").document(currentUser.userID).collection("CollabHistory").whereField("with.userID", isEqualTo: selectedFriend!.friendID).getDocuments { (snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    print ("damn")
                    
                    self.upcoming_historyTableView.reloadData()
                }
                else {
                    
                    for document in snapshot!.documents {
                    
                        let historicCollab = UpcomingCollab()
                        
                        historicCollab.collabID = document.data()["collabID"] as! String
                        historicCollab.collabName = document.data()["collabName"] as! String
                        historicCollab.collabDate = document.data()["collabDate"] as! String
                        historicCollab.collaborator = (document.data()["with"] as! [String : String])
                        
                        self.collabObjectArray.append(historicCollab)
                    }
                    
                    self.collabObjectArray = self.collabObjectArray.sorted(by: {self.formatter.date(from: $0.collabDate)! > self.formatter.date(from: $1.collabDate)!})
                    self.sortCollabs()
                    self.upcoming_historyTableView.reloadData()
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
        
    }
    
    func presentDeleteAlert () {
        
        let selectedFriendName: String = selectedFriend!.firstName + " " + selectedFriend!.lastName
        
        let deleteAlert = UIAlertController(title: "Delete " + selectedFriendName + "?", message: "All data with " + selectedFriendName + " will also be deleted", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (deleteAction) in
            
            self.deleteFriend(selectedFriendName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    func deleteFriend (_ selectedFriendName: String) {
        
        self.db.collection("Users").document(currentUser.userID).collection("Friends").document(selectedFriend!.friendID).delete()

        self.db.collection("Users").document(currentUser.userID).collection("PendingCollabs").whereField("with.userID", isEqualTo: selectedFriend!.friendID).getDocuments { (snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    print("no pending to delete")
                }
                
                else {
                    
                    for document in snapshot!.documents {
                        
                        let deletedPending = document.data()["collabID"] as! String
                        
                        self.db.collection("Users").document(self.currentUser.userID).collection("PendingCollabs").document(deletedPending).delete()
                    }
                }
            }
        }

        self.db.collection("Users").document(self.currentUser.userID).collection("UpcomingCollabs").whereField("with.userID", isEqualTo: selectedFriend!.friendID).getDocuments { (snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            
            else {
                
                if snapshot?.isEmpty == true {
                    print("no upcoming to delete")
                }
                else {
                    
                    for document in snapshot!.documents {
                        
                        let deletedUpcoming = document.data()["collabID"] as! String
                        
                        self.db.collection("Users").document(self.currentUser.userID).collection("UpcomingCollabs").document(deletedUpcoming).delete()
                    }
                }
            }
        }

        self.db.collection("Users").document(self.currentUser.userID).collection("CollabHistory").whereField("with.userID", isEqualTo: selectedFriend!.friendID).getDocuments { (snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    print("no history to delete")
                }
                
                else {
                    for document in snapshot!.documents {
                        
                        let deletedHistoric = document.data()["collabID"] as! String
                        
                        self.db.collection("Users").document(self.currentUser.userID).collection("CollabHistory").document(deletedHistoric).delete()
                    }
                }
            }
        }

        friendDeletedDelegate?.reloadFriends()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func addPanGesture (view: UIView) {
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))) //Initialization of the pan gesture
        
        view.addGestureRecognizer(pan) //Adds the pan gesture to the view that was passed in
    }
    
    @objc func handlePan (sender: UIPanGestureRecognizer) {
        
        let dismissView = sender.view!
        
        switch sender.state {
            
        //Case that handles when the gesture begins and changes
        case .began, .changed:
            
            moveViewWithPan(dismissView: dismissView, dismissIndicator: dismissTableViewIndicator, tableView: upcoming_historyTableView, sender: sender)
            
        //Case that handles when the gesture has ended
        case .ended:
            
            //If the dimissIndicator has reached a certain point when the gesture ends, dismiss it along with the "dismissView", and the tableView
            if dismissTableViewIndicator.frame.origin.y >= 250 {
                
                self.dismissView(dismissView: dismissView, dismissIndicator: dismissTableViewIndicator, tableView: upcoming_historyTableView)
            }
            
                //Otherwise, return them to their origin point
            else {
                returnViewToOrigin(dismissView: dismissView, dismissIndicator: dismissTableViewIndicator, tableView: upcoming_historyTableView)
            }
            
        default:
            break
        }
    }
    
    //Function that handles when the pan gesture is taking place
    func moveViewWithPan (dismissView: UIView, dismissIndicator: UIView, tableView: UIView, sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: friendView) //The translation of the pan gesture in the coordinate system of the specified view
        
        animateButtonTracker = false
        animateDown = true
        timer?.invalidate()
        
        dismissView.center = CGPoint(x: dismissView.center.x, y: dismissView.center.y + translation.y)
        dismissIndicator.center = CGPoint(x: dismissIndicator.center.x, y: dismissIndicator.center.y + translation.y)
        tableView.center = CGPoint(x: tableView.center.x, y: tableView.center.y + translation.y)
        
        sender.setTranslation(CGPoint.zero, in: friendView) //Sets the translation value in the coordinate system of the specified view
    }
    
    //Function that returns the views back to their origin point
    func returnViewToOrigin (dismissView: UIView, dismissIndicator: UIView, tableView: UIView) {
        
        //Restarting the timer and animation
        let date = Date()
        timer = Timer(fireAt: date, interval: 3, target: self, selector: #selector(self.animateDismissButton), userInfo: nil, repeats: true)
        animateButtonTracker = true
        
        UIView.animate(withDuration: 0.2, animations: {
            
            dismissView.frame.origin = self.dismissViewOrigin
            dismissIndicator.frame = CGRect(x: 103, y: 80, width: 100, height: 35)
            tableView.frame.origin = self.tableViewOrigin
            
        }) { (finished: Bool) in
            RunLoop.main.add(self.timer!, forMode: .common)
        }
    }
    
    //Function that dismisses the views
    func dismissView (dismissView: UIView, dismissIndicator: UIView, tableView: UIView) {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            
            dismissIndicator.frame = CGRect(x: 103, y: 500, width: 100, height: 35)
            tableView.frame.origin.y = 500
            
        }) { (finished: Bool) in
            UIView.animate(withDuration: 0.2) {
                
                self.newCollabButton.frame.origin.x = 23
                self.upcomingButton.frame.origin.x = 23
                self.historyButton.frame.origin.x = 23
                self.deleteFriendButton.frame.origin.x = 23
            }
        }
        
        //Ending the timer and the animations
        animateButtonTracker = false
        animateDown = true
        timer?.invalidate()
    }
    
    
    @objc func animateDismissButton (timer: Timer) {

        print("check")
        if animateButtonTracker == true {
            
            if animateDown == true {
                
                UIView.animate(withDuration: 2, animations: {

                    self.dismissTableViewIndicator.frame = CGRect(x: 133, y: 100, width: 40, height: 30)
                    //self.dismissTableViewButton.frame.origin.y = 100
                    
                }) { (finished: Bool) in
                    
                    self.animateDown = false
                }
                dismissIndicatorOrigin = CGPoint(x: 133, y: 100)
            }
            
            else if animateDown == false {
                
                UIView.animate(withDuration: 2, animations: {
                    
                    self.dismissTableViewIndicator.frame = CGRect(x: 103, y: 80, width: 100, height: 35)
                    //self.dismissTableViewButton.frame.origin.y = 80
                    
                }) { (finished: Bool) in
                    self.animateDown = true
                }
                dismissIndicatorOrigin = CGPoint(x: 103, y: 80)
            }
        }
        print(animateDown)
        
    }

    
    @IBAction func upcomingButton(_ sender: Any) {
        
        getUpcomingCollabs()
        tableViewIndicator = "upcoming"
        
        let date = Date()
        timer = Timer(fireAt: date, interval: 3, target: self, selector: #selector(self.animateDismissButton), userInfo: nil, repeats: true)
        animateButtonTracker = true
        
        //dismissTableViewButton.isEnabled = true
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.newCollabButton.frame.origin.x = -300
            self.upcomingButton.frame.origin.x = 415
            self.historyButton.frame.origin.x = -300
            self.deleteFriendButton.frame.origin.x = 415
            
        }) { (finished: Bool) in
            UIView.animate(withDuration: 0.2, animations: {
                
                self.dismissGestureView.frame.origin.y = 75
                self.dismissTableViewIndicator.frame.origin.y = 80
                self.upcoming_historyTableView.frame = CGRect(x: 0, y: 130, width: 306, height: 370)
            }, completion: { (finished: Bool) in
                RunLoop.main.add(self.timer!, forMode: .common)
            })
        }
        
        dismissViewOrigin = CGPoint(x: 8, y: 75)
        tableViewOrigin = CGPoint(x: 0, y: 130)
    }
    
    @IBAction func historyButton(_ sender: Any) {
        
        getHistoricCollabs()
        tableViewIndicator = "history"
        
        let date = Date()
        timer = Timer(fireAt: date, interval: 3, target: self, selector: #selector(self.animateDismissButton), userInfo: nil, repeats: true)
        animateButtonTracker = true
        
        //dismissTableViewButton.isEnabled = true
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.newCollabButton.frame.origin.x = -300
            self.upcomingButton.frame.origin.x = 415
            self.historyButton.frame.origin.x = -300
            self.deleteFriendButton.frame.origin.x = 415
            
        }) { (finished: Bool) in
            UIView.animate(withDuration: 0.2, animations: {
                
                self.dismissGestureView.frame.origin.y = 75
                self.dismissTableViewIndicator.frame.origin.y = 80
                self.upcoming_historyTableView.frame = CGRect(x: 0, y: 130, width: 306, height: 370)
                
            }, completion: { (finished: Bool) in
                RunLoop.main.add(self.timer!, forMode: .common)
                
            })
        }
        
        dismissViewOrigin = CGPoint(x: 8, y: 75)
        tableViewOrigin = CGPoint(x: 0, y: 130)
    }
    
    @IBAction func deleteFriendButton (_ sender: Any) {
        
        presentDeleteAlert()
    }
    
    
    @IBAction func newCollabButton(_ sender: Any) {
        
        performSegue(withIdentifier: "moveToCreateCollab", sender: self)
    }
    
    @IBAction func dismissTableViewButton(_ sender: Any) {
        

        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.dismissTableViewIndicator.frame = CGRect(x: 103, y: 525, width: 100, height: 35)
            self.upcoming_historyTableView.frame = CGRect(x: 0, y: 550, width: 306, height: 370)
            
        }) { (finished: Bool) in
            
            UIView.animate(withDuration: 0.2, animations: {
                self.newCollabButton.frame.origin.x = 23
                self.upcomingButton.frame.origin.x = 23
                self.historyButton.frame.origin.x = 23
                self.deleteFriendButton.frame.origin.x = 23
            })
        }
        
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        
        animateButtonTracker = false
        timer?.invalidate()
        
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToCreateCollab" {
            
            let createCollabView = segue.destination as! NewCollabViewController
            
            createCollabView.selectedFriend = selectedFriend
            createCollabView.dismissViewDelegate = self
        }
    }
    
}

extension SelectedFriendViewController: DismissView {
    
    func dismissSelectedFriend(_ collabID: String, _ collabName: String, _ collabDate: String) {
        
        dismiss(animated: true) {

            self.collabBlocksDelegate?.performSegue(collabID, collabName, collabDate)
        }
    }
    
}



