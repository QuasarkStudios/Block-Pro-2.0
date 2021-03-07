//
//  CollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/24/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class CollabViewController: UIViewController {
    
    var collabObjectiveVC: CollabObjectiveViewController?
    var memberProfileVC: CollabMemberProfileViewController?
    var hiddenBlockVC: HiddenBlocksViewController?
    
    lazy var collabHeaderView = CollabHeaderView(collab)
    lazy var collabHeaderViewHeightConstraint = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
    
    lazy var collabCalendarView = CollabCalendarView(self, collabStartTime: collab?.dates["startTime"], collabDeadline: collab?.dates["deadline"])
    
    lazy var collabNavigationView = CollabNavigationView(self, collabStartTime: collab?.dates["startTime"], collabDeadline: collab?.dates["deadline"])
    
    let collabHomeTableView = UITableView()
    
    lazy var editCoverButton: UIButton = configureEditButton()
    lazy var deleteCoverButton: UIButton = configureDeleteButton()
    
    let presentCollabNavigationViewButton = UIButton(type: .system)
    
    let addBlockButton = UIButton(type: .system)
    let seeHiddenBlocksButton = UIButton(type: .system)
    
    var copiedAnimationView: CopiedAnimationView?
    
    lazy var tabBar = CustomTabBar.sharedInstance
    
    let messageInputAccesoryView = InputAccesoryView(textViewPlaceholderText: "Send a message", showsAddButton: true)
    var inputAccesoryViewMethods: InputAccesoryViewMethods!
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    let firebaseBlock = FirebaseBlock.sharedInstance
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    var collab: Collab?
    
    let notificationScheduler = NotificationScheduler()
    
    let formatter = DateFormatter()
    let calendar = Calendar.current
    
    var blocks: [Block]?
    var selectedBlock: Block?
    var hiddenBlocks: [Block] = []
    var filteredBlocks: [Block] = []
    
    var messagingMethods: MessagingMethods!
    var messages: [Message]?
    
    var selectedTab: String = "Blocks"
    var alertTracker: String = ""
    
    var keyboardHeight: CGFloat?
    var keyboardWasPresent: Bool?
    
    var messageTextViewText: String = ""
    var selectedPhoto: UIImage?
    
    var gestureViewPanGesture: UIPanGestureRecognizer?
    var stackViewPanGesture: UIPanGestureRecognizer?
    var dismissExpandedViewGesture: UISwipeGestureRecognizer?
    
    var zoomingMethods: ZoomingImageViewMethods?
    var imageViewBeingZoomed: Bool?
    
    var calendarPresented: Bool = false
    
    var enableTabBarVisibiltyHandeling: Bool = false
    var tabBarWasHidden: Bool = false
    
    var searchBeingConducted: Bool = false
    var blocksFiltered: Bool = false
    
    var previousContentOffsetYCoord: CGFloat = 0
    
    var collabNavigationViewTopAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureGestureRecognizers()
        
        configureHeaderView()
        configureCollabHomeTableView()
        
        configureCalendarView()
        
        configurePresentCollabNavigationViewButton()
        configureCollabNavigationView()
        
        configureAddBlockButton()
        configureSeeHiddenBlocksButton()
        
        configureMessagingView() //Call first
        configureProgressView()
        configureBlockView()
        
        messageInputAccesoryView.alpha = 0
        
        monitorCollab()
        
        retrieveBlocks()
        retrieveMessages()
        
        setUserActiveStatus()
        
