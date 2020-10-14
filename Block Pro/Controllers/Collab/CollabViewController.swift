//
//  CollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/24/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class CollabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    lazy var collabHeaderView = CollabHeaderView(collab)
    
    let collabNavigationView = CollabNavigationView()
    let presentCollabNavigationViewButton = UIButton(type: .system)
    
    let collabHomeTableView = UITableView()
    
    lazy var editCoverButton: UIButton = configureEditCoverButton()
    lazy var deleteCoverButton: UIButton = configureDeleteCoverButton()
    
    let addBlockButton = UIButton(type: .system)
    
    let tabBar = CustomTabBar.sharedInstance
    
    var copiedAnimationView: CopiedAnimationView?
    
    let messageInputAccesoryView = InputAccesoryView(textViewPlaceholderText: "Send a message", showsAddButton: true)
    var inputAccesoryViewMethods: InputAccesoryViewMethods!
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    var collab: Collab?
    
    var messagingMethods: MessagingMethods!
    var messages: [Message]?
    
    var selectedTab: String = "Blocks"
    var alertTracker: String = ""
    
    var keyboardHeight: CGFloat?
    
    var messageTextViewText: String = ""
    var selectedPhoto: UIImage?
    
    var gestureViewPanGesture: UIPanGestureRecognizer?
    var stackViewPanGesture: UIPanGestureRecognizer?
    var dismissExpandedViewGesture: UISwipeGestureRecognizer?
    
    var zoomingMethods: ZoomingImageViewMethods?

    var imageViewBeingZoomed: Bool?
    var keyboardWasPresent: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        configureGestureRecognizers()
        
        configureHeaderView()
        configureCollabHomeTableView()
        
        configurePresentCollabNavigationViewButton()
        configureCollabNavigationView()
        
        configureAddBlockButton()
        
        configureBlockView()
