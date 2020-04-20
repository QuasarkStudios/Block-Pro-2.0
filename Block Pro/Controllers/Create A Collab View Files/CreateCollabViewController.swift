//
//  CreateCollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/9/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CreateCollabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    
    
    
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var segmentBackground: UIView!
    @IBOutlet weak var selectedSegmentIndicator: UIView!
    @IBOutlet weak var segmentIndicatorLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var segmentIndicatorWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var detailsButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var attachmentsButton: UIButton!
    @IBOutlet weak var attachmentButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var details_attachmentsTableView: UITableView!
    
    let formatter = DateFormatter()
    
    var viewIntiallyLoaded: Bool = false
    
    var selectedTableView: String = "details"
    
    var newCollab = NewCollab()
    
    var selectedMember: Friend?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        
        configureTableView()
        
        addTapGesture()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewIntiallyLoaded {
            
            configureSegmentedControl()
            viewIntiallyLoaded = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedTableView == "details" {
            
            return 10
        }
        
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if selectedTableView == "details" {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "collabNameCell", for: indexPath) as! CollabNameCell
                cell.selectionStyle = .none
                cell.collabNameEnteredDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 2 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "collabObjectiveCell", for: indexPath) as! CollabObjectiveCell
                cell.selectionStyle = .none
                cell.collabObjectiveEnteredDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 4 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "collabMembersCell", for: indexPath) as! CollabMembersCell
                cell.selectionStyle = .none
                cell.addMembersDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 6 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "collabDeadlineCell", for: indexPath) as! CollabDeadlineCell
                cell.selectionStyle = .none
                cell.deadlineCellDelegate = self
                
                if newCollab.dates["deadline"] == nil {
                    
                    let presetDeadline = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                    
                    if let date = presetDeadline {
                        
                        let suffix = date.daySuffix()
                        var dateString: String = ""

                        formatter.dateFormat = "MMMM d"
                        dateString = formatter.string(from: date)
                        dateString += "\(suffix), 5:00 PM"

                        cell.calendarButton.setTitle(dateString, for: .normal)
                    }
                    
                    else {
                        
                        cell.calendarButton.setTitle("Set Here", for: .normal)
                    }
                }
                
                return cell
            }
            
            else if indexPath.row == 8 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "collabRemindersCell", for: indexPath) as! CollabRemindersCell
                cell.selectionStyle = .none
                return cell
            }
        }
        
        else {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "collabPhotosCell", for: indexPath) as! CollabPhotosCell
                cell.selectionStyle = .none
                return cell
            }
        }
        
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if selectedTableView == "details" {
            
            switch indexPath.row {
                
            case 0:
                
                return 70
                
            case 2:
                
                return 110
                
            case 4:
                
                return 80
                
            case 6, 8:
                
                return 70
                
            default:
                
                return 25
                
            }
        }
        
        else {
            
            switch indexPath.row {
                
            case 0:
                
                return 80
                
            default:
                
                return 25
                
            }
        }
    }
    
    private func configureNavBar () {
        
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = .clear
    }
    
    private func configureSegmentedControl () {
        
        segmentContainer.layer.cornerRadius = 10
        segmentContainer.clipsToBounds = true
        
        segmentBackground.layer.cornerRadius = 10
        segmentBackground.clipsToBounds = true
        
        segmentIndicatorWidthConstraint.constant = segmentContainer.frame.width / 2
        selectedSegmentIndicator.layer.cornerRadius = 10
        selectedSegmentIndicator.clipsToBounds = true
        
        detailsButtonWidthConstraint.constant = segmentContainer.frame.width / 2
        detailsButton.layer.cornerRadius = 10
        detailsButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner] 
        detailsButton.clipsToBounds = true
        
        attachmentButtonWidthConstraint.constant = segmentContainer.frame.width / 2
        attachmentsButton.layer.cornerRadius = 10
        attachmentsButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        attachmentsButton.clipsToBounds = true
    }
    
    private func configureTableView () {
        
        details_attachmentsTableView.dataSource = self
        details_attachmentsTableView.delegate = self
        
        details_attachmentsTableView.separatorStyle = .none
        details_attachmentsTableView.showsVerticalScrollIndicator = false
        
        details_attachmentsTableView.register(UINib(nibName: "CollabNameCell", bundle: nil), forCellReuseIdentifier: "collabNameCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CollabObjectiveCell", bundle: nil), forCellReuseIdentifier: "collabObjectiveCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CollabMembersCell", bundle: nil), forCellReuseIdentifier: "collabMembersCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CollabDeadlineCell", bundle: nil), forCellReuseIdentifier: "collabDeadlineCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CollabRemindersCell", bundle: nil), forCellReuseIdentifier: "collabRemindersCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CollabPhotosCell", bundle: nil), forCellReuseIdentifier: "collabPhotosCell")
    }
    
    private func addTapGesture () {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard () {
        
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToAddMembersView" {
            
            let addMembersVC = segue.destination as! AddMembersViewController
            addMembersVC.membersAddedDelegate = self
            
            if newCollab.members.count > 0 {
                
                addMembersVC.previouslyAddedMembers = newCollab.members
            }
        }
        
        else if segue.identifier == "moveToMemberProfileView" {
            
            let memberProfileVC = segue.destination as! MemberProfileViewController
            memberProfileVC.removeMemberDelegate = self
            
            if let member = selectedMember {
                
                memberProfileVC.selectedFriend = member
            }
        }
        
        else if segue.identifier == "moveToCalendarView" {
            
            let datesVC = segue.destination as! CollabDatesViewController
            datesVC.collabDatesSelectedDelegate = self
            
            if newCollab.dates["startTime"] != nil {
                
                datesVC.selectedStartTime["startDate"] = newCollab.dates["startTime"]
                datesVC.selectedStartTime["startTime"] = newCollab.dates["startTime"]
                
                datesVC.selectedDeadline["deadlineDate"] = newCollab.dates["deadline"]
                datesVC.selectedDeadline["deadlineTime"] = newCollab.dates["deadline"]
                
                ProgressHUD.show()
            }
        }
    }
    
    @IBAction func exitButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func detailsButtonPressed(_ sender: Any) {
        
        if selectedTableView != "details" {
            
            segmentIndicatorLeadingAnchor.constant = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
                
                self.details_attachmentsTableView.alpha = 0
                
                self.attachmentsButton.setTitleColor(.black, for: .normal)
                self.detailsButton.setTitleColor(.white, for: .normal)
                
            }) { (finished: Bool) in
                
                self.selectedTableView = "details"
                self.details_attachmentsTableView.reloadData()
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.details_attachmentsTableView.alpha = 1
                    
                }) { (finished: Bool) in
                    

                }
            }
        }
    }
    
    
    @IBAction func attachmentsButtonPressed(_ sender: Any) {
        
        if selectedTableView != "attachments" {
            
            segmentIndicatorLeadingAnchor.constant = segmentContainer.frame.width / 2
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
                
                self.details_attachmentsTableView.alpha = 0
                
                self.attachmentsButton.setTitleColor(.white, for: .normal)
                self.detailsButton.setTitleColor(.black, for: .normal)
                
            }) { (finished: Bool) in
                
                self.selectedTableView = "attachments"
                self.details_attachmentsTableView.reloadData()
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.details_attachmentsTableView.alpha = 1
                    
                }) { (finished: Bool) in
                    

                }
            }
        }
    }
}

