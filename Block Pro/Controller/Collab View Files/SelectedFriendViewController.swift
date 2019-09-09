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

//
protocol ReconfigureCell {

    func reconfigureCell ()
}

class SelectedFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet weak var friendView: UIView!
    @IBOutlet weak var friendViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var friendViewBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var friendViewLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var friendViewTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var initialContainer: UIView!
    
    @IBOutlet weak var initialLabel: UILabel!
    
    @IBOutlet weak var initialLabelBottonAnchor: NSLayoutConstraint!
    @IBOutlet weak var initialLabelWidthConstraint: NSLayoutConstraint! // change name
    @IBOutlet weak var initialLabelHeightConstraint: NSLayoutConstraint! // change name
    
    @IBOutlet weak var friendNameContainer: UIView!
    @IBOutlet weak var friendName: UILabel!
    
    @IBOutlet weak var newCollabButton: UIButton!
    @IBOutlet weak var newCollabTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var newCollabLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var newCollabTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var upcomingButtonTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var upcomingButtonLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var upcomingButtonTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var historyButtonTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var historyButtonLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var historyButtonTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var deleteFriendButton: UIButton!
    @IBOutlet weak var deleteFriendTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var deleteFriendLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var deleteFriendTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var dismissGestureView: UIView!
    @IBOutlet weak var dismissViewTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var dismissIndicator: UIButton!
//    @IBOutlet weak var dismissIndicatorTopAnchor: NSLayoutConstraint!
//    @IBOutlet weak var dismissIndicatorHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var dismissIndicatorWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var upcoming_historyTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var exitButton: UIButton!
    
    var db = Firestore.firestore()
    
    let formatter = DateFormatter()
    
    let currentUser = UserData.singletonUser
    
    var selectedFriend: Friend?
    
    var collabObjectArray: [UpcomingCollab] = [UpcomingCollab]()
    var sectionDateArray: [String] = [String]()
    var sectionContentArray: [[UpcomingCollab]]?

    var tableViewPresentedHeight: CGFloat!
    var tableViewIndicator: String = ""
    
    var collabBlocksDelegate: CollabView?
    var reconfigureCellDelegate: ReconfigureCell?
    
    var gradientLayer: CAGradientLayer!
    var gradientLayer2: CAGradientLayer!
    
    var timer: Timer?
    
    var dismissViewOrigin: CGPoint! //Variable that holds the original position of the "dismissView"
    
    var dismissIndicatorHidden: CGRect!
    var dismissIndicatorExpanded: CGRect!
    var dismissIndicatorShrunk: CGRect!
    
    var tableViewOrigin: CGPoint! //Variable that holds the original position of the "tableView"
    
    var pan: UIPanGestureRecognizer? //Initialization of the pan gesture
    var animateButtonTracker: Bool = true
    var animateDown: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        upcoming_historyTableView.delegate = self
        upcoming_historyTableView.dataSource = self
        upcoming_historyTableView.register(UINib(nibName: "UpcomingCollabTableCell", bundle: nil), forCellReuseIdentifier: "UpcomingCollabCell")
        
        //upcoming_historyTableView.frame = CGRect(x: 0, y: 550, width: 306, height: 370)
        
        upcoming_historyTableView.rowHeight = 80
        
        friendView.layer.cornerRadius = 0.1 * friendView.bounds.size.width
        friendView.clipsToBounds = true
        
        //newCollabButton.backgroundColor = UIColor(hexString: "#e35d5b")?.lighten(byPercentage: 0.05)
        newCollabButton.backgroundColor = UIColor(hexString: "#e53935")?.lighten(byPercentage: 0.05)
        newCollabButton.layer.cornerRadius = 0.06 * newCollabButton.bounds.size.width
        newCollabButton.clipsToBounds = true
        
        upcomingButton.backgroundColor = UIColor(hexString: "#e53935")?.lighten(byPercentage: 0.05)
        upcomingButton.layer.cornerRadius = 0.06 * upcomingButton.bounds.size.width
        upcomingButton.clipsToBounds = true
        
        historyButton.backgroundColor = UIColor(hexString: "#e53935")?.lighten(byPercentage: 0.05)
        historyButton.layer.cornerRadius = 0.06 * historyButton.bounds.size.width
        historyButton.clipsToBounds = true
        
        deleteFriendButton.backgroundColor = UIColor(hexString: "#e53935")?.lighten(byPercentage: 0.05)
        deleteFriendButton.layer.cornerRadius = 0.06 * deleteFriendButton.bounds.size.width
        deleteFriendButton.clipsToBounds = true
        
        //dismissGestureView.frame.origin.y = 525
        
        exitButton.layer.cornerRadius = 0.5 * exitButton.bounds.size.width
        exitButton.clipsToBounds = true
        
        //self.view.bringSubviewToFront(dismissIndicator)
        //dismissIndicator.isEnabled = false
        
