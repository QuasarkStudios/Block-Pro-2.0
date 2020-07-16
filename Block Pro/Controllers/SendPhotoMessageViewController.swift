//
//  SendPhotoMessageViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ReconfigureView: AnyObject {
    
    func reconfigureView ()
}

class SendPhotoMessageViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var photoImageView: UIImageView!
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseMessaging = FirebaseMessaging()
    
    var personalConversation: Conversation?
    var collabConversation: Conversation?
    
    var selectedPhoto: UIImage?
    
    weak var reconfigureViewDelegate: ReconfigureView?
    
    let messageInputAccesoryView = InputAccesoryView(showsAddButton: false, textViewPlaceholderText: "Add a caption")
    var inputAccesoryViewMethods: InputAccesoryViewMethods!
    
    var messageTextViewText: String = ""
    
    var keyboardHeight: CGFloat?
    
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
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }

        navBar.configureNavBar()
        //navBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white)
        
        photoImageView.image = selectedPhoto ?? nil
        
        configureTextViewContainer()
        
        configureGestureRecognizors()
        
        //messageInputAccesoryView.backgroundColor = UIColor(hexString: "000000", withAlpha: 0.9)
        inputAccesoryViewMethods = InputAccesoryViewMethods(accesoryView: messageInputAccesoryView, textViewPlaceholderText: "Add a caption", tableView: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addObservors()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        //readMessages()
        
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
    
    private func configureTextViewContainer () {
        
        messageInputAccesoryView.parentViewController = self
        messageInputAccesoryView.isHidden = false
        messageInputAccesoryView.alpha = 1
    }
    
    private func configureGestureRecognizors () {
        
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    private func addObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUserActiveStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUserInactiveStatus), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendMessage), name: .userDidSendMessage, object: nil)
    }
    
    private func removeObservors () {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc internal func keyboardBeingPresented (notification: NSNotification) {
        
        inputAccesoryViewMethods.keyboardBeingPresented(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: 0, topBarHeight: topBarHeight)
    }

    
    @objc internal func keyboardBeingDismissed (notification: NSNotification) {

        inputAccesoryViewMethods.keyboardBeingDismissed(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: 0, textViewText: messageTextViewText)

    }
    
    @objc private func setUserActiveStatus () {
        
        if let conversation = personalConversation {
            
            firebaseMessaging.setActivityStatus(conversationID: conversation.conversationID, "now")
        }
        
        else if let collab = collabConversation {
            
            firebaseMessaging.setActivityStatus(collabID: collab.conversationID, "now")
        }
    }
    
    @objc private func setUserInactiveStatus () {
        
        if let conversation = personalConversation {
            
            firebaseMessaging.setActivityStatus(conversationID: conversation.conversationID, Date())
        }
        
        else if let collab = collabConversation {
            
            firebaseMessaging.setActivityStatus(collabID: collab.conversationID, Date())
        }
    }
    
    @objc private func sendMessage () {
        
        SVProgressHUD.show()
        
        let sendButton = messageInputAccesoryView.textViewContainer.sendButton
        sendButton.isEnabled = false

        var message = Message()
        message.sender = currentUser.userID
        message.timestamp = Date()
        
        let photoDict: [String : Any] = ["photoID" : UUID().uuidString, "photo" : selectedPhoto as Any, "photoWidth" : selectedPhoto?.size.width as Any, "photoHeight" : selectedPhoto?.size.height as Any]
        message.messagePhoto = photoDict
        
        if messageTextViewText.leniantValidationOfTextEntered() && inputAccesoryViewMethods.validateTextChange() {

            message.message = messageTextViewText
        }
        
        if let conversationID = personalConversation?.conversationID {
            
            firebaseMessaging.sendPersonalMessage(conversationID: conversationID, message) { (error) in

                if error != nil {

                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }

                else {

                    SVProgressHUD.dismiss()
                    
                    self.reconfigureViewDelegate?.reconfigureView()
                    
                    self.dismiss(animated: true)
                }
            }
        }
            
        else if let collabID = collabConversation?.conversationID {
            
            firebaseMessaging.sendCollabMessage(collabID: collabID, message) { (error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    SVProgressHUD.dismiss()
                    
                    self.reconfigureViewDelegate?.reconfigureView()
                    
                    self.dismiss(animated: true)
                }
            }
        }

        else {

            sendButton.isEnabled = true

            SVProgressHUD.showError(withStatus: "Sorry, something went wrong")
        }
    }
    
    @IBAction func exitButton(_ sender: Any) {
        
        reconfigureViewDelegate?.reconfigureView()
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard () {
        
        messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
    }
}

extension SendPhotoMessageViewController: UITextViewDelegate {
    
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