//        configureMessagingView()
        
        retrieveMessages()
        
        setUserActiveStatus()
        
        retrieveMemberProfilePics()
        
        messageInputAccesoryView.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        retrieveMessageDraft()
        
        //Initializing here allows the animationView to be removed and readded multiple times
        copiedAnimationView = CopiedAnimationView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addObservors()
        
        self.becomeFirstResponder()
        
        configureTabBar() //Possibly animate to avoid finnicky animation when user partially leaves view on swipe dismissal then returns 
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        removeObservors()
        
        firebaseCollab.messageListener?.remove()
        
        setUserInactiveStatus()
        
        saveMessageDraft()
        
        copiedAnimationView?.removeCopiedAnimation(remove: true)
        
        tabBar.previousNavigationController = navigationController
    }
    
    override var inputAccessoryView: UIView? {
        return messageInputAccesoryView
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView == collabHomeTableView {
            
            return 3
        }
        
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == collabHomeTableView {
            
            if section == 0 {
                
                return 3
            }
            
            else if section == 1 {
                
                return 4
            }
            
            else {
                
                return 3
            }
        }
        
        else {
            
            if selectedTab == "Blocks" {
                
                return 1
            }
            
            else if selectedTab == "Messages" {
                
                if tableView == collabNavigationView.collabTableView {

                    return messagingMethods.numberOfRowsInSection(messages: messages)
                }
                
                return messagingMethods.numberOfRowsInSection(messages: messages)
            }
            
            else {
                
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        if tableView == collabHomeTableView {
            
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeMembersHeaderCell", for: indexPath) as! CollabHomeMembersHeaderCell
                    cell.selectionStyle = .none
                    return cell
                }
                
                else if indexPath.row == 1 {
                    
                    let cell = UITableViewCell()
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeMembersCell", for: indexPath) as! CollabHomeMembersCell
                    cell.selectionStyle = .none
                    cell.collab = collab
                    
                    return cell
                }
            }
            
            else if indexPath.section == 1 {
                
                if indexPath.row == 0 {
                    
                    let cell = UITableViewCell()
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else if indexPath.row == 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeLocationsHeaderCell", for: indexPath) as! CollabHomeLocationsHeaderCell
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else if indexPath.row == 2 {
                    
                    let cell = UITableViewCell()
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeLocationsCell", for: indexPath) as! CollabHomeLocationsCell
                    cell.selectionStyle = .none
                    return cell
                }
            }
            
            else {
                
                if indexPath.row == 0 {
                    
                    let cell = UITableViewCell()
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else if indexPath.row == 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomePhotosHeaderCell", for: indexPath) as! CollabHomePhotosHeaderCell
                    cell.selectionStyle = .none
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomePhotosCell", for: indexPath) as! CollabHomePhotosCell
                    cell.selectionStyle = .none
                    
                    cell.collabID = collab?.collabID
                    cell.photoIDs = collab?.photoIDs

                    cell.cachePhotoDelegate = self
                    cell.zoomInDelegate = self
                    cell.presentCopiedAnimationDelegate = self
                    
                    return cell
                }
            }
        }
        
        else {
            
            if selectedTab == "Blocks" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "collabBlocksTableViewCell", for: indexPath) as! CollabBlocksTableViewCell
                cell.selectionStyle = .none
                return cell
            }
            
            else if selectedTab == "Messages" {
                
                if tableView == collabNavigationView.collabTableView {
                    
                    return messagingMethods.cellForRowAt(indexPath: indexPath, messages: messages, members: collab?.members)
                }
            }
            
            return messagingMethods.cellForRowAt(indexPath: indexPath, messages: messages, members: collab?.members)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == collabHomeTableView {
            
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                    return 20
                }
                
                else if indexPath.row == 1 {
                    
                    return 10
                }
                
                else if indexPath.row == 2 {
                    
                    return 170//200
                }
                
                else {
                    
                    return 200
                }
            }
            
            else if indexPath.section == 1 {
                
                if indexPath.row == 0 {
                    
                    return 20
                }
                
                else if indexPath.row == 1 {
                    
                    return 20
                }
                
                else if indexPath.row == 2 {
                    
                    return 10
                }
                
                else {
                    
                    return 210
                }
            }
            
            else {
                
                if indexPath.row == 0 {
                    
                    return 2.5
                }
                
                else if indexPath.row == 1 {
                    
                    return 25
                }
                
                else {
                    
                    let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
                    
                    if collab?.photoIDs.count ?? 0 <= 3 {
                        
                        return itemSize + 20 + 20// The item size plus the top and bottom edge insets, i.e. 20 and the top and bottom anchors i.e. 20
                    }
                    
                    else {
                        
                        return (itemSize * 2) + 20 + 20 + 5 //The height of the two rows of items that'll be displayed plus the edge insets, i.e. 20, the top and bottom anchors i.e. 20, and the line spacing i.e. 5
                    }
                }
            }
        }
        
        else {
            
            if selectedTab == "Blocks" {
                
                return 2210
            }
            
            else if selectedTab == "Messages" {
                
                if tableView == collabNavigationView.collabTableView {
                    
                    return messagingMethods.heightForRowAt(indexPath: indexPath, messages: messages)
                }
            }
            
            return messagingMethods.heightForRowAt(indexPath: indexPath, messages: messages)
        }
    }
    
    private func configureNavBar () {
        
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
    }
    
    private func configureHeaderView () {
        
        self.view.addSubview(collabHeaderView)
        collabHeaderView.collabViewController = self
    }
    
    private func configureCollabHomeTableView () {
        
        self.view.addSubview(collabHomeTableView)
        collabHomeTableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabHomeTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collabHomeTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            collabHomeTableView.topAnchor.constraint(equalTo: collabHeaderView.bottomAnchor, constant: 5),
            collabHomeTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
//        collabHomeTableView.backgroundColor = .blue
        
        collabHomeTableView.dataSource = self
        collabHomeTableView.delegate = self
        
        collabHomeTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 200, right: 0)
        collabHomeTableView.separatorStyle = .none
        
        collabHomeTableView.register(UINib(nibName: "CollabHomeMembersHeaderCell", bundle: nil), forCellReuseIdentifier: "collabHomeMembersHeaderCell")
        collabHomeTableView.register(UINib(nibName: "CollabHomeMembersCell", bundle: nil), forCellReuseIdentifier: "collabHomeMembersCell")
        collabHomeTableView.register(UINib(nibName: "CollabHomeLocationsHeaderCell", bundle: nil), forCellReuseIdentifier: "collabHomeLocationsHeaderCell")
        collabHomeTableView.register(UINib(nibName: "CollabHomeLocationsCell", bundle: nil), forCellReuseIdentifier: "collabHomeLocationsCell")
        collabHomeTableView.register(UINib(nibName: "CollabHomePhotosHeaderCell", bundle: nil), forCellReuseIdentifier: "collabHomePhotosHeaderCell")
        collabHomeTableView.register(UINib(nibName: "CollabHomePhotosCell", bundle: nil), forCellReuseIdentifier: "collabHomePhotosCell")
    }
    
    private func configureCollabNavigationView () {
        
        self.view.addSubview(collabNavigationView)
        collabNavigationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabNavigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collabNavigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
//            collabNavigationView.topAnchor.constraint(equalTo: collabHeaderView.bottomAnchor, constant: /*-50*/-80),
            collabNavigationView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: collabHeaderView.configureViewHeight() - 80),
            collabNavigationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        collabNavigationView.collabViewController = self
    }
    
    private func configureBlockView () {
        
        collabNavigationView.collabTableView.dataSource = self
        collabNavigationView.collabTableView.delegate = self
        
        collabNavigationView.collabTableView.separatorStyle = .none
        
        collabNavigationView.collabTableView.estimatedRowHeight = 0
        
        collabNavigationView.collabTableView.scrollsToTop = true
        
        collabNavigationView.collabTableView.register(UINib(nibName: "CollabBlocksTableViewCell", bundle: nil), forCellReuseIdentifier: "collabBlocksTableViewCell")
    }
    
    private func configureMessagingView () {
        
        messageInputAccesoryView.parentViewController = self
//        messageInputAccesoryView.isHidden = true
        
        messagingMethods = MessagingMethods(parentViewController: self, tableView: collabNavigationView.collabTableView, collabID: collab?.collabID ?? "")
        messagingMethods.configureTableView()
        
        inputAccesoryViewMethods = InputAccesoryViewMethods(accesoryView: messageInputAccesoryView, textViewPlaceholderText: "Send a message", tableView: collabNavigationView.collabTableView)
    }
    
    private func configurePresentCollabNavigationViewButton () {
        
        self.view.addSubview(presentCollabNavigationViewButton)
        presentCollabNavigationViewButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            presentCollabNavigationViewButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            presentCollabNavigationViewButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 40),
            presentCollabNavigationViewButton.widthAnchor.constraint(equalToConstant: 37.5),
            presentCollabNavigationViewButton.heightAnchor.constraint(equalToConstant: 37.5)
        
        ].forEach({ $0.isActive = true })

        presentCollabNavigationViewButton.tag = 1
        
        presentCollabNavigationViewButton.tintColor = UIColor(hexString: "222222")
        presentCollabNavigationViewButton.setImage(UIImage(systemName: "chevron.up.circle.fill"), for: .normal)
        presentCollabNavigationViewButton.contentVerticalAlignment = .fill
        presentCollabNavigationViewButton.contentHorizontalAlignment = .fill
        
        presentCollabNavigationViewButton.addTarget(self, action: #selector(presentNavViewButtonPressed), for: .touchUpInside)
    }
    
    private func configureEditCoverButton () -> UIButton {
        
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
    
    private func configureDeleteCoverButton () -> UIButton {
        
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
    
    private func configureAddBlockButton () {
        
//        addBlockButton.addTarget(self, action: #selector(newMessageButtonPressed), for: .touchUpInside)
        addBlockButton.backgroundColor = UIColor(hexString: "222222")
        addBlockButton.setImage(UIImage(named: "plus 2"), for: .normal)
        addBlockButton.tintColor = .white
        
        view.addSubview(addBlockButton)
        
        addBlockButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            addBlockButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -29),
            addBlockButton.widthAnchor.constraint(equalToConstant: 60),
            addBlockButton.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach( { $0.isActive = true } )
        
        addBlockButton.layer.cornerRadius = 30
        addBlockButton.clipsToBounds = true
    }
    
    func configureTabBar () {

        tabBarController?.tabBar.isHidden = true
        tabBarController?.delegate = tabBar
        
        tabBar.tabBarController = tabBarController
        tabBar.currentNavigationController = self.navigationController
        
//        tabBar.configureActiveTabBarGestureRecognizers(self.view)
        
        if tabBar.previousNavigationController == tabBar.currentNavigationController {
            
//            tabBar.shouldHide = true
        }
        
        view.addSubview(tabBar)
        
        addBlockButton.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -25).isActive = true
        
        presentCollabNavigationViewButton.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 20).isActive = true
    }
    
    
    internal func addObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUserActiveStatus), name: UIApplication.didBecomeActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(setUserInactiveStatus), name: UIApplication.willResignActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(saveMessageDraft), name: UIApplication.willTerminateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendMessage), name: .userDidSendMessage, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addAttachment), name: .userDidAddMessageAttachment, object: nil)
    }
    
    private func removeObservors () {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureGestureRecognizers () {

        dismissExpandedViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissExpandedView))
        dismissExpandedViewGesture?.delegate = self
        dismissExpandedViewGesture?.cancelsTouchesInView = true
        dismissExpandedViewGesture?.direction = .right
        view.addGestureRecognizer(dismissExpandedViewGesture!)
        
        gestureViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        //panGestureView.addGestureRecognizer(gestureViewPanGesture!)
        collabNavigationView.panGestureView.addGestureRecognizer(gestureViewPanGesture!)
        
        stackViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
