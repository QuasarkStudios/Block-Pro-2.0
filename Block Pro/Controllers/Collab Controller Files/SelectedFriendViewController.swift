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

//Protocol neccasary to animate the initialLabel of the selected friend
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
    
    @IBOutlet weak var initialLabelBottomAnchor: NSLayoutConstraint!
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
    
    @IBOutlet weak var dismissIndicator: UIButton!
    
    @IBOutlet weak var upcoming_historyTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var exitButton: UIButton!
    
    var db = Firestore.firestore()
    
    let formatter = DateFormatter()
    
    let currentUser = UserData.singletonUser
    
    var selectedFriend: Friend?
    
    var collabObjectArray: [UpcomingCollab] = [UpcomingCollab]() //Array that holds all the upcoming collabs retrieved from the database
    var sectionDateArray: [String] = [String]() //Array that holds all the dates for the upcoming collabs; used as section titles for the tableView
    var sectionContentArray: [[UpcomingCollab]]? //Array that holds which collabs should go into certain sections for the tableView

    var tableViewPresentedHeight: CGFloat! //Variable that holds the height constant for the tableView when it is presented
    var tableViewIndicator: String = "" //Variable used to track which tableView is being present and what data should be populated into the tableView
    
    var collabBlocksDelegate: CollabView? //Delegate used to move to the CollabViewController
    var reconfigureCellDelegate: ReconfigureCell? //Delegate used to reconfigure the initialLabel of the selected friend
    
    var gradientLayer: CAGradientLayer!
    
    var timer: Timer?
    
    var dismissViewOrigin: CGPoint! //Variable that holds the original position of the "dismissView"
    
    var dismissIndicatorHidden: CGRect! //Variable used to hold the location and dimensions of the indicator when it is hidden
    var dismissIndicatorExpanded: CGRect! //Variable used to hold the location and dimensions of the indicator when it is expanded during animation
    var dismissIndicatorShrunk: CGRect! //Variable used to hold the location and dimensions of the indicator when it is shrunk during animation

    var tableViewOrigin: CGPoint! //Variable that holds the original position of the "tableView"
    
    var pan: UIPanGestureRecognizer?
    var animateButtonTracker: Bool = true //Variable that tracks if the dismissIndicator should be animating or not
    var animateDown: Bool = true //Variable that tracks if the dismissIndicator should be animating up or down

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //If statement used to ensure the selectedFriend variable isn't nil, and bounce back to the previous view if it is
        if selectedFriend == nil {
            
            dismiss(animated: true) {
                ProgressHUD.showError("Sorry, sorry went wrong retrieving your friends data")
            }
            reconfigureCellDelegate?.reconfigureCell()
        }
        
        else {
            
            initialLabelBottomAnchor.constant = -76
            initialLabelWidthConstraint.constant = 72
            initialLabelHeightConstraint.constant = 72

            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    //MARK: - Configure View Function
    
    func configureView () {
        
        //Configuring friendView, friendNameContainer, intialContainer and initialLabel
        friendView.layer.cornerRadius = 0.1 * friendView.bounds.size.width
        friendView.clipsToBounds = true
        
        friendView.sendSubviewToBack(dismissIndicator)
        friendView.sendSubviewToBack(upcoming_historyTableView)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 344, height: 73)
        gradientLayer.colors = [UIColor(hexString: "#e35d5b")?.cgColor as Any, UIColor(hexString: "#e53935")?.cgColor as Any]
        gradientLayer.locations = [0.0, 0.7]
        
        friendNameContainer.layer.addSublayer(gradientLayer)
        friendNameContainer.bringSubviewToFront(friendName)
    
        initialContainer.backgroundColor = UIColor(hexString: "#e35d5b")
        initialContainer.layer.cornerRadius = 0.5 * initialContainer.bounds.width
        
        initialLabel.layer.cornerRadius = 0.5 * initialLabel.bounds.width
        initialLabel.clipsToBounds = true
        
        initialLabelBottomAnchor.constant = -38
        initialLabelWidthConstraint.constant = 0
        initialLabelHeightConstraint.constant = 0
        
        //Configuring buttons
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
        
        //Configuring tableView
        upcoming_historyTableView.delegate = self
        upcoming_historyTableView.dataSource = self
        upcoming_historyTableView.rowHeight = 80
        
        upcoming_historyTableView.register(UINib(nibName: "UpcomingCollabTableCell", bundle: nil), forCellReuseIdentifier: "UpcomingCollabCell")
        
        //Ensures the data from the selected friend has been passed to this view
        if selectedFriend != nil {
            
            let firstNameArray = Array(selectedFriend!.firstName)
            initialLabel.text = "\(firstNameArray[0].uppercased())"
            friendName.text = selectedFriend!.firstName + " " + selectedFriend!.lastName
        }
    }
    
    
    //MARK: - Configure Constraints Function
    
    func configureConstraints () {
        
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
    
    
    //MARK: TableView Datasource Methods
    
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
    
    
    //MARK: TableView Delegate Method
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        animateButtonTracker = false
        timer?.invalidate()
        
        dismiss(animated: true) { 
            
            guard let collabData = self.sectionContentArray?[indexPath.section][indexPath.row] else { return }
            
                self.collabBlocksDelegate?.performSegue(collabData.collabID, collabData.collabName, collabData.collabDate)
            
        }
        
        reconfigureCellDelegate?.reconfigureCell()
        
    }
    
    
    //MARK: - Reconfigure Collab Cell Function
    
    func reconfigureCollabCell (cell: UpcomingCollabTableCell) {
        
        cell.withLabelTopAnchor.constant = 5
        
        cell.seperatorViewTopAnchor.constant = 1.5
        
        cell.nameLabelTopAnchor.constant = 7
        cell.nameLabelBottomAnchor.constant = 7
    }
    
    
    //MARK: - Get Upcoming Collabs Function
    
    func getUpcomingCollabs () {
        
        collabObjectArray.removeAll() //Cleans the "collabObjectArray" to prepare it to be loaded with new data
        
        formatter.dateFormat = "MMMM dd, yyyy"
        
        //Database query to retrieve all the Upcoming Collabs with the selected friend
        db.collection("Users").document(currentUser.userID).collection("UpcomingCollabs").whereField("with.userID", isEqualTo: selectedFriend!.friendID).getDocuments { (snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            
            else {
                
                //If no Upcoming Collabs are found
                if snapshot!.isEmpty {
                    
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
    
    
    //MARK: - Get Historic Collabs Function
    
    func getHistoricCollabs () {
        
        collabObjectArray.removeAll() //Cleans the "collabObjectArray" to prepare it to be loaded with new data
        
        formatter.dateFormat = "MMMM dd, yyyy"
        
        //Database query to retrieve all the Historic Collabs with the selected friend
        db.collection("Users").document(currentUser.userID).collection("CollabHistory").whereField("with.userID", isEqualTo: selectedFriend!.friendID).getDocuments { (snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            else {
                
                //If no Historic Collabs are found
                if snapshot?.isEmpty == true {
        
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
    
    
    //MARK: - Sort Collabs Function
    
    func sortCollabs () {
        
        sectionDateArray.removeAll() //Cleans the "sectionDateArray"
        sectionContentArray?.removeAll() //Cleans the "sectionContentArray"
        
        for collab in collabObjectArray {
            
            //If a certain collab date has not yet been added to the "sectionDateArray"
            if sectionDateArray.contains(collab.collabDate) == false {
                sectionDateArray.append(collab.collabDate)
            }
        }
        
        //Creating a two dimensional array that contains the collab objects retrieved from Firebase; each new index of the first array is associated with a date from the "sectionDateArray"
        sectionContentArray = Array(repeating: Array(repeating: collabObjectArray[0], count: 0), count: sectionDateArray.count)
        
        for collab in collabObjectArray {
            
            //Appending the collab to the first index of the "sectionContentArray" that is associated with the date of that collab
            if let index = sectionDateArray.firstIndex(of: collab.collabDate) {
                sectionContentArray![index].append(collab)
            }
        }
    }
    
    
    //MARK: - Present Delete Alert Function
    
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
    
    
    //MARK: - Delete Friend Function
    func deleteFriend (_ selectedFriendName: String) {
        
        //Deleting the selected friend from the current users friend list
        self.db.collection("Users").document(currentUser.userID).collection("Friends").document(selectedFriend!.friendID).delete()

        //Deleting all pending collabs with this selected friend
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

        //Deleting all upcoming collabs with the selected friend
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

        //Deleting all historic collabs with this selected friend from collab history
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
        
        dismiss(animated: true) {
            ProgressHUD.showSuccess(self.selectedFriend!.firstName + " " + self.selectedFriend!.lastName + " has been deleted")
        }
        
    }
    
    
    //MARK: - Pan Gesture Functions
    
    func addPanGesture (view: UIView) {
        
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
            
            //If the dimissIndicator has reached a certain point when the gesture ends, dismiss the tableView
            if dismissIndicator.frame.origin.y >= friendView.frame.height / 2 {
            
                self.dismissView(dismissView: dismissView, dismissIndicator: dismissIndicator, tableView: upcoming_historyTableView)
            }
            
            //Otherwise, return it to it's origin point
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
            
            RunLoop.main.add(self.timer!, forMode: .common)
        }
    }
    
    //Function that dismisses the views
    func dismissView (dismissView: UIView, dismissIndicator: UIView, tableView: UIView) {
        
        tableViewHeightConstraint.constant = 0
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.view.layoutIfNeeded()
            
            dismissIndicator.frame.origin.y = 550
            
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
    
    //Function that removes the pan gesture
    func removePanGesture (view: UIView) {
        
        view.removeGestureRecognizer(pan!)
    }
    
    
    //MARK: Button Functions
    
    @objc func animateDismissButton (timer: Timer) {

        //If the dismissIndicator is supposed to be animating
        if animateButtonTracker == true {
            
            //If true, animate the dismissIndicator to it's shrunken frame
            if animateDown == true {
                
                UIView.animate(withDuration: 2, animations: {
                    
                    self.dismissIndicator.frame = self.dismissIndicatorShrunk
                    
                }) { (finished: Bool) in

                    self.animateDown = false
                }
            }
            
            //If false, animate the dismissIndicator to it's expanded frame
            else if animateDown == false {
                
                UIView.animate(withDuration: 2, animations: {
                    
                    self.dismissIndicator.frame = self.dismissIndicatorExpanded
                    
                }) { (finished: Bool) in
                    
                    self.animateDown = true
                }
            }
        }
    }

    
    @IBAction func upcomingButton(_ sender: Any) {
        
        getUpcomingCollabs()
        tableViewIndicator = "upcoming"
        
        let date = Date()
        timer = Timer(fireAt: date, interval: 3, target: self, selector: #selector(animateDismissButton), userInfo: nil, repeats: true)
        animateButtonTracker = true
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))) //Initialization of the pan gesture
        addPanGesture(view: dismissGestureView)
        
        //Setting the new constraints of the buttons
        newCollabLeadingAnchor.constant = 423
        newCollabTrailingAnchor.constant = -377

        upcomingButtonLeadingAnchor.constant = -377
        upcomingButtonTrailingAnchor.constant = 423

        historyButtonLeadingAnchor.constant = 423
        historyButtonTrailingAnchor.constant = -377

        deleteFriendLeadingAnchor.constant = -377
        deleteFriendTrailingAnchor.constant = 423
        
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.friendView.layoutIfNeeded() //Animating the buttons off the view
            
        }) { (finished: Bool) in
            
            self.tableViewHeightConstraint.constant = self.tableViewPresentedHeight //Setting the new tableViewHeightConstraint
            self.dismissIndicator.isHidden = false
            
            UIView.animate(withDuration: 0.2, animations: {
            
                self.friendView.layoutIfNeeded() //Animating the tableView onto the screen
                self.dismissIndicator.frame = self.dismissIndicatorExpanded //Animating the dismissIndicator onto the screen
                
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
        addPanGesture(view: dismissGestureView)
        
        //Setting the new constraints of the buttons
        newCollabLeadingAnchor.constant = 423
        newCollabTrailingAnchor.constant = -377
        
        upcomingButtonLeadingAnchor.constant = -377
        upcomingButtonTrailingAnchor.constant = 423
        
        historyButtonLeadingAnchor.constant = 423
        historyButtonTrailingAnchor.constant = -377
        
        deleteFriendLeadingAnchor.constant = -377
        deleteFriendTrailingAnchor.constant = 423
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.friendView.layoutIfNeeded() //Animating the buttons off the view
            
        }) { (finished: Bool) in
            
            self.tableViewHeightConstraint.constant = self.tableViewPresentedHeight //Setting the new tableViewHeightConstraint
            self.dismissIndicator.isHidden = false
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.friendView.layoutIfNeeded() //Animating the tableView onto the screen
                self.dismissIndicator.frame = self.dismissIndicatorExpanded //Animating the dismissIndicator onto the screen
                
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
