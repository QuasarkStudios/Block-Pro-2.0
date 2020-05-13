//
//  CreateCollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/9/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol CollabCreated: AnyObject {
    
    func reloadData ()
}

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
    
    let firebaseCollab = FirebaseCollab()
    
    let formatter = DateFormatter()
    
    var viewIntiallyLoaded: Bool = false
    
    var selectedTableView: String = "details"
    
    var newCollab = NewCollab()
    
    var selectedMember: Friend?
    var selectedPhoto: UIImage?
    
    var photosCellCollectionViewPresent: Bool = false
    
    weak var collabCreatedDelegate: CollabCreated?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        
        configureTableView()
        
        configureGestureRecognizors()
        
        fetchCollabData()
        
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
                
                if let deadline = newCollab.dates["deadline"] {
                    
                    let suffix = deadline.daySuffix()
                    var dateString: String = ""

                    formatter.dateFormat = "MMM d"
                    dateString = formatter.string(from: deadline)
                    dateString += "\(suffix), "
                    
                    formatter.dateFormat = "h:mm a"
                    dateString += formatter.string(from: deadline)
                    
                    cell.calendarButton.setTitle(dateString, for: .normal)
                }
                
                else {
                    
                    cell.calendarButton.setTitle("Set Here", for: .normal)
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
                cell.collabPhotosCellDelegate = self
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
                
                return photosCellCollectionViewPresent ? 210 : 80
                
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
    
    private func fetchCollabData () {
        
        let currentDate = Date()
        
        formatter.dateFormat = "MMMM dd yyyy"
        let startDate: String = formatter.string(from: currentDate)
        let deadlineDate: String = formatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!)
        
        formatter.dateFormat = "HH:mm"
        let startTime: String = "00:00"
        let deadlineTime: String = "17:00"
        
        formatter.dateFormat = "MMMM dd yyyy HH:mm"
        let starts: Date = formatter.date(from: startDate + " " + startTime)!
        let deadline: Date = formatter.date(from: deadlineDate + " " + deadlineTime)!

        newCollab.dates = ["startTime" : starts, "deadline" : deadline]
    }
    
    private func configureGestureRecognizors () {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let presentTabBar = UISwipeGestureRecognizer(target: self, action: #selector(presentDisabledTabBar))
        presentTabBar.delegate = self
        presentTabBar.cancelsTouchesInView = false
        presentTabBar.direction = .left
        view.addGestureRecognizer(presentTabBar)
    }
    
    @objc private func presentDisabledTabBar () {
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    private func createCollab () {
        
        SVProgressHUD.show()
        
        firebaseCollab.createCollab(collabInfo: newCollab) {
            
            self.collabCreatedDelegate?.reloadData()
            
            SVProgressHUD.dismiss()
            
            self.dismiss(animated: true, completion: nil)
        }
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

            if let starts = newCollab.dates["startTime"], let deadline = newCollab.dates["deadline"] {

                SVProgressHUD.show()
                
                formatter.dateFormat = "MMMM dd yyyy"
                datesVC.selectedStartTime["startDate"] = formatter.date(from: formatter.string(from: starts))
                datesVC.selectedDeadline["deadlineDate"] = formatter.date(from: formatter.string(from: deadline))

                formatter.dateFormat = "HH:mm"
                datesVC.selectedStartTime["startTime"] = formatter.date(from: formatter.string(from: starts))
                datesVC.selectedDeadline["deadlineTime"] = formatter.date(from: formatter.string(from: deadline))
            }
        }
        
        else if segue.identifier == "moveToSelectedPhotoView" {
            
            let selectedPhotoVC = segue.destination as! SelectedPhotoViewController
            selectedPhotoVC.selectedPhoto = selectedPhoto
            selectedPhotoVC.photoEditedDelegate = self
        }
    }
    
    @IBAction func exitButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
        
        if newCollab.name.leniantValidationOfTextEntered() {
            
            createCollab()
        }
        
        else {
            
           SVProgressHUD.showError(withStatus: "Please enter a name for this Collab")
        }
        
//        if validateTextEntered(newCollab.name) {
//
//            createCollab ()
//        }
//
//        else {
//
//            SVProgressHUD.showError(withStatus: "Please enter a name for this Collab")
//        }
        
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
            
            if member.userID == members.userID {
                
                newCollab.members.remove(at: count)
                break
            }
            
            count += 1
        }
        
        guard let cell = details_attachmentsTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? CollabMembersCell else { return }
        
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
        
        formatter.dateFormat = "MMMM d"
        deadlineButtonTitle = formatter.string(from: deadline)
        
        deadlineButtonTitle += deadline.daySuffix()
        
        formatter.dateFormat = "h:mm a"
        deadlineButtonTitle += ", \(formatter.string(from: deadline))"
        
        let cell = details_attachmentsTableView.cellForRow(at: IndexPath(item: 6, section: 0)) as! CollabDeadlineCell
        cell.calendarButton.setTitle(deadlineButtonTitle, for: .normal)
    }
}

extension CreateCollabViewController: CollabPhotosCellProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func attachPhotosButtonPressed () {
        
        let photoAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        photoAlert.view.tintColor = .black

        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { (takePhoto) in

            let imagePicker = UIImagePickerController()
            imagePicker.navigationBar.configureNavBar()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }

        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default) { (chooseFromLibrary) in

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        photoAlert.addAction(takePhotoAction)
        photoAlert.addAction(chooseFromLibraryAction)
        photoAlert.addAction(cancelAction)

        present(photoAlert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] {
            
            selectedImageFromPicker = editedImage as? UIImage
        }
        
        else if let originalImage = info[.originalImage] {
            
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            newCollab.photos.append(selectedImage)
            
            guard let cell = details_attachmentsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CollabPhotosCell else { return }

                photosCellCollectionViewPresent = true
                details_attachmentsTableView.reloadData()
 
                cell.reconfigureAttachmentContainer(collectionViewPresent: true)
            
                cell.selectedPhotos.append(selectedImage)
                cell.photosCollectionView.reloadData()
        }
        
        else {
            
            SVProgressHUD.showError(withStatus: "Sorry, something went wrong selecting this photo")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func addedPhotoSelected (photo: UIImage) {
        
        selectedPhoto = photo
        
        performSegue(withIdentifier: "moveToSelectedPhotoView", sender: self)
    }
}

extension CreateCollabViewController: PhotoEdited {
    
    func photoChanged (changedPhoto: UIImage) {
        
        var count = 0
        
        for photo in newCollab.photos {
            
            if photo == selectedPhoto {
                
                newCollab.photos[count] = changedPhoto
                selectedPhoto = nil
                break
            }
            
            count += 1
        }
        
        guard let cell = details_attachmentsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CollabPhotosCell else { return }
        
        cell.selectedPhotos = newCollab.photos
        cell.photosCollectionView.reloadData()
    }
    
    func photoDeleted (deletedPhoto: UIImage) {
        
        var count = 0
        
        for photo in newCollab.photos {
            
            if photo == deletedPhoto {
                
                newCollab.photos.remove(at: count)
                selectedPhoto = nil
                break
            }
            
            count += 1
        }
        
        guard let cell = details_attachmentsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CollabPhotosCell else { return }
        
        cell.selectedPhotos = newCollab.photos
        cell.photosCollectionView.reloadData()
        
        if newCollab.photos.count == 0 {
            
            cell.reconfigureAttachmentContainer(collectionViewPresent: false)
            
            photosCellCollectionViewPresent = false
            details_attachmentsTableView.reloadData()
        }
    }
}

extension CreateCollabViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