extension CreateCollabViewController: CollabNameEntered {
    
    func nameEntered (_ name: String) {
    
        newCollab.name = name
    }
}

extension CreateCollabViewController: CollabObjectiveEntered {
    
    func objectiveEntered (_ objective: String) {
        
        newCollab.objective = objective
    }
}

extension CreateCollabViewController: AddMembers {

    func addMemberButtonPressed () {

        performSegue(withIdentifier: "moveToAddMembersView", sender: self)
    }
    
    func performSegueToProfileView (member: Friend) {

        selectedMember = member
        performSegue(withIdentifier: "moveToMemberProfileView", sender: self)
    }
}

extension CreateCollabViewController: MembersAdded {
    
    func membersAdded(members: [Friend]) {
        
        let cell = details_attachmentsTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! CollabMembersCell
        
        if members.count > 0 {
            
            cell.reconfigureButtonContainer(collectionViewPresent: true)
        }
        
        else {
            
            cell.reconfigureButtonContainer(collectionViewPresent: false)
        }
        
        cell.members = members
        cell.membersCollectionView.reloadData()
        
        newCollab.members = members
    }
}

extension CreateCollabViewController: RemoveMemberFromCollab {
    
    func removeMember(member: Friend) {
        
        var count = 0
        
        for members in newCollab.members {
            
            if member.friendID == members.friendID {
                
                newCollab.members.remove(at: count)
                break
            }
            
            count += 1
        }
        
        let cell = details_attachmentsTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! CollabMembersCell
        
        cell.members = newCollab.members
        cell.membersCollectionView.reloadData()
        
        if newCollab.members.count == 0 {
            
            cell.reconfigureButtonContainer(collectionViewPresent: false)
        }
    }
}

extension CreateCollabViewController: DeadlineCell {
    
    func moveToCalendarView () {
        
        performSegue(withIdentifier: "moveToCalendarView", sender: self)
    }
}

extension CreateCollabViewController: CollabDatesSelected {
    
    func datesSelected(startTime: Date, deadline: Date) {
        
        newCollab.dates = ["startTime" : startTime, "deadline" : deadline]
        
        var deadlineButtonTitle: String
        
        formatter.dateFormat = "MMMM dd"
        deadlineButtonTitle = formatter.string(from: deadline)
        
        deadlineButtonTitle += deadline.daySuffix()
        
        formatter.dateFormat = "h:mm a"
        deadlineButtonTitle += ", \(formatter.string(from: deadline))"
        
        let cell = details_attachmentsTableView.cellForRow(at: IndexPath(item: 6, section: 0)) as! CollabDeadlineCell
        cell.calendarButton.setTitle(deadlineButtonTitle, for: .normal)
    }
}
