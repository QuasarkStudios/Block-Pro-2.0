//
//  CollabView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/24/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class CollabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var leftBarButtonItem: UIButton!
    var rightBarButtonItem1: UIButton!
    var rightBarButtonItem2: UIButton!
    
    @IBOutlet weak var collabName: UILabel!
    @IBOutlet weak var collabObjective: UITextView!
    
    @IBOutlet weak var editCollabButton: UIButton!
    
    @IBOutlet weak var collabNavigationContainer: UIView!
    @IBOutlet weak var collabNavigationContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var panGestureIndicator: UIView!
    @IBOutlet weak var panGestureView: UIView!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var blocksButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    
    @IBOutlet weak var collabTableView: UITableView!
    @IBOutlet weak var tableViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomAnchor: NSLayoutConstraint!
    
    let tabBar = CustomTabBar.sharedInstance
    
    var copiedAnimationView: CopiedAnimationView?
    
    let messageInputAccesoryView = InputAccesoryView(textViewPlaceholderText: "Send a message", showsAddButton: true)
    var inputAccesoryViewMethods: InputAccesoryViewMethods!
    
//    let textViewContainer = MessageTextViewContainer()
//    let messageTextView = UITextView()
//    let sendButton = UIButton(type: .system)
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    var collab: Collab?
    
    var messagingMethods: MessagingMethods!
    var messages: [Message]?
    
    var viewInitiallyLoaded: Bool = false
    
    var selectedTab: String = "Blocks"
    
    var keyboardHeight: CGFloat?
    
    var messageTextViewText: String = ""
    var selectedPhoto: UIImage?
    
    var gestureViewPanGesture: UIPanGestureRecognizer?
    var stackViewPanGesture: UIPanGestureRecognizer?
    var dismissExpandedViewGesture: UISwipeGestureRecognizer?
    
    //Variables for zooming and panning of selected images
    var zoomedOutImageView: UIImageView?
    var zoomedOutImageViewFrame: CGRect?
    
    var blackBackground: UIView?
    var zoomedInImageView: UIImageView?
    var zoomedInImageViewFrame: CGRect?

    var imageViewBeingZoomed: Bool?
    var keyboardWasPresent: Bool?
    
    var panGesture: UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        configureGestureRecognizers()
        
        //configureTableView()
        
        configureMessagingView()
        
        //configureTextViewContainer()
        
        retrieveMessages()
        
        setUserActiveStatus()
        
        retrieveMemberProfilePics()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewInitiallyLoaded {
           
            configureView()
            viewInitiallyLoaded = true
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return messageInputAccesoryView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedTab == "Messages" {
            
            return messagingMethods.numberOfRowsInSection(messages: messages)
        }
        
        else {
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //if selectedTab == "Messages" {
            
           return messagingMethods.cellForRowAt(indexPath: indexPath, messages: messages, members: collab?.members)
        //}
        
//        if indexPath.row % 2 == 0 {
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
//            cell.members = collab?.members // Must be set first
//            cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
//            cell.message = messages?[indexPath.row / 2]
//
//            cell.selectionStyle = .none
//
//            return cell
//        }
//
//        else {
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
//            cell.selectionStyle = .none
//            return cell
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return messagingMethods.heightForRowAt(indexPath: indexPath, messages: messages)
        
//        if indexPath.row % 2 == 0 {
//
//            //First message
//            if indexPath.row == 0 {
//
//               //If the current user sent the message
//                if messages?[indexPath.row / 2].sender == currentUser.userID {
//
//                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 15
//                }
//
//                else {
//
//                   return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 30
//                }
//            }
//
//            //Not the first message
//            else if (indexPath.row / 2) - 1 >= 0 {
//
//                //If the current user sent the message
//                if messages?[indexPath.row / 2].sender == currentUser.userID {
//
//                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 15
//                }
//
//                //If the previous message was sent by another user
//                else if messages?[indexPath.row / 2].sender != messages![(indexPath.row / 2) - 1].sender {
//
//                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 30
//                }
//            }
//
//            return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 15
//        }
//
//        else {
//
//            //Seperator cell
//            return determineSeperatorRowHeight(indexPath: indexPath)
//        }
    }
    
    private func configureNavBar () {
        
        rightBarButtonItem1 = UIButton(type: .system)
        rightBarButtonItem1.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        rightBarButtonItem1.setImage(UIImage(named: "UserGroup"), for: .normal)
        rightBarButtonItem1.addTarget(self, action: #selector(usersButtonPressed), for: .touchUpInside)
        
        rightBarButtonItem2 = UIButton(type: .system)
        rightBarButtonItem2.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        rightBarButtonItem2.setImage(UIImage(named: "attach"), for: .normal)
        rightBarButtonItem2.addTarget(self, action: #selector(attachmentButtonPressed), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightBarButtonItem2), UIBarButtonItem(customView: rightBarButtonItem1)]
    }
    
    private func configureView () {
        
        collabName.text = collab?.name
        collabObjective.text = collab?.objective
        
        editCollabButton.layer.cornerRadius = 10
        
        collabNavigationContainer.backgroundColor = .white
        
        collabNavigationContainer.layer.shadowRadius = 2
        collabNavigationContainer.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        collabNavigationContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        collabNavigationContainer.layer.shadowOpacity = 0.35
        
        collabNavigationContainer.layer.cornerRadius = 25
        collabNavigationContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collabNavigationContainer.layer.masksToBounds = false
        
        collabNavigationContainerTopAnchor.constant = (editCollabButton.frame.minY - 10)
        
        panGestureIndicator.backgroundColor = UIColor(hexString: "35393C")
        panGestureIndicator.layer.cornerRadius = 3
        
        panGestureView.backgroundColor = .clear
        
        progressButton.setTitleColor(.lightGray, for: .normal)
        messagesButton.setTitleColor(.lightGray, for: .normal)
        
        tableViewBottomAnchor.constant = 0
    }
    
    private func configureMessagingView () {
        
        messageInputAccesoryView.parentViewController = self
        
        messagingMethods = MessagingMethods(parentViewController: self, tableView: collabTableView, collabID: collab?.collabID ?? "")
        messagingMethods.configureTableView()
        
        inputAccesoryViewMethods = InputAccesoryViewMethods(accesoryView: messageInputAccesoryView, textViewPlaceholderText: "Send a message", tableView: collabTableView)
    }
    
    private func configureTableView () {
        
        collabTableView.dataSource = self
        collabTableView.delegate = self
        
        collabTableView.rowHeight = 50
        collabTableView.separatorStyle = .none
        
        collabTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
    }
    
    func configureTabBar () {

        tabBarController?.tabBar.isHidden = true
        tabBarController?.delegate = tabBar
        
        tabBar.tabBarController = tabBarController
        tabBar.currentNavigationController = self.navigationController
        
        tabBar.configureActiveTabBarGestureRecognizers(self.view)
        
        if tabBar.previousNavigationController == tabBar.currentNavigationController {
            
            tabBar.shouldHide = true
        }
        
        view.addSubview(tabBar)
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
        
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardTap)

        dismissExpandedViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissExpandedView))
        dismissExpandedViewGesture?.delegate = self
        dismissExpandedViewGesture?.cancelsTouchesInView = true
        dismissExpandedViewGesture?.direction = .right
        view.addGestureRecognizer(dismissExpandedViewGesture!)
        
        gestureViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        panGestureView.addGestureRecognizer(gestureViewPanGesture!)
        
        stackViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        buttonStackView.addGestureRecognizer(stackViewPanGesture!)
    }
        
    private func reconfigureGestureRecognizers () {
        
        panGestureView.addGestureRecognizer(gestureViewPanGesture!)
        buttonStackView.addGestureRecognizer(stackViewPanGesture!)
    }
    
    private func removeGestureRecognizers () {
        
        if let gestureViewGesture = gestureViewPanGesture, let stackViewGesture = stackViewPanGesture {
            
            panGestureView.removeGestureRecognizer(gestureViewGesture)
            buttonStackView.removeGestureRecognizer(stackViewGesture)
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
            
            if (collabNavigationContainerTopAnchor.constant >= (editCollabButton.frame.minY - 70)) && (collabNavigationContainerTopAnchor.constant <= (editCollabButton.frame.minY + editCollabButton.frame.height / 2)) {
                
                returnToOrigin()
            }
            
            else if (collabNavigationContainerTopAnchor.constant > (editCollabButton.frame.minY + editCollabButton.frame.height / 2)){
                
                shrinkView()
            }
            
            else if (collabNavigationContainerTopAnchor.constant < (editCollabButton.frame.minY - 50)) {
                
                expandView()
            }
            
           break
        default:
            
            break
        }
    }
    
    private func moveWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        if (collabNavigationContainerTopAnchor.constant + translation.y) > (editCollabButton.frame.maxY + 20) {
            
            collabNavigationContainerTopAnchor.constant = editCollabButton.frame.maxY + 20
        }
            
        else if (collabNavigationContainerTopAnchor.constant + translation.y) < (editCollabButton.frame.minY - 10) {
            
            let topAnchorValue = collabNavigationContainerTopAnchor.constant - 44 > 0 ? collabNavigationContainerTopAnchor.constant - 44 : 0
            let adjustedAlpha: CGFloat = ((1 / (editCollabButton.frame.minY - 10)) * topAnchorValue)
            
            panGestureIndicator.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
            buttonStackView.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
            
            
            collabNavigationContainerTopAnchor.constant += translation.y
            sender.setTranslation(CGPoint.zero, in: view)
        }
        
        else {
            
            collabNavigationContainerTopAnchor.constant += translation.y
            sender.setTranslation(CGPoint.zero, in: view)
        }
    }
    
    private func returnToOrigin () {
        
        collabNavigationContainerTopAnchor.constant = (editCollabButton.frame.minY - 10)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            
            self.view.layoutIfNeeded()
            
            self.panGestureIndicator.alpha = 1
            self.buttonStackView.alpha = 1
        })
    }
    
    private func shrinkView () {
        
        collabNavigationContainerTopAnchor.constant = editCollabButton.frame.maxY + 20
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    internal func expandView () {
        
        collabNavigationContainerTopAnchor.constant = 0
        tableViewTopAnchor.constant = setTableViewTopAnchor()//30
 
        title = selectedTab
        
        viewExpanded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()

            self.panGestureIndicator.alpha = 0
            self.buttonStackView.alpha = 0
        })
    }
    
    internal func viewExpanded () {
        
        navigationItem.hidesBackButton = true

        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(cancelButtonPressed))
        cancelButton.style = .done
        
        navigationItem.leftBarButtonItem = cancelButton
        
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
    }
    
    @objc private func dismissKeyboard () {
        
        //messageTextView.resignFirstResponder()
    }
    
    @objc private func cancelButtonPressed () {
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = false

        collabNavigationContainerTopAnchor.constant = (editCollabButton.frame.minY - 10)

        title = ""
        
        reconfigureGestureRecognizers()

        tableViewTopAnchor.constant = 10
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

           self.view.layoutIfNeeded()

           self.panGestureIndicator.alpha = 1
           self.buttonStackView.alpha = 1
           
        })
        
        if selectedTab == "Messages" {

            dismissKeyboard ()
            
//            textViewContainer.constraints.forEach { (constraint) in
//                
//                if constraint.firstAttribute == .height {
//                    
//                    constraint.constant = 34
//                }
//            }
//            
//            messageTextView.constraints.forEach { (constraint) in
//                
//                if constraint.firstAttribute == .height {
//                    
//                    constraint.constant = 34
//                }
//            }
            
            messageInputAccesoryView.size = messageInputAccesoryView.configureSize()
            
            if messages?.count ?? 0 > 0 {
                
                collabTableView.scrollToRow(at: IndexPath(row: (messages!.count * 2) - 1, section: 0), at: .top, animated: true)
            }
        }
    }
    
    @objc private func dismissExpandedView () {

        if navigationItem.hidesBackButton == true && tabBar.shouldHide == true {
            
            cancelButtonPressed()
        }
    }
    
    @objc private func usersButtonPressed () {
        
    }
    
    @objc private func attachmentButtonPressed () {
        
        
    }
    
    
    
    @IBAction func editCollab(_ sender: Any) {
    }
    
    
    @IBAction func progressButton(_ sender: Any) {
        
        selectedTab = "Progress"
        
        progressButton.setTitleColor(.black, for: .normal)
        blocksButton.setTitleColor(.lightGray, for: .normal)
        messagesButton.setTitleColor(.lightGray, for: .normal)
        
        view.removeGestureRecognizer(tabBar.presentDisabledTabBarSwipeGesture)
        tabBar.configureActiveTabBarGestureRecognizers(self.view)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            
            self.messageInputAccesoryView.alpha = 0
            
        }) { (finished: Bool) in
            
            self.messageInputAccesoryView.isHidden = true
            
            self.tableViewBottomAnchor.constant = 0
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {

                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func blocksButton(_ sender: Any) {
        
        selectedTab = "Blocks"
        
        blocksButton.setTitleColor(.black, for: .normal)
        progressButton.setTitleColor(.lightGray, for: .normal)
        messagesButton.setTitleColor(.lightGray, for: .normal)
        
        view.removeGestureRecognizer(tabBar.presentDisabledTabBarSwipeGesture)
        tabBar.configureActiveTabBarGestureRecognizers(self.view)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                            
            self.messageInputAccesoryView.alpha = 0
            
        }) { (finished: Bool) in
            
            self.messageInputAccesoryView.isHidden = true
            
            self.tableViewBottomAnchor.constant = 0
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func messagesButton(_ sender: Any) {
        
        selectedTab = "Messages"
        
        messagesButton.setTitleColor(.black, for: .normal)
        blocksButton.setTitleColor(.lightGray, for: .normal)
        progressButton.setTitleColor(.lightGray, for: .normal)
        
        //tableViewBottomAnchor.constant = messageInputAccesoryView.configureSize().height
        
        view.removeGestureRecognizer(tabBar.presentActiveTabBarSwipeGesture)
        view.removeGestureRecognizer(tabBar.dismissActiveTabBarSwipeGesture)
        tabBar.configureDisabledTabBarGestureRecognizer(self.view)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            
            self.view.layoutIfNeeded()
            
            self.collabTableView.alpha = 0
            
            self.tabBar.shouldHide = true

        }) { (finished: Bool) in
            
            self.collabTableView.reloadData()
            
            if self.messages?.count ?? 0 > 0 {
                
                self.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: false)
            }
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {

                self.messageInputAccesoryView.isHidden = false
                self.messageInputAccesoryView.alpha = 1
                
                self.collabTableView.alpha = 1
            })
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
        
        let topAnchor: CGFloat
        
        //The view hasn't been expanded
        if collabNavigationContainerTopAnchor.constant != 0 {
            
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
        
        performZoomOnPhotoImageView(photoImageView: photoImageView)
    }
    
    func performZoomOnPhotoImageView (photoImageView: UIImageView) {
        
        self.zoomedOutImageView = photoImageView
        imageViewBeingZoomed = true
        
        if messageInputAccesoryView.textViewContainer.messageTextView.isFirstResponder {
            
            keyboardWasPresent = true
        }
        
        else {
            
            keyboardWasPresent = false
        }
        
        self.messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
        self.resignFirstResponder()
        
        blackBackground = UIView(frame: self.view.frame)
        blackBackground?.backgroundColor = .clear
        
        blackBackground?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        UIApplication.shared.keyWindow?.addSubview(blackBackground!)
        
        if let startingFrame = photoImageView.superview?.convert(photoImageView.frame, from: self.view) {
            
            zoomedOutImageViewFrame = CGRect(x: abs(startingFrame.minX), y: abs(startingFrame.minY), width: startingFrame.width, height: startingFrame.height)
            
            let zoomingImageView = UIImageView(frame: zoomedOutImageViewFrame!)
            zoomingImageView.image = photoImageView.image
            zoomingImageView.layer.cornerRadius = 10
            zoomingImageView.clipsToBounds = true
            
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            
            UIApplication.shared.keyWindow?.addSubview(zoomingImageView)
            zoomedInImageView = zoomingImageView
            
            photoImageView.isHidden = true
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                
                let height = (startingFrame.height / startingFrame.width) * self.view.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)
                zoomingImageView.center = self.view.center
                
                zoomingImageView.layer.cornerRadius = 0
                
            }) { (finished: Bool) in
                
                self.zoomedInImageViewFrame = self.zoomedInImageView?.frame
                
                self.addPhotoImageViewPanGesture(view: self.zoomedInImageView)
                self.addPhotoImageViewPanGesture(view: self.blackBackground)
            }
        }
    }
    
    @objc private func handleZoomOut () {
        
        self.becomeFirstResponder()
        
        if keyboardWasPresent ?? false {
            
            messageInputAccesoryView.textViewContainer.messageTextView.becomeFirstResponder()
        }
        
        if let imageView = zoomedInImageView {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .clear
                
                imageView.frame = self.zoomedOutImageViewFrame!
                imageView.layer.cornerRadius = 10
                imageView.clipsToBounds = true
                
            }) { (finished: Bool) in
                
                self.imageViewBeingZoomed = false
                
                self.zoomedOutImageView?.isHidden = false
                self.blackBackground?.removeFromSuperview()
                imageView.removeFromSuperview()
            }
        }
    }
    
    private func addPhotoImageViewPanGesture (view: UIView?) {
        
        if view != nil {
            
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePhotoImageViewPan(sender:)))
            
            view?.addGestureRecognizer(panGesture!)
        }
    }
    
    @objc private func handlePhotoImageViewPan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            movePhotoImageViewWithPan(sender: sender)
            
        case .ended:
            
            if (zoomedInImageView?.frame.minY ?? 0 > (self.view.frame.height / 2)) {
                
                handleZoomOut()
            }
            
            else if (zoomedInImageView?.frame.maxY ?? 0 < (self.view.frame.height / 2)) {
                
                handleZoomOut()
            }
            
            else {
                
                returnPhotoImageViewToOrigin()
            }
            
        default:
            break
        }
    }
    
    private func movePhotoImageViewWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        
        if let imageView = zoomedInImageView {
            
            let translatedMinYCoord = imageView.frame.minY + translation.y
            let translatedMinXCoord = imageView.frame.minX + translation.x
            let translatedMaxYCoord = imageView.frame.maxY + translation.y
            
            imageView.frame = CGRect(x: translatedMinXCoord, y: translatedMinYCoord, width: imageView.frame.width, height: imageView.frame.height)
            
            if let backgroundView = blackBackground, let zoomedInMinYCoord = zoomedInImageViewFrame?.minY, let zoomedInMaxYCoord = zoomedInImageViewFrame?.maxY {
                
                if translatedMinYCoord > zoomedInMinYCoord {
                    
                    let originalMinYDistanceToBottom = view.frame.height - zoomedInMinYCoord
                    let adjustedMinYDistanceToBottom = abs((translatedMinYCoord - (view.frame.height - originalMinYDistanceToBottom)) - originalMinYDistanceToBottom) //tricky but it works
                    let alphaPart = (1 / originalMinYDistanceToBottom)
                    
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * adjustedMinYDistanceToBottom)
                }
                
                else if translatedMinYCoord < zoomedInMinYCoord {
                    
                    let alphaPart = (1 / zoomedInMaxYCoord)
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * translatedMaxYCoord)
                }
            }
            
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    private func returnPhotoImageViewToOrigin () {
        
        if let imageView = zoomedInImageView, let imageViewFrame = zoomedInImageViewFrame {
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                
                imageView.frame = imageViewFrame
            })
        }
    }
}
