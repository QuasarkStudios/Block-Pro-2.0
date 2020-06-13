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

    @IBOutlet weak var messagesTableView: UITableView!
    
    let messageInputAccesoryView = InputAccesoryView(showsAddButton: true, textViewPlaceholderText: "Send a message")
    var inputAccesoryViewMethods: InputAccesoryViewMethods!
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseMessaging = FirebaseMessaging()
    let firebaseStorage = FirebaseStorage()
    
    var conversationID: String? {
        didSet {
            
            retrievePersonalMessages()
        }
    }
    
    var collabID: String? {
        didSet {
            
            retrieveCollabMessages()
        }
    }
    
    var conversationMembers: [Member]?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.configureNavBar()
        
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
                cell.conversationID = conversationID
                cell.members = conversationMembers
                cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
                cell.message = messages?[indexPath.row / 2]
                
                cell.selectionStyle = .none
                
                return cell
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "photoMessageCell", for: indexPath) as! PhotoMessageCell
                cell.conversationID = conversationID
                cell.collabID = collabID
                cell.members = conversationMembers
                cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
                cell.message = messages?[indexPath.row / 2]
                
                cell.cachePhotoDelegate = self
                
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
    
    private func configureTableView (tableView: UITableView) {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = 0
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: topBarHeight, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: topBarHeight, right: 0)
        
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
    
    @objc internal func keyboardBeingPresented (notification: NSNotification) {
        
        inputAccesoryViewMethods.keyboardBeingPresented(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: messages?.count ?? 0, topBarHeight: topBarHeight)
    }

    
    @objc internal func keyboardBeingDismissed (notification: NSNotification) {

        inputAccesoryViewMethods.keyboardBeingDismissed(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: messages?.count ?? 0, textViewText: messageTextViewText)
    }
    
    private func retrievePersonalMessages () {
        
        guard let conversation = conversationID else { return }
        
            firebaseMessaging.retrieveAllPersonalMessages(conversationID: conversation) { (messages, error) in
                
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
    
    private func retrieveCollabMessages () {
        
        guard let collab = collabID else { return }
        
            firebaseMessaging.retrieveAllCollabMessages(collabID: collab) { (messages, error) in
                
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
        
        firebaseMessaging.readMessages(conversationID: conversationID)
    }
    
    @objc private func sendMessage () {
        
        let sendButton = messageInputAccesoryView.textViewContainer.sendButton
        sendButton.isEnabled = false
        
        if messageTextViewText.leniantValidationOfTextEntered() && inputAccesoryViewMethods.validateTextChange() {
            
            var message = Message()
            message.sender = currentUser.userID
            message.message = messageTextViewText
            message.timestamp = Date()
            
            if let conversation = conversationID {
                
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
                
            else if let collab = collabID {
                
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToSendPhotoView" {
            
            let sendPhotoVC = segue.destination as! SendPhotoMessageViewController
            sendPhotoVC.reconfigureViewDelegate = self
            sendPhotoVC.selectedPhoto = selectedPhoto
            
            if let conversation = conversationID {
                
                sendPhotoVC.conversationID = conversation
            }
            
            else if let collab = collabID {
                
                sendPhotoVC.collabID = collab
            }
            
            removeObservors()
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
