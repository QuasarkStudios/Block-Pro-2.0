//
//  SendPhotoMessageViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ReconfigureMessagingViewFromSendPhotoVC: AnyObject {
    
    func reconfigureView ()
}

protocol ReconfigureCollabViewFromSendPhotoVC: AnyObject {
    
    func reconfigureView ()
}

class SendPhotoMessageViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var imageViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomAnchor: NSLayoutConstraint!
    
    let messageInputAccesoryView = InputAccesoryView(textViewPlaceholderText: "Add a caption", textViewPlaceholderTextColor: .white, showsAddButton: false)
    var inputAccesoryViewMethods: InputAccesoryViewMethods!
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseMessaging = FirebaseMessaging()
    
    var personalConversationID: String?
    var collabConversationID: String?
    
    var selectedPhoto: UIImage?
    
    var keyboardHeight: CGFloat?
    
    var messageTextViewText: String = ""
    
    weak var reconfigureMessagingViewDelegate: ReconfigureMessagingViewFromSendPhotoVC?
    weak var reconfigureCollabViewDelegate: ReconfigureCollabViewFromSendPhotoVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white)
        
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        
        photoImageView.image = selectedPhoto
        imageViewBottomAnchor.constant = messageInputAccesoryView.configureSize().height //Setting the bottom anchor of the imageView to be at the top of the messageInputAccesoryView
        
        configureInputAccesoryView()
        
        configureGestureRecognizors()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObservors()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
    
    
    //MARK: - Configure Input Accesory View
    
    private func configureInputAccesoryView () {
        
        messageInputAccesoryView.parentViewController = self
        
        //Tweaking the appearance of the inputAccesoryView
        messageInputAccesoryView.backgroundColor = .clear
        messageInputAccesoryView.textViewContainer.backgroundColor = .clear
        messageInputAccesoryView.textViewContainer.messageTextView.backgroundColor = .clear
        messageInputAccesoryView.textViewContainer.messageTextView.textColor = .white
        
        messageInputAccesoryView.textViewContainer.sendButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 4, bottom: 3, right: 3)
        messageInputAccesoryView.textViewContainer.sendButton.backgroundColor = .clear
        messageInputAccesoryView.textViewContainer.sendButton.tintColor = .white
        
        inputAccesoryViewMethods = InputAccesoryViewMethods(accesoryView: messageInputAccesoryView, textViewPlaceholderText: "Add a caption", textViewPlaceholderTextColor: .white, textViewTextColor: .white, tableView: nil)
    }
    
    
    //MARK: - Configure Gesture Recognizors
    
    private func configureGestureRecognizors () {
        
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    
    //MARK: - Add and Remove Observor Functions
    
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
    
    
    //MARK: - Keyboard Notification Handlers
    
    @objc internal func keyboardBeingPresented (notification: NSNotification) {
        
        inputAccesoryViewMethods.keyboardBeingPresented(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: 0)
    }

    
    @objc internal func keyboardBeingDismissed (notification: NSNotification) {

        inputAccesoryViewMethods.keyboardBeingDismissed(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: 0, textViewText: messageTextViewText)
    }
    
    
    //MARK: - Animate ImageView Function
    
    private func animateImageView (up: Bool) {
        
        if up {
            
            self.imageViewTopAnchor.constant = -200
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
                
                self.photoImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.photoImageView.alpha = 0.7
            })
        }
        
        else {
            
            self.imageViewTopAnchor.constant = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
                
                self.photoImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.photoImageView.alpha = 1
                
            })
        }
    }
    
    
    //MARK: - User Activity Functions
    
    @objc private func setUserActiveStatus () {
        
        if let conversationID = personalConversationID {
            
            firebaseMessaging.setActivityStatus(conversationID: conversationID, "now")
        }
        
        else if let collabID = collabConversationID {
            
            firebaseMessaging.setActivityStatus(collabID: collabID, "now")
        }
    }
    
    @objc private func setUserInactiveStatus () {
        
        if let conversationID = personalConversationID {
            
            firebaseMessaging.setActivityStatus(conversationID: conversationID, Date())
        }
        
        else if let collabID = collabConversationID {
            
            firebaseMessaging.setActivityStatus(collabID: collabID, Date())
        }
    }
    
    
    //MARK: - Send Message Function
    
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
        
        if let conversationID = personalConversationID {
            
            firebaseMessaging.sendPersonalMessage(conversationID: conversationID, message) { (error) in

                if error != nil {

                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }

                else {

                    SVProgressHUD.dismiss()
                    
                    self.reconfigureMessagingViewDelegate?.reconfigureView()
                    
                    self.dismiss(animated: true)
                }
            }
        }
            
        else if let collabID = collabConversationID {
            
            firebaseMessaging.sendCollabMessage(collabID: collabID, message) { (error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    SVProgressHUD.dismiss()
                    
                    self.reconfigureMessagingViewDelegate?.reconfigureView()
                    self.reconfigureCollabViewDelegate?.reconfigureView()
                    
                    self.dismiss(animated: true)
                }
            }
        }

        else {

            sendButton.isEnabled = true

            SVProgressHUD.showError(withStatus: "Sorry, something went wrong")
        }
    }
    
    
    //MARK: - Exit Button Function
    
    @IBAction func exitButton(_ sender: Any) {
        
        reconfigureMessagingViewDelegate?.reconfigureView()
        reconfigureCollabViewDelegate?.reconfigureView()
        
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Dismiss Keyboard Function
    
    @objc private func dismissKeyboard () {
        
        messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
    }
}

//MARK: - UITextViewDelegate Extension

extension SendPhotoMessageViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        inputAccesoryViewMethods.textViewBeganEditing(textView: textView, keyboardHeight: keyboardHeight)
        
        animateImageView(up: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        messageTextViewText = textView.text
        
        inputAccesoryViewMethods.textViewTextChanged(textView: textView, keyboardHeight: keyboardHeight)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        inputAccesoryViewMethods.textViewEndedEditing(textView: textView)
        
        animateImageView(up: false)
    }
}
