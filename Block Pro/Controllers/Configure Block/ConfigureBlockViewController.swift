//
//  ConfigureBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/26/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD

class ConfigureBlockViewController: UIViewController {
    
    let navBarExtensionView = UIView()
    lazy var segmentControl = CustomSegmentControl(parentViewController: self)
    
    let configureBlockTableView = UITableView()
    
    lazy var editPhotoButton: UIButton = configureEditButton()
    lazy var deletePhotoButton: UIButton = configureDeleteButton()
    
    var copiedAnimationView: CopiedAnimationView?
    
    var navBarExtensionHeightAnchor: NSLayoutConstraint?
    var tableViewTopAnchor: NSLayoutConstraint?
    
    let firebaseBlock = FirebaseBlock.sharedInstance
    
    let currentUser = CurrentUser.sharedInstance
    var collab: Collab?
    var block = Block()
    
    var selectedTableView = "details"
    
    var startsCalendarPresented: Bool = false
    var endsCalendarPresented: Bool = false
    var calendarExpanded: Bool = false
    
    var selectedPhoto: UIImage?
    var photoEditing: Bool = false
    
    var selectedLocation: Location?
    
    var audioVisualizerPresent: Bool = false
    
    var zoomingMethods: ZoomingImageViewMethods?
    
    weak var blockCreatedDelegate: BlockCreatedProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBarButtonItems()
        
        self.isModalInPresentation = true
        self.view.backgroundColor = .white

        configureTableView(configureBlockTableView) //Call first to allow for the navigation bar to work properly
        configureNavBarExtensionView()
        configureGestureRecognizors()
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
    
    private func configureBarButtonItems () {
        
        if self.navigationController?.viewControllers.count == 1 {
            
            let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonPressed))
            cancelBarButtonItem.style = .done
            
            self.navigationItem.leftBarButtonItem = cancelBarButtonItem
            
            let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            rightBarButtonItem.style = .done
            
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
        
        else {
            
            let rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(editButtonPressed))
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
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        
        tableView.register(NameConfigurationCell.self, forCellReuseIdentifier: "nameConfigurationCell")
        tableView.register(TimeConfigurationCell.self, forCellReuseIdentifier: "timeConfigurationCell")
        tableView.register(MemberConfigurationCell.self, forCellReuseIdentifier: "memberConfigurationCell")
        tableView.register(ReminderConfigurationCell.self, forCellReuseIdentifier: "reminderConfigurationCell")
        
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
        
        tableViewTopAnchor = configureBlockTableView.topAnchor.constraint(equalTo: navBarExtensionView.bottomAnchor, constant: 0)
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
            