//        print(collab?.collabID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavBar()
        
        retrieveMessageDraft()
        
        tabBar.shouldHide = tabBarWasHidden
        
        //Initializing here allows the animationView to be removed and readded multiple times
        copiedAnimationView = CopiedAnimationView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Prevents the tabBar from flashing when this view is being presented for the first time
        enableTabBarVisibiltyHandeling = true
        
        hiddenBlockVC = nil
        
        addObservors()
        
        self.becomeFirstResponder()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarWasHidden = tabBar.alpha == 0
        
        removeObservors()
        
        setUserInactiveStatus()
        
        saveMessageDraft()
        
        copiedAnimationView?.removeCopiedAnimation(remove: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        var count = 0
        
        while count < messages?.count ?? 0 {
            
            messages?[count].messagePhoto?["photo"] = nil
            
            count += 1
        }
    }
    
    override var inputAccessoryView: UIView? {
        return messageInputAccesoryView
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    deinit {
        
        print("deinit")
        
        firebaseCollab.singularCollabListener?.remove()
        
        firebaseBlock.collabBlocksListener?.remove()
        firebaseMessaging.messageListener?.remove()
        
        firebaseBlock.cachedCollabBlocks = []
    }
    
    
    //MARK: - Configure Nav Bar
    
    private func configureNavBar () {
        
        //If the collabNavigationView is expanded or the calendar is present
        if navigationItem.hidesBackButton == true {

            //If the collabNavigationView is expanded
            if collabNavigationViewTopAnchor?.constant == 0 {

                self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
            }

            else {

                self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
            }
        }
        
        else {
            
            //If the view has a title evident that the collabHeaderView or collabCalendarView is hidden
            if self.title?.leniantValidationOfTextEntered() ?? false {
                
                self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
            }
            
            else {
                
                self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
            }
        }
    }
    
    
    //MARK: - Configure Header View
    
    private func configureHeaderView () {
        
        self.view.addSubview(collabHeaderView)
        collabHeaderView.collabViewController = self
    }
    
    
    //MARK: - Configure Collab Navigation View
    
    private func configureCollabNavigationView () {
        
        self.view.addSubview(collabNavigationView)
        collabNavigationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabNavigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collabNavigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            collabNavigationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        collabNavigationViewTopAnchor = collabNavigationView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: collabHeaderView.configureViewHeight() - 80)
        collabNavigationViewTopAnchor?.isActive = true
        
        collabNavigationView.collabViewController = self
    }
    
    
    //MARK: - Configure Calendar View
    
    private func configureCalendarView () {

        self.view.addSubview(collabCalendarView)
        collabCalendarView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabCalendarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collabCalendarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            collabCalendarView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            collabCalendarView.heightAnchor.constraint(equalToConstant: topBarHeight + 425)
        
        ].forEach({ $0.isActive = true })
        
        collabCalendarView.isHidden = true
    }
    
    
    //MARK: - Configure Home Table View
    
    private func configureCollabHomeTableView () {
        
        self.view.addSubview(collabHomeTableView)
        collabHomeTableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabHomeTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collabHomeTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            collabHomeTableView.topAnchor.constraint(equalTo: collabHeaderView.bottomAnchor, constant: 5),
            collabHomeTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        collabHomeTableView.dataSource = self
        collabHomeTableView.delegate = self
        
        collabHomeTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 15 : 30, right: 0)
        collabHomeTableView.separatorStyle = .none
        collabHomeTableView.showsVerticalScrollIndicator = false
        collabHomeTableView.delaysContentTouches = false
        
        collabHomeTableView.register(CollabHomeMembersCell.self, forCellReuseIdentifier: "collabHomeMembersCell")
        collabHomeTableView.register(LocationsPresentationCell.self, forCellReuseIdentifier: "locationsPresentationCell")
        collabHomeTableView.register(PhotosPresentationCell.self, forCellReuseIdentifier: "photosPresentationCell")
        collabHomeTableView.register(VoiceMemosPresentationCell.self, forCellReuseIdentifier: "voiceMemosPresentationCell")
        collabHomeTableView.register(LinksPresentationCell.self, forCellReuseIdentifier: "linksPresentationCell")
        collabHomeTableView.register(CollabHomeEdit_LeaveCell.self, forCellReuseIdentifier: "collabHomeEdit_LeaveCell")
    }
    
    
    //MARK: - Configure Progress View
    
    private func configureProgressView () {
        
        collabNavigationView.collabTableView.scrollsToTop = true
        
        collabNavigationView.collabTableView.register(BlockCell.self, forCellReuseIdentifier: "blockCell")
    }
    
    
    //MARK: - Configure Block View
    
    private func configureBlockView () {
        
        collabNavigationView.collabTableView.dataSource = self
        collabNavigationView.collabTableView.delegate = self
        
        collabNavigationView.collabTableView.separatorStyle = .none
        
        collabNavigationView.collabTableView.estimatedRowHeight = 0
        
        collabNavigationView.collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0, right: 0)
        collabNavigationView.collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 40 : 0, right: 0)
        
        collabNavigationView.collabTableView.scrollsToTop = true
        
        collabNavigationView.collabTableView.register(BlocksTableViewCell.self, forCellReuseIdentifier: "blocksTableViewCell")
    }
    
    
    //MARK: - Configure Messaging View
    
    private func configureMessagingView () {
        
        messageInputAccesoryView.parentViewController = self
        
        messagingMethods = MessagingMethods(parentViewController: self, tableView: collabNavigationView.collabTableView, collabID: collab?.collabID ?? "")
        messagingMethods.configureTableView()
        
        inputAccesoryViewMethods = InputAccesoryViewMethods(accesoryView: messageInputAccesoryView, textViewPlaceholderText: "Send a message", tableView: collabNavigationView.collabTableView)
    }
    
    
    //MARK: - Configure Present Collab NavView Button
    
    private func configurePresentCollabNavigationViewButton () {
        
        self.view.addSubview(presentCollabNavigationViewButton)
        presentCollabNavigationViewButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            presentCollabNavigationViewButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            presentCollabNavigationViewButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(self.view.frame.height - tabBar.frame.minY) - 15),
            presentCollabNavigationViewButton.widthAnchor.constraint(equalToConstant: 37.5),
            presentCollabNavigationViewButton.heightAnchor.constraint(equalToConstant: 37.5)
        
        ].forEach({ $0.isActive = true })
        
        presentCollabNavigationViewButton.tag = 1
        
        presentCollabNavigationViewButton.tintColor = UIColor(hexString: "222222")
        presentCollabNavigationViewButton.setImage(UIImage(systemName: "chevron.up.circle.fill"), for: .normal)
        presentCollabNavigationViewButton.contentVerticalAlignment = .fill
        presentCollabNavigationViewButton.contentHorizontalAlignment = .fill
        
        presentCollabNavigationViewButton.addTarget(self, action: #selector(presentNavViewButtonPressed), for: .touchUpInside)
        
        let buttonBackgroundView = UIView(frame: CGRect(x: 5, y: 5, width: 27.5, height: 27.5))
        buttonBackgroundView.backgroundColor = .white
        buttonBackgroundView.isUserInteractionEnabled = false
        
        buttonBackgroundView.layer.cornerRadius = 27.5 * 0.5
        buttonBackgroundView.clipsToBounds = true
        
        presentCollabNavigationViewButton.addSubview(buttonBackgroundView)
        presentCollabNavigationViewButton.bringSubviewToFront(presentCollabNavigationViewButton.imageView!)
    }
    
    
    //MARK: - Configure Edit Button
    
    private func configureEditButton () -> UIButton {
        
        let button = UIButton(type: .system)
        
        button.frame = CGRect(x: 15, y: 50, width: 75, height: 35)
        
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        button.contentHorizontalAlignment = .center
        button.tintColor = .white
        button.alpha = 0
        button.addTarget(self, action: #selector(editCoverButtonPressed), for: .touchUpInside)
        
        return button
    }
    
    
    //MARK: - Configure Delete Button
    
    private func configureDeleteButton () -> UIButton {
        
        let button = UIButton(type: .system)
        
        let xCoord = self.view.frame.width - (75 + 20)
        button.frame = CGRect(x: xCoord, y: 50, width: 75, height: 35)
        
        button.setTitle("Delete", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        button.contentHorizontalAlignment = .center
        button.tintColor = .systemRed
        button.alpha = 0
        button.addTarget(self, action: #selector(deleteCoverButtonPressed), for: .touchUpInside)
        
        return button
    }
    
    
    //MARK: - Configure Add Block Button
    
    private func configureAddBlockButton () {
        
        view.addSubview(addBlockButton)
        addBlockButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            addBlockButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -29),
            addBlockButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(self.view.frame.height - tabBar.frame.minY) - 25),
            addBlockButton.widthAnchor.constraint(equalToConstant: 60),
            addBlockButton.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach( { $0.isActive = true } )
        
        addBlockButton.backgroundColor = UIColor(hexString: "222222")
        addBlockButton.setImage(UIImage(named: "plus 2"), for: .normal)
        addBlockButton.tintColor = .white
        
        addBlockButton.layer.cornerRadius = 30

        addBlockButton.addTarget(self, action: #selector(addBlockButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure See Hidden Blocks Button
    
    private func configureSeeHiddenBlocksButton () {
        
        self.view.addSubview(seeHiddenBlocksButton)
        seeHiddenBlocksButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            seeHiddenBlocksButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12.5),
            seeHiddenBlocksButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            seeHiddenBlocksButton.widthAnchor.constraint(equalToConstant: 35),
            seeHiddenBlocksButton.heightAnchor.constraint(equalToConstant: 35)
            
        ].forEach({ $0.isActive = true })
        
        seeHiddenBlocksButton.alpha = 0
        
        seeHiddenBlocksButton.tintColor = UIColor(hexString: "222222")
        seeHiddenBlocksButton.setImage(UIImage(systemName: "chevron.right.circle.fill"), for: .normal)
        seeHiddenBlocksButton.contentVerticalAlignment = .fill
        seeHiddenBlocksButton.contentHorizontalAlignment = .fill
        
        seeHiddenBlocksButton.addTarget(self, action: #selector(seeHiddenBlocksButtonPressed), for: .touchUpInside)
        
        let buttonBackgroundView = UIView(frame: CGRect(x: 5, y: 5, width: 25, height: 25))
        buttonBackgroundView.backgroundColor = .white
        buttonBackgroundView.isUserInteractionEnabled = false
        
        buttonBackgroundView.layer.cornerRadius = 25 * 0.5
        buttonBackgroundView.clipsToBounds = true
        
        seeHiddenBlocksButton.addSubview(buttonBackgroundView)
        seeHiddenBlocksButton.bringSubviewToFront(seeHiddenBlocksButton.imageView!)
    }
    
    
    //MARK: - Configure Gesture Recognizors
    
    private func configureGestureRecognizers () {

        let dismissKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTap))
        dismissKeyboardTapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(dismissKeyboardTapGesture)
        
        dismissExpandedViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissExpandedView))
        dismissExpandedViewGesture?.delegate = self
        dismissExpandedViewGesture?.cancelsTouchesInView = true
        dismissExpandedViewGesture?.direction = .right
        view.addGestureRecognizer(dismissExpandedViewGesture!)
        
        gestureViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        collabNavigationView.panGestureView.addGestureRecognizer(gestureViewPanGesture!)
        
        stackViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        collabNavigationView.buttonStackView.addGestureRecognizer(stackViewPanGesture!)
    }
    
    
    //MARK: - Add Observors
    
    func addObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(setUserActiveStatus), name: UIApplication.didBecomeActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(setUserInactiveStatus), name: UIApplication.willResignActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(saveMessageDraft), name: UIApplication.willTerminateNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(sendMessage), name: .userDidSendMessage, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(addAttachment), name: .userDidAddMessageAttachment, object: nil)
    }
    
    
    //MARK: - Remove Observors
    
    private func removeObservors () {
        
        NotificationCenter.default.removeObserver(self)
    }
        
    
    //MARK: - Monitor Collab
    
    private func monitorCollab () {
        
        firebaseCollab.monitorCollab(collabID: collab?.collabID ?? "") { [weak self] (monitoredCollab) in
            
            if let error = monitoredCollab["error"] as? Error {
                
                print(error.localizedDescription as Any)
            }
            
            else {
                
                if let updatedCollab = monitoredCollab["collab"] as? Collab {
                    
                    var indexPathsToReload: [IndexPath] = []
                    
                    //Collab Name////////////////////////////////////////////////////////////
                    if updatedCollab.name != self?.collab?.name {
                        
                        self?.collab?.name = updatedCollab.name
                        self?.collabHeaderView.collab?.name = updatedCollab.name
                        self?.collabHeaderView.nameLabel.text = updatedCollab.name
                        
                        //Ensures that the collabNavigationView is shrunken and the title is currently displaying the name of the collab
                        if self?.title != nil && self?.collabNavigationViewTopAnchor?.constant != 0 {
                            
                            self?.title = updatedCollab.name
                        }
                    }
                    ////////////////////////////////////////////////////////////////////////
                    
                    
                    //Cover Photo///////////////////////////////////////////////////////////
                    if updatedCollab.coverPhotoID != self?.collab?.coverPhotoID {
                        
                        self?.collab?.coverPhotoID = updatedCollab.coverPhotoID
                        
                        self?.collabHeaderView.setCoverPhoto(self?.collab)
                    }
                    ////////////////////////////////////////////////////////////////////////
                    
                    
                    //Collab Objective/////////////////////////////////////////////////////
                    if updatedCollab.objective != self?.collab?.objective {
                        
                        self?.collab?.objective = updatedCollab.objective
                        self?.collabHeaderView.collab?.objective = updatedCollab.objective
                        
                        self?.collabHeaderView.setObjectiveLabelText()
                        
                        self?.collabObjectiveVC?.objective = updatedCollab.objective
                    }
                    ////////////////////////////////////////////////////////////////////////
                    
                    
                    //Collab Time///////////////////////////////////////////////////////////
                    if updatedCollab.dates["startTime"] != self?.collab?.dates["startTime"] || updatedCollab.dates["deadline"] != self?.collab?.dates["deadline"] {
                        
                        self?.collab?.dates = updatedCollab.dates
                        
                        //Keeping a reference to the date that was previously selected by the user
                        let previouslySelectedDate = self?.collabCalendarView.calendarView.selectedDates.first
                        
                        self?.collabCalendarView.collabStartTime = self?.collab?.dates["startTime"]
                        self?.collabCalendarView.collabDeadline = self?.collab?.dates["deadline"]
                        self?.collabCalendarView.calendarView.reloadData()
                        
                        self?.collabNavigationView.collabStartTime = self?.collab?.dates["startTime"]
                        self?.collabNavigationView.collabDeadline = self?.collab?.dates["deadline"]
                        self?.collabNavigationView.calendarView.reloadData()
                        
                        self?.collabNavigationView.collabTableView.reloadData()
                        
                        if let date = previouslySelectedDate {
                            
                            self?.collabCalendarView.calendarView.selectDates([date])
                            self?.collabCalendarView.calendarView.scrollToDate(date, animateScroll: false)

                            self?.collabNavigationView.calendarView.selectDates([date])
                            self?.collabNavigationView.calendarView.scrollToDate(date, animateScroll: false)
                            
                            if let formatter = self?.formatter, var startTime = updatedCollab.dates["startTime"], var deadline = updatedCollab.dates["deadline"] {
                                
                                //Formatting the startTime and deadline so that the only the date and not the time is truly used
                                formatter.dateFormat = "yyyy MM dd"
                                
                                startTime = formatter.date(from: formatter.string(from: startTime)) ?? Date()
                                deadline = formatter.date(from: formatter.string(from: deadline)) ?? Date()
                                
                                //Delaying slightly presumably allows the tableView time to reload its cell and prevents it from scrolling to the wrong cell once these statements are ran
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    
                                    //If the preselected date is between the new startTime and deadline
                                    if date.isBetween(startDate: startTime, endDate: deadline) {

                                        self?.scrollToFirstBlock(indexPathToScrollTo: IndexPath(row: self?.calendar.dateComponents([.day], from: startTime, to: date).day ?? 0, section: 0), animate: false)
                                    }

                                    //If the preselected date is less than or equal to the new startTime
                                    else if date <= startTime {

                                        self?.scrollToFirstBlock(indexPathToScrollTo: IndexPath(row: 0, section: 0), animate: false)
                                    }

                                    //If the preselected date is greater than or equal to the deadline
                                    else if date >= deadline {

                                        self?.scrollToFirstBlock(indexPathToScrollTo: IndexPath(row: self?.calendar.dateComponents([.day], from: startTime, to: deadline).day ?? 0, section: 0), animate: false)
                                    }
                                }
                            }
                        }

                        //Resetting the deadline text in the collabHeaderView
                        if let formatter = self?.formatter {
                            
                            formatter.dateFormat = "d MMMM yyyy"
                            var deadlineText = formatter.string(from: updatedCollab.dates["deadline"]!)
                            deadlineText += " at "
                            
                            formatter.dateFormat = "h:mm a"
                            deadlineText += formatter.string(from: updatedCollab.dates["deadline"]!)
                            
                            self?.collabHeaderView.deadlineTextLabel.text = deadlineText
                        }
                    }
                    ////////////////////////////////////////////////////////////////////////
                    
                    
                    //Member Activity///////////////////////////////////////////////////////
                    if updatedCollab.memberActivity?.count != self?.collab?.memberActivity?.count {
                        
                        self?.collab?.memberActivity = updatedCollab.memberActivity
                        
                        indexPathsToReload.append(IndexPath(row: 1, section: 0))
                    }
                    
                    else {
                        
                        for status in updatedCollab.memberActivity ?? [:] {
                            
                            if status.value as? Date != self?.collab?.memberActivity?[status.key] as? Date {
                                
                                self?.collab?.memberActivity = updatedCollab.memberActivity
                                
                                indexPathsToReload.append(IndexPath(row: 1, section: 0))
                                
                                break
                            }
                        }
                    }
                    ////////////////////////////////////////////////////////////////////////
                    
                    
                    //Reminders/////////////////////////////////////////////////////////////
                    self?.collab?.reminders = updatedCollab.reminders
                    
                    self?.notificationScheduler.removePendingCollabNotifications(collabID: updatedCollab.collabID) {
                        
                        self?.notificationScheduler.scheduleCollabNotifications(collab: updatedCollab)
                    }
                    ////////////////////////////////////////////////////////////////////////
                    
                    
                    //Locations/////////////////////////////////////////////////////////////
                    if let locations = updatedCollab.locations {
                        
                        if locations.count != self?.collab?.locations?.count ?? 0 {
                            
                            indexPathsToReload.append(IndexPath(row: 3, section: 0))
                            indexPathsToReload.append(IndexPath(row: 4, section: 0))
                        }
                        
                        else {
                            
                            for location in locations {
                                
                                //If there is a location that isn't currently in the cachedCollab location array
                                if !(self?.collab?.locations?.contains(where: { $0.locationID == location.locationID }) ?? false) {
                                    
                                    indexPathsToReload.append(IndexPath(row: 3, section: 0))
                                    indexPathsToReload.append(IndexPath(row: 4, section: 0))
                                    break
                                }
                                
                                //If a location has had it's name changed
                                else if let cachedLocation = self?.collab?.locations?.first(where: { $0.locationID == location.locationID }), cachedLocation.name != location.name {
                                    
                                    indexPathsToReload.append(IndexPath(row: 3, section: 0))
                                    indexPathsToReload.append(IndexPath(row: 4, section: 0))
                                    break
                                }
                            }
                        }
                        
                        self?.collab?.locations = updatedCollab.locations
                    }
                    ////////////////////////////////////////////////////////////////////////
                    
                    
                    //Photos////////////////////////////////////////////////////////////////
                    if updatedCollab.photoIDs.count != self?.collab?.photoIDs.count ?? 0 {
                        
                        self?.collab?.photoIDs = updatedCollab.photoIDs
                        
                        for photo in self?.collab?.photos ?? [:] {
                            
                            //If the updatedCollab photoIDs does not contain a key from the photosDict in the cachedCollab
                            if !(updatedCollab.photoIDs.contains(where: { $0 == photo.key })) {
                                
                                //Removing the photo that no longer exists
                                self?.collab?.photos.removeValue(forKey: photo.key)
                            }
                        }
                        
                        indexPathsToReload.append(IndexPath(row: 5, section: 0))
                    }
                    
                    else {
                        
                        for photoID in updatedCollab.photoIDs {
                            
                            //If the photoIDs from the cachedCollab contains a photoID not contained in the updatedCollab
                            if !(self?.collab?.photoIDs.contains(where: { $0 == photoID }) ?? false) {
                                
                                self?.collab?.photoIDs = updatedCollab.photoIDs
                                
                                indexPathsToReload.append(IndexPath(row: 5, section: 0))
                                break
                            }
                        }
                        
                        //If the updatedCollab photoIDs does not contain a key from the photosDict in the cachedCollab
                        for photo in self?.collab?.photos ?? [:] {
                            
                            if !(updatedCollab.photoIDs.contains(where: { $0 == photo.key })) {
                                
                                //Removing the photo that no longer exists
                                self?.collab?.photos.removeValue(forKey: photo.key)
                            }
                        }
                    }
                    ////////////////////////////////////////////////////////////////////////
                    
                    
                    //Voice Memos///////////////////////////////////////////////////////////
                    if let voiceMemos = updatedCollab.voiceMemos {
                        
                        if voiceMemos.count != self?.collab?.voiceMemos?.count {
                            
                            indexPathsToReload.append(IndexPath(row: 7, section: 0))
                        }
                        
                        else {
                            
                            for voiceMemo in voiceMemos {
                                
                                //If there is a voiceMemo that isn't currently in the cachedCollab voiceMemo array
                                if !(self?.collab?.voiceMemos?.contains(where: { $0.voiceMemoID == voiceMemo.voiceMemoID }) ?? false) {
                                    
                                    indexPathsToReload.append(IndexPath(row: 7, section: 0))
                                    break
                                }
                                
                                //If a voice memo has had it's name changed
                                else if let cachedVoiceMemo = self?.collab?.voiceMemos?.first(where: { $0.voiceMemoID == voiceMemo.voiceMemoID }), cachedVoiceMemo.name != voiceMemo.name {
                                    
                                    indexPathsToReload.append(IndexPath(row: 7, section: 0))
                                    break
                                }
                            }
                        }
                        
                        self?.collab?.voiceMemos = updatedCollab.voiceMemos
                    }
                    ////////////////////////////////////////////////////////////////////////
                    
                    
                    //Links/////////////////////////////////////////////////////////////////
                    if let links = updatedCollab.links {
                        
                        if links.count != self?.collab?.links?.count ?? 0 {
                            
                            indexPathsToReload.append(IndexPath(row: 9, section: 0))
                        }
                        
                        else {
                            
                            for link in links {
                                
                                //If there is a link that isn't currently in the cachedCollab link array
                                if !(self?.collab?.links?.contains(where: { $0.linkID == link.linkID }) ?? false) {
                                    
                                    indexPathsToReload.append(IndexPath(row: 9, section: 0))
                                    break
                                }
                                
                                //If a link has had its name or url changed
                                else if let cachedLink = self?.collab?.links?.first(where: { $0.linkID == link.linkID }), cachedLink.name != link.name || cachedLink.url != link.url {
                                    
                                    indexPathsToReload.append(IndexPath(row: 9, section: 0))
                                    break
                                }
                            }
                        }
                        
                        self?.collab?.links = updatedCollab.links
                    }
                    ////////////////////////////////////////////////////////////////////////
                    
                    self?.collabHomeTableView.reloadRows(at: indexPathsToReload, with: .none)
                }
                
                //Members///////////////////////////////////////////////////////////////////
                if let historicMembers = monitoredCollab["historicMembers"] as? [Member], let currentMembers = monitoredCollab["currentMembers"] as? [Member] {
                    
                    //This collab has been deleted or the currentUser has been removed
                    if currentMembers.count == 0 || !currentMembers.contains(where: { $0.userID == self?.currentUser.userID }) {
                        
                        self?.firebaseCollab.singularCollabListener?.remove()
                        
                        //Zooming out of any photo that may be zoomed in on
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                            
                            self?.zoomingMethods?.blackBackground?.backgroundColor = .clear
                            self?.zoomingMethods?.optionalButtons.forEach({ $0?.alpha = 0 })
                            self?.zoomingMethods?.zoomedInImageView?.alpha = 0
                            
                        } completion: { (finished: Bool) in
                            
                            self?.zoomingMethods?.blackBackground?.removeFromSuperview()
                            self?.zoomingMethods?.optionalButtons.forEach({ $0?.removeFromSuperview() })
                            self?.zoomingMethods?.zoomedInImageView?.removeFromSuperview()
                        }
                        
                        //Dismissing any view that has been modally presented
                        if self?.navigationController?.visibleViewController != self {
                            
                            self?.navigationController?.visibleViewController?.dismiss(animated: true, completion: nil)
                        }
                        
                        //Ensuring that the user hasn't moved to another tab
                        //Ensuring that the current user wasn't the lead, meaning that they couldn't have been the one that deleted the collab
                        if self?.tabBar.selectedIndex == 0, self?.collab?.currentMembers.first(where: { $0.userID == self?.currentUser.userID })?.role != "Lead" {
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                
                                //The collab has been deleted
                                if currentMembers.count == 0 {
                                    
                                    SVProgressHUD.showInfo(withStatus: "\(self?.collab?.name ?? "This collab") has been deleted")
                                }
                                
                                //The currentUser has been removed
                                else {
                                    
                                    SVProgressHUD.showInfo(withStatus: "You've been removed from \(self?.collab?.name ?? "this collab")")
                                }
                            }
                        }
                        
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                    
                    //The members have simply been updated
                    else {
                        
                        self?.collab?.historicMembers = historicMembers
                        self?.collab?.currentMembers = currentMembers
                        
                        self?.collabHomeTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                    }
                }
            }
        }
    }
    
    
    //MARK: - Handle Pan
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            moveWithPan(sender: sender)
            
        case .ended:
            
            //If the calendar isn't presented
            if !calendarPresented {
                
                if (collabNavigationView.frame.minY > (collabHeaderView.frame.height / 2)) && (collabNavigationView.frame.minY < (UIScreen.main.bounds.height / 2)) {
                    
                    returnToOrigin()
                }
                
                else if (collabNavigationView.frame.minY < (collabHeaderView.frame.height / 2)) {
                    
                    expandView()
                }
                
                else if (collabNavigationView.frame.minY > (UIScreen.main.bounds.height / 2)) {
                    
                    shrinkView()
                }
            }
            
            //If the calendar is present
            else {
                
                //If the minY of the collabNavigationView is less than half of its preset anchor when the calendar is present
                if collabNavigationView.frame.minY < (topBarHeight + (collabCalendarView.calendarView.visibleDates().monthDates.first?.date.determineNumberOfWeeks() == 4 ? 330 : 376)) / 2 {
                    
                    expandView()
                }
                
                else {
                    
                    returnToOrigin()
                }
            }
            
        default:
            
            break
        }
    }
    
    
    //MARK: - Move with Pan
    
    private func moveWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        let collabHeaderViewHeightConstraint = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        
        //If the calendar isn't present
        if !calendarPresented {
            
            //If the collabNavigationView is moving upwards above its origin
            if (collabNavigationView.frame.minY + translation.y) < (collabHeaderView.configureViewHeight() - 80) {
                
                collabNavigationViewTopAnchor?.constant += translation.y
                collabNavigationViewBottomAnchor?.constant = 0
                
                //Alpha animation
                let collabNavigationViewMinY = collabNavigationView.frame.minY - 44 > 0 ? collabNavigationView.frame.minY - 44 : 0
                let adjustedAlpha: CGFloat = ((1 / (collabHeaderView.configureViewHeight() - 80)) * collabNavigationViewMinY)
                collabNavigationView.panGestureIndicator.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
                collabNavigationView.buttonStackView.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
            }
            
            //If the collabNavigationView is moving downwards below its origin
            else {
                
                collabNavigationViewTopAnchor?.constant += translation.y
                collabNavigationViewBottomAnchor?.constant = collabNavigationView.frame.minY - (collabHeaderView.configureViewHeight() - 80)
            
                let collabNavViewOriginMinY = collabHeaderView.configureViewHeight() - 80
                let collabNavViewDistanceFromBottom = (collabNavigationViewTopAnchor!.constant - collabNavViewOriginMinY) / (self.view.frame.height - collabNavViewOriginMinY)
                
                collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight() - (70 * collabNavViewDistanceFromBottom)
                
                if selectedTab == "Messages" {
                    
                    messageInputAccesoryView.alpha = 1 - (1 * collabNavViewDistanceFromBottom)
                }
            }
        }
        
        //If the calendar is presented
        else {
            
            //If the navigationViewTopAnchor + the translation is less than 330/376, the preset anchor for when the calendar view is presented
            if ((collabNavigationViewTopAnchor?.constant ?? 0) + translation.y) < topBarHeight + (collabCalendarView.calendarView.visibleDates().monthDates.first?.date.determineNumberOfWeeks() == 4 ? 330 : 376) {
                
                collabNavigationViewTopAnchor?.constant += translation.y
                collabNavigationViewBottomAnchor?.constant = 0
            }
            
            else {
                
                collabNavigationViewTopAnchor?.constant = topBarHeight + (collabCalendarView.calendarView.visibleDates().monthDates.first?.date.determineNumberOfWeeks() == 4 ? 330 : 376)
                collabNavigationViewBottomAnchor?.constant = 0
            }
        }
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    
    //MARK: - Return to Origin
    
    @objc private func returnToOrigin (animateCollabHeaderView: Bool = true, scrollTableView: Bool = true) {
        
        collabNavigationView.panGestureView.isUserInteractionEnabled = true
        
        resetConstraintsForReturnToOrigin(animateCollabHeaderView)
        
        if selectedTab == "Progress" {
            
            if blocks?.count ?? 0 == 0 {
                
                //Should be fine being called from here instead of from the animation block
                collabNavigationView.handleProgressAnimation()
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()
            
            self.collabHeaderView.alpha = 1
            
            self.collabHomeTableView.contentOffset.y = 0

            self.collabNavigationView.layer.cornerRadius = 27.5
            self.collabNavigationView.panGestureIndicator.alpha = 1
            self.collabNavigationView.buttonStackView.alpha = !self.calendarPresented ? 1 : 0
            self.collabNavigationView.messagesAnimationView.animationTitleLabel.alpha = 0
            
            self.seeHiddenBlocksButton.alpha = 0
            
            if !self.calendarPresented {
                
                self.tabBar.alpha = self.selectedTab != "Messages" ? 1 : 0
                self.addBlockButton.alpha = self.selectedTab == "Blocks" ? 1 : 0
            }
            
            else {
                
                //Will remove the "addBlockButton" and the "tabBar" if the collabNavigationView will be too small once the calendar is presented
                self.tabBar.alpha = (self.addBlockButton.frame.minY - 330 >= 200) ? 1 : 0
                self.addBlockButton.alpha = (self.addBlockButton.frame.minY - 330 >= 200) ? 1 : 0
            }
        })
        
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        collabNavigationViewBottomAnchor?.constant = 0
        
        //Prevents the bottom of the collabNavigationView from bouncing
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
        }
        
        if selectedTab == "Blocks" {

            collabNavigationView.dismissCalendar()
        }
        
        if selectedTab == "Messages" && self.messages?.count ?? 0 > 0 && scrollTableView {
            
            self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
        }
    }
    
    
    //MARK: - Shrink View
    
    private func shrinkView () {
        
        self.resignFirstResponder()
        
        let collabHeaderViewHeightAnchor = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        let presentNavViewButtonBottomAnchor = self.view.constraints.first(where: { $0.firstItem?.tag == 1 && $0.firstAttribute == .bottom })
        
        collabHeaderViewHeightAnchor?.constant = collabHeaderView.configureViewHeight() - 70
        collabNavigationViewTopAnchor?.constant = self.view.frame.height
        collabNavigationViewBottomAnchor?.constant = self.view.frame.height
        presentNavViewButtonBottomAnchor?.constant = -(self.view.frame.height - tabBar.frame.minY) - 15
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.tabBar.alpha = 1
            self.presentCollabNavigationViewButton.alpha = 1
            self.addBlockButton.alpha = 0
            self.seeHiddenBlocksButton.alpha = 0
            self.messageInputAccesoryView.alpha = 0
        }
    }
    
    
    //MARK: - Expand View
    
    internal func expandView () {
        
        viewExpanded() //Call here
        
        title = selectedTab
        
        collabNavigationView.panGestureView.isUserInteractionEnabled = false
        
        if selectedTab == "Messages" {
            
            collabNavigationView.tableViewTopAnchorWithStackView?.constant = ((topBarHeight - collabNavigationView.buttonStackView.frame.maxY) + 5)
            
            collabNavigationView.messagesAnimationViewCenterYAnchor?.constant = -35
        }
        
        else if selectedTab == "Progress" {
            
            collabNavigationView.progressViewTopAnchorWithStackView?.constant = keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 30 : 10
            
            let progressViewHeight: CGFloat = ((UIScreen.main.bounds.width * 0.5) + 12 + 55) + 87
            
            //Adjusts the topAnchor of the tableView when the progressView is completely present as the view is being expanded
            if (collabNavigationView.progressViewHeightConstraint?.constant ?? 0) == progressViewHeight {
                
                //Setting the top anchor based on if the iPhone has a notch -- an iPhone with a notch will cause the progressView to have a larger topAnchor
                //Therefore the top anchor of the tableView will also have to be larger by 20 points to compensate
                collabNavigationView.tableViewTopAnchorWithStackView?.constant = progressViewHeight + (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0)
            }
            
            if blocks?.count ?? 0 == 0 {
                
                //Should be fine being called from here instead of from the animation block
                collabNavigationView.handleProgressAnimation()
            }
        }
        
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        
        collabNavigationViewTopAnchor?.constant = 0
        collabNavigationViewBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()

            self.collabNavigationView.layer.cornerRadius = 0
            self.collabNavigationView.panGestureIndicator.alpha = 0
            self.collabNavigationView.buttonStackView.alpha = 0
            
            self.collabNavigationView.messagesAnimationView.animationTitleLabel.alpha = self.messages?.count ?? 0 == 0 ? 1 : 0
            
            if self.selectedTab == "Blocks" {
                
                self.addBlockButton.alpha = 1
                self.tabBar.alpha = 1
            }
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {

            if self.selectedTab == "Blocks" {
                
                self.collabNavigationView.presentCalendar()
                
                self.determineHiddenBlocks(self.collabNavigationView.collabTableView)
            }
        }
    }
    
    
    //MARK: - Reset Constraints for Return to Origin
    
    private func resetConstraintsForReturnToOrigin (_ animateCollabHeaderView: Bool) {
        
        let presentNavViewButtonBottomAnchor = self.view.constraints.first(where: { $0.firstItem?.tag == 1 && $0.firstAttribute == .bottom })
        let collabTableViewTopAnchor = collabNavigationView.constraints.first(where: { $0.firstItem as? UITableView != nil && $0.firstAttribute == .top })
        
        if animateCollabHeaderView {
            
            collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight()
        }
    
        if calendarPresented {
            
            collabNavigationViewTopAnchor?.constant = topBarHeight + (collabCalendarView.calendarView.visibleDates().monthDates.first?.date.determineNumberOfWeeks() == 4 ? 330 : 376)
        }
        
        else {
            
            collabNavigationViewTopAnchor?.constant = collabHeaderView.configureViewHeight() - 80
        }
        
        presentNavViewButtonBottomAnchor?.constant = 40
        
        if selectedTab == "Progress" {
            
            collabNavigationView.progressViewTopAnchorWithStackView?.constant = 10
            
            //Checks to see if the currentHeight of the progressView will cause the height of the tableView to be less than 0
            //Explanation for the math in this statement is in the collabNavigationView when initializing the computed property "maximumTableViewTopAnchorWithStackView"
            if (collabHeaderView.configureViewHeight() - 80) + (27.5 + 40) + (collabNavigationView.progressViewHeightConstraint?.constant ?? 0) + 10 > UIScreen.main.bounds.height {
                
                collabNavigationView.tableViewTopAnchorWithStackView?.constant = collabNavigationView.maximumTableViewTopAnchorWithStackView
            }
        }
        
        else if selectedTab == "Blocks" {
            
            collabTableViewTopAnchor?.constant = 10
        }
        
        else if selectedTab == "Messages" {
            
            collabTableViewTopAnchor?.constant = 10
            
            collabNavigationView.messagesAnimationViewCenterYAnchor?.constant = 0
        }
    }
    
    
    //MARK: - View Expanded
    
    internal func viewExpanded () {
        
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
        navigationItem.hidesBackButton = true

        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(cancelButtonPressed))
        cancelButton.style = .done
        navigationItem.leftBarButtonItem = cancelButton
        
        if selectedTab == "Messages" {
            
            let attachmentButton = UIBarButtonItem(image: UIImage(named: "attach"), style: .done, target: self, action: #selector(attachmentButtonPressed))
            navigationItem.setRightBarButton(attachmentButton, animated: true)
        }
    }
    
    
    //MARK: - User Activity Functions
    
    @objc private func setUserActiveStatus () {
        
        if let collabID = collab?.collabID {
            
            firebaseMessaging.setActivityStatus(collabID: collabID, "now")
        }
    }
    
    @objc private func setUserInactiveStatus () {
            
        if let collabID = collab?.collabID {
            
            firebaseMessaging.setActivityStatus(collabID: collabID, Date())
        }
    }
    
    
    //MARK: - Present Calendar
    
    func presentCalendar () {
        
        self.becomeFirstResponder() //Fixes bug that was causing the messageInputAccesoryView from being shown once the calendar was presented when the collabNavigationView was shrunken
        
        var delay: Double = 0
        
        calendarPresented = true
        
        collabCalendarView.blocks = blocks
        collabCalendarView.selectedDate = collabNavigationView.calendarView.selectedDates.first

        if selectedTab == "Progress" || selectedTab == "Messages" {
            
            //Calling this func will allow for the buttons to be animated to their correct color as well as allow for the tableView to be changed
            collabNavigationView.blocksButtonTouchUpInside()
            
            delay = 0.25 //Slight delay to improve animations
        }
        
        //Adjusting the position of the panGetsureView
        collabNavigationView.insertSubview(collabNavigationView.panGestureView, aboveSubview: collabNavigationView.collabTableView)
        
        //Reconfiguring constraints
        collabNavigationViewTopAnchor?.constant = topBarHeight + (collabNavigationView.calendarView.selectedDates.first?.determineNumberOfWeeks() == 4 ? 330 : 376)
        collabNavigationView.buttonStackView.constraints.forEach { (constraint) in

            if constraint.firstAttribute == .height {

                constraint.constant = 0
            }
        }
        
        //Animations
        UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()

            self.collabNavigationView.buttonStackView.alpha = 0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

            UIView.transition(from: self.collabHeaderView, to: self.collabCalendarView, duration: 0.35, options: [.transitionCrossDissolve, .showHideTransitionViews], completion: nil)

            self.navigationItem.hidesBackButton = true

            let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(self.dismissCalendar))
            cancelButton.style = .done
            self.navigationItem.leftBarButtonItem = cancelButton
        }
        
        UIView.animate(withDuration: 0.35, delay: delay, options: .curveEaseInOut) {
            
            //Will remove the "addBlockButton" and the "tabBar" if the collabNavigationView will be too small once the calendar is presented
            self.addBlockButton.alpha = (self.addBlockButton.frame.minY - 330 >= 200) ? 1 : 0
            self.tabBar.alpha = (self.addBlockButton.frame.minY - 330 >= 200) ? 1 : 0
        }
    }
    
    
    //MARK: - Dismiss Calendar
    
    @objc private func dismissCalendar () {
        
        calendarPresented = false
        
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = false
        
        //Adjusting the position of the panGetsureView
        collabNavigationView.insertSubview(collabNavigationView.panGestureView, aboveSubview: collabNavigationView.panGestureIndicator)
        
        //Resetting constraints
        collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight()
        collabNavigationViewTopAnchor?.constant = collabHeaderView.configureViewHeight() - 80
        
        collabNavigationView.buttonStackView.constraints.forEach { (constraint) in

            if constraint.firstAttribute == .height {

                constraint.constant = 40
            }
        }

        //Animations
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()

            self.collabNavigationView.buttonStackView.alpha = 1
        })

        UIView.transition(from: collabCalendarView, to: collabHeaderView, duration: 0.35, options: [.transitionCrossDissolve, .showHideTransitionViews]) { (finished: Bool) in
            
            //Once transition is completed
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {

                self.addBlockButton.alpha = 1
                self.tabBar.alpha = 1
            }
        }
    }
    
    
    //MARK: - Determine Hidden Blocks
    
    internal func determineHiddenBlocks (_ scrollView: UIScrollView) {
        
        //Ensures that the view is expanded
        if let indexPath = collabNavigationView.collabTableView.indexPathsForVisibleRows?.first, navigationItem.hidesBackButton, collabNavigationViewTopAnchor?.constant ?? 0 == 0 {
            
            //The range of y-Coords that is used to determine which hidden blocks can be presented
            let range = scrollView.contentOffset.y - CGFloat(2210 * indexPath.row) ... scrollView.contentOffset.y - CGFloat(2210 * indexPath.row) + scrollView.frame.height
            
            if let cell = collabNavigationView.collabTableView.cellForRow(at: indexPath) as? BlocksTableViewCell {
                
                hiddenBlocks = []
                
                for hiddenBlock in cell.hiddenBlocks {
                    
                    let blockStartHour = calendar.dateComponents([.hour], from: hiddenBlock.starts!).hour!
                    let blockStartMinute = calendar.dateComponents([.minute], from: hiddenBlock.starts!).minute!
                    let yCoord = CGFloat((Double(blockStartHour) * 90) + (Double(blockStartMinute) * 1.5)) + 50
                    
                    //If the hidden block's y-Coord is within the range meaning that it would be visible to the user if it wasn't hidden
                    if range.contains(yCoord) {
                        
                        hiddenBlocks.append(hiddenBlock)
                    }
                }
                
                //If the hiddenBlocksVC is currently in the navigation stack/presented to the user, this will update the hiddenBlocks in that view
                if let viewController = hiddenBlockVC {
                    
                    viewController.hiddenBlocks = hiddenBlocks
                }
                
                //Animating the hiddenBlocksButton based on the number of hiddenBlocks available
                if hiddenBlocks.count > 0 {
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        self.seeHiddenBlocksButton.alpha = 1
                    }
                }
                
                else {
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        self.seeHiddenBlocksButton.alpha = 0
                    }
                }
            }
        }
    }
    
    
    //MARK: - Add Cover Photo Alert
    
    func presentAddPhotoAlert (tracker: String, shrinkView: Bool) {
        
        if shrinkView {
            
            self.shrinkView()
        }
        
        alertTracker = tracker
        
        let addCoverPhotoAlert = UIAlertController (title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "    Take a Cover Photo", style: .default) { [weak self] (takePhotoAction) in
          
            self?.takePhotoSelected()
        }
        
        let cameraImage = UIImage(named: "camera2")
        takePhotoAction.setValue(cameraImage, forKey: "image")
        takePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let choosePhotoAction = UIAlertAction(title: "    Choose a Cover Photo", style: .default) { [weak self] (choosePhotoAction) in
            
            self?.choosePhotoSelected()
        }
        
        let photoImage = UIImage(named: "image")
        choosePhotoAction.setValue(photoImage, forKey: "image")
        choosePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addCoverPhotoAlert.addAction(takePhotoAction)
        addCoverPhotoAlert.addAction(choosePhotoAction)
        addCoverPhotoAlert.addAction(cancelAction)
        
        present(addCoverPhotoAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - Leave Collab Alert
    
    func presentLeaveCollabAlert () {
        
        let leaveCollabAlert = UIAlertController(title: "Leave this Collab?", message: "You will also lose access to all the data associated with this Collab", preferredStyle: .actionSheet)
        
        let leaveAction = UIAlertAction(title: "Leave", style: .destructive) { [weak self] (leaveAction) in
            
            self?.leaveCollab()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        leaveCollabAlert.addAction(leaveAction)
        leaveCollabAlert.addAction(cancelAction)
        
        self.present(leaveCollabAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - Prep for Image Zooming
    
    private func prepViewForImageViewZooming () {
        
        imageViewBeingZoomed = true
        
        if messageInputAccesoryView.textViewContainer.messageTextView.isFirstResponder {
            
            keyboardWasPresent = true
        }
        
        else {
            
            keyboardWasPresent = false
        }
        
        self.messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
        self.resignFirstResponder()
    }
    
    
    //MARK: - Dismiss Expanded View
    
    @objc private func dismissExpandedView () {
        
        if navigationItem.hidesBackButton == true {
            
            if calendarPresented {
                
                //If the "collabNavigationView" is expanded
                if collabNavigationViewTopAnchor?.constant == 0 {
                    
                    cancelButtonPressed()
                }
                
                else {
                    
                    dismissCalendar()
                }
            }
            
            else {
                
                cancelButtonPressed()
            }
        }
    }
    
    
    //MARK: - Load Remaining Voice Memos
    
    private func loadRemainingVoiceMemos () {
        
        //Loads all the voiceMemos so they can be played in the EditCollabViewController
        for voiceMemo in collab?.voiceMemos ?? [] {
            
            //If this voiceMemo hasn't yet been loaded
            if !FileManager.default.fileExists(atPath: documentsDirectory.path + "/VoiceMemos" + "\(voiceMemo.voiceMemoID ?? "").m4a") {
                
                if let collabID = collab?.collabID, let voiceMemoID = voiceMemo.voiceMemoID {
                    
                    firebaseStorage.retrieveCollabVoiceMemoFromStorage(collabID, voiceMemoID) { (progress, error) in
                        
                        if error != nil {
                            
                            print(error?.localizedDescription as Any)
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - Leave Collab
    
    private func leaveCollab () {
        
        if collab != nil {
            
            firebaseCollab.singularCollabListener?.remove()
            
            SVProgressHUD.show()
            
            firebaseCollab.leaveCollab(collab!) { [weak self] (error) in
                
                SVProgressHUD.dismiss()
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                    
                    SVProgressHUD.showError(withStatus: "Sorry, something went wrong while attempting to remove you from this Collab")
                }
                
                else {
                    
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
    //MARK: - Progress Button Tapped
    
    func progressButtonTouchUpInside () {
        
        if selectedTab == "Progress" {
            
            if blocks?.count ?? 0 > 0 {
                
                collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
            
            return
        }
        
        collabNavigationView.collabTableView.scrollsToTop = true
        collabNavigationView.collabTableView.keyboardDismissMode = .onDrag
        
        collabNavigationView.collabProgressView.collab = collab
        collabNavigationView.collabProgressView.blocks = blocks
        collabNavigationView.presentProgressView()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            
            self.collabNavigationView.collabTableView.alpha = 0
            self.addBlockButton.alpha = 0
            self.messageInputAccesoryView.alpha = 0
            self.collabNavigationView.messagesAnimationView.alpha = 0
            
            //Passed in the "selectedTab" because it hasn't been set for this view yet to prevent the "scrollViewDidScroll" method
            //from interferring with the animations of the "collabProgressView"
            self.collabNavigationView.handleProgressAnimation(selectedTab: "Progress")
            
            self.view.layoutIfNeeded()
            
        }) { (finished: Bool) in
            
            self.collabNavigationView.messagesAnimationView.animationView.stop()
            
            //Prevents interference from the scrollViewDidScroll func
            //Stops the scrolling of the tableView
            self.collabNavigationView.collabTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            
            self.selectedTab = "Progress" //Should be set here to prevent interference from the "scrollViewDidScroll" method
            self.collabNavigationView.collabTableView.reloadData()
            
            self.collabNavigationView.collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40, right: 0)
            self.collabNavigationView.collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40, right: 0)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.collabNavigationView.collabTableView.alpha = 1
                self.tabBar.alpha = 1
            })
        }
    }
    
    
    //MARK: - Blocks Button Tapped
    
    func blocksButtonTouchUpInside () {
        
        if selectedTab == "Blocks" {
            
            //Helps with the animations
            UIView.transition(with: collabNavigationView.collabTableView, duration: 0.3, options: .transitionCrossDissolve) {

                self.scrollToCurrentDate()
                self.scrollToFirstBlock()
            }
            
            if var startTime = collab?.dates["startTime"] {
                
                //Formatting the startTime so that the only the date and not the time is truly used
                formatter.dateFormat = "yyyy MM dd"
                startTime = formatter.date(from: formatter.string(from: startTime)) ?? Date()
                
                if let date = calendar.date(byAdding: .day, value: collabNavigationView.collabTableView.indexPathsForVisibleRows?.last?.row ?? 0, to: startTime) {
                    
                    collabCalendarView.calendarView.selectDates([date])
                    collabCalendarView.calendarView.scrollToDate(date)
                    
                    collabNavigationView.calendarView.selectDates([date])
                    collabNavigationView.calendarView.scrollToDate(date)
                }
            }
            
            return
        }
        
        //If the tableView is scrolling, this will help configure a placeholder cell before the tableView gets reloaded
        selectedTab = ""
        
        collabNavigationView.collabTableView.scrollsToTop = true
        
        collabNavigationView.dismissProgressView()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                     
            self.collabNavigationView.collabTableView.alpha = 0
            self.messageInputAccesoryView.alpha = 0
            self.collabNavigationView.messagesAnimationView.alpha = 0
            
            //Calling inside animation blocks allows for all animations to be performed seamlessly
            self.collabNavigationView.handleProgressAnimation()
            
            self.view.layoutIfNeeded()
            
        }) { (finished: Bool) in
            
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            self.collabNavigationView.messagesAnimationView.animationView.stop()
            
            //Stops the scrolling of the tableView
            self.collabNavigationView.collabTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //Setting here prevents the tableView from trying to use cells from a different tab for the blocks tab
            //averting a possible outOfBounds error (has not yet occured but this is precautionary because it was occuring when moving
            //to the messages tab)
            self.selectedTab = "Blocks"
            self.collabNavigationView.collabTableView.reloadData()
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            if var startTime = self.collab?.dates["startTime"], let currentSelectedDate = self.collabNavigationView.calendarView.selectedDates.first {

                //Formatting the startTime so that the only the date and not the time is truly used
                self.formatter.dateFormat = "yyyy MM dd"
                startTime = self.formatter.date(from: self.formatter.string(from: startTime)) ?? Date()

                //Scrolling to the first block of the currently selected date
                self.scrollToFirstBlock(indexPathToScrollTo: IndexPath(row: self.calendar.dateComponents([.day], from: startTime, to: currentSelectedDate).day ?? 0, section: 0), animate: false)
            }
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            self.collabNavigationView.collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0, right: 0)
            self.collabNavigationView.collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 40 : 0, right: 0)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.collabNavigationView.collabTableView.alpha = 1
                
                //The present calendar func decides whether the "tabBar" and "addBlockButton" should be hidden or not
                if !self.calendarPresented {
                    
                    self.tabBar.alpha = 1
                    self.addBlockButton.alpha = 1
                }
            })
        }
    }
    
    
    //MARK: - Messages Button Tapped
    
    func messagesButtonTouchUpInside () {
        
        if selectedTab == "Messages" {
            
            if messages?.count ?? 0 > 0 {
                
                //Scrolling to the last message
                collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
            }
            
            return
        }
        
        var delay: Double = 0
        
        //If the selectedTab is "Progress", will cause a 0.3 second delay to allow for the progressView to be dismissed before moving to the messages view
        //Fixes bug that was causing a crash when animating tableView change
        if selectedTab == "Progress" {
            
            //Fixes bug that wouldn't allow for the progressView to be dismissed when it was shrunken to only show it's searchBar
            //The scrollViewDidScroll method would be called overridding the dismissal of the progressView
            selectedTab = ""
            
            delay = 0.3
            collabNavigationView.dismissProgressView()
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                //Calling inside animation blocks allows for all animations to be performed seamlessly
                self.collabNavigationView.handleProgressAnimation()
                
                self.view.layoutIfNeeded()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
    
            self.collabNavigationView.collabTableView.scrollsToTop = false
            self.collabNavigationView.collabTableView.keyboardDismissMode = .interactive
    
            if self.messages?.count ?? 0 == 0 {
                
                self.collabNavigationView.messagesAnimationView.animationView.play()
            }
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
    
                self.collabNavigationView.collabTableView.alpha = 0
                self.tabBar.alpha = 0
                self.addBlockButton.alpha = 0
                
            }) { (finished: Bool) in
    
                //Stops the tableView from scrolling to prevent the "messages" array in the messaging methods from going out of bounds
                //with a indexPath.row that was going to be used by either the "Progress" or "Block" tab
                self.collabNavigationView.collabTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                
                //Setting here prevents the tableView from trying to use cells from a different tab for the messages tab
                //averting a outOfBounds error in the messagingMethods
                self.selectedTab = "Messages"
                self.collabNavigationView.collabTableView.reloadData()
    
                //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //Borrowed from the inputAccesoryViewMethods class
                let messageViewHeight = (self.messageInputAccesoryView.textViewContainer.frame.height + abs(self.inputAccesoryViewMethods.setTextViewBottomAnchor())) + 5
                
                self.collabNavigationView.collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: messageViewHeight + 5, right: 0)
                self.collabNavigationView.collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: messageViewHeight, right: 0)
                //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
                if self.messages?.count ?? 0 > 0 {
    
                    //Scrolling to the last message
                    self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: false)
                }
    
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
    
                    self.messageInputAccesoryView.alpha = 1
    
                    self.collabNavigationView.collabTableView.alpha = 1
                    
                    self.collabNavigationView.messagesAnimationView.alpha = self.messages?.count ?? 0 == 0 ? 1 : 0
                })
            }
        }
    }
    
    
    //MARK: - Edit Cover Pressed
    
    @objc func editCoverButtonPressed () {
        
        zoomingMethods?.handleZoomOutOnImageView()
        
        presentAddPhotoAlert(tracker: "coverAlert", shrinkView: false)
    }
    
    
    //MARK: - Delete Cover Pressed
    
    @objc func deleteCoverButtonPressed () {
        
        SVProgressHUD.show()
        
        firebaseCollab.deleteCollabCoverPhoto(collabID: collab!.collabID) { [weak self] (error) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            
            else {
                
                SVProgressHUD.dismiss()
                
                self?.collab?.coverPhotoID = nil
                self?.collab?.coverPhoto = nil
                self?.collabHeaderView.setCoverPhoto(self?.collab)
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                    
                    self?.zoomingMethods?.blackBackground?.backgroundColor = .clear
                    self?.zoomingMethods?.optionalButtons.forEach({ $0?.alpha = 0 })
                    self?.zoomingMethods?.zoomedInImageView?.alpha = 0
                    
                } completion: { (finished: Bool) in
                    
                    self?.zoomingMethods?.blackBackground?.removeFromSuperview()
                    self?.zoomingMethods?.optionalButtons.forEach({ $0?.removeFromSuperview() })
                    self?.zoomingMethods?.zoomedInImageView?.removeFromSuperview()
                }
            }
        }
    }
    
    
    //MARK: - Cancel Button Pressed
    
    @objc private func cancelButtonPressed () {
        
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
        title = ""
        
        //Dismissing the expanded view
        if !calendarPresented {
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            navigationItem.hidesBackButton = false
        }
        
        //Dismissing the expanded view to go back to the calendarPresented view
        else {
            
            let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(dismissCalendar))
            cancelButton.style = .done
            navigationItem.leftBarButtonItem = cancelButton
        }
        
        if selectedTab == "Progress" {
            
            collabNavigationView.collabProgressView.searchBar?.endEditing(true)
        }
        
        else if selectedTab == "Messages" {

            dismissKeyboard ()
            
            messageInputAccesoryView.size = messageInputAccesoryView.configureSize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
                if self.messages?.count ?? 0 > 0 {
                    
                    self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
                }
            }
        }
        
        //Experimenting with calling this after the if statements above... was previously before those statements but was causing issues with the "Blocks" condition
        //Allows for the "originalTableViewContentOffset" to be set by the "Blocks" condition
        returnToOrigin(scrollTableView: false)
    }
    
    
    //MARK: - Attachment Button Pressed
    
    @objc private func attachmentButtonPressed () {
        
        performSegue(withIdentifier: "moveToAttachmentsView", sender: self)
    }
    
    
    //MARK: - Add Block Button
    
    @objc private func addBlockButtonPressed () {
        
        //Ensures that the collabNavigationView is expanded
        if collabNavigationViewTopAnchor?.constant ?? 0 != 0 {
            
            expandView()
        }
        
        performSegue(withIdentifier: "moveToConfigureBlockView", sender: self)
    }
    
    
    //MARK: - See Hidden Blocks Button
    
    @objc private func seeHiddenBlocksButtonPressed () {
        
        hiddenBlockVC = HiddenBlocksViewController()
        hiddenBlockVC?.hiddenBlocks = hiddenBlocks
        hiddenBlockVC?.blockSelectedDelegate = self
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        self.navigationController?.pushViewController(hiddenBlockVC!, animated: true)
    }
    
    
    //MARK: - Present Nav View Button
    
    @objc private func presentNavViewButtonPressed () {
        
        returnToOrigin(animateCollabHeaderView: false)
        
        self.becomeFirstResponder()
        
        self.title = nil
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
        
        self.collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight()
        
        UIView.animate(withDuration: 0.275, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.collabHeaderView.alpha = 1
            
            self.collabHomeTableView.contentOffset.y = 0
        }
        
        if selectedTab == "Messages" {
            
            messageInputAccesoryView.alpha = 1
        }
    }
    
    
    //MARK: - Edit Collab Pressed
    
    func editCollabButtonPressed () {
        
        loadRemainingVoiceMemos()
        
        moveToEditCollabView()
    }
    
    
    //MARK: - Leave Collab Pressed
    
    func leaveCollabButtonPressed () {
        
        presentLeaveCollabAlert()
    }
    
    
    //MARK: - Dismiss Keyboard
    
    private func dismissKeyboard () {
        
        messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
    }
    
    
    //MARK: - Dismiss Keyboard Tap
    
    @objc private func dismissKeyboardTap () {
        
        if selectedTab == "Messages", messages?.count ?? 0 == 0 {
            
            messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
        }
    }
    
    
    //MARK: - Move to Objective View
    
    func moveToObjectiveView () {
        
        collabObjectiveVC = CollabObjectiveViewController()
        collabObjectiveVC?.collabViewController = self
        collabObjectiveVC?.objective = collab?.objective
        
        self.present(collabObjectiveVC!, animated: true, completion: nil)
    }
    
    
    //MARK: - Move to Edit Collab View
    
    private func moveToEditCollabView () {
        
        if collab != nil {
            
            let configureCollabVC = ConfigureCollabViewController()
            configureCollabVC.title = "Edit a Collab"
            configureCollabVC.collab = collab!
            
            configureCollabVC.configurationView = false
            configureCollabVC.configureBarButtonItems()
            
            let configureCollabNavigationController = UINavigationController(rootViewController: configureCollabVC)
            configureCollabNavigationController.navigationBar.prefersLargeTitles = true
            
            self.present(configureCollabNavigationController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToSendPhotoView" {
            
            let sendPhotoVC = segue.destination as! SendPhotoMessageViewController
            sendPhotoVC.collabConversationID = collab?.collabID
            sendPhotoVC.reconfigureCollabViewDelegate = self
            sendPhotoVC.selectedPhoto = selectedPhoto
            
            removeObservors()
        }
        
        else if segue.identifier == "moveToAttachmentsView" {
            
            let attachmentsView = segue.destination as! CollabMessagesAttachmentsView
            attachmentsView.collabID = collab?.collabID
            attachmentsView.photoMessages = firebaseMessaging.filterPhotoMessages(messages: messages).sorted(by: { $0.timestamp > $1.timestamp })
        }
        
        else if segue.identifier == "moveToLocationsView" {
            
            let locationVC = segue.destination as! LocationsViewController
            locationVC.locations = collab?.locations
            
            if let cell = collabHomeTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? LocationsPresentationCell {
                
                locationVC.selectedLocationIndex = cell.selectedLocationIndex
            }
        }
        
        else if segue.identifier == "moveToConfigureBlockView" {
            
            let configureBlockVC: ConfigureBlockViewController = ConfigureBlockViewController()
            configureBlockVC.title = "Add a Block"
            
            configureBlockVC.collab = collab
            configureBlockVC.blockCreatedDelegate = self
            
            //This will set the block date to be the current selected date
            if let selectedDate = collabNavigationView.calendarView.selectedDates.first, !calendar.isDate(selectedDate, inSameDayAs: Date()) {
                
                configureBlockVC.block.starts = selectedDate
                configureBlockVC.block.ends = selectedDate.adjustTime(roundDown: false)
            }
            
            let configureBlockNavigationController = UINavigationController(rootViewController: configureBlockVC)
            configureBlockNavigationController.navigationBar.prefersLargeTitles = true
            
            self.present(configureBlockNavigationController, animated: true, completion: nil)
        }
        
        else if segue.identifier == "moveToSelectedBlockView" {
            
            if let navController = segue.destination as? UINavigationController {
                
                let selectedBlockVC = navController.viewControllers.first as! SelectedBlockViewController
                selectedBlockVC.collab = collab
                selectedBlockVC.block = selectedBlock
            }
        }
    }
}