//        buttonStackView.addGestureRecognizer(stackViewPanGesture!)
        collabNavigationView.buttonStackView.addGestureRecognizer(stackViewPanGesture!)
    }
        
    private func reconfigureGestureRecognizers () {
        
//        panGestureView.addGestureRecognizer(gestureViewPanGesture!)
//        buttonStackView.addGestureRecognizer(stackViewPanGesture!)
    }
    
    private func removeGestureRecognizers () {
        
        if let gestureViewGesture = gestureViewPanGesture, let stackViewGesture = stackViewPanGesture {
            
//            panGestureView.removeGestureRecognizer(gestureViewGesture)
//            buttonStackView.removeGestureRecognizer(stackViewGesture)
        }
    }
    
    //May not be neccasary because profile pics may already be obtained from the home view; leaving it here for now tho. Mainly because there may be cases where the user hasnt allowed for all the pics to be loaded yet, and its not the time for me to be setting up observors 
    private func retrieveMemberProfilePics () {

        if let members = collab?.members {
            
            var count = 0
            
            for member in members {
                
                if let memberIndex = firebaseCollab.friends.firstIndex(where: {$0.userID == member.userID}) {

                    collab?.members[count].profilePictureImage = firebaseCollab.friends[memberIndex].profilePictureImage
                }
                
                else {
                    
                    let memberIndex = count
                    
                    firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { (profilePic, userID) in
                        
                        self.collab?.members[memberIndex].profilePictureImage = profilePic
                        
                        
                    }
                }
                
                count += 1
            }
        }
        
        else {
            
            print("something went wrong")
        }
    }
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            moveWithPan(sender: sender)
            
        case .ended:
            
            if (collabNavigationView.frame.minY > (collabHeaderView.frame.height / 2)) && (collabNavigationView.frame.minY < (UIScreen.main.bounds.height / 2)) {
                
                returnToOrigin()
            }
            
            else if (collabNavigationView.frame.minY < (collabHeaderView.frame.height / 2)) {
                
                expandView()
            }
            
            else if (collabNavigationView.frame.minY > (UIScreen.main.bounds.height / 2)) {
                
                shrinkView()
            }

        default:
            
            break
        }
    }
    
    private func moveWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        let collabHeaderViewHeightConstraint = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
        let collabNavigationViewTopAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .top })
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        
        if (collabNavigationView.frame.minY + translation.y) < (collabHeaderView.configureViewHeight() - 80) {
            
            //where you should do the nav view animation
            
            if collabNavigationViewBottomAnchor?.constant == 0 {
                
                collabNavigationView.collabTableView.contentOffset.y = collabNavigationView.collabTableView.contentOffset.y + translation.y
            }
            
            else {
                
                collabNavigationView.collabTableView.contentOffset.y += abs(collabNavigationViewBottomAnchor?.constant ?? 0)
            }
            
            collabNavigationViewTopAnchor?.constant += translation.y
            collabNavigationViewBottomAnchor?.constant = 0
            
//            the alpha animation stuff
            let collabNavigationViewMinY = collabNavigationView.frame.minY - 44 > 0 ? collabNavigationView.frame.minY - 44 : 0
            let adjustedAlpha: CGFloat = ((1 / (collabHeaderView.configureViewHeight() - 80)) * collabNavigationViewMinY)
            collabNavigationView.panGestureIndicator.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
            collabNavigationView.buttonStackView.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
        }
        
        else {
            
            //where you should do the header view animation
            
            collabNavigationViewTopAnchor?.constant += translation.y
            collabNavigationViewBottomAnchor?.constant = collabNavigationView.frame.minY - (collabHeaderView.configureViewHeight() - 80)
        
            let collabNavViewOriginMinY = collabHeaderView.configureViewHeight() - 80
            let collabNavViewDistanceFromBottom = (collabNavigationViewTopAnchor!.constant - collabNavViewOriginMinY) / (self.view.frame.height - collabNavViewOriginMinY)
            
            collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight() - (70 * collabNavViewDistanceFromBottom)
            
//            messageInputAccesoryView.alpha = 1 - (1 * collabNavViewDistanceFromBottom)
        }
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc private func returnToOrigin (scrollTableView: Bool = true) {
        
        let collabHeaderViewHeightConstraint = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
        let collabNavigationViewTopAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .top })
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        let presentNavViewButtonBottomAnchor = self.view.constraints.first(where: { $0.firstItem?.tag == 1 && $0.firstAttribute == .bottom })
        let collabTableViewTopAnchor = collabNavigationView.constraints.first(where: { $0.firstItem as? UITableView != nil && $0.firstAttribute == .top })
        
