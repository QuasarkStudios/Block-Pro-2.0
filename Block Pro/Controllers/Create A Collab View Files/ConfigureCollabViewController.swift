//
//  ConfigureCollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/25/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD

class ConfigureCollabViewController: UIViewController {

    let navBarExtensionView = UIView()
    lazy var segmentControl = CustomSegmentControl(parentViewController: self)
    
    let configureCollabTableView = UITableView()
    
    lazy var editPhotoButton: UIButton = configureEditButton()
    lazy var deletePhotoButton: UIButton = configureDeleteButton()
    
    var copiedAnimationView: CopiedAnimationView?
    
    var navBarExtensionHeightAnchor: NSLayoutConstraint?
    var tableViewTopAnchor: NSLayoutConstraint?
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    
    let currentUser = CurrentUser.sharedInstance
    var collab = Collab()
    
    let formatter = DateFormatter()
    
    var configurationView: Bool = true
    var selectedTableView = "details"
    
    var startsCalendarPresented: Bool = false
    var endsCalendarPresented: Bool = false
    var calendarExpanded: Bool = false
    
    var selectedPhoto: UIImage?
    var photoEditing: Bool = false
    
    var selectedLocation: Location?
    
    var audioVisualizerPresent: Bool = false
    
    var zoomingMethods: ZoomingImageViewMethods?
    
    weak var collabCreatedDelegate: CollabCreatedProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.isModalInPresentation = true
        self.view.backgroundColor = .white
        
        configureTableView(configureCollabTableView) //Call first to allow for the navigation bar to work properly
        configureNavBarExtensionView()
        configureGestureRecognizors()
        
        //Removes the "Lead"/currentUser from the memebers array -- will be added back once the collab is edited
        var filteredMembers = collab.currentMembers
        filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
        
