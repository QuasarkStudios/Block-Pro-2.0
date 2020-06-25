//
//  MessagingViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/25/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class MessagingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var navBarExtensionView: UIView!
    @IBOutlet weak var conversationNameLabel: UILabel!
    @IBOutlet weak var messagesTableView: UITableView!
    
    let messageInputAccesoryView = InputAccesoryView(showsAddButton: true, textViewPlaceholderText: "Send a message")
    var inputAccesoryViewMethods: InputAccesoryViewMethods!
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseMessaging = FirebaseMessaging()
    let firebaseStorage = FirebaseStorage()
    
    var personalConversation: Conversation? {
        didSet {
            
            if !viewInitiallyLoaded {
                
                retrievePersonalMessages(personalConversation)
                monitorPersonalConversation(personalConversation)
            }
        }
    }
    
    var collabConversation: Conversation? {
        didSet {
            
            if !viewInitiallyLoaded {
                
                retrieveCollabMessages(collabConversation)
                monitorCollabConversation(collabConversation)
            }
        }
    }
    
//    var conversationID: String? {
//        didSet {
//            
//            retrievePersonalMessages()
//        }
//    }
//    
//    var collabID: String? {
//        didSet {
//            
//            retrieveCollabMessages()
//        }
//    }
    
    //var conversationMembers: [Member]?
    
    var messages: [Message]?
    
    var selectedPhoto: UIImage?
    
    var keyboardHeight: CGFloat?
    
    var messageTextViewText: String = ""
    
    var viewInitiallyLoaded: Bool = false
    
    var topBarHeight: CGFloat {
        
        //iPhone 11 Pro Max & iPhone 11
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            return (self.navigationController?.navigationBar.frame.height ?? 0.0)
        }
            
        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            return (self.navigationController?.navigationBar.frame.height ?? 0.0)
        }
            
        //Every other iPhone
        else {

            return (UIApplication.shared.statusBarFrame.height) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        }
    }
    
    weak var moveToConversationWithMemberDelegate: MoveToConversationWithMemberProtcol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar(navBar: navigationController?.navigationBar)
        
        configureTableView(tableView: messagesTableView)
        
        configureTextViewContainer()
        
        configureGestureRecognizors()
        
        inputAccesoryViewMethods = InputAccesoryViewMethods(accesoryView: messageInputAccesoryView, textViewPlaceholderText: "Send a message", tableView: messagesTableView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addObservors()
        
        self.becomeFirstResponder()
        
        viewInitiallyLoaded = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        readMessages()
        
        removeObservors()
    }
    
    deinit {
        
        print("view deintialized")
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
        
        return (messages?.count ?? 0) * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            if messages?[indexPath.row / 2].messagePhoto == nil {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
                cell.members = personalConversation != nil ? personalConversation?.members : collabConversation?.members
                cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
                cell.message = messages?[indexPath.row / 2]
                
                cell.selectionStyle = .none
                
                return cell
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "photoMessageCell", for: indexPath) as! PhotoMessageCell
                cell.conversationID = personalConversation != nil ? personalConversation?.conversationID : nil
                cell.collabID = collabConversation != nil ? collabConversation?.conversationID : nil
                cell.members = personalConversation != nil ? personalConversation?.members : collabConversation?.members
                cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
                cell.message = messages?[indexPath.row / 2]
                
                cell.cachePhotoDelegate = self
                cell.zoomInDelegate = self
                
                cell.selectionStyle = .none

                return cell
            }
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
            cell.isUserInteractionEnabled = false
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            return determineMessageRowHeight(indexPath: indexPath)
        }
        
        else {
            
            return determineSeperatorRowHeight(indexPath: indexPath)
        }
    }
    
    private func configureNavBar (navBar: UINavigationBar?) {
        
        navBar?.configureNavBar(barBackgroundColor: .clear)
        applyGradientFade(view: navBarExtensionView)
        
        if let conversation = personalConversation {
            
            configureNavBarTitleView(conversation.members)
            
            configureConversationNameLabel(conversation: conversation)
        }
        
        else if let conversation = collabConversation {
            
            configureNavBarTitleView(conversation.members)
            
            configureConversationNameLabel(conversation: conversation)
        }
    }
    
    private func configureNavBarTitleView (_ convoMembers: [Member]) {
        
        self.navigationItem.titleView = nil
        
        let stackViewWidth = ((convoMembers.count - 1) * 32) - ((convoMembers.count - 1) * 11)
        let memberStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: stackViewWidth, height: 32))
        memberStackView.alignment = .center
        memberStackView.distribution = .fillProportionally
        memberStackView.axis = .horizontal
        memberStackView.spacing = -13
        
        var memberCount = 0
        
        for member in convoMembers {
            
            if member.userID != currentUser.userID {
                
                let profilePic = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic"), shadowRadius: 2, shadowOpacity: 0.35, borderColor: UIColor.white.cgColor)
                
                memberStackView.addArrangedSubview(profilePic)
                
                profilePic.translatesAutoresizingMaskIntoConstraints = false
                
                [

                    profilePic.topAnchor.constraint(equalTo: profilePic.superview!.topAnchor, constant: 0),
                    profilePic.leadingAnchor.constraint(equalTo: profilePic.superview!.leadingAnchor, constant: CGFloat(memberCount * 19)),
                    profilePic.widthAnchor.constraint(equalToConstant: 32),
                    profilePic.heightAnchor.constraint(equalToConstant: 32)
                    
                ].forEach( { $0.isActive = true } )
                
                if let friend = firebaseCollab.friends.first(where: { $0.userID == member.userID }) {
                    
                    profilePic.profilePic = friend.profilePictureImage
                }
                
                else if let memberProfilePic = firebaseCollab.membersProfilePics[member.userID] {
                    
                    profilePic.profilePic = memberProfilePic
                }
                
                else {
                    
                    firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { (retrievedProfilePic, userID) in
                        
                        profilePic.profilePic = retrievedProfilePic
                        
                        self.firebaseCollab.cacheMemberProfilePics(userID: member.userID, profilePic: retrievedProfilePic)
                    }
                }
                
                memberCount += 1
            }
        }
        
        self.navigationItem.titleView = memberStackView
    }
    
    private func configureConversationNameLabel (conversation: Conversation) {
        
        if let name = conversation.conversationName {
            
            conversationNameLabel.text = name
        }
        
        else {
            
            var organizedMembers = conversation.members.sorted(by: { $0.firstName < $1.firstName })
            
            if let currentUserIndex = organizedMembers.firstIndex(where: { $0.userID == currentUser.userID }) {
                
                organizedMembers.remove(at: currentUserIndex)
            }
            
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
    }
    
    private func configureTableView (tableView: UITableView) {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = 0
        
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: topBarHeight, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: topBarHeight, right: 0)
        
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        tableView.register(UINib(nibName: "PhotoMessageCell", bundle: nil), forCellReuseIdentifier: "photoMessageCell")
    }
    
    private func configureTextViewContainer () {
        
        messageInputAccesoryView.parentViewController = self
        messageInputAccesoryView.isHidden = false
        messageInputAccesoryView.alpha = 1
    }
    
    private func configureSelectedAttachmentView () {
        
//        selectedAttachmentView.translatesAutoresizingMaskIntoConstraints = false
//
//        [
//
//            selectedAttachmentView.topAnchor.constraint(equalTo: textViewContainer.topAnchor, constant: 0),
//            selectedAttachmentView.bottomAnchor.constraint(equalTo: messageTextView.topAnchor, constant: 0),
//            selectedAttachmentView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor, constant: 10),
//            selectedAttachmentView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: -55)
//
//        ].forEach( { $0.isActive = true } )
//
//        selectedAttachmentView.backgroundColor = .blue
    }

    private func configureGestureRecognizors () {

        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    private func applyGradientFade (view: UIView) {
        
        let gradientFade = CAGradientLayer()
        gradientFade.frame = view.bounds
//        gradientFade.colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor]
        gradientFade.colors = [UIColor.white.withAlphaComponent(0.99).cgColor, UIColor.white.withAlphaComponent(0.25).cgColor, UIColor.clear.cgColor]
        
        gradientFade.locations = [0.45, 0.7, 0.8]//[0.45, 0.7, 0.8]
        
        view.layer.mask = gradientFade
    }

    private func addObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(readMessages), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendMessage), name: .userDidSendMessage, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addAttachment), name: .userDidAddMessageAttachment, object: nil)
    }
    
    private func removeObservors () {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func monitorPersonalConversation (_ personalConversation: Conversation?) {
        
        if let conversation = personalConversation {
            
            firebaseMessaging.monitorPersonalConversation(conversationID: conversation.conversationID) { (conversationName, conversationMembers, error) in
                
                if error != nil {
                    
                    print(error as Any)
                }
                
                else if let name = conversationName {
                    
                    if name != conversation.conversationName {
                        
                        self.personalConversation?.conversationName = name
                        self.configureConversationNameLabel(conversation: self.personalConversation!)
                    }
                }
                
                else if let members = conversationMembers {
                    
                    if conversation.members.count != members.count {
                        
                        self.personalConversation?.members = members
                        self.configureNavBarTitleView(members)
                    }
                    
                    else {
                        
                        for member in members {
                            
                            if conversationMembers?.contains(where: { $0.userID == member.userID }) == false {
                                
                                self.personalConversation?.members = members
                                self.configureNavBarTitleView(members)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func monitorCollabConversation (_ collabConversation: Conversation?) {
        
        if let conversation = collabConversation {
            
            firebaseMessaging.monitorCollabConversation(collabID: conversation.conversationID) { (collabName, collabMembers, error) in
                
                if error != nil {
                    
                    print(error as Any)
                }
                
                else if let name = collabName {
                    
                    if name != conversation.conversationName {
                        
                        self.collabConversation?.conversationName = name
                        self.configureConversationNameLabel(conversation: self.collabConversation!)
                    }
                }
                
                else if let members = collabMembers {
                    
                    if conversation.members.count != members.count {
                        
                        self.collabConversation?.members = members
                        self.configureNavBarTitleView(members)
                    }
                    
                    else {
                        
                        for member in members {
                            
                            if collabMembers?.contains(where: { $0.userID == member.userID }) == false {
                                
                                self.collabConversation?.members = members
                                self.configureNavBarTitleView(members)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc internal func keyboardBeingPresented (notification: NSNotification) {
        
        if !(imageViewBeingZoomed ?? false) {
            
            inputAccesoryViewMethods.keyboardBeingPresented(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: messages?.count ?? 0, topBarHeight: topBarHeight)
        }
    }

    
    @objc internal func keyboardBeingDismissed (notification: NSNotification) {
        
        if !(imageViewBeingZoomed ?? false) {
            
            inputAccesoryViewMethods.keyboardBeingDismissed(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: messages?.count ?? 0, textViewText: messageTextViewText)
        }
    }
    
    private func retrievePersonalMessages (_ personalConversation: Conversation?) {
        
        guard let conversation = personalConversation else { return }
        
        firebaseMessaging.retrieveAllPersonalMessages(conversationID: conversation.conversationID) { (messages, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    for message in messages {
                        
                        if self.messages == nil {
                            
                            self.messages = []
                        }
                        
                        //Checks if current message already exists in global messages array
                        if !(self.messages?.contains(where: { $0.messageID == message.messageID }) ?? false) {
                            
                            self.messages?.append(message)
                        }
                    }
                    
                    self.messages = self.messages?.sorted(by: { $0.timestamp < $1.timestamp })
                    
                    self.reloadTableView()
                }
            }
    }
    
    private func retrieveCollabMessages (_ collabConversation: Conversation?) {
        
        guard let collab = collabConversation else { return }
        
        firebaseMessaging.retrieveAllCollabMessages(collabID: collab.conversationID) { (messages, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    for message in messages {
                        
                        if self.messages == nil {
                            
                            self.messages = []
                        }
                        
                        //Checks if current message already exists in global messages array
                        if !(self.messages?.contains(where: { $0.messageID == message.messageID }) ?? false) {
                            
                            self.messages?.append(message)
                        }
                    }
                    
                    self.messages = self.messages?.sorted(by: { $0.timestamp < $1.timestamp })
                    
                    self.reloadTableView()
                }
            }
    }
    
    private func reloadTableView () {
        
        if !self.viewInitiallyLoaded {

            self.messagesTableView.reloadData()
        }

        //If new messages have been recieved
        else if ((self.messages?.count ?? 0) * 2) != self.messagesTableView.numberOfRows(inSection: 0) {

            let seperatorCellIndexPath = IndexPath(row: ((self.messages?.count ?? 0) * 2) - 2, section: 0)
            let messageCellIndexPath = IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0)

            let lastMessageIndex = messages?.count ?? 0 > 0 ? (messages?.count ?? 0) - 1 : 0

            if messages?[lastMessageIndex].sender == self.currentUser.userID {

                self.messagesTableView.insertRows(at: [seperatorCellIndexPath, messageCellIndexPath], with: .right)
            }

            else {

                self.messagesTableView.insertRows(at: [seperatorCellIndexPath, messageCellIndexPath], with: .left)
            }
        }

        if self.messages?.count ?? 0 > 0 {

            let animateScroll = viewInitiallyLoaded ? true : false
            self.messagesTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .bottom, animated: animateScroll)
        }
    }
    
    @objc private func readMessages () {
        
        if let conversation = personalConversation {
            
            firebaseMessaging.readMessages(conversationID: conversation.conversationID)
        }
        
        else if let conversation = collabConversation {
            
            firebaseMessaging.readMessages(collabID: conversation.conversationID)
        }
        
        //firebaseMessaging.readMessages(conversationID: conversationID)
    }
    
    @objc private func sendMessage () {
        
        let sendButton = messageInputAccesoryView.textViewContainer.sendButton
        sendButton.isEnabled = false
        
        if messageTextViewText.leniantValidationOfTextEntered() && inputAccesoryViewMethods.validateTextChange() {
            
            var message = Message()
            message.sender = currentUser.userID
            message.message = messageTextViewText
            message.timestamp = Date()
            
            if let conversation = personalConversation?.conversationID {
                
                firebaseMessaging.sendPersonalMessage(conversationID: conversation, message) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        self.inputAccesoryViewMethods.messageSent(messagesCount: self.messages?.count ?? 0)
                        self.messageTextViewText = ""
                        sendButton.isEnabled = true
                    }
                }
            }
                
            else if let collab = collabConversation?.conversationID {
                
                firebaseMessaging.sendCollabMessage(collabID: collab, message) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        self.inputAccesoryViewMethods.messageSent(messagesCount: self.messages?.count ?? 0)
                        self.messageTextViewText = ""
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
    
    @objc private func addAttachment () {
        
        let addAttachmentAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //addAttachmentAlert.view.tintColor = .black
        
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
        
        
        let shareScheduleAction = UIAlertAction(title: "    Share your Schedule", style: .default) { (shareScheduleAction) in
            
        }
        
        let shareImage = UIImage(named: "share")
        shareScheduleAction.setValue(shareImage, forKey: "image")
        shareScheduleAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addAttachmentAlert.addAction(takePhotoAction)
        addAttachmentAlert.addAction(choosePhotoAction)
        addAttachmentAlert.addAction(shareScheduleAction)
        addAttachmentAlert.addAction(cancelAction)
        
        present(addAttachmentAlert, animated: true, completion: nil)
    }
    
    private func determineMessageRowHeight (indexPath: IndexPath) -> CGFloat {

        //First message
        if indexPath.row == 0 {

           //If the current user sent the message
            if messages?[indexPath.row / 2].sender == currentUser.userID {

                if let messagePhoto = messages?[indexPath.row / 2].messagePhoto {
                    
                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -14
                    
                    return imageViewHeight + textViewHeight + 16
                }
                
                else {
                    
                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 15
                }
            }

            //If another user sent the message
            else {
                
                if let messagePhoto = messages?[indexPath.row / 2].messagePhoto {
                    
                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -29
                    
                    return imageViewHeight + textViewHeight + 31
                }
                
                else {
                    
                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 30
                }
            }
        }

        //Not the first message
        else {

            //If the current user sent the message
            if messages?[indexPath.row / 2].sender == currentUser.userID {

                if let messagePhoto = messages?[indexPath.row / 2].messagePhoto {
                    
                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -14
                    
                    return imageViewHeight + textViewHeight + 16
                }
                
                else {
                    
                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 15
                }
            }

            //If the previous message was sent by another user
            else if messages?[indexPath.row / 2].sender != messages![(indexPath.row / 2) - 1].sender {

                if let messagePhoto = messages?[indexPath.row / 2].messagePhoto {
                   
                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -29
                    
                    return imageViewHeight + textViewHeight + 31
                }
                
                else {
                    
                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 30
                }
            }
            
            //If all else fails 
            else {
                
                if let messagePhoto = messages?[indexPath.row / 2].messagePhoto {

                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -14

                    return imageViewHeight + textViewHeight + 16
                }

                else {

                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 15
                }
            }
        }
    }
    
    private func calculatePhotoMessageCellHeight (messagePhoto: [String : Any]) -> CGFloat {
        
        let photoWidth = messagePhoto["photoWidth"] as! CGFloat
        let photoHeight = messagePhoto["photoHeight"] as! CGFloat
        let height = (photoHeight / photoWidth) * 200
        
        return height
    }
    
    private func determineSeperatorRowHeight (indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.row / 2) + 1 < messages!.count {
            
            if messages![indexPath.row / 2].sender == messages![(indexPath.row / 2) + 1].sender {
                
                return 2
            }
            
            else {
                
                return 10
            }
        }
        
        else {
            
            return 0
        }
    }
    
    var zoomedOutImageView: UIImageView?
    var zoomedOutImageViewFrame: CGRect?
    
    var blackBackground: UIView?
    var zoomedInImageView: UIImageView?

    var imageViewBeingZoomed: Bool?
    var keyboardWasPresent: Bool?
    
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
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                
                let height = (startingFrame.height / startingFrame.width) * self.view.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)
                zoomingImageView.center = self.view.center
                
                zoomingImageView.layer.cornerRadius = 0
            })
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToSendPhotoView" {
            
            let sendPhotoVC = segue.destination as! SendPhotoMessageViewController
            sendPhotoVC.reconfigureViewDelegate = self
            sendPhotoVC.selectedPhoto = selectedPhoto
            
            if let personalConversationID = personalConversation?.conversationID {
                
                sendPhotoVC.conversationID = personalConversationID
            }
            
            else if let collabConversationID = collabConversation?.conversationID {
                
                sendPhotoVC.collabID = collabConversationID
            }
            
            removeObservors()
        }
        
        else if segue.identifier == "moveToConvoInfoView" {
            
            let convoInfoVC = segue.destination as! ConversationInfoViewController
            convoInfoVC.personalConversation = personalConversation
            convoInfoVC.collabConversation = collabConversation
            convoInfoVC.moveToConversationWithMemberDelegate = self
        }
    }
    
    @objc private func dismissKeyboard () {
        
        messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
    }
}

extension MessagingViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        inputAccesoryViewMethods.textViewBeganEditing(textView: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        messageTextViewText = textView.text
        
        inputAccesoryViewMethods.textViewTextChanged(textView: textView, keyboardHeight: keyboardHeight)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        inputAccesoryViewMethods.textViewEndedEditing(textView: textView)
    }
}

extension MessagingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhotoSelected () {
        
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.configureNavBar()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
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

extension MessagingViewController: ReconfigureView {
    
    func reconfigureView () {
        
        addObservors()
        
        self.becomeFirstResponder()
    }
}

extension MessagingViewController: CachePhotoProtocol {
    
    func cachePhoto (messageID: String, photo: UIImage?) {
        
        if let messageIndex = messages?.firstIndex(where: { $0.messageID == messageID }) {
            
            messages?[messageIndex].messagePhoto?["photo"] = photo
        }
    }
}

extension MessagingViewController: ZoomInProtocol {
    
    func zoomInOnPhotoImageView(photoImageView: UIImageView) {
        
        performZoomOnPhotoImageView(photoImageView: photoImageView)
    }
}

extension MessagingViewController: MoveToConversationWithMemberProtcol {
    
    func moveToConversationWithMember(_ member: Friend) {
        
        navigationController?.popToRootViewController(animated: true)
        
        moveToConversationWithMemberDelegate?.moveToConversationWithMember(member)
    }
    

}
