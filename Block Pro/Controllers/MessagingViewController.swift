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
    let textViewContainer = MessageTextViewContainer()
    let messageTextView = UITextView()
    let selectedAttachmentView = UIView()
    //let sendButton = UIButton(type: .system)

    let addButton = UIButton(type: .system)
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseMessaging = FirebaseMessaging()
    
    var inputAccesoryViewMethods: InputAccesoryViewMethods!
    
    var conversationID: String? {
        didSet {
            
            retrieveMessages()
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        readMessages()
        
        removeObservors()
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
            cell.members = conversationMembers
            cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
            cell.message = messages?[indexPath.row / 2]
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        else {
            
//            let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
//            cell.selectionStyle = .none
            
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
        
            //First message
            if indexPath.row == 0 {
                
               //If the current user sent the message
                if messages?[indexPath.row / 2].sender == currentUser.userID {
                    
                    return (messages?[indexPath.row / 2].message.estimateFrameForMessageCell().height)! + 15
                }
                
                else {
                    
                   return (messages?[indexPath.row / 2].message.estimateFrameForMessageCell().height)! + 30
                }
            }
            
            //Not the first message
            else if (indexPath.row / 2) - 1 >= 0 {
                
                //If the current user sent the message
                if messages?[indexPath.row / 2].sender == currentUser.userID {
                    
                    return (messages?[indexPath.row / 2].message.estimateFrameForMessageCell().height)! + 15
                }
                
                //If the previous message was sent by another user
                else if messages?[indexPath.row / 2].sender != messages![(indexPath.row / 2) - 1].sender {
                    
                    return (messages?[indexPath.row / 2].message.estimateFrameForMessageCell().height)! + 30
                }
            }

            return (messages?[indexPath.row / 2].message.estimateFrameForMessageCell().height)! + 15
        }
        
        else {
            
            //Seperator cell
            return determineSeperatorRowHeight(indexPath: indexPath)
        }
    }
    
    private func configureTableView (tableView: UITableView) {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: topBarHeight, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: topBarHeight, right: 0)
        
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
    }
    
    private func configureTextViewContainer () {
        
        messageInputAccesoryView.parentViewController = self
        messageInputAccesoryView.isHidden = false
        messageInputAccesoryView.alpha = 1
        messageInputAccesoryView.addSubview(textViewContainer)
//        
//        textViewContainer.configureConstraints() //Has to be called from here
//        
//        textViewContainer.addSubview(selectedAttachmentView)
//        textViewContainer.addSubview(messageTextView)
//        
//        configureSelectedAttachmentView()
//        configureMessageTextView()
//        
//        textViewContainer.addSubview(sendButton)
//        configureSendButton()
//    
//        messageInputAccesoryView.addSubview(addButton)
//        configureAddButton()
    }
    
    private func configureSelectedAttachmentView () {
        
        selectedAttachmentView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            selectedAttachmentView.topAnchor.constraint(equalTo: textViewContainer.topAnchor, constant: 0),
            selectedAttachmentView.bottomAnchor.constraint(equalTo: messageTextView.topAnchor, constant: 0),
            selectedAttachmentView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor, constant: 10),
            selectedAttachmentView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: -55)
        
        ].forEach( { $0.isActive = true } )
        
        selectedAttachmentView.backgroundColor = .blue
    }
    
    private func configureAddButton () {
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            addButton.leadingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: 17.5),
            addButton.trailingAnchor.constraint(equalTo: messageInputAccesoryView.trailingAnchor, constant: -17.5),
            addButton.widthAnchor.constraint(equalToConstant: 27),
            addButton.heightAnchor.constraint(equalToConstant: 27),
            addButton.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor, constant: -5)
            //addButton.centerYAnchor.constraint(equalTo: textViewContainer.centerYAnchor, constant: -2.5)
        
        ].forEach( { $0.isActive = true })
        
        //addButton.setImage(UIImage(named: "share"), for: .normal)
        addButton.setImage(UIImage(named: "plus 3"), for: .normal)
        addButton.tintColor = UIColor(hexString: "222222")
        
        //addButton.addTarget(self, action: #selector((addButtonPressed)), for: .touchUpInside)
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
    
    private func retrieveMessages () {
        
        guard let conversation = conversationID else { return }
        
        firebaseMessaging.retrieveAllPersonalMessages(conversationID: conversation) { (messages, error) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            
            else {
                
                self.messages = messages
                self.messagesTableView.reloadData()
                
                //if !self.viewInitiallyLoaded {
                    
                    if self.messages?.count ?? 0 > 0 {
                        
                        self.messagesTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .bottom, animated: true)
                    }
                    
                    self.viewInitiallyLoaded = true
                //}
                
                //self.collabTableView.reloadRows(at: <#T##[IndexPath]#>, with: <#T##UITableView.RowAnimation#>) look into this future sir
                
            }
        }
    }
    
    @objc private func readMessages () {
        
        firebaseMessaging.readMessages(conversationID: conversationID)
    }
    
    @objc private func sendMessage () {
        
        //sendButton.isEnabled = false
        
        if messageTextViewText.leniantValidationOfTextEntered() && inputAccesoryViewMethods.validateTextChange() {
            
            var message = Message()
            message.sender = currentUser.userID
            message.message = messageTextViewText
            message.timestamp = Date()
            //message.readBy = [currentUser.userID]
            
            if let conversation = conversationID {
                
                firebaseMessaging.sendPersonalMessage(conversationID: conversation, message) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        //self.messageSent()
                        
                        self.inputAccesoryViewMethods.messageSent(messagesCount: self.messages?.count ?? 0)
                    }
                }
            }
            
            else {
                
                //sendButton.isEnabled = true
                
                SVProgressHUD.showError(withStatus: "Sorry, something went wrong")
            }
        }
        
        else {
            
            //sendButton.isEnabled = true
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
    
//    private func messageSent () {
//        
//        //self.sendButton.isEnabled = true
//        self.messageTextView.text = ""
//        
//        //self.resetMessageContainerHeights()
//        inputAccesoryViewMethods.resetMessageContainerHeights()
//        
//        if self.messages?.count ?? 0 > 0 {
//            
//            self.messagesTableView.scrollToRow(at: IndexPath(row: (self.messages!.count * 2) - 1, section: 0), at: .top, animated: true)
//        }
//    }
    
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
    
//    func validateTextChange () -> Bool {
//        
//        if messageTextView.text != "Send a message" {
//            
//            return true
//        }
//        
//        else {
//            
//            if #available(iOS 13.0, *) {
//                
//                if (messageTextView.text == "Send a message") && (messageTextView.textColor != UIColor.placeholderText) {
//                    
//                    return true
//                }
//                
//                else {
//                    
//                    return false
//                }
//                
//            }
//            
//            else {
//                
//                if (messageTextView.text == "Send a message") && (messageTextView.textColor != UIColor.lightGray) {
//                    
//                    return true
//                }
//                
//                else {
//                    
//                    return false
//                }
//            }
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToSendPhotoView" {
            
            let sendPhotoVC = segue.destination as! SendPhotoMessageViewController
            sendPhotoVC.selectedPhoto = selectedPhoto
        }
    }
    
    @objc private func dismissKeyboard () {
        
        //messageTextView.resignFirstResponder()
        messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
    }
}

extension MessagingViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        inputAccesoryViewMethods.textViewBeganEditing(textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        inputAccesoryViewMethods.textViewEndedEditing(textView: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        messageTextViewText = textView.text
        
        inputAccesoryViewMethods.textViewTextChanged(textView: textView, keyboardHeight: keyboardHeight)
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

//            messageInputAccesoryView.size = CGSize(width: 0, height: messageInputAccesoryView.size!.height + 200)
//
//            textViewContainer.constraints.forEach { (constraint) in
//
//                if constraint.firstAttribute == .height {
//
//                    constraint.constant = 237
//                }
//            }
            
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