//        let distanceFromOrigin = abs((collabHeaderView.configureViewHeight() - 80) - (collabNavigationViewTopAnchor?.constant ?? 0))
//        let duration = TimeInterval(distanceFromOrigin * 0.001)
//        print(collabNavigationViewTopAnchor?.constant, duration)
        
        collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight()
        collabNavigationViewTopAnchor?.constant = collabHeaderView.configureViewHeight() - 80
        collabNavigationViewBottomAnchor?.constant = 0
        presentNavViewButtonBottomAnchor?.constant = 40
        collabTableViewTopAnchor?.constant = 10
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()

            self.collabNavigationView.layer.cornerRadius = 27.5
            self.collabNavigationView.panGestureIndicator.alpha = 1
            self.collabNavigationView.buttonStackView.alpha = 1
            
            self.tabBar.alpha = self.selectedTab != "Messages" ? 1 : 0
            self.addBlockButton.alpha = self.selectedTab == "Blocks" ? 1 : 0
        })
        
        if selectedTab == "Messages" && self.messages?.count ?? 0 > 0 && scrollTableView {
            
            self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
        }
    }
    
    private func shrinkView () {
        
        self.resignFirstResponder()
        
        let collabHeaderViewHeightAnchor = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
        let collabNavigationViewTopAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .top })
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        let presentNavViewButtonBottomAnchor = self.view.constraints.first(where: { $0.firstItem?.tag == 1 && $0.firstAttribute == .bottom })
        
        collabHeaderViewHeightAnchor?.constant = collabHeaderView.configureViewHeight() - 70
        collabNavigationViewTopAnchor?.constant = self.view.frame.height
        collabNavigationViewBottomAnchor?.constant = self.view.frame.height
        presentNavViewButtonBottomAnchor?.constant = -20//-40
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.tabBar.alpha = 1
            self.addBlockButton.alpha = 0
            self.messageInputAccesoryView.alpha = 0
        }
    }
    
    internal func expandView () {
 
        let collabNavigationViewTopAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .top })
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        let collabTableViewTopAnchor = collabNavigationView.constraints.first(where: { $0.firstItem as? UITableView != nil && $0.firstAttribute == .top })
        
        collabNavigationViewTopAnchor?.constant = 0
        collabNavigationViewBottomAnchor?.constant = 0
        collabTableViewTopAnchor?.constant = ((topBarHeight - collabNavigationView.buttonStackView.frame.maxY) + 5)
        
        title = selectedTab
        
        viewExpanded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()
            
            self.collabNavigationView.layer.cornerRadius = 0
            self.collabNavigationView.panGestureIndicator.alpha = 0
            self.collabNavigationView.buttonStackView.alpha = 0
        })
    }
    
    internal func viewExpanded () {
        
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
        navigationItem.hidesBackButton = true

        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(cancelButtonPressed))
        cancelButton.style = .done
        navigationItem.leftBarButtonItem = cancelButton
        
        if selectedTab == "Blocks" {
            
            let attachmentButton = UIBarButtonItem(image: UIImage(named: "info"), style: .done, target: self, action: #selector(infoButtonPressed))
            navigationItem.setRightBarButton(attachmentButton, animated: true)
        }
        
        else if selectedTab == "Messages" {
            
            let attachmentButton = UIBarButtonItem(image: UIImage(named: "attach"), style: .done, target: self, action: #selector(attachmentButtonPressed))
            navigationItem.setRightBarButton(attachmentButton, animated: true)
        }
        
        removeGestureRecognizers()
    }
    
    private func setTableViewTopAnchor () -> CGFloat {
        
        //iPhone 11 Pro Max & iPhone 11
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            return 30
        }
            
        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            return 30
        }
        
        else {
            
            return 0
        }
    }
    
    //MARK: - User Activity Functions
    
    #warning("yo this is a quick reminder that this works a little weird in this view; basically it'll always cause the messages in the messagehomeview to appear read even if the user hasn't moved to the messages tab in this view yet... sumn to look at and decide whether or not to fix in da future")
    @objc private func setUserActiveStatus () {
        
        if let collabID = collab?.collabID {
            
            //Probably move this func to firebaseCollab as well as firebaseMessaging; little weird using firebaseMessaging this weird imo
            firebaseMessaging.setActivityStatus(collabID: collabID, "now")
        }
    }
    
    @objc private func setUserInactiveStatus () {
          
        //if !infoViewBeingPresented {
            
        if let collabID = collab?.collabID {
                
                //Probably move this func to firebaseCollab as well as firebaseMessaging; little weird using firebaseMessaging this weird imo
                firebaseMessaging.setActivityStatus(collabID: collabID, Date())
            }
        //}
    }
    
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
    }
    
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
    
    @objc private func dismissKeyboard () {
        
        messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
    }
    
    @objc private func cancelButtonPressed () {
        
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = false

        title = ""
        
        reconfigureGestureRecognizers()
        
        returnToOrigin(scrollTableView: false)
        
        if selectedTab == "Messages" {

            dismissKeyboard ()
            
            messageInputAccesoryView.size = messageInputAccesoryView.configureSize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
                if self.messages?.count ?? 0 > 0 {
                    
                    self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    @objc private func dismissExpandedView () {

        if navigationItem.hidesBackButton == true && tabBar.shouldHide == true {
            
            cancelButtonPressed()
        }
    }
    
    @objc private func infoButtonPressed () {
        
    }
    
    @objc private func attachmentButtonPressed () {
        
        performSegue(withIdentifier: "moveToAttachmentsView", sender: self)
    }
    
    
    
    @objc private func editCoverButtonPressed () {
        
        zoomingMethods?.handleZoomOutOnImageView()
        
        presentAddPhotoAlert(tracker: "coverAlert")
    }
    
    @objc private func deleteCoverButtonPressed () {
        
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
    
    //MARK: - Add Cover Photo Function
    
    func presentAddPhotoAlert (tracker: String) {
        
        shrinkView()
        
        alertTracker = tracker
        
        let addCoverPhotoAlert = UIAlertController (title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "    Take a Photo", style: .default) { (takePhotoAction) in
          
            self.takePhotoSelected()
        }
        
        let cameraImage = UIImage(named: "camera2")
        takePhotoAction.setValue(cameraImage, forKey: "image")
        takePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let choosePhotoAction = UIAlertAction(title: "    Choose a Photo", style: .default) { (choosePhotoAction) in
            
            self.choosePhotoSelected()
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
    
    func progressButtonTouchUpInside () {
        
        selectedTab = "Progress"
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            
            self.messageInputAccesoryView.alpha = 0
            
        }) { (finished: Bool) in
            
//            self.messageInputAccesoryView.isHidden = true
            
            self.collabNavigationView.collabTableView.reloadSections([0], with: .none)
        }
    }
    
    func blocksButtonTouchUpInside () {
        
        selectedTab = "Blocks"
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                     
            self.collabNavigationView.collabTableView.alpha = 0
            self.messageInputAccesoryView.alpha = 0
            
        }) { (finished: Bool) in
            
            self.collabNavigationView.collabTableView.reloadData()
            
            self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.collabNavigationView.collabTableView.alpha = 1
                self.tabBar.alpha = 1
                self.addBlockButton.alpha = 1
            })
        }
    }
    
    func messagesButtonTouchUpInside () {
        
        selectedTab = "Messages"
        
        configureMessagingView()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            
            self.collabNavigationView.collabTableView.alpha = 0
            self.tabBar.alpha = 0
            self.addBlockButton.alpha = 0
            //self.tabBar.shouldHide = true

        }) { (finished: Bool) in
            
            self.collabNavigationView.collabTableView.reloadData()
            
            if self.messages?.count ?? 0 > 0 {
                
                self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: false)
            }
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {

//                self.messageInputAccesoryView.isHidden = false
                self.messageInputAccesoryView.alpha = 1
                
                self.collabNavigationView.collabTableView.alpha = 1
            })
        }
    }
    
    @objc private func presentNavViewButtonPressed () {
        
        returnToOrigin()
        
        self.becomeFirstResponder()
        
        if selectedTab == "Messages" {
            
            messageInputAccesoryView.alpha = 1
        }
    }
}

extension CollabViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer == tabBar.dismissActiveTabBarSwipeGesture && otherGestureRecognizer == dismissExpandedViewGesture {

            return true
        }

        else if gestureRecognizer == dismissExpandedViewGesture && otherGestureRecognizer == tabBar.dismissActiveTabBarSwipeGesture {

            return true
        }

        return false
    }
}

extension CollabViewController: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        var collabNavigationViewTopAnchor: NSLayoutConstraint?
        var topAnchor: CGFloat
        
        self.view.constraints.forEach { (constraint) in
            
            if constraint.firstItem as? CollabNavigationView != nil && constraint.firstAttribute == .top {
                
                collabNavigationViewTopAnchor = constraint
            }
        }
        
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
