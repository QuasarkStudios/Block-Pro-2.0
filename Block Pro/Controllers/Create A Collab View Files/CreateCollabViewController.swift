//
//  CreateCollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/9/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import MapKit
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
    
    lazy var editPhotoButton: UIButton = configureEditButton()
    lazy var deletePhotoButton: UIButton = configureDeleteButton()
    
    var copiedAnimationView: CopiedAnimationView?
    
    let firebaseCollab = FirebaseCollab()
    
    let formatter = DateFormatter()
    
    var viewIntiallyLoaded: Bool = false
    
    var selectedTableView: String = "details"
    
    var newCollab = NewCollab()
    
    var selectedMember: Friend?
    var selectedPhoto: UIImage?
    
//    var selectedLocation: MKMapItem?
    var selectedLocation: Location?
    
    var zoomingMethods: ZoomingImageViewMethods?
    
    weak var collabCreatedDelegate: CollabCreated?
    
    var photoEditing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: UIColor.white.withAlphaComponent(0.9))
        
        configureTableView()
        
        configureGestureRecognizors()
        
        fetchCollabData()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Initializing here allows the animationView to be removed and readded multiple times
        copiedAnimationView = CopiedAnimationView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        selectedLocation = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        copiedAnimationView?.removeCopiedAnimation(remove: true)
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
            
            return 3
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
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "createCollabPhotosCell", for: indexPath) as! CreateCollabPhotosCell
                cell.selectionStyle = .none
                
                cell.selectedPhotos = newCollab.photos
                cell.createCollabPhotosCellDelegate = self
                cell.zoomInDelegate = self
                cell.presentCopiedAnimationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 2 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "createCollabLocationsCell", for: indexPath) as! CreateCollabLocationsCell
                cell.selectionStyle = .none
                
                cell.selectedLocations = newCollab.locations
                
                cell.createCollabLocationsCellDelegate = self
                cell.locationSelectedDelegate = self
                cell.cancelLocationSelectionDelegate = self
                
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
                
                if newCollab.photos?.count ?? 0 > 0 {
                    
                    let heightOfPhotosLabelAndBottomAnchor: CGFloat = 25
                    let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
                    
                    if newCollab.photos?.count ?? 0 <= 3 {
                        
                        //The item size plus the top and bottom edge insets, i.e. 20
                        let heightOfCollectionView: CGFloat = itemSize + 20
                        
                        //The height of the "attach" button plus a 10 point buffer on the top annd bottom
                        let heightOfAttachButton: CGFloat = 40 + 20
                        
                        return heightOfPhotosLabelAndBottomAnchor + heightOfCollectionView + heightOfAttachButton
                        
                    }
                    
                    else if newCollab.photos?.count ?? 0 < 6 {
                        
                        //The height of the two rows of items that'll be displayed, the edge insets, i.e. 20, and the line spacing i.e. 5
                        let heightOfCollectionView: CGFloat = (itemSize * 2) + 20 + 5
                        
                        //The height of the "attach" button plus a 10 point buffer on the top annd bottom
                        let heightOfAttachButton: CGFloat = 40 + 20
                        
                        return heightOfPhotosLabelAndBottomAnchor + heightOfCollectionView + heightOfAttachButton
                    }
                    
                    else {
                        
                        //The height of the two rows of items that'll be displayed, the edge insets, i.e. 20, and the line spacing i.e. 5
                        let heightOfCollectionView: CGFloat = (itemSize * 2) + 20 + 5
                        
                        return heightOfPhotosLabelAndBottomAnchor + heightOfCollectionView
                    }
                }
                
                else {
                    
                    return 85
                }
                
            case 2:
                
                if newCollab.locations?.count ?? 0 == 0 {
                    
                    return 85
                }
                
                else if newCollab.locations?.count ?? 0 == 1 {
                    
                    return 287.5
                }
                
                else if newCollab.locations?.count ?? 0 == 2 {
                   
                    return 315
                }
                
                else {
                    
                    return 262.5
                }
                
            default:
                
                return 25
                
            }
        }
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
        
        details_attachmentsTableView.delaysContentTouches = false
        
        details_attachmentsTableView.register(UINib(nibName: "CollabNameCell", bundle: nil), forCellReuseIdentifier: "collabNameCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CollabObjectiveCell", bundle: nil), forCellReuseIdentifier: "collabObjectiveCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CollabMembersCell", bundle: nil), forCellReuseIdentifier: "collabMembersCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CollabDeadlineCell", bundle: nil), forCellReuseIdentifier: "collabDeadlineCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CollabRemindersCell", bundle: nil), forCellReuseIdentifier: "collabRemindersCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CreateCollabPhotosCell", bundle: nil), forCellReuseIdentifier: "createCollabPhotosCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CreateCollabLocationsCell", bundle: nil), forCellReuseIdentifier: "createCollabLocationsCell")
    }
    
    private func configureEditButton () -> UIButton {
        
        let button = UIButton(type: .system)
        
        button.frame = CGRect(x: 15, y: 50, width: 75, height: 35)
        
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        button.contentHorizontalAlignment = .center
        button.tintColor = .white
        button.alpha = 0
        button.addTarget(self, action: #selector(editPhotoButtonPressed), for: .touchUpInside)
        
        return button
    }
    
    private func configureDeleteButton () -> UIButton {
        
        let button = UIButton(type: .system)
        
        let xCoord = self.view.frame.width - (75 + 20)
        button.frame = CGRect(x: xCoord, y: 50, width: 75, height: 35)
        
        button.setTitle("Delete", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        button.contentHorizontalAlignment = .center
        button.tintColor = .systemRed
        button.alpha = 0
        button.addTarget(self, action: #selector(deletePhotoButtonPressed), for: .touchUpInside)
        
        return button
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
        
//        let presentTabBar = UISwipeGestureRecognizer(target: self, action: #selector(presentDisabledTabBar))
//        presentTabBar.delegate = self
//        presentTabBar.cancelsTouchesInView = false
//        presentTabBar.direction = .left
//        view.addGestureRecognizer(presentTabBar)
    }
    
    @objc private func presentDisabledTabBar () {
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    private func photoEdited (newImage: UIImage) {
        
        var count = 0
        
        for photo in newCollab.photos ?? [] {
            
            if photo == selectedPhoto {
                
                newCollab.photos?[count] = newImage
                selectedPhoto = nil
                break
            }
            
            count += 1
        }
        
        photoEditing = false
    }
    
    private func createCollab () {
        
        SVProgressHUD.show()
        
        firebaseCollab.createCollab(collabInfo: newCollab) { [weak self] in
            
            self?.collabCreatedDelegate?.reloadData()
            
            SVProgressHUD.dismiss()
            
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func editPhotoButtonPressed () {
        
        zoomingMethods?.handleZoomOutOnImageView()
        
        photoEditing = true
        
        presentAddPhotoAlert()
    }
    
    @objc private func deletePhotoButtonPressed () {
        
        var count = 0
        
        for photo in newCollab.photos ?? [] {
            
            if photo == selectedPhoto {
                
                newCollab.photos?.remove(at: count)
                selectedPhoto = nil
                break
            }
            
            count += 1
        }
        
        details_attachmentsTableView.reloadSections([0], with: .none)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            
            self.zoomingMethods?.blackBackground?.backgroundColor = .clear
            self.zoomingMethods?.optionalButtons.forEach({ $0?.alpha = 0 })
            self.zoomingMethods?.zoomedInImageView?.alpha = 0
            
        } completion: { (finished: Bool) in
            
            self.zoomingMethods?.blackBackground?.removeFromSuperview()
            self.zoomingMethods?.optionalButtons.forEach({ $0?.removeFromSuperview() })
            self.zoomingMethods?.zoomedInImageView?.removeFromSuperview()
        }
    }
    
    @objc private func dismissKeyboard () {
        
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToAddMembersView" {
            
            let addMembersVC = segue.destination as! AddMembersViewController
            addMembersVC.membersAddedDelegate = self
            
            addMembersVC.headerLabelText = "Add Members"
            
            if newCollab.members.count > 0 {
                
                addMembersVC.previouslyAddedFriends = newCollab.members
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
        
        else if segue.identifier == "moveToAddLocationsView" {
            
            let item: UIBarButtonItem = UIBarButtonItem()
            item.title = ""
            navigationItem.backBarButtonItem = item
            
            let addLocationVC = segue.destination as! AddLocationViewController
            addLocationVC.locationSavedDelegate = self
            addLocationVC.cancelLocationSelectionDelegate = self
            
            addLocationVC.locationPreselected = selectedLocation != nil
            addLocationVC.selectedLocation = selectedLocation
            
            if let placemark = selectedLocation?.placemark {
                
                addLocationVC.locationMapItem = MKMapItem(placemark: placemark)
            }
        }
//        
//        else if segue.identifier == "moveToSelectedPhotoView" {
//            
//            let selectedPhotoVC = segue.destination as! SelectedPhotoViewController
//            selectedPhotoVC.selectedPhoto = selectedPhoto
//            selectedPhotoVC.photoEditedDelegate = self
//        }
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
                
                let tableViewLeadingAnchor = self.view.constraints.first(where: { $0.firstAttribute == .leading && $0.firstItem as? UITableView != nil })
                let tableViewTrailingAnchor = self.view.constraints.first(where: { $0.firstAttribute == .trailing && $0.secondItem as? UITableView != nil })
                
                tableViewLeadingAnchor?.constant = 40
                tableViewTrailingAnchor?.constant = 40
                
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
                
                let tableViewLeadingAnchor = self.view.constraints.first(where: { $0.firstAttribute == .leading && $0.firstItem as? UITableView != nil })
                let tableViewTrailingAnchor = self.view.constraints.first(where: { $0.firstAttribute == .trailing && $0.secondItem as? UITableView != nil })
                
                tableViewLeadingAnchor?.constant = 0
                tableViewTrailingAnchor?.constant = 0
                
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
        
        newCollab.objective = objective.leniantValidationOfTextEntered() == true ? objective : nil
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
        
        dismiss(animated: true, completion: nil)
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

extension CreateCollabViewController: CreateCollabPhotosCellProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentAddPhotoAlert () {
        
        let addPhotoAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let takePhotoAction = UIAlertAction(title: "    Take a Photo", style: .default) { (takePhoto) in

            let imagePicker = UIImagePickerController()
            imagePicker.navigationBar.configureNavBar()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cameraImage = UIImage(named: "camera2")
        takePhotoAction.setValue(cameraImage, forKey: "image")
        takePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

        let choosePhotoAction = UIAlertAction(title: "    Choose a Photo", style: .default) { (chooseFromLibrary) in

            let imagePicker = UIImagePickerController()
            imagePicker.navigationBar.configureNavBar()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let photoImage = UIImage(named: "image")
        choosePhotoAction.setValue(photoImage, forKey: "image")
        choosePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
            
            self.photoEditing = false
        }

        addPhotoAlert.addAction(takePhotoAction)
        addPhotoAlert.addAction(choosePhotoAction)
        addPhotoAlert.addAction(cancelAction)

        present(addPhotoAlert, animated: true)
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
            
            if !photoEditing {
                
                if newCollab.photos == nil {
                    
                    newCollab.photos = []
                    newCollab.photos?.append(selectedImage)
                }
                
                else {
                    
                    newCollab.photos?.append(selectedImage)
                }
            }
            
            else {
                
                photoEdited(newImage: selectedImage)
            }
            
            details_attachmentsTableView.reloadSections([0], with: .none)
            
//            if let cell = details_attachmentsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreateCollabPhotosCell {
//
//                print("check")
//            }
        }
        
        else {
            
            SVProgressHUD.showError(withStatus: "Sorry, something went wrong selecting this photo")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        photoEditing = false
        
        dismiss(animated: true, completion: nil)
    }
}

extension CreateCollabViewController: CreateCollabLocationsCellProtocol {
    
    func attachLocationSelected () {
        
        performSegue(withIdentifier: "moveToAddLocationsView", sender: self)
    }
}

extension CreateCollabViewController: LocationSavedProtocol {
    
    func locationSaved(_ location: Location?) {
        
        //If the location hasn't been added yet
        if newCollab.locations?.first(where: { $0.locationID == location?.locationID}) == nil {
            
            if location != nil && newCollab.locations == nil {
                
                newCollab.locations = []
                newCollab.locations?.append(location!)
            }
            
            else if location != nil {
                
                newCollab.locations?.append(location!)
            }
        }
        
        //If the location has been added
        else {
            
            newCollab.locations?.removeAll(where: { $0.locationID == location?.locationID })
            
            if location != nil {
                
                newCollab.locations?.append(location!)
            }
        }
        
        details_attachmentsTableView.reloadSections([0], with: .none)
    }
}

extension CreateCollabViewController: LocationSelectedProtocol {
    
    func locationSelected (_ location: Location?) {
        
        selectedLocation = location
        
        performSegue(withIdentifier: "moveToAddLocationsView", sender: self)
    }
}

extension CreateCollabViewController: CancelLocationSelectionProtocol {
    
    func selectionCancelled(_ locationID: String?) {
        
        if locationID != nil {
            
            newCollab.locations?.removeAll(where: { $0.locationID == locationID! })
            selectedLocation = nil
            
            details_attachmentsTableView.reloadSections([0], with: .fade)
        }
    }
}

extension CreateCollabViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CreateCollabViewController: ZoomInProtocol {
    
    func zoomInOnPhotoImageView(photoImageView: UIImageView) {
        
        selectedPhoto = photoImageView.image
        
        zoomingMethods = ZoomingImageViewMethods(on: photoImageView, cornerRadius: 8, with: [editPhotoButton, deletePhotoButton])
        zoomingMethods?.performZoom()
    }
}

extension CreateCollabViewController: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        let navBarFrame = navBar.convert(navBar.frame, to: UIApplication.shared.keyWindow)
        
        //12.5 is equal to 10 point top anchor the photosCollectionView has from the navBar plus an extra 10 point buffer
        copiedAnimationView?.presentCopiedAnimation(topAnchor: navBarFrame.minY + 10)
    }
}
