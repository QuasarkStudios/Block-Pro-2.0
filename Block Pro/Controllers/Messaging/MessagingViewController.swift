//
//  MessagingViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/25/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD
import Lottie

class MessagingViewController: UIViewController {
    
    @IBOutlet weak var conversationNameLabel: UILabel!
    @IBOutlet weak var messagesTableView: UITableView!
    
    let noMessagesAnimationContainer = UIView()
    let noMessagesAnimationView = LottieAnimationView(name: "chat-bubbles-animation")
    let noMessagesAnimationTitle = UILabel()
    
    var copiedAnimationView: CopiedAnimationView?
    
    var messagingMethods: MessagingMethods!
    
    let messageInputAccesoryView = InputAccesoryView(textViewPlaceholderText: "Send a message", showsAddButton: true)
    var inputAccesoryViewMethods: InputAccesoryViewMethods!
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var personalConversation: Conversation?
    var collabConversation: Conversation?
    
    var messages: [Message]?
    
    var selectedPhoto: UIImage?
    
    var keyboardHeight: CGFloat?
    
    var messageTextViewText: String = "" //Text entered into the messageTextView
    
    var infoViewBeingPresented: Bool = false
    
    var zoomingMethods: ZoomingImageViewMethods?
    var imageViewBeingZoomed: Bool?
    var keyboardWasPresent: Bool?
    
    var dismissKeyboardGesture: UITapGestureRecognizer?
    
    var dismissAnimationContainerWorkItem: DispatchWorkItem?
    
    weak var moveToConversationWithFriendDelegate: MoveToConversationWithFriendProtcol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageInputAccesoryView.parentViewController = self
        
        //Initializing MessagingMethods
        if let conversationID = personalConversation?.conversationID {
            
            messagingMethods = MessagingMethods(parentViewController: self, tableView: messagesTableView, conversationID: conversationID)
            messagingMethods.configureTableView()
        }
        
        else if let collabID = collabConversation?.conversationID {
            
            messagingMethods = MessagingMethods(parentViewController: self, tableView: messagesTableView, collabID: collabID)
            messagingMethods.configureTableView()
        }
        
        //Initializing InputAccesoryViewMethods
        inputAccesoryViewMethods = InputAccesoryViewMethods(accesoryView: messageInputAccesoryView, textViewPlaceholderText: "Send a message", tableView: messagesTableView)
        
        setUserActiveStatus()
        
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavBar(navBar: navigationController?.navigationBar)
        
        let tabBar = CustomTabBar.sharedInstance
        tabBar.shouldHide = true
        
        retrievePersonalMessages(personalConversation)
        retrieveCollabMessages(collabConversation)
        
        monitorPersonalConversation(personalConversation)
        monitorCollabConversation(collabConversation)
        
        addObservors()
        
        self.becomeFirstResponder()
        
        retrieveMessageDraft()
        
        infoViewBeingPresented = false
        
        //Initializing here allows the animationView to be removed and readded multiple times
        copiedAnimationView = CopiedAnimationView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        firebaseMessaging.monitorPersonalConversationListener?.remove()
        firebaseMessaging.monitorCollabConversationListener?.remove()
        
        firebaseMessaging.messageListener?.remove()
        
        removeObservors()
        
        saveMessageDraft()
        
        setUserInactiveStatus()
        