//MARK: - Gesture Recognizor Extension

extension CollabViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return false
    }
}


//MARK: - Cache Photo Protocol Extension

extension CollabViewController: CachePhotoProtocol {
    
    internal func cacheMessagePhoto(messageID: String, photo: UIImage?) {
        
        if let messageIndex = messages?.firstIndex(where: { $0.messageID == messageID }) {
            
            messages?[messageIndex].messagePhoto?["photo"] = photo
        }
    }
    
    func cacheCollabPhoto(photoID: String, photo: UIImage?) {
        
        collab?.photos[photoID] = photo
    }
    
    func cacheBlockPhoto(photoID: String, photo: UIImage?) {}
}


//MARK: - Present Copied Animation Protocol Extension

extension CollabViewController: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        var topAnchor: CGFloat
        
        //The view hasn't been expanded
        if collabNavigationViewTopAnchor?.constant != 0 {
            
            let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            topAnchor = statusBarHeight + 10
        }
        
        else {
            let navBarHeight = navigationController?.navigationBar.frame.maxY ?? 0
            topAnchor = navBarHeight + 10
        }
        
        copiedAnimationView?.presentCopiedAnimation(topAnchor: topAnchor)
    }
}


//MARK: - Zoom In Protocol Extension

extension CollabViewController: ZoomInProtocol {
    