        collab.addedMembers = filteredMembers
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hexString: "222222") as Any, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.bold)]
        
        self.navigationController?.navigationBar.configureNavBar()
        self.navigationItem.largeTitleDisplayMode = .always
        
        //Initializing here allows the animationView to be removed and readded multiple times
        copiedAnimationView = CopiedAnimationView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        copiedAnimationView?.removeCopiedAnimation(remove: true)
        
        SVProgressHUD.dismiss()
    }
    
    
    //MARK: - Configure Bar Button Item
    
    func configureBarButtonItems () {
        
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonPressed))
        cancelBarButtonItem.style = .done
        
        self.navigationItem.leftBarButtonItem = cancelBarButtonItem
        
        if configurationView {
            
            let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            rightBarButtonItem.style = .done
            
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
        
        else {
            
            let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
            rightBarButtonItem.style = .done
            
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
    
    
    //MARK: - Configure TableView
    
    private func configureTableView (_ tableView: UITableView) {
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)

        ].forEach({ $0.isActive = true })
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        
        tableView.register(NameConfigurationCell.self, forCellReuseIdentifier: "nameConfigurationCell")
        tableView.register(ObjectiveConfigurationCell.self, forCellReuseIdentifier: "objectiveConfigurationCell")
        tableView.register(TimeConfigurationCell.self, forCellReuseIdentifier: "timeConfigurationCell")
        tableView.register(MemberConfigurationCell.self, forCellReuseIdentifier: "memberConfigurationCell")
        tableView.register(ReminderConfigurationCell.self, forCellReuseIdentifier: "reminderConfigurationCell")
        tableView.register(DeleteConfigurationCell.self, forCellReuseIdentifier: "deleteConfigurationCell")
        
        tableView.register(PhotosConfigurationCell.self, forCellReuseIdentifier: "photosConfigurationCell")
        tableView.register(LocationsConfigurationCell.self, forCellReuseIdentifier: "locationsConfigurationCell")
        tableView.register(VoiceMemosConfigurationCell.self, forCellReuseIdentifier: "voiceMemosConfigurationCell")
        tableView.register(LinksConfigurationCell.self, forCellReuseIdentifier: "linksConfigurationCell")
    }
    
    
    //MARK: - Configure Nav Bar Extension View
    
    private func configureNavBarExtensionView () {
        
        self.view.addSubview(navBarExtensionView)
        navBarExtensionView.translatesAutoresizingMaskIntoConstraints = false
        
        [

            navBarExtensionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            navBarExtensionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            navBarExtensionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),

        ].forEach({ $0.isActive = true })

        navBarExtensionHeightAnchor = navBarExtensionView.heightAnchor.constraint(equalToConstant: 70)
        navBarExtensionHeightAnchor?.isActive = true
        
        tableViewTopAnchor = configureCollabTableView.topAnchor.constraint(equalTo: navBarExtensionView.bottomAnchor, constant: 0)
        tableViewTopAnchor?.isActive = true
        
        navBarExtensionView.addSubview(segmentControl)
    }
    
    
    //MARK: - Configure Edit Photo Button
    
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
    
    
    //MARK: - Configure Delete Photo Button
    
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
    
    
    //MARK: - Configure Gesture Recognizors
    
    private func configureGestureRecognizors () {
        
        let downSwipeGesture = UISwipeGestureRecognizer()
        downSwipeGesture.direction = .down
        downSwipeGesture.delegate = self
        downSwipeGesture.addTarget(self, action: #selector(swipDownGesture))
        self.view.addGestureRecognizer(downSwipeGesture)

        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    
    //MARK: - Change Selected TableView
    
    func changeSelectedTableView (detailsTableView: Bool) {
        
        if detailsTableView {
            
            selectedTableView = "details"
            
            UIView.transition(with: configureCollabTableView, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.configureCollabTableView.reloadData()
            }
        }
        
        else {
            
            selectedTableView = "attachments"
            
            UIView.transition(with: configureCollabTableView, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.configureCollabTableView.reloadData()
            }
        }
    }
    
    
    //MARK: - Photo Edited
    
    private func photoEdited (newImage: UIImage) {
        
        for photo in collab.photos {

            if photo.value == selectedPhoto {

                collab.photos[photo.key] = newImage
                selectedPhoto = nil

                break
            }
        }
        
        photoEditing = false
    }
    
    
    //MARK: - Photo Deleted
    
    private func photoDeleted () {
        
        for photo in collab.photos {

            if photo.value == selectedPhoto {

                collab.photoIDs.removeAll(where: { $0 == photo.key })
                collab.photos.removeValue(forKey: photo.key)
                selectedPhoto = nil

                break
            }
        }

        configureCollabTableView.reloadSections([0], with: .none)

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
    
    
    //MARK: - Present Delete Alert
    
    func presentDeleteCollabAlert () {
        
        let deleteCollabAlert = UIAlertController(title: "Delete this Collab?", message: "All members will also lose access to all the data associated with this Collab", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (deleteAction) in
            
            self?.deleteCollab()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        deleteCollabAlert.addAction(deleteAction)
        deleteCollabAlert.addAction(cancelAction)
        
        self.present(deleteCollabAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - Delete Collab
    
    private func deleteCollab () {
        
        SVProgressHUD.show()
        
        firebaseCollab.deleteCollab(collab) { [weak self] (error) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: "Sorry, something went wrong while deleting this Collab")
            }
            
            else {
                
                self?.dismiss(animated: true)
            }
        }
    }
    
    //MARK: - Move to Add Members View
    
    private func moveToAddMembersView () {
        
        let addMembersVC: AddMembersViewController = AddMembersViewController()
        addMembersVC.membersAddedDelegate = self
        addMembersVC.headerLabelText = "Add Members"
        
        addMembersVC.members = firebaseCollab.friends
        
        addMembersVC.addedMembers = [:]
        
        //Setting the added members for the AddMembersViewController
        for member in collab.addedMembers {
            
            if let friend = member as? Friend {
                
                addMembersVC.addedMembers?[friend.userID] = friend
            }
            
            else if let member = member as? Member {
                
                addMembersVC.addedMembers?[member.userID] = member
            }
        }
        
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = ""
        navigationItem.backBarButtonItem = backButtonItem
        
        self.navigationController?.pushViewController(addMembersVC, animated: true)
    }
    
    
    //MARK: - Move to Add Location View
    
    private func moveToAddLocationView () {
        
        let addLocationVC: AddLocationViewController = AddLocationViewController()
        addLocationVC.locationSavedDelegate = self
        addLocationVC.cancelLocationSelectionDelegate = self
        
        addLocationVC.locationPreselected = selectedLocation != nil
        addLocationVC.selectedLocation = selectedLocation
        
        if let placemark = selectedLocation?.placemark {
            
            addLocationVC.locationMapItem = MKMapItem(placemark: placemark)
        }
        
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = ""
        navigationItem.backBarButtonItem = backButtonItem
        
        self.navigationController?.pushViewController(addLocationVC, animated: true)
    }
    
    
    //MARK: - Dismiss Keyboard
    
    @objc private func dismissKeyboard () {
        
        self.view.endEditing(true)
    }
    
    
    //MARK: - Swipe Down Gesture
    
    @objc private func swipDownGesture () {
        
        if configureCollabTableView.contentOffset.y <= 0 {
            
            //Expands the navBarExtensionView when the view is swipped down
            navBarExtensionHeightAnchor?.constant = 75
    
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
    
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    //MARK: - Edit Photo Button Pressed
    
    @objc private func editPhotoButtonPressed () {
        
        zoomingMethods?.handleZoomOutOnImageView()
        
        photoEditing = true
        
        presentAddPhotoAlert()
    }
    
    
    //MARK: - Delete Photo Button Pressed
    
    @objc private func deletePhotoButtonPressed () {
        
        photoDeleted()
    }
    
    
    //MARK: - Cancel Button Pressed
    
    @objc private func cancelButtonPressed () {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Done Button Pressed
    
    @objc private func doneButtonPressed () {
        
        SVProgressHUD.show()
        
        collab.collabID = UUID().uuidString

        if collab.name.leniantValidationOfTextEntered() {

            firebaseCollab.createCollab(collab: collab) { [weak self] (error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    let notificationScheduler = NotificationScheduler()
                    notificationScheduler.scheduleCollabNotifications(collab: self!.collab)
                    
                    self?.collabCreatedDelegate?.collabCreated(self!.collab)

                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }

        else {

            SVProgressHUD.showError(withStatus: "Please enter a name for this Collab")
        }
    }
    
    
    //MARK: - Edit Button Pressed
    
    @objc private func editButtonPressed () {
        
        SVProgressHUD.show()
        
        if collab.name.leniantValidationOfTextEntered() {

            firebaseCollab.editCollab(collab: collab) { [weak self] (error) in

                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    let notificationScheduler = NotificationScheduler()
                    
                    notificationScheduler.removePendingCollabNotifications(collabID: self!.collab.collabID) {

                        notificationScheduler.scheduleCollabNotifications(collab: self!.collab)
                    }

                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        else {
            
            SVProgressHUD.showError(withStatus: "Please enter a name for this Collab")
        }
    }
}


//MARK: - TableView Datasource and Delegate Extension

extension ConfigureCollabViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedTableView == "details" {
            
            return configurationView ? 12 : 14
        }
        
        else {
            
            return 8
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if selectedTableView == "details" {
            
            if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameConfigurationCell", for: indexPath) as! NameConfigurationCell
                cell.selectionStyle = .none
                
                cell.collab = collab
                cell.nameConfigurationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 3 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "objectiveConfigurationCell", for: indexPath) as! ObjectiveConfigurationCell
                cell.selectionStyle = .none
                
                cell.collab = collab
                cell.objectiveConfigurationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 5 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeConfigurationCell", for: indexPath) as! TimeConfigurationCell
                cell.selectionStyle = .none
                
                cell.titleLabel.text = "Starts"
                
                //If the collab has already had a startTime set
                if let startTime = collab.dates["startTime"]  {
                    
                    cell.starts = startTime
                }
                
                else {
                    
                    collab.dates["startTime"] = Date().adjustTime(roundDown: true)
                    cell.starts = collab.dates["startTime"]
                }

                cell.timeConfigurationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 7 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeConfigurationCell", for: indexPath) as! TimeConfigurationCell
                cell.selectionStyle = .none
                
                cell.titleLabel.text = "Deadline"
                
                //If the collab has already had a deadline set
                if let deadline = collab.dates["deadline"] {
                    
                    cell.ends = deadline
                }
                
                else {
                    
                    collab.dates["deadline"] = Date().addingTimeInterval(86700).adjustTime(roundDown: true)
                    cell.ends = collab.dates["deadline"]
                }
                
                cell.timeConfigurationDelegate = self
                
                
                return cell
            }
            
            else if indexPath.row == 9 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "memberConfigurationCell", for: indexPath) as! MemberConfigurationCell
                cell.selectionStyle = .none
                
                cell.addMembersLabel.text = "Add Members"
                
                cell.collab = collab
                cell.members = collab.addedMembers
                
                cell.memberConfigurationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 11 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "reminderConfigurationCell", for: indexPath) as! ReminderConfigurationCell
                cell.selectionStyle = .none
                
                cell.startTime = collab.dates["startTime"] ?? Date().adjustTime(roundDown: true)
                
                cell.selectedReminders = collab.reminders

                cell.remindersCountLabel.alpha = collab.reminders.count > 0 ? 1 : 0
                cell.remindersCountLabel.text = "\(collab.reminders.count)/2"
                
                cell.reminderConfigurationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 13 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "deleteConfigurationCell", for: indexPath) as! DeleteConfigurationCell
                cell.selectionStyle = .none
                
                cell.configureCollabViewController = self
                
                return cell
            }
        }
        
        else {
            
            if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "photosConfigurationCell", for: indexPath) as! PhotosConfigurationCell
                cell.selectionStyle = .none
                
                cell.selectedPhotoIDs = collab.photoIDs
                cell.selectedPhotos = collab.photos
                
                cell.photosConfigurationDelegate = self
                cell.zoomInDelegate = self
                cell.presentCopiedAnimationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 3 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationsConfigurationCell", for: indexPath) as! LocationsConfigurationCell
                cell.selectionStyle = .none
                
                cell.selectedLocations = collab.locations
                
                cell.locationsConfigurationDelegate = self
                cell.locationSelectedDelegate = self
                cell.cancelLocationSelectionDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 5 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "voiceMemosConfigurationCell", for: indexPath) as! VoiceMemosConfigurationCell
                cell.selectionStyle = .none
                
                cell.voiceMemos = collab.voiceMemos
                
                cell.voiceMemosConfigurationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 7 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "linksConfigurationCell", for: indexPath) as! LinksConfigurationCell
                cell.selectionStyle = .none
                
                cell.links = collab.links
                
                cell.linksConfigurationDelegate = self
                
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
            
                //Buffer cell
                case 0:
                    
                    return 15
                
                //Name Configuration Cell
                case 1:
                    
                    return 80
                   
                //Objective Configuration Cell
                case 3:
                
                    return 120
                    
                //StartTime Configuration Cell
                case 5:
                    
                    if startsCalendarPresented {
                        
                        //If the calendar requires all 6 rows
                        if calendarExpanded {
                            
                            return 543
                        }
                        
                        else {
                            
                            return 511
                        }
                    }
                    
                    else {
                        
                        return 135
                    }
                
                //EndTime Configuration Cell
                case 7:
                    
                    if endsCalendarPresented {
                        
                        //If the calendar requires all 6 rows
                        if calendarExpanded {
                            
                            return 543
                        }
                        
                        else {
                            
                            return 511
                        }
                    }
                    
                    else {
                        
                        return 135
                    }
                 
                //Member Configuration Cell
                case 9:
                    
                    if collab.addedMembers.count == 0 {
                        
                        return 85
                    }
                    
                    else if collab.addedMembers.count == 5 {
                        
                        return 165
                    }
                    
                    else {
                        
                        return 225
                    }
                
                //Reminder Configuration Cell
                case 11:
                    
                    return 130
                
                //Buffer Cell
                case 12:
                
                    return 30
             
                //Delete Configuration Cell
                case 13:
                
                    return 50
                    
                //Buffer Cells
                default:
                    
                    return 25
                
            }
        }
        
        else {
            
            switch indexPath.row {
            
                //Buffer Cell
                case 0:
                    
                    return 15
                
                //Photos Configuration Cell
                case 1:
                    
                    if collab.photos.count > 0 {
                        
                        let heightOfPhotosLabelAndBottomAnchor: CGFloat = 25
                        
                        if collab.photos.count <= 3 {
                            
                            //The item size plus the top and bottom edge insets, i.e. 20
                            let heightOfCollectionView: CGFloat = itemSize + 20
                            
                            //The height of the "attach" button plus a 10 point buffer on the top annd bottom
                            let heightOfAttachButton: CGFloat = 40 + 20
                            
                            return heightOfPhotosLabelAndBottomAnchor + heightOfCollectionView + heightOfAttachButton
                            
                        }
                        
                        else if collab.photos.count < 6 {
                            
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
                
                //Locations Configuration Cell
                case 3:
                    
                    if collab.locations?.count ?? 0 == 0 {
                        
                        return 85
                    }
                    
                    else if collab.locations?.count ?? 0 == 1 {
                        
                        return 285
                    }
                    
                    else if collab.locations?.count ?? 0 == 2 {
                       
                        return 315
                    }
                    
                    else {
                        
                        return 262.5
                    }
                 
                //Voice Memos Configuration Cell
                case 5:
                    
                    if collab.voiceMemos?.count ?? 0 == 0 {
                        
                        return audioVisualizerPresent ? 200 : 85
                    }
                    
                    else if collab.voiceMemos?.count ?? 0 < 3 {
                    
                        return audioVisualizerPresent ? floor(itemSize) + 194 : floor(itemSize) + 105
                    }
                    
                    else {
                        
                        return floor(itemSize) + 50
                    }
                
                //Links Configuration Cell
                case 7:
                    
                    if collab.links?.count ?? 0 == 0 {
                        
                        return 85
                    }
                    
                    else if collab.links?.count ?? 0 < 3 {
                        
                        return 185
                    }
                    
                    else if collab.links?.count ?? 0 < 6 {
                        
                        return 212.5
                    }
                    
                    else {
                        
                        return 162.5
                    }
                
                //Buffer Cells
                default:
                    
                    return 25
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let reminderCell = cell as? ReminderConfigurationCell {
            
            var collabReminders = collab.reminders
            collabReminders.sort()
            
            if let firstReminder = collabReminders.first {
                
                reminderCell.remindersCollectionView.scrollToItem(at: IndexPath(item: firstReminder, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    
    //MARK: - ScrollView Did Scroll
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= 0 {
            
            //If the navBarExtensionView hasn't been completely shrunken yet
            if ((navBarExtensionHeightAnchor?.constant ?? 0) - scrollView.contentOffset.y) > 0 {
                
                navBarExtensionHeightAnchor?.constant -= scrollView.contentOffset.y
                scrollView.contentOffset.y = 0
            }
            
            else {
                
                navBarExtensionHeightAnchor?.constant = 0
            }
        }
        
        else {
            
            //If the navBarExtensionView hasn't been completely expanded
            if navBarExtensionHeightAnchor?.constant ?? 0 < 70 {

                navBarExtensionHeightAnchor?.constant = 70
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {

                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}


//MARK: - UIGesture Recognizor Delegate

extension ConfigureCollabViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


//MARK: - Name Configuration Protocol Extension

extension ConfigureCollabViewController: NameConfigurationProtocol {
    
    func nameEntered (_ text: String) {
        
        collab.name = text
    }
}


//MARK: - Objective Configuration Protocol Extension

extension ConfigureCollabViewController: ObjectiveConfigurationProtocol {
    
    func objectiveEntered(_ text: String) {
        
        collab.objective = text
    }
}


//MARK: - Time Configuration Protocol Extension

extension ConfigureCollabViewController: TimeConfigurationProtocol {
    
    func presentCalendar(startsCalendar: Bool) {
        
        //If the starts calendar should be presented
        if startsCalendar {
            
            //If the ends calendar is currently presented; this will stagger the animations required to present the starts calendar
            if endsCalendarPresented {
                
                //Removing the calendar from ends cell
                if let cell = self.configureCollabTableView.cellForRow(at: IndexPath(row: 7, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithoutCalendar()
                }
                
                //Animation of the tableView after a 0.25 delay to improve the animation of the ends calendar removal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.endsCalendarPresented = false
                    
                    self.configureCollabTableView.beginUpdates()
                    self.configureCollabTableView.endUpdates()
                }
                
                //Configuring the calendar in the starts cell after the ends calendar has been removed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    
                    if let cell = self.configureCollabTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                        
                        cell.reconfigureCellWithCalendar()
                    }
                }
                
                //Animation of the tableView 0.25 seconds after the starts calendar has begun to be configured to improve animations
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    
                    self.startsCalendarPresented = true
                    
                    self.configureCollabTableView.beginUpdates()
                    self.configureCollabTableView.endUpdates()
                    
                    self.configureCollabTableView.scrollToRow(at: IndexPath(row: 5, section: 0), at: .top, animated: true)
                }
            }
            
            //If the ends calendar isn't currently presented
            else {
                
                //Configuring the starts calendar in the starts cell
                if let cell = self.configureCollabTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithCalendar()
                }
                
                //Animation of the tableView after a 0.25 seconds delay to improve animations
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.startsCalendarPresented = true
                    
                    self.configureCollabTableView.beginUpdates()
                    self.configureCollabTableView.endUpdates()
                    
                    self.configureCollabTableView.scrollToRow(at: IndexPath(row: 5, section: 0), at: .top, animated: true)
                }
            }
        }
        
        //Comments required for this block exist in the previous block
        else {
            
            if startsCalendarPresented {
                
                if let cell = self.configureCollabTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithoutCalendar()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.startsCalendarPresented = false
                    
                    self.configureCollabTableView.beginUpdates()
                    self.configureCollabTableView.endUpdates()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    
                    if let cell = self.configureCollabTableView.cellForRow(at: IndexPath(row: 7, section: 0)) as? TimeConfigurationCell {
                        
                        cell.reconfigureCellWithCalendar()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    
                    self.endsCalendarPresented = true
                    
                    self.configureCollabTableView.beginUpdates()
                    self.configureCollabTableView.endUpdates()
                    
                    self.configureCollabTableView.scrollToRow(at: IndexPath(row: 7, section: 0), at: .top, animated: true)
                }
            }
            
            else {
                
                if let cell = self.configureCollabTableView.cellForRow(at: IndexPath(row: 7, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithCalendar()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.endsCalendarPresented = true
                    
                    self.configureCollabTableView.beginUpdates()
                    self.configureCollabTableView.endUpdates()
                    
                    self.configureCollabTableView.scrollToRow(at: IndexPath(row: 7, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    func dismissCalendar(startsCalendar: Bool) {
        
        if startsCalendar {
            
            startsCalendarPresented = false
        }
        
        else {
            
            endsCalendarPresented = false
        }
        
        configureCollabTableView.beginUpdates()
        configureCollabTableView.endUpdates()
        
        //Expands the navBarExtensionView when the view is swipped down
        navBarExtensionHeightAnchor?.constant = 75

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {

            self.view.layoutIfNeeded()
        }
    }
    
    func expandCalendarCellHeight(expand: Bool) {
        
        calendarExpanded = expand
        
        configureCollabTableView.beginUpdates()
        configureCollabTableView.endUpdates()
    }
    
    func timeEntered(startTime: Date?, endTime: Date?) {
        
        if let time = startTime, let deadline = collab.dates["deadline"] {
        
            collab.dates["startTime"] = time
            
            if time >= deadline {
                
                collab.dates["deadline"] = Calendar.current.date(byAdding: .day, value: 1, to: time)
                
                if let cell = configureCollabTableView.cellForRow(at: IndexPath(row: 7, section: 0)) as? TimeConfigurationCell {
                    
                    cell.ends = collab.dates["deadline"]
                }
            }
        }
        
        else if let time = endTime, let startTime = collab.dates["startTime"] {
            
            collab.dates["deadline"] = time
            
            if time <= startTime {
                
                collab.dates["startTime"] = Calendar.current.date(byAdding: .day, value: -1, to: time)
                
                if let cell = configureCollabTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                    
                    cell.starts = collab.dates["startTime"]
                }
            }
        }
        
        if let cell = configureCollabTableView.cellForRow(at: IndexPath(row: 11, section: 0)) as? ReminderConfigurationCell {
            
            cell.startTime = collab.dates["startTime"]
            
            configureCollabTableView.beginUpdates()
            configureCollabTableView.endUpdates()
        }
    }
}


//MARK: - Member Configuration Protocol Extension

extension ConfigureCollabViewController: MemberConfigurationProtocol, MembersAdded {
    
    func moveToAddMemberView () {
        
        self.moveToAddMembersView()
    }
    
    func membersAdded(_ addedMembers: [Any]) {
        
        collab.addedMembers = []
        
        for addedMember in addedMembers {

            if let friend = addedMember as? Friend {

                collab.addedMembers.append(friend)
            }
            
            else if let member = addedMember as? Member {
                
                collab.addedMembers.append(member)
            }
        }

        self.navigationController?.popViewController(animated: true)

        if let cell = configureCollabTableView.cellForRow(at: IndexPath(row: 9, section: 0)) as? MemberConfigurationCell {

            cell.members = collab.addedMembers
        }

        configureCollabTableView.beginUpdates()
        configureCollabTableView.endUpdates()

        configureCollabTableView.scrollToRow(at: IndexPath(row: 9, section: 0), at: .top, animated: true)
    }
    
    func memberDeleted (_ userID: String) {
        
        var filteredMembers: [Any] = []
        
        for addedMember in collab.addedMembers {
            
            if let friend = addedMember as? Friend {
                
                if friend.userID != userID {
                    
                    filteredMembers.append(friend)
                }
            }
            
            else if let member = addedMember as? Member {
                
                if member.userID != userID {
                    
                    filteredMembers.append(member)
                }
            }
        }
        
        collab.addedMembers = filteredMembers

        if let cell = configureCollabTableView.cellForRow(at: IndexPath(row: 9, section: 0)) as? MemberConfigurationCell {
            
            cell.members = collab.addedMembers
        }

        configureCollabTableView.beginUpdates()
        configureCollabTableView.endUpdates()
    }
}


//MARK: - Reminder Configuration Protocol Extension

extension ConfigureCollabViewController: ReminderConfigurationProtocol {
    
    func reminderSelected (_ selectedReminders: [Int]) {
        
        collab.reminders = selectedReminders
    }
    
    func reminderDeleted (_ deletedReminder: Int) {
        
        collab.reminders.removeAll(where: { $0 == deletedReminder })
    }
}


//MARK: - Photos Configuration Protocol Extension

extension ConfigureCollabViewController: PhotosConfigurationProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentAddPhotoAlert() {
        
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
                
                let photoID = UUID().uuidString
                collab.photoIDs.append(photoID)
                collab.photos[photoID] = selectedImage
            }
            
            else {
                
                photoEdited(newImage: selectedImage)
            }
            
            configureCollabTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
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


//MARK: - Locations Configuration Protocol Extension

extension ConfigureCollabViewController: LocationsConfigurationProtocol {
    
    func attachLocationSelected() {
        
        moveToAddLocationView()
    }
}


//MARK: - Location Saved Protocol Extension

extension ConfigureCollabViewController: LocationSavedProtocol {
    
    func locationSaved(_ location: Location?) {
        
        //If the location hasn't been added yet
        if collab.locations?.first(where: { $0.locationID == location?.locationID}) == nil {
            
            if location != nil && collab.locations == nil {
                
                collab.locations = []
                collab.locations?.append(location!)
            }
            
            else if location != nil {
                
                collab.locations?.append(location!)
            }
        }
        
        //If the location has been added
        else {
            
            collab.locations?.removeAll(where: { $0.locationID == location?.locationID })
            
            if location != nil {
                
                collab.locations?.append(location!)
            }
        }
        
        configureCollabTableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
    }
}

extension ConfigureCollabViewController: LocationSelectedProtocol {
    
    func locationSelected (_ location: Location?) {
        
        selectedLocation = location
        
        moveToAddLocationView()
    }
}

extension ConfigureCollabViewController: CancelLocationSelectionProtocol {
    
    func selectionCancelled(_ locationID: String?) {
        
        if locationID != nil {
            
            collab.locations?.removeAll(where: { $0.locationID == locationID! })
            selectedLocation = nil
            
            configureCollabTableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
        }
    }
}


//MARK: - Voice Memos Configuration Protocol Extension

extension ConfigureCollabViewController: VoiceMemosConfigurationProtocol {
    
    func attachMemoSelected () {
        
        audioVisualizerPresent = true
        
        configureCollabTableView.beginUpdates()
        configureCollabTableView.endUpdates()
    }
    
    func recordingCancelled () {
        
        audioVisualizerPresent = false
        
        configureCollabTableView.beginUpdates()
        configureCollabTableView.endUpdates()
    }
    
    func voiceMemoSaved(_ voiceMemo: VoiceMemo) {
        
        audioVisualizerPresent = false
        
        if collab.voiceMemos == nil {
            
            collab.voiceMemos = []
        }
        
        collab.voiceMemos?.append(voiceMemo)
        
        configureCollabTableView.beginUpdates()
        configureCollabTableView.endUpdates()
    }
    
    func voiceMemoNameChanged (_ voiceMemoID: String, _ name: String?){
        
        if let index = collab.voiceMemos?.firstIndex(where: { $0.voiceMemoID == voiceMemoID }) {
            
            if name != nil, name!.leniantValidationOfTextEntered() {
                
                collab.voiceMemos?[index].name = name
            }
            
            else {
                
                collab.voiceMemos?[index].name = nil
            }
        }
    }
    
    func voiceMemoDeleted (_ voiceMemo: VoiceMemo) {
        
        collab.voiceMemos?.removeAll(where: { $0.voiceMemoID == voiceMemo.voiceMemoID })
            
        if let cell = configureCollabTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? VoiceMemosConfigurationCell {
            
            cell.voiceMemos = collab.voiceMemos
        }

        configureCollabTableView.beginUpdates()
        configureCollabTableView.endUpdates()
    }
}


//MARK: - Links Configuration Protocol Extension

extension ConfigureCollabViewController: LinksConfigurationProtocol {
    
    func attachLinkSelected() {
        
        var link = Link()
        link.linkID = UUID().uuidString
        
        if collab.links == nil {
            
            collab.links = [link]
        }
        
        else {
            
            collab.links?.append(link)
        }
        
        if let cell = configureCollabTableView.cellForRow(at: IndexPath(row: 7, section: 0)) as? LinksConfigurationCell {

            cell.links = collab.links
        }
        
        configureCollabTableView.beginUpdates()
        configureCollabTableView.endUpdates()
    }
    
    func linkEntered (_ linkID: String, _ url: String) {
        
        if let linkIndex = collab.links?.firstIndex(where: { $0.linkID == linkID }) {
            
            collab.links?[linkIndex].url = url
        }
    }
    
    func linkIconSaved (_ linkID: String, _ icon: UIImage?) {
        
        if let linkIndex = collab.links?.firstIndex(where: { $0.linkID == linkID }) {
            
            collab.links?[linkIndex].icon = icon
        }
    }
    
    func linkRenamed (_ linkID: String, _ name: String) {
        
        if let linkIndex = collab.links?.firstIndex(where: { $0.linkID == linkID }) {
            
            collab.links?[linkIndex].name = name
        }
    }
    
    func linkDeleted (_ linkID: String) {
        
        collab.links?.removeAll(where: { $0.linkID == linkID })
        
        if let cell = configureCollabTableView.cellForRow(at: IndexPath(row: 7, section: 0)) as? LinksConfigurationCell {

            cell.links = collab.links
        }
        
        configureCollabTableView.beginUpdates()
        configureCollabTableView.endUpdates()
    }
}

//MARK: - Zoom In Protocol Extension

extension ConfigureCollabViewController: ZoomInProtocol {
    
    func zoomInOnPhotoImageView(photoImageView: UIImageView) {
        
        selectedPhoto = photoImageView.image
        
        zoomingMethods = ZoomingImageViewMethods(on: photoImageView, cornerRadius: 8, with: [editPhotoButton, deletePhotoButton])
        zoomingMethods?.performZoom()
    }
}

//MARK: - Present Copied Animation Protocol Extension

extension ConfigureCollabViewController: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        let navBarFrame = navigationController?.navigationBar.convert(navigationController?.navigationBar.frame ?? .zero, to: keyWindow) ?? .zero
        
        //12.5 is equal to 10 point top anchor the photosCollectionView has from the navBar plus an extra 10 point buffer
        copiedAnimationView?.presentCopiedAnimation(topAnchor: navBarFrame.minY + 10)
    }
}
