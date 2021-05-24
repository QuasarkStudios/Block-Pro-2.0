//
//  CollabView+Messages2.swift
//  Block Pro
//
//  Created by Nimat Azeez on 9/8/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

extension CollabViewController: UITextViewDelegate {
    
    //MARK: - Retrieve Messages
    
    func retrieveMessages () {
        
        guard let collabID = collab?.collabID else { return }
         
            firebaseMessaging.retrieveAllCollabMessages(collabID: collabID) { [weak self] (messages, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    if messages.count == 0 {
                        
                    }
                    
                    else {
                        
                        self?.collabNavigationView.messagesAnimationView.removeNoMessagesAnimation()
                        
                        for message in messages {
                            
                            if self?.messages == nil {
                                
                                self?.messages = []
                            }
                            
                            if !(self?.messages?.contains(where: { $0.messageID == message.messageID }) ?? false) {
                                
                                self?.messages?.append(message)
                            }
                        }
                        
                        self?.messages = self?.messages?.sorted(by: { $0.timestamp < $1.timestamp })
                        
                        if self?.selectedTab == "Messages" {
                            
                            self?.messagingMethods.reloadTableView(messages: self?.messages)
                        }
                    }
                }
            }
    }
    
    
    //MARK: - Text View Did Being Editing
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        expandView()
        
        inputAccesoryViewMethods.textViewBeganEditing(textView: textView, keyboardHeight: keyboardHeight)
    }
    
    
    //MARK: - Text View Did Change
    
    func textViewDidChange(_ textView: UITextView) {
        
        messageTextViewText = textView.text
        
        inputAccesoryViewMethods.textViewTextChanged(textView: textView, keyboardHeight: keyboardHeight)
    }
    
    //MARK: - Text View Did End Editing
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        inputAccesoryViewMethods.textViewEndedEditing(textView: textView)
    }
    
    
    //MARK: - Keyboard Being Presented
    
    @objc internal func keyboardBeingPresented (notification: NSNotification) {
        
        //Required for smoothness
        if !(imageViewBeingZoomed ?? false) && messageInputAccesoryView.textViewContainer.messageTextView.isFirstResponder {
            
            inputAccesoryViewMethods?.keyboardBeingPresented(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: messages?.count ?? 0)
        }
    }
    
    
    //MARK: - Keyboard Being Dismissed
    
    @objc internal func keyboardBeingDismissed (notification: NSNotification) {
        
        //keyboardWillHide notification stopped firing so this is the fix
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        
        //Required for smoothness
        if !(imageViewBeingZoomed ?? false) && keyboardFrame.cgRectValue.height < 200 {
            
            inputAccesoryViewMethods?.keyboardBeingDismissed(notification: notification, keyboardHeight: &keyboardHeight, messagesCount: messages?.count ?? 0, textViewText: messageTextViewText)
        }
    }
    
    //MARK: - Save Message Draft Function
    
    @objc internal func saveMessageDraft () {
        
        if messageTextViewText.leniantValidationOfTextEntered() && inputAccesoryViewMethods.validateTextChange()/* && !infoViewBeingPresented */ {
            
            let defaults = UserDefaults.standard
            
            if let collabID = collab?.collabID {
                
                defaults.setValue(messageTextViewText, forKey: "messageDraftForConvo: " + collabID)
            }
        }
    }
    
    
    //MARK: - Retrieve Message Draft Function
    
    internal func retrieveMessageDraft () {
        
        let defaults = UserDefaults.standard
        
        if let collabID = collab?.collabID {
            
            if let messageDraft = defaults.value(forKey: "messageDraftForConvo: " + collabID) as? String {
                
                messageInputAccesoryView.textViewContainer.messageTextView.text = messageDraft
                messageInputAccesoryView.textViewContainer.messageTextView.textColor = inputAccesoryViewMethods.textViewTextColor
                messageTextViewText = messageDraft
                
                defaults.setValue(nil, forKey: "messageDraftForConvo: " + collabID)
            }
        }
    }
    
    
    //MARK: - Send Message
    
    @objc internal func sendMessage () {
        
        let sendButton = messageInputAccesoryView.textViewContainer.sendButton
        sendButton.isEnabled = false
        
        if messageTextViewText.leniantValidationOfTextEntered() && inputAccesoryViewMethods.validateTextChange() {
            
            var message = Message()
            message.sender = currentUser.userID
            message.message = messageTextViewText
            message.timestamp = Date()
            
            if let collab = collab?.collabID {
                
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
    
    //MARK: - Add Attachment Function
    
    @objc internal func addAttachment () {
        
        expandView()
        
        alertTracker = "attachmentAlert"
        
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
}


//MARK: - Reconfigure CollabView from Send Photo VC Extension

extension CollabViewController: ReconfigureCollabViewFromSendPhotoVC {
    
    func reconfigureView() {
        
        addObservors()
        
        self.becomeFirstResponder()
    }
}


//MARK: - Schedule Protocol Extension

extension CollabViewController: ScheduleProtocol {
    
    func moveToScheduleView(message: Message) {
        
        let scheduleVC = ScheduleMessageViewController()
        scheduleVC.message = message
        scheduleVC.members = collab?.historicMembers
        
        let scheduleNavigationController = UINavigationController(rootViewController: scheduleVC)
        
        self.present(scheduleNavigationController, animated: true)
    }
}