    func zoomInOnPhotoImageView(photoImageView: UIImageView) {
        
        prepViewForImageViewZooming() 
        
        zoomingMethods = ZoomingImageViewMethods(on: photoImageView, cornerRadius: 10, completion: { [weak self] in
        
            self?.becomeFirstResponder()
            
            if self?.keyboardWasPresent ?? false {
                
                self?.messageInputAccesoryView.textViewContainer.messageTextView.becomeFirstResponder()
            }
            
            self?.imageViewBeingZoomed = false
        })
        
        zoomingMethods?.performZoom()
    }
}


//MARK: - Image Picker Extension

extension CollabViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhotoSelected () {

        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.configureNavBar()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false

        self.present(imagePicker, animated: true, completion: nil)
    }

    func choosePhotoSelected () {

        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.configureNavBar()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true

        present(imagePicker, animated: true, completion: nil)
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

            dismiss(animated: true, completion: nil)

            if alertTracker == "coverAlert" {

                collabHeaderView.configureCoverPhoto()
                
                let coverPhotoID = UUID().uuidString
                
                firebaseCollab.saveCollabCoverPhoto(collabID: collab!.collabID, coverPhotoID: coverPhotoID, coverPhoto: selectedImage) { [weak self] (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        self?.collab?.coverPhotoID = coverPhotoID
                        self?.collab?.coverPhoto = selectedImage
                        self?.collabHeaderView.setCoverPhoto(self?.collab)
                    }
                }
            }
            
            else if alertTracker == "attachmentAlert" {
                
                selectedPhoto = selectedImage
                
                performSegue(withIdentifier: "moveToSendPhotoView", sender: self)
            }
        }

        else {

            dismiss(animated: true) {

                SVProgressHUD.showError(withStatus: "Sorry, something went wrong selecting this photo")
            }
        }
    }
}