            UIView.transition(with: configureBlockTableView, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.configureBlockTableView.reloadData()
            }
        }
        
        else {
            
            selectedTableView = "attachments"
            
            UIView.transition(with: configureBlockTableView, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.configureBlockTableView.reloadData()
            }
        }
    }
    
    
    //MARK: - Photo Edited
    
    private func photoEdited (newImage: UIImage) {
        
        for photo in block.photos ?? [:] {
            
            if photo.value == selectedPhoto {
                
                block.photos?[photo.key] = newImage
                selectedPhoto = nil
                
                break
            }
        }
        
        photoEditing = false
    }
    
    
    //MARK: - Photo Deleted
    
    private func photoDeleted () {
        
        for photo in block.photos ?? [:] {
            
            if photo.value == selectedPhoto {
                
                block.photoIDs?.removeAll(where: { $0 == photo.key })
                block.photos?.removeValue(forKey: photo.key)
                selectedPhoto = nil
                
                break
            }
        }
        
        configureBlockTableView.reloadSections([0], with: .none)
        
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
    
    
    //MARK: - Move to Add Members View
    
    private func moveToAddMembersView () {
        
        let addMembersVC: AddMembersViewController = AddMembersViewController()
        addMembersVC.membersAddedDelegate = self
        addMembersVC.headerLabelText = "Assign Members"
        
        var members = collab?.currentMembers
        members?.removeAll(where: { $0.userID == currentUser.userID })
        addMembersVC.members = members
        
        addMembersVC.addedMembers = [:]
        
        //Setting the added members for the AddMembersViewController
        for member in block.members ?? [] {
            
            if member.userID != currentUser.userID {
                
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
        
        if configureBlockTableView.contentOffset.y <= 0 {
            
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
        
        block.blockID = UUID().uuidString
        
        if let name = block.name, name.leniantValidationOfTextEntered() {
            
            //Collab Block
            if collab != nil {
                
                firebaseBlock.createCollabBlock(collabID: collab?.collabID ?? "", block: block) { [weak self] (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        let notificationScheduler = NotificationScheduler()
                        notificationScheduler.scheduleBlockNotifications(collab: self!.collab, self!.block)
                        
                        self?.blockCreatedDelegate?.blockCreated(self!.block)
                        
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
            //Personal Block
            else {
                
                firebaseBlock.createPersonalBlock(block: block) { [weak self] (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        let notificationScheduler = NotificationScheduler()
                        notificationScheduler.scheduleBlockNotifications(self!.block)
                        
                        self?.blockCreatedDelegate?.blockCreated(self!.block)
                        
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
        else {
            
            SVProgressHUD.showError(withStatus: "Please enter a name for this Block")
        }
    }
    
    
    //MARK: - Edit Button Pressed
    
    @objc private func editButtonPressed () {
        
        SVProgressHUD.show()
        
        if let name = block.name, name.leniantValidationOfTextEntered() {
            
            //Collab Block
            if collab != nil {
                
                firebaseBlock.editCollabBlock(collabID: collab?.collabID ?? "", block: block) { [weak self] (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        let notificationScheduler = NotificationScheduler()
                        
                        notificationScheduler.removePendingBlockNotifications(self!.block.blockID!) {
                            
                            notificationScheduler.scheduleBlockNotifications(collab: self!.collab, self!.block)
                        }
                        
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            //Personal Block
            else {
                
                firebaseBlock.editPersonalBlock(block: block) { [weak self] (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        let notificationScheduler = NotificationScheduler()

                        notificationScheduler.removePendingBlockNotifications(self!.block.blockID!) {

                            notificationScheduler.scheduleBlockNotifications(self!.block)
                        }
                        
//                        self?.blockCreatedDelegate?.blockCreated(self!.block)
                        
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}


//MARK: - TableView Datasource and Delegate Extension

extension ConfigureBlockViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedTableView == "details" {
            
            return collab != nil ? 10 : 8
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
                
                cell.block = block
                cell.nameConfigurationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 3 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeConfigurationCell", for: indexPath) as! TimeConfigurationCell
                cell.selectionStyle = .none
                
                cell.titleLabel.text = "Starts"
                
                cell.collab = collab
                
                //Signifying it hasn't been set yet
                if block.starts == nil {
                    
                    if let deadline = collab?.dates["deadline"] {
                        
                        //If the current date is before the deadline of the collab
                        if Date() < Calendar.current.date(byAdding: .minute, value: -5, to: deadline) ?? Date() {
                            
                            block.starts = Date().adjustTime(roundDown: true)
                        }
                        
                        //If the current date is after the deadline of the collab
                        else {
                            
                            block.starts = (Calendar.current.date(byAdding: .minute, value: -5, to: deadline) ?? Date()).adjustTime(roundDown: true)
                        }
                    }
                    
                    else {
                        
                        block.starts = Date().adjustTime(roundDown: true)
                    }
                }
                
                cell.starts = block.starts
                
                cell.timeConfigurationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 5 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeConfigurationCell", for: indexPath) as! TimeConfigurationCell
                cell.selectionStyle = .none
                
                cell.titleLabel.text = "Ends"
                
                cell.collab = collab
                
                //Signifying it hasn't been set yet
                if block.ends == nil {
                    
                    if let deadline = collab?.dates["deadline"] {
                        
                        //If the current date is before the deadline of the collab
                        if Date() < Calendar.current.date(byAdding: .minute, value: -5, to: deadline) ?? Date() {
                            
                            block.ends = Date().adjustTime(roundDown: false)
                        }
                        
                        //If the current date is after the deadline of the collab
                        else {
                            
                            block.ends = (Calendar.current.date(byAdding: .minute, value: -5, to: deadline) ?? Date()).adjustTime(roundDown: false)
                        }
                    }
                    
                    else {
                        
                        block.ends = Date().adjustTime(roundDown: false)
                    }
                }
                
                cell.ends = block.ends
                
                cell.timeConfigurationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 7 {
                
                //Collab Block
                if collab != nil {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "memberConfigurationCell", for: indexPath) as! MemberConfigurationCell
                    cell.selectionStyle = .none
                    
                    cell.memberConfigurationDelegate = self
                    
                    cell.addMembersLabel.text = "Assign Members"
                    
                    cell.editingCell = !(self.navigationController?.viewControllers.count == 1)
                    
                    cell.collab = collab
                    cell.members = block.members
                    
                    return cell
                }
                
                //Personal Block
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reminderConfigurationCell", for: indexPath) as! ReminderConfigurationCell
                    cell.selectionStyle = .none
                    
                    cell.startTime = block.starts
                    
                    cell.selectedReminders = block.reminders ?? []
                    
                    cell.remindersCountLabel.alpha = block.reminders?.count ?? 0 > 0 ? 1 : 0
                    cell.remindersCountLabel.text = "\(block.reminders?.count ?? 0)/2"
                    
                    cell.reminderConfigurationDelegate = self
                    
                    return cell
                }
            }
            
            else if indexPath.row == 9 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "reminderConfigurationCell", for: indexPath) as! ReminderConfigurationCell
                cell.selectionStyle = .none
                
                cell.startTime = block.starts
                
                cell.selectedReminders = block.reminders ?? []
                
                cell.remindersCountLabel.alpha = block.reminders?.count ?? 0 > 0 ? 1 : 0
                cell.remindersCountLabel.text = "\(block.reminders?.count ?? 0)/2"
                
                cell.reminderConfigurationDelegate = self
                
                return cell
            }
        }
        
        else {
            
            if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "photosConfigurationCell", for: indexPath) as! PhotosConfigurationCell
                cell.selectionStyle = .none
                
                cell.selectedPhotoIDs = block.photoIDs
                cell.selectedPhotos = block.photos
                
                cell.photosConfigurationDelegate = self
                cell.zoomInDelegate = self
                cell.presentCopiedAnimationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 3 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationsConfigurationCell", for: indexPath) as! LocationsConfigurationCell
                cell.selectionStyle = .none
                
                cell.selectedLocations = block.locations
                
                cell.locationsConfigurationDelegate = self
                cell.locationSelectedDelegate = self
                cell.cancelLocationSelectionDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 5 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "voiceMemosConfigurationCell", for: indexPath) as! VoiceMemosConfigurationCell
                cell.selectionStyle = .none
                
                cell.voiceMemos = block.voiceMemos
                
                cell.voiceMemosConfigurationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 7 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "linksConfigurationCell", for: indexPath) as! LinksConfigurationCell
                cell.selectionStyle = .none
                
                cell.links = block.links
                
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
                    
                //StartTime Configuration Cell
                case 3:
                    
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
                case 5:
                    
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
                 
                //Member or Reminder Configuration Cell
                case 7:
                    
                    //Collab Block
                    if collab != nil {
                        
                        if self.navigationController?.viewControllers.count == 1 {
                            
                            if (collab?.currentMembers.count ?? 0 > 1) && (block.members?.count ?? 0 == (collab?.currentMembers.count ?? 0) - 1) {
                                
                                return 160
                            }
                            
                            else if block.members?.count ?? 0 > 0 {
                                
                                return 225
                            }
                            
                            else {
                                
                                return 85
                            }
                        }
                        
                        else {
                            
                            if block.members?.count ?? 0 == collab?.currentMembers.count ?? 0 {
                                
                                return 160
                            }
                            
                            else if block.members?.count ?? 0 > 0 {
                                
                                return 225
                            }
                            
                            else {
                                
                                return 85
                            }
                        }
                    }
                    
                    //Personal Block
                    else {
                        
                        return 130
                    }
                
                //Reminder Configuration Cell
                case 9:
                    
                    return 130
                 
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
                    
                    if block.photos?.count ?? 0 > 0 {
                        
                        let heightOfPhotosLabelAndBottomAnchor: CGFloat = 25
                        
                        if block.photos?.count ?? 0 <= 3 {
                            
                            //The item size plus the top and bottom edge insets, i.e. 20
                            let heightOfCollectionView: CGFloat = itemSize + 20
                            
                            //The height of the "attach" button plus a 10 point buffer on the top annd bottom
                            let heightOfAttachButton: CGFloat = 40 + 20
                            
                            return heightOfPhotosLabelAndBottomAnchor + heightOfCollectionView + heightOfAttachButton
                            
                        }
                        
                        else if block.photos?.count ?? 0 < 6 {
                            
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
                    
                    if block.locations?.count ?? 0 == 0 {
                        
                        return 85
                    }
                    
                    else if block.locations?.count ?? 0 == 1 {
                        
                        return 285
                    }
                    
                    else if block.locations?.count ?? 0 == 2 {
                       
                        return 315
                    }
                    
                    else {
                        
                        return 262.5
                    }
                 
                //Voice Memos Configuration Cell
                case 5:
                    
                    if block.voiceMemos?.count ?? 0 == 0 {
                        
                        return audioVisualizerPresent ? 200 : 85
                    }
                    
                    else if block.voiceMemos?.count ?? 0 < 3 {
                    
                        return audioVisualizerPresent ? floor(itemSize) + 194 : floor(itemSize) + 105
                    }
                    
                    else {
                        
                        return floor(itemSize) + 50
                    }
                
                //Links Configuration Cell
                case 7:
                    
                    if block.links?.count ?? 0 == 0 {
                        
                        return 85
                    }
                    
                    else if block.links?.count ?? 0 < 3 {
                        
                        return 185
                    }
                    
                    else if block.links?.count ?? 0 < 6 {
                        
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
        
        if let reminderCell = cell as? ReminderConfigurationCell, var blockReminders = block.reminders {
            
            blockReminders.sort()
            
            if let firstReminder = blockReminders.first {
                
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

extension ConfigureBlockViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


//MARK: - Name Configuration Protocol Extension

extension ConfigureBlockViewController: NameConfigurationProtocol {
    
    func nameEntered (_ text: String) {
        
        block.name = text
    }
}


//MARK: - Time Configuration Protocol Extension

extension ConfigureBlockViewController: TimeConfigurationProtocol {
    
    func presentCalendar (startsCalendar: Bool) {
        
        //If the starts calendar should be presented
        if startsCalendar {
            
            //If the ends calendar is currently presented; this will stagger the animations required to present the starts calendar
            if endsCalendarPresented {
                
                //Removing the calendar from ends cell
                if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithoutCalendar()
                }
                
                //Animation of the tableView after a 0.25 delay to improve the animation of the ends calendar removal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.endsCalendarPresented = false
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                }
                
                //Configuring the calendar in the starts cell after the ends calendar has been removed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    
                    if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TimeConfigurationCell {
                        
                        cell.reconfigureCellWithCalendar()
                    }
                }
                
                //Animation of the tableView 0.25 seconds after the starts calendar has begun to be configured to improve animations
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    
                    self.startsCalendarPresented = true
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                    
                    self.configureBlockTableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .top, animated: true)
                }
            }
            
            //If the ends calendar isn't currently presented
            else {
                
                //Configuring the starts calendar in the starts cell
                if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithCalendar()
                }
                
                //Animation of the tableView after a 0.25 seconds delay to improve animations
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.startsCalendarPresented = true
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                    
                    self.configureBlockTableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .top, animated: true)
                }
            }
        }
        
        //Comments required for this block exist in the previous block
        else {
            
            if startsCalendarPresented {
                
                if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithoutCalendar()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.startsCalendarPresented = false
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    
                    if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                        
                        cell.reconfigureCellWithCalendar()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    
                    self.endsCalendarPresented = true
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                    
                    self.configureBlockTableView.scrollToRow(at: IndexPath(row: 5, section: 0), at: .top, animated: true)
                }
            }
            
            else {
                
                if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithCalendar()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.endsCalendarPresented = true
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                    
                    self.configureBlockTableView.scrollToRow(at: IndexPath(row: 5, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    func dismissCalendar (startsCalendar: Bool) {
        
        if startsCalendar {
            
            startsCalendarPresented = false
        }
        
        else {
            
            endsCalendarPresented = false
        }
        
        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
        
        //Expands the navBarExtensionView when the view is swipped down
        navBarExtensionHeightAnchor?.constant = 75

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {

            self.view.layoutIfNeeded()
        }
    }
    
    func expandCalendarCellHeight (expand: Bool) {
        
        calendarExpanded = expand
        
        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
    }
    
    func timeEntered (startTime: Date?, endTime: Date?) {
        
        let formatter = DateFormatter()
        
        if let time = startTime {
            
            block.starts = time //Setting the selected start time
            
            //Ensures that the blocks dates match and that the start time is before the end time
            formatter.dateFormat = "yyyy MM dd "
            let newDate = formatter.string(from: time)
            
            formatter.dateFormat = "h:mm a"
            let endTime = formatter.string(from: block.ends ?? Date())

            formatter.dateFormat = "yyyy MM dd h:mm a"
            
            //If the end time is before the start time, likely because of the time and not the date
            if let adjustedEndTime = formatter.date(from: newDate + endTime), adjustedEndTime <= time {
                
                //Incrementing the end time by 5 minutes
                block.ends = Calendar.current.date(byAdding: .minute, value: 5, to: time)
            }
            
            else {
                
                block.ends = formatter.date(from: newDate + endTime)
            }
            
            //Setting the end time of the endTime configuration cell
            if let cell = configureBlockTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                
                cell.ends = block.ends
            }
        }
        
        else if let time = endTime {
            
            block.ends = time //Setting the selected end time
            
            //Ensures that the blocks dates match and that the start time is before the end time
            formatter.dateFormat = "yyyy MM dd "
            let newDate = formatter.string(from: time)
            
            formatter.dateFormat = "h:mm a"
            let startTime = formatter.string(from: block.starts ?? Date())

            formatter.dateFormat = "yyyy MM dd h:mm a"
            
            //If the end time is before the start time, likely because of the time and not the date
            if let adjustedStartTime = formatter.date(from: newDate + startTime), adjustedStartTime >= time {
                
                //Decrementing the start time by 5 minutes
                block.starts = Calendar.current.date(byAdding: .minute, value: -5, to: time)
            }
            
            else {
                
                block.starts = formatter.date(from: newDate + startTime)
            }
            
            //Setting the start time of the startTime configuration cell
            if let cell = configureBlockTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TimeConfigurationCell {
                
                cell.starts = block.starts
            }
        }
        
        //Setting the start time for the reminder configuration cell
        if let cell = configureBlockTableView.cellForRow(at: IndexPath(row: collab != nil ? 9 : 7, section: 0)) as? ReminderConfigurationCell {
            
            cell.startTime = block.starts
            
            configureBlockTableView.beginUpdates()
            configureBlockTableView.endUpdates()
        }
    }
}


//MARK: - Member Configuration Protocol Extension

extension ConfigureBlockViewController: MemberConfigurationProtocol, MembersAdded {
    
    func moveToAddMemberView () {
        
        self.moveToAddMembersView()
    }
    
    func membersAdded(_ addedMembers: [Any]) {
        
        if block.members == nil {
            
            block.members = []
        }
        
        else {
            
            block.members?.removeAll(where: { $0.userID != currentUser.userID })
        }
        
        for addedMember in addedMembers {
            
            if let member = addedMember as? Member {
                
                block.members?.append(member)
            }
        }
        
        self.navigationController?.popViewController(animated: true)
        
        if let cell = configureBlockTableView.cellForRow(at: IndexPath(row: 7, section: 0)) as? MemberConfigurationCell {
            
            cell.members = block.members
        }
        
        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
        
        configureBlockTableView.scrollToRow(at: IndexPath(row: 7, section: 0), at: .top, animated: true)
    }
    
    func memberDeleted (_ userID: String) {
        
        block.members?.removeAll(where: { $0.userID == userID })
        
        if let cell = configureBlockTableView.cellForRow(at: IndexPath(row: 7, section: 0)) as? MemberConfigurationCell {
            
            cell.members = block.members
        }
        
        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
    }
}


//MARK: - Reminder Configuration Protocol Extension

extension ConfigureBlockViewController: ReminderConfigurationProtocol {
    
    func reminderSelected (_ selectedReminders: [Int]) {
        
        block.reminders = selectedReminders
    }
    
    func reminderDeleted (_ deletedReminder: Int) {
        
        block.reminders?.removeAll(where: { $0 == deletedReminder })
    }
}


//MARK: - Photos Configuration Protocol Extension

extension ConfigureBlockViewController: PhotosConfigurationProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
                
                if block.photos == nil {
                    
                    block.photoIDs = []
                    block.photos = [:]
                    
                    let photoID = UUID().uuidString
                    block.photoIDs?.append(photoID)
                    block.photos?[photoID] = selectedImage
                }
                
                else {
                    
                    let photoID = UUID().uuidString
                    block.photoIDs?.append(photoID)
                    block.photos?[photoID] = selectedImage
                }
            }
            
            else {
                
                photoEdited(newImage: selectedImage)
            }
            
            configureBlockTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
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

extension ConfigureBlockViewController: LocationsConfigurationProtocol {
    
    func attachLocationSelected() {
        
        moveToAddLocationView()
    }
}


//MARK: - Location Saved Protocol Extension

extension ConfigureBlockViewController: LocationSavedProtocol {
    
    func locationSaved(_ location: Location?) {
        
        //If the location hasn't been added yet
        if block.locations?.first(where: { $0.locationID == location?.locationID}) == nil {
            
            if location != nil && block.locations == nil {
                
                block.locations = []
                block.locations?.append(location!)
            }
            
            else if location != nil {
                
                block.locations?.append(location!)
            }
        }
        
        //If the location has been added
        else {
            
            block.locations?.removeAll(where: { $0.locationID == location?.locationID })
            
            if location != nil {
                
                block.locations?.append(location!)
            }
        }
        
        configureBlockTableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
    }
}

extension ConfigureBlockViewController: LocationSelectedProtocol {
    
    func locationSelected (_ location: Location?) {
        
        selectedLocation = location
        
        moveToAddLocationView()
    }
}

extension ConfigureBlockViewController: CancelLocationSelectionProtocol {
    
    func selectionCancelled(_ locationID: String?) {
        
        if locationID != nil {
            
            block.locations?.removeAll(where: { $0.locationID == locationID! })
            selectedLocation = nil
            
            configureBlockTableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
        }
    }
}


//MARK: - Voice Memos Configuration Protocol Extension

extension ConfigureBlockViewController: VoiceMemosConfigurationProtocol {
    
    func attachMemoSelected () {
        
        audioVisualizerPresent = true
        
        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
    }
    
    func recordingCancelled () {
        
        audioVisualizerPresent = false
        
        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
    }
    
    func voiceMemoSaved(_ voiceMemo: VoiceMemo) {
        
        audioVisualizerPresent = false
        
        if block.voiceMemos == nil {
            
            block.voiceMemos = []
        }
        
        block.voiceMemos?.append(voiceMemo)
        
        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
    }
    
    func voiceMemoNameChanged (_ voiceMemoID: String, _ name: String?){
        
        if let index = block.voiceMemos?.firstIndex(where: { $0.voiceMemoID == voiceMemoID }) {
            
            if name != nil, name!.leniantValidationOfTextEntered() {
                
                block.voiceMemos?[index].name = name
            }
            
            else {
                
                block.voiceMemos?[index].name = nil
            }
        }
    }
    
    func voiceMemoDeleted (_ voiceMemo: VoiceMemo) {
        
        block.voiceMemos?.removeAll(where: { $0.voiceMemoID == voiceMemo.voiceMemoID })
            
        if let cell = configureBlockTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? VoiceMemosConfigurationCell {
            
            cell.voiceMemos = block.voiceMemos
        }

        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
    }
}


//MARK: - Links Configuration Protocol Extension

extension ConfigureBlockViewController: LinksConfigurationProtocol {
    
    func attachLinkSelected() {
        
        var link = Link()
        link.linkID = UUID().uuidString
        
        if block.links == nil {
            
            block.links = [link]
        }
        
        else {
            
            block.links?.append(link)
        }
        
        if let cell = configureBlockTableView.cellForRow(at: IndexPath(row: 7, section: 0)) as? LinksConfigurationCell {

            cell.links = block.links
        }
        
        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
    }
    
    func linkEntered (_ linkID: String, _ url: String) {
        
        if let linkIndex = block.links?.firstIndex(where: { $0.linkID == linkID }) {
            
            block.links?[linkIndex].url = url
        }
    }
    
    func linkIconSaved (_ linkID: String, _ icon: UIImage?) {
        
        if let linkIndex = block.links?.firstIndex(where: { $0.linkID == linkID }) {
            
            block.links?[linkIndex].icon = icon
        }
    }
    
    func linkRenamed (_ linkID: String, _ name: String) {
        
        if let linkIndex = block.links?.firstIndex(where: { $0.linkID == linkID }) {
            
            block.links?[linkIndex].name = name
        }
    }
    
    func linkDeleted (_ linkID: String) {
        
        block.links?.removeAll(where: { $0.linkID == linkID })
        
        if let cell = configureBlockTableView.cellForRow(at: IndexPath(row: 7, section: 0)) as? LinksConfigurationCell {

            cell.links = block.links
        }
        
        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
    }
}


//MARK: - Zoom In Protocol Extension

extension ConfigureBlockViewController: ZoomInProtocol {
    
    func zoomInOnPhotoImageView(photoImageView: UIImageView) {
        
        selectedPhoto = photoImageView.image
        
        zoomingMethods = ZoomingImageViewMethods(on: photoImageView, cornerRadius: 8, with: [editPhotoButton, deletePhotoButton])
        zoomingMethods?.performZoom()
    }
}


//MARK: - Present Copied Animation Protocol Extension

extension ConfigureBlockViewController: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        let navBarFrame = navigationController?.navigationBar.convert(navigationController?.navigationBar.frame ?? .zero, to: keyWindow) ?? .zero
        
        //12.5 is equal to 10 point top anchor the photosCollectionView has from the navBar plus an extra 10 point buffer
        copiedAnimationView?.presentCopiedAnimation(topAnchor: navBarFrame.minY + 10)
    }
}