//        addPanGesture(view: dismissGestureView) //Function that adds the pan gesture to the "dismissGestureView"
        
        #warning("make sure you put this in a guard let or if let statment")
        let firstNameArray = Array(selectedFriend!.firstName)
        initialLabel.text = "\(firstNameArray[0])"
        friendName.text = selectedFriend!.firstName + " " + selectedFriend!.lastName
        
        //self.view.insertSubview(initialContainer, at: 0)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 344, height: 73)//friendNameContainer.bounds
        gradientLayer.colors = [UIColor(hexString: "#e35d5b")?.cgColor as Any, UIColor(hexString: "#e53935")?.cgColor as Any]
        gradientLayer.locations = [0.0, 0.7]
        
        friendNameContainer.layer.addSublayer(gradientLayer)
        friendNameContainer.bringSubviewToFront(friendName)
        
        gradientLayer2 = CAGradientLayer()
        
        gradientLayer2.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        gradientLayer2.colors = [UIColor(hexString: "#e35d5b")?.cgColor as Any, UIColor(hexString: "#e53935")?.cgColor as Any]
        
        
        //initialContainer.layer.addSublayer(gradientLayer2)
        initialContainer.backgroundColor = UIColor(hexString: "#e35d5b")
        
        initialContainer.layer.cornerRadius = 0.5 * initialContainer.bounds.width
        
        initialLabel.layer.cornerRadius = 0.5 * initialLabel.bounds.width
        initialLabel.clipsToBounds = true
        
        initialLabelBottonAnchor.constant = -38
        initialLabelWidthConstraint.constant = 0
        initialLabelHeightConstraint.constant = 0
        
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {

//        UIView.animate(withDuration: 0.5) {
//            self.initialLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1) //Scale label area
//        }
        
        initialLabelBottonAnchor.constant = -76
        initialLabelWidthConstraint.constant = 72
        initialLabelHeightConstraint.constant = 72

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.initialLabel.font = UIFont(name: ".SFUIDisplay", size: 30)
        }
    }
    
    func configureConstraints () {
        
        friendView.sendSubviewToBack(dismissIndicator)
        friendView.sendSubviewToBack(upcoming_historyTableView)
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            friendViewBottomAnchor.constant = 200
            
            newCollabTopAnchor.constant = 85
            upcomingButtonTopAnchor.constant = 50
            historyButtonTopAnchor.constant = 50
            deleteFriendTopAnchor.constant = 50
            
            tableViewHeightConstraint.constant = 0
            tableViewPresentedHeight = 417.5
            
            dismissIndicator.frame = CGRect(x: 172, y: 75, width: 0, height: 0)
            
            dismissIndicatorHidden = CGRect(x: 172, y: 75, width: 0, height: 0)
            dismissIndicatorExpanded = CGRect(x: 120, y: 75, width: 105, height: 35)
            dismissIndicatorShrunk = CGRect(x: 152, y: 95, width: 40, height: 30)
            
        }
            
        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {
            
            friendViewTopAnchor.constant = 100
            friendViewBottomAnchor.constant = 125
            
            newCollabTopAnchor.constant = 75
            upcomingButtonTopAnchor.constant = 45
            historyButtonTopAnchor.constant = 45
            deleteFriendTopAnchor.constant = 45
            
            tableViewHeightConstraint.constant = 0
            tableViewPresentedHeight = 387.5
            
            dismissIndicator.frame = CGRect(x: 172, y: 75, width: 0, height: 0)
            
            dismissIndicatorHidden = CGRect(x: 172, y: 75, width: 0, height: 0)
            dismissIndicatorExpanded = CGRect(x: 120, y: 75, width: 105, height: 35)
            dismissIndicatorShrunk = CGRect(x: 152, y: 95, width: 40, height: 30)
            
        }
            
        //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            upcomingButtonTopAnchor.constant = 45
            historyButtonTopAnchor.constant = 45
            deleteFriendTopAnchor.constant = 45
            
            tableViewHeightConstraint.constant = 0
            tableViewPresentedHeight = 377.5
            
            dismissIndicator.frame = CGRect(x: 152.67, y: 75, width: 0, height: 0)
            
            dismissIndicatorHidden = CGRect(x: 152.67, y: 75, width: 0, height: 0)
            dismissIndicatorExpanded = CGRect(x: 100, y: 75, width: 105, height: 35)
            dismissIndicatorShrunk = CGRect(x: 132, y: 95, width: 40, height: 30)
            
        }
            
        //iPhone 8
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0{
            
            friendViewTopAnchor.constant = 100
            friendViewBottomAnchor.constant = 100
            
            newCollabTopAnchor.constant = 65
            upcomingButtonTopAnchor.constant = 37.5
            historyButtonTopAnchor.constant = 37.5
            deleteFriendTopAnchor.constant = 37.5
            
            tableViewHeightConstraint.constant = 0
            tableViewPresentedHeight = 345
            
            dismissIndicator.frame = CGRect(x: 152.67, y: 75, width: 0, height: 0)
            
            dismissIndicatorHidden = CGRect(x: 152.67, y: 75, width: 0, height: 0)
            dismissIndicatorExpanded = CGRect(x: 100, y: 75, width: 105, height: 35)
            dismissIndicatorShrunk = CGRect(x: 132, y: 95, width: 40, height: 30)
            
        }
            
        //iPhone SE
        else if UIScreen.main.bounds.width == 320.0 {
 
            friendViewTopAnchor.constant = 75
            friendViewBottomAnchor.constant = 75
            friendViewLeadingAnchor.constant = 20
            friendViewTrailingAnchor.constant = 20
            
            dismissIndicator.isHidden = true
            
            newCollabTopAnchor.constant = 43.5
            upcomingButtonTopAnchor.constant = 37.5
            historyButtonTopAnchor.constant = 37.5
            deleteFriendTopAnchor.constant = 37.5
            
            tableViewHeightConstraint.constant = 0
            tableViewPresentedHeight = 297.5
            
            dismissIndicator.frame = CGRect(x: 140, y: 75, width: 0, height: 0)
            
            dismissIndicatorHidden = CGRect(x: 140, y: 75, width: 0, height: 0)
            dismissIndicatorExpanded = CGRect(x: 88, y: 75, width: 105, height: 35)
            dismissIndicatorShrunk = CGRect(x: 120, y: 95, width: 40, height: 30)
        }
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
            
            let collabWithText = sectionContentArray![indexPath.section][indexPath.row].collaborator!["firstName"]! + " " + sectionContentArray![indexPath.section][indexPath.row].collaborator!["lastName"]!
            
            cell.collabWithLabel.text = "Collab with " + collabWithText
            cell.collabNameLabel.text = sectionContentArray![indexPath.section][indexPath.row].collabName
            
            reconfigureCollabCell(cell: cell)
            
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
        
        reconfigureCellDelegate?.reconfigureCell()
        
    }
    
    func reconfigureCollabCell (cell: UpcomingCollabTableCell) {
        
        cell.withLabelTopAnchor.constant = 5
        
        cell.seperatorViewTopAnchor.constant = 1.5
        
        cell.nameLabelTopAnchor.constant = 7
        cell.nameLabelBottomAnchor.constant = 7
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

        //friendDeletedDelegate?.reloadFriends()
        
        dismiss(animated: true) {
            ProgressHUD.showSuccess(self.selectedFriend!.firstName + " " + self.selectedFriend!.lastName + " has been deleted")
        }
        
    }
    
    func addPanGesture (view: UIView) {
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))) //Initialization of the pan gesture
        
        view.addGestureRecognizer(pan!) //Adds the pan gesture to the view that was passed in
    }
    
    @objc func handlePan (sender: UIPanGestureRecognizer) {
        
        let dismissView = sender.view!
        
        switch sender.state {
            
        //Case that handles when the gesture begins and changes
        case .began, .changed:
            
            moveViewWithPan(dismissView: dismissView, dismissIndicator: dismissIndicator, tableView: upcoming_historyTableView, sender: sender)
            
        //Case that handles when the gesture has ended
        case .ended:
            
            //If the dimissIndicator has reached a certain point when the gesture ends, dismiss it along with the "dismissView", and the tableView
//            if dismissIndicator.frame.origin.y >= 250 {
            if dismissIndicator.frame.origin.y >= friendView.frame.height / 2 {
            
                self.dismissView(dismissView: dismissView, dismissIndicator: dismissIndicator, tableView: upcoming_historyTableView)
            }
            
                //Otherwise, return them to their origin point
            else {
                returnViewToOrigin(dismissView: dismissView, dismissIndicator: dismissIndicator, tableView: upcoming_historyTableView)
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
            
            self.dismissGestureView.frame.origin = self.dismissViewOrigin
            self.dismissIndicator.frame = self.dismissIndicatorExpanded
            self.upcoming_historyTableView.frame.origin = self.tableViewOrigin
            
        }) { (finished: Bool) in
            
            print("origin", self.dismissIndicator.frame.origin)
            
            RunLoop.main.add(self.timer!, forMode: .common)
        }
    }
    
    //Function that dismisses the views
    func dismissView (dismissView: UIView, dismissIndicator: UIView, tableView: UIView) {
        
        tableViewHeightConstraint.constant = 0
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.view.layoutIfNeeded()
            
            dismissIndicator.frame.origin.y = 550//CGRect(x: 103, y: 500, width: 100, height: 35)
            
        }) { (finished: Bool) in
            
            
            
            self.newCollabLeadingAnchor.constant = 23
            self.newCollabTrailingAnchor.constant = 23
            
            self.upcomingButtonLeadingAnchor.constant = 23
            self.upcomingButtonTrailingAnchor.constant = 23
            
            self.historyButtonLeadingAnchor.constant = 23
            self.historyButtonTrailingAnchor.constant = 23
            
            self.deleteFriendLeadingAnchor.constant = 23
            self.deleteFriendTrailingAnchor.constant = 23
            
            self.dismissIndicator.isHidden = true
            
            UIView.animate(withDuration: 0.2) {
                
                self.view.layoutIfNeeded()
                
                self.dismissIndicator.frame = self.dismissIndicatorHidden
            }
        }
        
        //Ending the timer and the animations
        animateButtonTracker = false
        animateDown = true
        timer?.invalidate()
        
        removePanGesture(view: dismissView)
    }
    
    func removePanGesture (view: UIView) {
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))) //Initialization of the pan gesture
        
        view.removeGestureRecognizer(pan!)
    }
    
    
    @objc func animateDismissButton (timer: Timer) {

        print("check")
        if animateButtonTracker == true {
            
            if animateDown == true {
                
                UIView.animate(withDuration: 2, animations: {
                    
                    self.dismissIndicator.frame = self.dismissIndicatorShrunk
                    
                }) { (finished: Bool) in

                    self.animateDown = false
                }
            }
            
            else if animateDown == false {
                
                UIView.animate(withDuration: 2, animations: {
                    
                    self.dismissIndicator.frame = self.dismissIndicatorExpanded
                    
                }) { (finished: Bool) in
                    
                    self.animateDown = true
                }
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
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))) //Initialization of the pan gesture
        addPanGesture(view: dismissGestureView) //Function that adds the pan gesture to the "dismissGestureView"
        
        //dismissTableViewButton.isEnabled = true
        
        newCollabLeadingAnchor.constant = 423
        newCollabTrailingAnchor.constant = -377

        upcomingButtonLeadingAnchor.constant = -377
        upcomingButtonTrailingAnchor.constant = 423

        historyButtonLeadingAnchor.constant = 423
        historyButtonTrailingAnchor.constant = -377

        deleteFriendLeadingAnchor.constant = -377
        deleteFriendTrailingAnchor.constant = 423
        
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.friendView.layoutIfNeeded()
            
            
        }) { (finished: Bool) in
            
            self.tableViewHeightConstraint.constant = self.tableViewPresentedHeight
            self.dismissIndicator.isHidden = false
            
            UIView.animate(withDuration: 0.2, animations: {
            
                self.friendView.layoutIfNeeded()
                self.dismissIndicator.frame = self.dismissIndicatorExpanded
                
//                self.dismissGestureView.frame.origin.y = 75
//                self.dismissIndicator.frame.origin.y = 80
//                self.upcoming_historyTableView.frame = CGRect(x: 0, y: 130, width: 306, height: 370)
                
            }, completion: { (finished: Bool) in
                
                self.tableViewOrigin = self.upcoming_historyTableView.frame.origin
                self.dismissViewOrigin = self.dismissGestureView.frame.origin
                
                RunLoop.main.add(self.timer!, forMode: .common)
            })
        }
    }
    
    @IBAction func historyButton(_ sender: Any) {
        
        getHistoricCollabs()
        tableViewIndicator = "history"
        
        let date = Date()
        timer = Timer(fireAt: date, interval: 3, target: self, selector: #selector(self.animateDismissButton), userInfo: nil, repeats: true)
        animateButtonTracker = true
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))) //Initialization of the pan gesture
        addPanGesture(view: dismissGestureView) //Function that adds the pan gesture to the "dismissGestureView"
        
        //dismissTableViewButton.isEnabled = true
        
        newCollabLeadingAnchor.constant = 423
        newCollabTrailingAnchor.constant = -377
        
        upcomingButtonLeadingAnchor.constant = -377
        upcomingButtonTrailingAnchor.constant = 423
        
        historyButtonLeadingAnchor.constant = 423
        historyButtonTrailingAnchor.constant = -377
        
        deleteFriendLeadingAnchor.constant = -377
        deleteFriendTrailingAnchor.constant = 423
        
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.friendView.layoutIfNeeded()
            
            
        }) { (finished: Bool) in
            
            self.tableViewHeightConstraint.constant = self.tableViewPresentedHeight
            self.dismissIndicator.isHidden = false
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.friendView.layoutIfNeeded()
                self.dismissIndicator.frame = self.dismissIndicatorExpanded
                
                //                self.dismissGestureView.frame.origin.y = 75
                //                self.dismissIndicator.frame.origin.y = 80
                //                self.upcoming_historyTableView.frame = CGRect(x: 0, y: 130, width: 306, height: 370)
                
            }, completion: { (finished: Bool) in
                
                self.tableViewOrigin = self.upcoming_historyTableView.frame.origin
                self.dismissViewOrigin = self.dismissGestureView.frame.origin
                
                RunLoop.main.add(self.timer!, forMode: .common)
            })
        }
    }
    
    @IBAction func deleteFriendButton (_ sender: Any) {
        
        presentDeleteAlert()
    }
    
    
    @IBAction func newCollabButton(_ sender: Any) {
        
        performSegue(withIdentifier: "moveToCreateCollab", sender: self)
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        
        animateButtonTracker = false
        timer?.invalidate()
        
        dismiss(animated: true, completion: nil)
        
        self.reconfigureCellDelegate?.reconfigureCell()
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
        reconfigureCellDelegate?.reconfigureCell()
    }
    
}