//MARK: - Collab Member Protocol Extension

extension CollabViewController: CollabMemberProtocol {
    
    func moveToProfileView (_ member: Member, _ memberContainerView: UIView) {
        
        tabBar.shouldHide = true
        
        memberProfileVC = CollabMemberProfileViewController()
        memberProfileVC?.modalPresentationStyle = .overCurrentContext
        
        memberProfileVC?.collabViewController = self
        
        memberProfileVC?.member = member
        memberProfileVC?.memberActivity = collab?.memberActivity?[member.userID]
        memberProfileVC?.blocks = blocks
        memberProfileVC?.memberContainerView = memberContainerView
        
        self.present(memberProfileVC!, animated: false) {
            
            self.memberProfileVC?.performZoomPresentationAnimation()
        }
    }
}


//MARK: - Location Selected Extension

extension CollabViewController: LocationSelectedProtocol {
    
    func locationSelected(_ location: Location?) {
        
        let locationsVC: LocationsViewController = LocationsViewController()
        locationsVC.locations = collab?.locations
    
        if let cell = collabHomeTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? LocationsPresentationCell {
            
            locationsVC.selectedLocationIndex = cell.selectedLocationIndex
        }
        
        //Creating the navigation controller for the LocationsViewController
        let locationsNavigationController = UINavigationController(rootViewController: locationsVC)
        
        self.present(locationsNavigationController, animated: true, completion: nil)
    }
}


//MARK: - Cache Icon Protocol Extension

extension CollabViewController: CacheIconProtocol {
    
    func cacheIcon (linkID: String, icon: UIImage?) {
        
        if let linkIndex = collab?.links?.firstIndex(where: { $0.linkID == linkID }) {
            
            collab?.links?[linkIndex].icon = icon != nil ? icon : UIImage(named: "link")
            
            if let cell = collabHomeTableView.cellForRow(at: IndexPath(row: 9, section: 0)) as? LinksPresentationCell {
                
                cell.links = collab?.links
            }
        }
    }
}