        //If the infoView is not being presented, then the copiedAnimationContainer should be removed; otherwise just dismissed if present
        copiedAnimationView?.removeCopiedAnimation(remove: !infoViewBeingPresented)
    }
    
    override func didReceiveMemoryWarning() {
        
        var count = 0
        
        while count < messages?.count ?? 0 {
            
            messages?[count].messagePhoto?["photo"] = nil
            
            count += 1
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
    
    
    //MARK: - Configure NavBar Function
    
    private func configureNavBar (navBar: UINavigationBar?) {
        
        navBar?.configureNavBar(barBackgroundColor: .clear, barTintColor: .black)
        self.navigationItem.titleView = nil
        
        if let conversation = personalConversation {
            
            if conversation.coverPhotoID != nil {
                
                configureNavBarTitleViewWithCoverPhoto(personalConversation: conversation)
            }
            
            else {
                
                configureNavBarTitleViewWithMembers(conversation)
            }
            
            configureConversationNameLabel(conversation: conversation)
        }
        
        else if let conversation = collabConversation {
            
            if conversation.coverPhotoID != nil {
                
                configureNavBarTitleViewWithCoverPhoto(collabConversation: conversation)
            }
            
            else {
                
                configureNavBarTitleViewWithMembers(conversation)
            }
            
            configureConversationNameLabel(conversation: conversation)
        }
    }
    
    
    //MARK: - Configure NavBar TitleView Functions
    
    private func configureNavBarTitleViewWithCoverPhoto (personalConversation: Conversation? = nil, collabConversation: Conversation? = nil) {
        
        let coverContainer = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        let coverPicture = ProfilePicture(profilePic: UIImage(named: "Mountains"), shadowRadius: 2, shadowOpacity: 0.35, borderColor: UIColor(hexString: "F4F4F4", withAlpha: 0.1)!.cgColor)
        
        coverContainer.addSubview(coverPicture)
        
        coverPicture.translatesAutoresizingMaskIntoConstraints = false
        
        [

            coverPicture.widthAnchor.constraint(equalToConstant: 32),
            coverPicture.heightAnchor.constraint(equalToConstant: 32),
            coverPicture.centerXAnchor.constraint(equalTo: coverPicture.superview!.centerXAnchor),
            coverPicture.centerYAnchor.constraint(equalTo: coverPicture.superview!.centerYAnchor)
            
        ].forEach( { $0.isActive = true } )
        
        if let conversation = personalConversation {
            
            if let conversationIndex = firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                
                if let cover = firebaseMessaging.personalConversations[conversationIndex].conversationCoverPhoto {
                    
                    coverPicture.profilePic = cover
                }
                
                else {
                    
                    firebaseStorage.retrievePersonalConversationCoverPhoto(conversationID: conversation.conversationID) { [weak self] (cover, error) in
                        
                        if error != nil {
                            
                            SVProgressHUD.showError(withStatus: "Sorry, something went wrong retrieving the Cover Photo")
                        }
                        
                        else {
                            
                            coverPicture.profilePic = cover
                            
                            if let conversationIndex = self?.firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                                
                                self?.firebaseMessaging.personalConversations[conversationIndex].conversationCoverPhoto = cover
                            }
                        }
                    }
                }
            }
        }
        
        else if let conversation = collabConversation {
            
            if let conversationIndex = firebaseMessaging.collabConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                
                if let cover = firebaseMessaging.collabConversations[conversationIndex].conversationCoverPhoto {
                    
                    coverPicture.profilePic = cover
                }
                
                else {
                    
                    firebaseStorage.retrieveCollabCoverPhoto(collabID: conversation.conversationID) { [weak self] (cover, error) in
                        
                        if error != nil {
                            
                            SVProgressHUD.showError(withStatus: "Sorry, something went wrong retrieving the Cover Photo")
                        }
                        
                        else {
                            
                            coverPicture.profilePic = cover
                            
                            if let conversationIndex = self?.firebaseMessaging.collabConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                                
                                self?.firebaseMessaging.collabConversations[conversationIndex].conversationCoverPhoto = cover
                            }
                        }
                    }
                }
            }
        }
        
        self.navigationItem.titleView = coverContainer
    }
    
    private func configureNavBarTitleViewWithMembers (_ personalConversation: Conversation? = nil, _ collabConversation: Conversation? = nil) {

        guard let conversation = personalConversation != nil ? personalConversation : collabConversation else { return }

            if conversation.currentMembers.count == 1 {

                configureCurrentUserProfilePic()
            }

            else {

                var filteredMembers = conversation.currentMembers.sorted(by: { $0.firstName < $1.firstName })
                filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                
                let stackViewWidth = filteredMembers.count * 34
                let memberStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: CGFloat(stackViewWidth), height: 34))
                memberStackView.alignment = .center
                memberStackView.distribution = .fillProportionally
                memberStackView.axis = .horizontal
                memberStackView.spacing = -17 //Half the size of the profilePicOutline
                
                var memberCount: Int = 0
                
                for member in filteredMembers {
                    
                    let profilePicOutline = UIView()
                    profilePicOutline.backgroundColor = memberCount == 0 ? .clear : .white
                    profilePicOutline.layer.cornerRadius = 0.5 * 34
                    profilePicOutline.clipsToBounds = true
                    
                    var profilePic: ProfilePicture
                        
                    if memberCount == 0 {
                        
                        profilePic = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic"), shadowRadius: 2, shadowOpacity: 0.2, borderColor: UIColor.clear.cgColor, borderWidth: 0)
                    }
                    
                    else {
                        
                        profilePic = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic"), shadowRadius: 0, shadowColor: UIColor.clear.cgColor, shadowOpacity: 0, borderColor: UIColor.clear.cgColor, borderWidth: 0)
                    }
                    
                    profilePicOutline.addSubview(profilePic)
                    memberStackView.addArrangedSubview(profilePicOutline)
                    
                    profilePicOutline.translatesAutoresizingMaskIntoConstraints = false
                    profilePic.translatesAutoresizingMaskIntoConstraints = false
                    
                    [
                        // 17 is half the size of the profilePicOutline
                        profilePicOutline.topAnchor.constraint(equalTo: profilePicOutline.superview!.topAnchor, constant: 0),
                        profilePicOutline.leadingAnchor.constraint(equalTo: profilePicOutline.superview!.leadingAnchor, constant: CGFloat(memberCount * 17)),
                        profilePicOutline.widthAnchor.constraint(equalToConstant: 34),
                        profilePicOutline.heightAnchor.constraint(equalToConstant: 34),
                        
                        profilePic.centerXAnchor.constraint(equalTo: profilePic.superview!.centerXAnchor),
                        profilePic.centerYAnchor.constraint(equalTo: profilePic.superview!.centerYAnchor),
                        profilePic.widthAnchor.constraint(equalToConstant: 30),
                        profilePic.heightAnchor.constraint(equalToConstant: 30)
                    
                    ].forEach({ $0.isActive = true })
                    
                    if let friend = firebaseCollab.friends.first(where: { $0.userID == member.userID }) {

                        profilePic.profilePic = friend.profilePictureImage
                    }

                    else if let memberProfilePic = firebaseCollab.membersProfilePics[member.userID] {

                        profilePic.profilePic = memberProfilePic
                    }

                    else {

                        firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { [weak self] (retrievedProfilePic, userID) in

                            profilePic.profilePic = retrievedProfilePic

                            self?.firebaseCollab.cacheMemberProfilePics(userID: member.userID, profilePic: retrievedProfilePic)
                        }
                    }
                    
                    memberCount += 1
                }
                
                self.navigationItem.titleView = memberStackView
            }
    }
    
    private func configureCurrentUserProfilePic () {
        
        let profilePicture = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic")!, shadowRadius: 2, shadowOpacity: 0.35, borderColor: UIColor(hexString: "F4F4F4", withAlpha: 0.1)!.cgColor)
        
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        
        [

            profilePicture.widthAnchor.constraint(equalToConstant: 32),
            profilePicture.heightAnchor.constraint(equalToConstant: 32)
            
        ].forEach( { $0.isActive = true } )
        
        if let currentUserProfilePic = currentUser.profilePictureImage {
            
            profilePicture.profilePic = currentUserProfilePic
            
            self.navigationItem.titleView = profilePicture
        }
        
        else {
            
            firebaseStorage.retrieveUserProfilePicFromStorage(userID: currentUser.userID) { [weak self] (profilePic, userID) in
                
                profilePicture.profilePic = profilePic
                
                self?.navigationItem.titleView = profilePicture
            }
        }
    }

    
    
    //MARK: - Configure Conversation Name Function
    
    private func configureConversationNameLabel (conversation: Conversation) {
        
        if let name = conversation.conversationName {
            
            conversationNameLabel.text = name
        }
        
        else if conversation.currentMembers.count > 1 {
            
            var organizedMembers = conversation.currentMembers.sorted(by: { $0.firstName < $1.firstName })
            organizedMembers.removeAll(where: { $0.userID == currentUser.userID })
            
            var name: String = ""
            
            for member in organizedMembers {
                
                if member.userID == organizedMembers.first?.userID {
                    
                    name = member.firstName
                }
                
                else if member.userID != organizedMembers.last?.userID {
                    
                    name += ", \(member.firstName)"
                }
                
                else {
                    
                    name += " & \(member.firstName) "
                }
            }
            
            conversationNameLabel.text = name
        }
        
        else {
            
            conversationNameLabel.text = "Just You"
        }
    }
    
    
    //MARK: - No Message Animation Functions
    
    private func configureNoMessagesAnimation() {
        
        //Configuring the container
        noMessagesAnimationContainer.alpha = noMessagesAnimationContainer.superview == nil ? 0 : 1
        noMessagesAnimationContainer.isUserInteractionEnabled = false
        
        self.view.addSubview(noMessagesAnimationContainer)
        noMessagesAnimationContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noMessagesAnimationContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            noMessagesAnimationContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -35),
            noMessagesAnimationContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            noMessagesAnimationContainer.heightAnchor.constraint(equalToConstant: self.view.frame.width)
            
        ].forEach({ $0.isActive = true })
        
        UIView.animate(withDuration: 0.2) {
            
            self.noMessagesAnimationContainer.alpha = 1
        }
        
        //Configuring the animationView
        noMessagesAnimationContainer.addSubview(noMessagesAnimationView)
        noMessagesAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noMessagesAnimationView.centerXAnchor.constraint(equalTo: noMessagesAnimationContainer.centerXAnchor),
            noMessagesAnimationView.topAnchor.constraint(equalTo: noMessagesAnimationContainer.topAnchor, constant: 0),
            noMessagesAnimationView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            noMessagesAnimationView.heightAnchor.constraint(equalToConstant: self.view.frame.width)
        
        ].forEach({ $0?.isActive = true })
        
        noMessagesAnimationView.loopMode = .loop
        noMessagesAnimationView.backgroundBehavior = .pauseAndRestore
        noMessagesAnimationView.play()
        
        //Configuring the animationTitle
        noMessagesAnimationContainer.addSubview(noMessagesAnimationTitle)
        noMessagesAnimationTitle.translatesAutoresizingMaskIntoConstraints = false
        
        [
    
            noMessagesAnimationTitle.centerXAnchor.constraint(equalTo: noMessagesAnimationContainer.centerXAnchor),
            noMessagesAnimationTitle.topAnchor.constraint(equalTo: noMessagesAnimationView.bottomAnchor, constant: -85),
            noMessagesAnimationTitle.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            noMessagesAnimationTitle.heightAnchor.constraint(equalToConstant: 75)
        
        ].forEach({ $0.isActive = true })
        
        noMessagesAnimationTitle.text = "No Messages \n Yet"
        noMessagesAnimationTitle.textAlignment = .center
        noMessagesAnimationTitle.numberOfLines = 2
        noMessagesAnimationTitle.font = UIFont(name: "Poppins-SemiBold", size: 23)
    }
    
    private func removeNoMessagesAnimation () {
        
        //Ensures the noMessagesAnimation is present
        if noMessagesAnimationContainer.superview != nil {
            
            noMessagesAnimationView.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                    
                    constraint.constant = 0
                }
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
                
                self.noMessagesAnimationTitle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                
                self.noMessagesAnimationContainer.alpha = 0
                
            }) { (finished: Bool) in
                
                self.noMessagesAnimationContainer.removeFromSuperview()
            }
        }
    }
    
    
    //MARK: Add and Remove Observor Functions
    
    private func addObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUserActiveStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUserInactiveStatus), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveMessageDraft), name: UIApplication.willTerminateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendMessage), name: .userDidSendMessage, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addAttachment), name: .userDidAddMessageAttachment, object: nil)
    }
    
    private func removeObservors () {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Keyboard Notification Handlers
    
    @objc private func keyboardBeingPresented (notification: NSNotification) {
        
        //Required for smoothness
        if !(imageViewBeingZoomed ?? false) && messageInputAccesoryView.textViewContainer.messageTextView.isFirstResponder {

            inputAccesoryViewMethods.keyboardBeingPresented(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: messages?.count ?? 0)
        }
    }

    
    @objc private func keyboardBeingDismissed (notification: NSNotification) {
        
        //keyboardWillHide notification stopped firing so this is the fix
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        
        //Required for smoothness
        if !(imageViewBeingZoomed ?? false) && keyboardFrame.cgRectValue.height < 200 {
            
            inputAccesoryViewMethods.keyboardBeingDismissed(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: messages?.count ?? 0, textViewText: messageTextViewText)
        }
    }
    
    
    //MARK: - Retrieve Messages Functions
    
    private func retrievePersonalMessages (_ personalConversation: Conversation?) {
        
        guard let conversation = personalConversation else { return }
        
        var animate: Bool = false //Fixes bug that caused bad configuration of the tableView when only two messages had been sent
        
            firebaseMessaging.retrieveAllPersonalMessages(conversationID: conversation.conversationID) { [weak self] (messages, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    //If no messages yet, configure noMessagesAnimation
                    if messages.count == 0 {
                        
                        self?.configureNoMessagesAnimation()
                        
                        self?.dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(self?.dismissKeyboard))
                        self?.view.addGestureRecognizer((self?.dismissKeyboardGesture)!)
                    }
                    
                    else {
                        
                        self?.removeNoMessagesAnimation()
                        
                        if let gesture = self?.dismissKeyboardGesture {
                            
                            self?.view.removeGestureRecognizer(gesture)
                            self?.dismissKeyboardGesture = nil
                        }
                    }
                    
                    for message in messages {
                        
                        if self?.messages == nil {
                            
                            self?.messages = []
                        }
                        
                        //Checks if current message already exists in global messages array
                        if self?.messages?.contains(where: { $0.messageID == message.messageID }) == false {
                            
                            self?.messages?.append(message)
                        }
                    }
                    
                    //Sorts messages by date sent
                    self?.messages = self?.messages?.sorted(by: { $0.timestamp < $1.timestamp })
                    
                    self?.messagingMethods.reloadTableView(messages: self?.messages, animate)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        
                        animate = true //Allows new messages to be animated after it's been intially loaded
                    }
                }
            }
    }
    
    private func retrieveCollabMessages (_ collabConversation: Conversation?) {
        
        guard let collab = collabConversation else { return }
        
        var animate: Bool = false //Fixes bug that caused bad configuration of the tableView when only two messages had been sent
        
        firebaseMessaging.retrieveAllCollabMessages(collabID: collab.conversationID) { [weak self] (messages, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    //If no messages yet, configure noMessagesAnimation
                    if messages.count == 0 {
                        
                        self?.configureNoMessagesAnimation()
                        
                        self?.dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(self?.dismissKeyboard))
                        self?.view.addGestureRecognizer((self?.dismissKeyboardGesture)!)
                    }
                    
                    else {
                        
                        self?.removeNoMessagesAnimation()
                        
                        if let gesture = self?.dismissKeyboardGesture {
                            
                            self?.view.removeGestureRecognizer(gesture)
                            self?.dismissKeyboardGesture = nil
                        }
                    }
                    
                    for message in messages {
                        
                        if self?.messages == nil {
                            
                            self?.messages = []
                        }
                        
                        //Checks if current message already exists in global messages array
                        if !(self?.messages?.contains(where: { $0.messageID == message.messageID }) ?? false) {
                            
                            self?.messages?.append(message)
                        }
                    }
                    
                    //Sorts messages by date sent
                    self?.messages = self?.messages?.sorted(by: { $0.timestamp < $1.timestamp })
                    
                    self?.messagingMethods.reloadTableView(messages: self?.messages, animate)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        
                        animate = true //Allows new messages to be animated after it's been intially loaded
                    }
                }
            }
    }
    
    
    //MARK: - Monitor Conversation Functions
    
    private func monitorPersonalConversation (_ personalConversation: Conversation?) {
        
        guard let conversation = personalConversation else { return }
        
            firebaseMessaging.monitorPersonalConversation(conversationID: conversation.conversationID) { [weak self] (updatedConvo) in
                
                if let error = updatedConvo["error"] {
                    
                    print(error as Any)
                }
                
                else {
                    
                    if updatedConvo.contains(where: { $0.key == "conversationName" }) {
                        
                        //Conversation name has been changed
                        if updatedConvo["conversationName"] as? String != self?.personalConversation?.conversationName {
                            
                            self?.personalConversation?.conversationName = updatedConvo["conversationName"] as? String
                            
                            self?.configureConversationNameLabel(conversation: self!.personalConversation!)
                        }
                    }
                    
                    if updatedConvo.contains(where: { $0.key == "coverPhotoID" }) {
                        
                        //Conversation cover has been changed
                        if updatedConvo["coverPhotoID"] as? String != self?.personalConversation?.coverPhotoID {
                            
                            self?.personalConversation?.coverPhotoID = updatedConvo["coverPhotoID"] as? String
                            
                            self?.personalConversation?.conversationCoverPhoto = nil
                            
                            if self?.personalConversation?.coverPhotoID != nil {
                                
                                self?.configureNavBarTitleViewWithCoverPhoto(personalConversation: self!.personalConversation!)
                            }
                            
                            else {
                                
                                self?.configureNavBarTitleViewWithMembers(self?.personalConversation)
                            }
                        }
                    }
                    
                    if updatedConvo.contains(where: { $0.key == "memberActivity" }) {
                        
                        //Member activity has been updated
                        if let activity = updatedConvo["memberActivity"] as? [String : Any] {
                            
                            self?.personalConversation?.memberActivity = activity
                        }
                    }
                    
                    if updatedConvo.contains(where: { $0.key == "currentMembersIDs" }) {
                        
                        //Current members may have been updated
                        if let memberIDs = updatedConvo["currentMembersIDs"] as? [String] {
                            
                            self?.personalConversation?.currentMembersIDs = memberIDs
                        }
                    }
                    
                    //Conversation members have been changed
                    if updatedConvo.contains(where: { $0.key == "historicMembers" }) && updatedConvo.contains(where: { $0.key == "currentMembers" }) {
                        
                        if let historicMembers = updatedConvo["historicMembers"] as? [Member], let currentMembers = updatedConvo["currentMembers"] as? [Member] {
                            
                            self?.personalConversation?.historicMembers = historicMembers
                            self?.personalConversation?.currentMembers = currentMembers
                            
                            if self?.personalConversation?.coverPhotoID == nil {
                                
                                self?.configureNavBarTitleViewWithMembers(self?.personalConversation)
                            }
                            
                            else {
                                
                                if let conversation = self?.personalConversation {
                                    
                                    self?.configureConversationNameLabel(conversation: conversation)
                                }
                            }
                        }
                    }
                }
            }
    }
    
    private func monitorCollabConversation (_ collabConversation: Conversation?) {

        guard let conversation = collabConversation else { return }
        
            firebaseMessaging.monitorCollabConversation(collabID: conversation.conversationID) { [weak self] (updatedConvo) in
                
                if let error = updatedConvo["error"] {
                    
                    print(error as Any)
                }
                
                else {
                    
                    if updatedConvo.contains(where: { $0.key == "collabName" }) {
                        
                        //Collab name has been changed
                        if updatedConvo["collabName"] as? String != self?.collabConversation?.conversationName {
                            
                            if updatedConvo["collabName"] as? String != self?.collabConversation?.conversationName {
                                
                                self?.collabConversation?.conversationName = updatedConvo["collabName"] as? String
                                
                                self?.configureConversationNameLabel(conversation: self!.collabConversation!)
                            }
                        }
                        
                        //Collab cover has been changed
                        if updatedConvo.contains(where: { $0.key == "coverPhotoID" }) {
                            
                            if updatedConvo["coverPhotoID"] as? String != self?.collabConversation?.coverPhotoID {
                                
                                self?.collabConversation?.coverPhotoID = updatedConvo["coverPhotoID"] as? String
                                
                                self?.collabConversation?.conversationCoverPhoto = nil
                                
                                if self?.collabConversation?.coverPhotoID != nil {
                                    
                                    self?.configureNavBarTitleViewWithCoverPhoto(collabConversation: self!.collabConversation!)
                                }
                                
                                else {
                                    
                                    self?.configureNavBarTitleViewWithMembers(self?.collabConversation)
                                }
                            }
                        }
                        
                        //Member activity has been updated
                        if updatedConvo.contains(where: { $0.key == "memberActivity" }) {
                            
                            if let activity = updatedConvo["memberActivity"] as? [String : Any] {
                                
                                self?.collabConversation?.memberActivity = activity
                            }
                        }
                        
                        if updatedConvo.contains(where: { $0.key == "currentMembersIDs" }) {
                            
                            //Current members may have been updated
                            if let memberIDs = updatedConvo["currentMembersIDs"] as? [String] {
                                
                                self?.collabConversation?.currentMembersIDs = memberIDs
                            }
                        }
                        
                        //Collab members have been changed
                        if updatedConvo.contains(where: { $0.key == "historicMembers" }) && updatedConvo.contains(where: { $0.key == "currentMembers" }) {
                            
                            if let historicMembers = updatedConvo["historicMembers"] as? [Member], let currentMembers = updatedConvo["currentMembers"] as? [Member] {
                                

                                self?.collabConversation?.historicMembers = historicMembers
                                self?.collabConversation?.currentMembers = currentMembers
                                
                                if self?.collabConversation?.coverPhotoID == nil {
                                    
                                    self?.configureNavBarTitleViewWithMembers(self?.collabConversation)
                                }
                                
                                else {
                                    
                                    if let conversation = self?.collabConversation {
                                        
                                        self?.configureConversationNameLabel(conversation: conversation)
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    
    //MARK: - Save Message Draft Function
    
    @objc private func saveMessageDraft () {
        
        if messageTextViewText.leniantValidationOfTextEntered() && inputAccesoryViewMethods.validateTextChange() && !infoViewBeingPresented {
            
            let defaults = UserDefaults.standard
            
            if let conversationID = personalConversation?.conversationID {
                
                defaults.setValue(messageTextViewText, forKey: "messageDraftForConvo: " + conversationID)
            }
            
            else if let collabID = collabConversation?.conversationID {
                
                defaults.setValue(messageTextViewText, forKey: "messageDraftForConvo: " + collabID)
            }
        }
    }
    
    
    //MARK: - Retrieve Message Draft Function
    
    private func retrieveMessageDraft () {
        
        let defaults = UserDefaults.standard
        
        if let conversationID = personalConversation?.conversationID {
            
            if let messageDraft = defaults.value(forKey: "messageDraftForConvo: " + conversationID) as? String {
                
                messageInputAccesoryView.textViewContainer.messageTextView.text = messageDraft
                messageInputAccesoryView.textViewContainer.messageTextView.textColor = inputAccesoryViewMethods.textViewTextColor
                messageTextViewText = messageDraft
                
                defaults.setValue(nil, forKey: "messageDraftForConvo: " + conversationID)
            }
        }
        
        else if let collabID = collabConversation?.conversationID {
            
            if let messageDraft = defaults.value(forKey: "messageDraftForConvo: " + collabID) as? String {
                
                messageInputAccesoryView.textViewContainer.messageTextView.text = messageDraft
                messageInputAccesoryView.textViewContainer.messageTextView.textColor = inputAccesoryViewMethods.textViewTextColor
                messageTextViewText = messageDraft
                
                defaults.setValue(nil, forKey: "messageDraftForConvo: " + collabID)
            }
        }
    }
    
    
    //MARK: - Send Message Function
    
    @objc private func sendMessage () {
        
        let sendButton = messageInputAccesoryView.textViewContainer.sendButton
        sendButton.isEnabled = false
        
        if messageTextViewText.leniantValidationOfTextEntered() && inputAccesoryViewMethods.validateTextChange() {
            
            var message = Message()
            message.sender = currentUser.userID
            message.message = messageTextViewText
            message.timestamp = Date()
            
            if let conversation = personalConversation?.conversationID {
                
                firebaseMessaging.sendPersonalMessage(conversationID: conversation, message) { [weak self] (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        self?.inputAccesoryViewMethods.messageSent(keyboardHeight: self?.keyboardHeight)
                        self?.messageTextViewText = ""
                        sendButton.isEnabled = true
                    }
                }
            }
                
            else if let collab = collabConversation?.conversationID {
                
                firebaseMessaging.sendCollabMessage(collabID: collab, message) { [weak self] (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        self?.inputAccesoryViewMethods.messageSent(keyboardHeight: self?.keyboardHeight)
                        self?.messageTextViewText = ""
                        sendButton.isEnabled = true
                    }
                }
            }
            
            else {
                
                sendButton.isEnabled = true
                
                SVProgressHUD.showError(withStatus: "Sorry, something went wrong")
            }
        }
        
        else {
            
            sendButton.isEnabled = true
        }
    }
    

    //MARK: - User Activity Functions
    
    @objc private func setUserActiveStatus () {
            
        if let conversation = personalConversation {
            
            firebaseMessaging.setActivityStatus(conversationID: conversation.conversationID, "now")
        }
        
        else if let collab = collabConversation {
            
            firebaseMessaging.setActivityStatus(collabID: collab.conversationID, "now")
        }
    }
    
    @objc private func setUserInactiveStatus () {
          
        if !infoViewBeingPresented {
            
            if let conversation = personalConversation {
                
                firebaseMessaging.setActivityStatus(conversationID: conversation.conversationID, Date())
            }
            
            else if let collab = collabConversation {
                
                firebaseMessaging.setActivityStatus(collabID: collab.conversationID, Date())
            }
        }
    }
    
    
    //MARK: - Add Attachment Function
    
    @objc private func addAttachment () {
        
        let addAttachmentAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "    Take a Photo", style: .default) { [weak self] (takePhotoAction) in
          
            self?.takePhotoSelected()
        }
        
        let cameraImage = UIImage(named: "camera2")
        takePhotoAction.setValue(cameraImage, forKey: "image")
        takePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment") //Aligning text to the left
        
        let choosePhotoAction = UIAlertAction(title: "    Choose a Photo", style: .default) { [weak self] (choosePhotoAction) in
            
            self?.choosePhotoSelected()
        }
        
        let photoImage = UIImage(named: "image")
        choosePhotoAction.setValue(photoImage, forKey: "image")
        choosePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment") //Aligning text to the left
        
        
        let shareScheduleAction = UIAlertAction(title: "    Share your Schedule", style: .default) { [weak self] (shareScheduleAction) in
            
            self?.moveToSendScheduleView()
        }
        
        let shareImage = UIImage(named: "share")
        shareScheduleAction.setValue(shareImage, forKey: "image")
        shareScheduleAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment") //Aligning text to the left
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addAttachmentAlert.addAction(takePhotoAction)
        addAttachmentAlert.addAction(choosePhotoAction)
        addAttachmentAlert.addAction(shareScheduleAction)
        addAttachmentAlert.addAction(cancelAction)
        
        present(addAttachmentAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - Prep View for Zooming Function
    
    private func prepViewForImageViewZooming (completion: (() -> Void)) {
        
        imageViewBeingZoomed = true

        if messageInputAccesoryView.textViewContainer.messageTextView.isFirstResponder {

            keyboardWasPresent = true
        }

        else {

            keyboardWasPresent = false
        }
        
        self.messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
        self.resignFirstResponder()
        
        completion()
    }
    
    
    //MARK: - Move to Share Schedule View
    
    private func moveToSendScheduleView () {
        
        let sendScheduleVC = SendScheduleViewController()
        sendScheduleVC.personalConversationID = personalConversation?.conversationID
        sendScheduleVC.collabConversationID = collabConversation?.conversationID
        
        self.present(sendScheduleVC, animated: true)
    }
    
    //MARK: Prepare for Segue Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToSendPhotoView" {
            
            let sendPhotoVC = segue.destination as! SendPhotoMessageViewController
            sendPhotoVC.reconfigureMessagingViewDelegate = self
            sendPhotoVC.selectedPhoto = selectedPhoto
            
            if let conversation = personalConversation {
                
                sendPhotoVC.personalConversationID = conversation.conversationID
            }
            
            else if let conversation = collabConversation {
                
                sendPhotoVC.collabConversationID = conversation.conversationID
            }
            
            removeObservors()
        }
        
        else if segue.identifier == "moveToConvoInfoView" {
            
            let convoInfoVC = segue.destination as! ConversationInfoViewController
            convoInfoVC.personalConversation = personalConversation
            convoInfoVC.collabConversation = collabConversation
            convoInfoVC.photoMessages = firebaseMessaging.filterPhotoMessages(messages: messages)
            convoInfoVC.scheduleMessages = firebaseMessaging.filterScheduleMessages(messages: messages)
            
            convoInfoVC.moveToConversationWithFriendDelegate = self
            convoInfoVC.reconfigureViewDelegate = self
            
            infoViewBeingPresented = true
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    
    //MARK: - Dismiss Keyboard Function
    
    @objc private func dismissKeyboard () {
        
        messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
    }
}

//MARK: - UITableView DataSource and Delegate Extension

extension MessagingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messagingMethods.numberOfRowsInSection(messages: messages)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let members = personalConversation != nil ? personalConversation?.historicMembers : collabConversation?.historicMembers

        return messagingMethods.cellForRowAt(indexPath: indexPath, messages: messages, members: members)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let members = personalConversation != nil ? personalConversation?.historicMembers : collabConversation?.historicMembers
        
        return messagingMethods.heightForRowAt(indexPath: indexPath, messages: messages, members: members ?? [])
    }
}

//MARK: - UITextViewDelegate Extension

extension MessagingViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        inputAccesoryViewMethods.textViewBeganEditing(textView: textView, keyboardHeight: keyboardHeight)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        messageTextViewText = textView.text
        
        inputAccesoryViewMethods.textViewTextChanged(textView: textView, keyboardHeight: keyboardHeight)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        inputAccesoryViewMethods.textViewEndedEditing(textView: textView)
    }
}

//MARK: - UIImagePickerControllerDelegate Extension

extension MessagingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            
            selectedPhoto = selectedImage
            
            dismiss(animated: true, completion: nil)
            
            performSegue(withIdentifier: "moveToSendPhotoView", sender: self)
        }
        
        else {
            
            dismiss(animated: true) {
                
                SVProgressHUD.showError(withStatus: "Sorry, something went wrong selecting this photo")
            }
        }
    }
}


//MARK: - ReconfigureView Protocols Extension

extension MessagingViewController: ReconfigureMessagingViewFromSendPhotoVC, ReconfigureMessagingViewFromConvoInfoVC {
    
    func reconfigureView () {
        
        addObservors()
        
        self.becomeFirstResponder()
    }
    
    func reconfigureView(personalConversation: Conversation?, collabConversation: Conversation?) {
        
        self.personalConversation = personalConversation
        self.collabConversation = collabConversation
    }
}


//MARK: - CachePhoto Protocol Extension

extension MessagingViewController: CachePhotoProtocol {
    
    func cacheMessagePhoto (messageID: String, photo: UIImage?) {
        
        if let messageIndex = messages?.firstIndex(where: { $0.messageID == messageID }) {
            
            messages?[messageIndex].messagePhoto?["photo"] = photo
        }
    }
    
    func cacheCollabPhoto(photoID: String, photo: UIImage?) {}
    
    func cacheBlockPhoto(photoID: String, photo: UIImage?) {}
}


//MARK: - ZoomIn Protocol Extension

extension MessagingViewController: ZoomInProtocol {
    
    func zoomInOnPhotoImageView(photoImageView: UIImageView) {
        
        prepViewForImageViewZooming { [weak self] in

            self?.zoomingMethods = ZoomingImageViewMethods(on: photoImageView, cornerRadius: 10, completion: {

                self?.becomeFirstResponder()

                if self?.keyboardWasPresent ?? false {

                    self?.messageInputAccesoryView.textViewContainer.messageTextView.becomeFirstResponder()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                    self?.imageViewBeingZoomed = false
                }
            })

            zoomingMethods?.performZoom()
        }
    }
}


//MARK: - Schedule Protocol Extension

extension MessagingViewController: ScheduleProtocol {
    
    func moveToScheduleView(message: Message) {
        
        let scheduleVC = ScheduleMessageViewController()
        scheduleVC.message = message
        scheduleVC.members = personalConversation != nil ? personalConversation?.historicMembers : collabConversation?.historicMembers
        
        let scheduleNavigationController = UINavigationController(rootViewController: scheduleVC)
        
        self.present(scheduleNavigationController, animated: true)
    }
}


//MARK: - PresentCopiedAnimation Protocol Extension

extension MessagingViewController: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        copiedAnimationView?.presentCopiedAnimation(topAnchor: conversationNameLabel.frame.maxY + 5)
    }
}


//MARK: - MoveToConversationWithFriend Protocol Extension

extension MessagingViewController: MoveToConversationWithFriendProtcol {
    
    func moveToConversationWithFriend(_ friend: Friend) {
        
        navigationController?.popToRootViewController(animated: true)
        
        moveToConversationWithFriendDelegate?.moveToConversationWithFriend(friend)
    }
}
