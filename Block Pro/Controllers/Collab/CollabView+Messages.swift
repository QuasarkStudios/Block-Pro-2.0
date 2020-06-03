//
//  CollabView+Messages.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/26/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

extension CollabViewController: UITextViewDelegate {
    
    internal func configureTextViewContainer () {
        
        messageInputAccesoryView.addSubview(textViewContainer)
        
        textViewContainer.configureConstraints(true) //Has to be called from here
        
        textViewContainer.addSubview(messageTextView)
        configureMessageTextView()
        
        textViewContainer.addSubview(sendButton)
        configureSendButton()
    }
    
    internal func retrieveMessages () {
        
        guard let collabID = collab?.collabID else { return }
        
        firebaseMessaging.retrieveAllCollabMessages(collabID: collabID) { (messages, error) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            
            else {
                
                self.messages = messages
                self.collabTableView.reloadData()
                
                //self.collabTableView.reloadRows(at: <#T##[IndexPath]#>, with: <#T##UITableView.RowAnimation#>) look into this future sir
            }
        }
    }
    
    internal func determineSeperatorRowHeight (indexPath: IndexPath) -> CGFloat {
        
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Send a message" {
            
            textView.text = ""
            textView.textColor = .black
        }
        
        expandView()
        
        let size = CGSize(width: messageTextView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        messageInputAccesoryView.size = CGSize(width: 0, height: estimatedSize.height + 15) //15 is equal to the  10 point bottom anchor and a 5 point buffer on top
        
        textViewContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = estimatedSize.height
            }
        }
        
        messageTextView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = estimatedSize.height
            }
        }
        
        messageInputAccesoryView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute  == .bottom {
                
                constraint.constant = -10 //Setting the bottom anchor for the textView
            }
        }
        
        UIView.animate(withDuration: 0.3) {

            self.view.layoutIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            
            let endOfTextView = textView.endOfDocument
            textView.selectedTextRange = textView.textRange(from: endOfTextView, to: endOfTextView) //Setting the cursor to the end
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = "Send a message"
            
            if #available(iOS 13.0, *) {
                messageTextView.textColor = .placeholderText
            } else {
                messageTextView.textColor = .lightGray
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: messageTextView.frame.width, height: .infinity)
        var estimatedSize = textView.sizeThatFits(size)
        
        if UIScreen.main.bounds.width == 320.0 {
            
            let newKeyboardHeight = ((keyboardHeight ?? 324) - messageInputAccesoryView.size!.height) + estimatedSize.height
            
            if newKeyboardHeight > (UIScreen.main.bounds.height * 0.7) {
                
                let maxMessageViewHeight = (UIScreen.main.bounds.height * 0.7) - ((keyboardHeight ?? 324) - messageInputAccesoryView.size!.height)
                
                messageTextView.isScrollEnabled = true
                
                messageInputAccesoryView.size = CGSize(width: 0, height: maxMessageViewHeight)
                
                estimatedSize = CGSize(width: 0, height: maxMessageViewHeight - 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top
            }
            
            else {
                
                messageTextView.isScrollEnabled = false
                
                messageInputAccesoryView.size = CGSize(width: 0, height: estimatedSize.height + 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top

            }
        }
        
        else {
            
            let newKeyboardHeight = ((keyboardHeight ?? 400) - messageInputAccesoryView.size!.height) + estimatedSize.height
            
            if newKeyboardHeight > (UIScreen.main.bounds.height * 0.7) {
                
                let maxMessageViewHeight = (UIScreen.main.bounds.height * 0.7) - ((keyboardHeight ?? 400) - messageInputAccesoryView.size!.height)
                
                messageTextView.isScrollEnabled = true
                
                messageInputAccesoryView.size = CGSize(width: 0, height: maxMessageViewHeight)
                
                estimatedSize = CGSize(width: 0, height: maxMessageViewHeight - 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top
            }
            
            else {
                
                messageTextView.isScrollEnabled = false

                messageInputAccesoryView.size = CGSize(width: 0, height: estimatedSize.height + 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top
            }
        }

        textViewContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = estimatedSize.height
            }
        }
        
        messageTextView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = estimatedSize.height
            }
        }
    }
    
    private func configureMessageTextView () {
        
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
        messageTextView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor, constant: 10),
        messageTextView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: -55),
        messageTextView.heightAnchor.constraint(equalToConstant: 35),
        messageTextView.centerYAnchor.constraint(equalTo: textViewContainer.centerYAnchor)
            
        ].forEach { $0.isActive = true }
        
        messageTextView.delegate = self
        messageTextView.font = UIFont(name: "Poppins-SemiBold", size: 14)
        messageTextView.text = "Send a message"
        messageTextView.isScrollEnabled = false
        messageTextView.showsVerticalScrollIndicator = false

        if #available(iOS 13.0, *) {
            messageTextView.textColor = .placeholderText
        } else {
            messageTextView.textColor = .lightGray
        }
    }
    
    private func configureSendButton () {
        
         sendButton.translatesAutoresizingMaskIntoConstraints = false
         
         [
             
         sendButton.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: -10),
         sendButton.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor, constant: -8),
         sendButton.widthAnchor.constraint(equalToConstant: 25),
         sendButton.heightAnchor.constraint(equalToConstant: 25)
             
         ].forEach { $0.isActive = true }
        
         sendButton.setBackgroundImage(UIImage(named: "paper_plane"), for: .normal)
         sendButton.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 8)
         sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    @objc internal func keyboardBeingPresented (notification: NSNotification) {
        
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        
        keyboardHeight = keyboardFrame.cgRectValue.height
            
        let bottomInset: CGFloat = keyboardHeight! - messageInputAccesoryView.configureSize().height
        
        collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    
        if messages?.count ?? 0 > 0 && selectedTab == "Messages" {

            collabTableView.scrollToRow(at: IndexPath(row: ((messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
        }
    }

    
    @objc internal func keyboardBeingDismissed (notification: NSNotification) {
        
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSValue

        keyboardHeight = keyboardFrame.cgRectValue.height
        collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        if messages?.count ?? 0 > 0 {
            
            collabTableView.scrollToRow(at: IndexPath(row: ((messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
        }
        
        if messageTextView.text == "" || messageTextView.text == "Send a message" {
            
            collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            messageInputAccesoryView.size = messageInputAccesoryView.configureSize()
        }
        
        else {
            
            let messageViewHeight = (textViewContainer.frame.height + abs(setTextViewBottomAnchor())) + 5
            
            collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: messageViewHeight, right: 0)
            collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: messageViewHeight, right: 0)
            
            messageInputAccesoryView.size = CGSize(width: 0, height: messageViewHeight)
        }
        
        messageInputAccesoryView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .bottom {
                
                constraint.constant = setTextViewBottomAnchor()
            }
        }
        
        UIView.animate(withDuration: keyboardAnimationDuration as! Double) {

            self.view.layoutIfNeeded()
        }
    }
    
    private func resetMessageContainerHeights () {

        textViewContainer.constraints.forEach { (constraint) in

            if constraint.firstAttribute == .height {

                constraint.constant = 35
            }
        }

        messageTextView.constraints.forEach { (constraint) in

            if constraint.firstAttribute == .height {

                constraint.constant = 35
            }
        }
    }
    
    private func setTextViewBottomAnchor () -> CGFloat {
        
        //iPhone 11 Pro Max & iPhone 11
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            return -36
        }
            
        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            return -36
        }
            
        //Every other iPhone
        else {

            return -10
        }
    }
    
    func validateTextChange () -> Bool {
        
        if messageTextView.text != "Send a message" {
            
            return true
        }
        
        else {
            
            if #available(iOS 13.0, *) {
                
                if (messageTextView.text == "Send a message") && (messageTextView.textColor != UIColor.placeholderText) {
                    
                    return true
                }
                
                else {
                    
                    return false
                }
                
            }
            
            else {
                
                if (messageTextView.text == "Send a message") && (messageTextView.textColor != UIColor.lightGray) {
                    
                    return true
                }
                
                else {
                    
                    return false
                }
            }
        }
    }
    
    @objc internal func sendMessage () {
        
        sendButton.isEnabled = false
        
        if messageTextView.text.leniantValidationOfTextEntered() && validateTextChange() {
            
            var message = Message()
            message.sender = currentUser.userID
            message.message = messageTextView.text
            message.timestamp = Date()
            
            if let collabID = collab?.collabID {
                
                firebaseMessaging.sendCollabMessage(collabID: collabID, message) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        self.sendButton.isEnabled = true
                        self.messageTextView.text = ""
                        
                        self.resetMessageContainerHeights()
                        
                        if self.messages?.count ?? 0 > 0 {
                            
                            self.collabTableView.scrollToRow(at: IndexPath(row: (self.messages!.count * 2) - 1, section: 0), at: .top, animated: true)
                        }
                    }
                }
            }
            
            else {
                
                self.sendButton.isEnabled = true
                
                SVProgressHUD.showError(withStatus: "Sorry, something went wrong")
            }
        }
        
        //Text wasn't entered properly
        else {
            
            self.sendButton.isEnabled = true
        }
    }
}
