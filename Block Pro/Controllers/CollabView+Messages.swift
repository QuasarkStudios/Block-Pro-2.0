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
        
        messageViewContainer.alpha = 0
        messageViewContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        messageViewContainer.backgroundColor = .white
        messageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        messageViewContainer.addSubview(textViewContainer)
        
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [

        textViewContainer.bottomAnchor.constraint(equalTo: messageViewContainer.bottomAnchor, constant: -26),
        textViewContainer.leadingAnchor.constraint(equalTo: messageViewContainer.leadingAnchor, constant: 23),
        textViewContainer.trailingAnchor.constraint(equalTo: messageViewContainer.trailingAnchor, constant: -23),
        textViewContainer.heightAnchor.constraint(equalToConstant: 34)
            
        ].forEach { $0.isActive = true }
        
        
        textViewContainer.backgroundColor = .white
        textViewContainer.layer.cornerRadius = 16
        textViewContainer.clipsToBounds = true
        textViewContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        textViewContainer.layer.borderWidth = 1
        
        textViewContainer.addSubview(messageTextView)
        
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        
        [

        messageTextView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor, constant: 10),
        messageTextView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: -55),
        messageTextView.heightAnchor.constraint(equalToConstant: 34),
        messageTextView.centerYAnchor.constraint(equalTo: textViewContainer.centerYAnchor)
            

        ].forEach { $0.isActive = true }
        
        messageTextView.delegate = self
        messageTextView.font = UIFont(name: "Poppins-SemiBold", size: 13)
        messageTextView.text = "Send a message"
        messageTextView.isScrollEnabled = false
        
        if #available(iOS 13.0, *) {
            messageTextView.textColor = .placeholderText
        } else {
            messageTextView.textColor = .lightGray
        }
        
        textViewContainer.addSubview(sendButton)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
        sendButton.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: -10),
        sendButton.centerYAnchor.constraint(equalTo: textViewContainer.centerYAnchor),
        sendButton.widthAnchor.constraint(equalToConstant: 25),
        sendButton.heightAnchor.constraint(equalToConstant: 25)
            
        ].forEach { $0.isActive = true }
       
        sendButton.setBackgroundImage(UIImage(named: "paper_plane"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    internal func retrieveMessages () {
        
        guard let collabID = collab?.collabID else { return }
        
        firebaseCollab.retrieveMessages(collabID: collabID) { (messages, error) in
            
            if error != nil {
                
                // progress stuff once xcode stops acting like a fucking bitch
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
            
            expandView()
            viewExpanded()
        }
        
        messageViewContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute  == .bottom {
                
                constraint.constant = -10
            }
        }
        
        UIView.animate(withDuration: 0.3) {

            self.view.layoutIfNeeded()
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
            
            if (keyboardHeight ?? 324) + estimatedSize.height > (UIScreen.main.bounds.height - 66) {
                
                estimatedSize.height = UIScreen.main.bounds.height - ((keyboardHeight ?? 324) + 66)
                messageTextView.isScrollEnabled = true
            }
            
            else {
                
                messageTextView.isScrollEnabled = false
            }
            
            //tableViewBottomAnchor.constant = (keyboardHeight ?? 324) + (estimatedSize.height - 34)
        }
        
        else {
            
            if (keyboardHeight ?? 400) + estimatedSize.height > (UIScreen.main.bounds.height - 66) {
                
                estimatedSize.height = (UIScreen.main.bounds.height - ((keyboardHeight ?? 400) + 66))
                messageTextView.isScrollEnabled = true
            }
            
            else {
                
                messageTextView.isScrollEnabled = false
            }
            
            //tableViewBottomAnchor.constant = (keyboardHeight ?? 400) + (estimatedSize.height - 34)
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
    
    @objc internal func keyboardBeingPresented (notification: NSNotification) {
            
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSValue

        //tableViewBottomAnchor.constant = keyboardFrame.cgRectValue.height
        keyboardHeight = keyboardFrame.cgRectValue.height
        collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight! - 70, right: 0)
        collabTableView.scrollToRow(at: IndexPath(row: (messages?.count ?? 0) - 1, section: 0), at: .top, animated: true)
        
        UIView.animate(withDuration: keyboardAnimationDuration as! Double) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc internal func keyboardBeingDismissed (notification: NSNotification) {
        
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSValue

        //tableViewBottomAnchor.constant = keyboardFrame.cgRectValue.height

        keyboardHeight = keyboardFrame.cgRectValue.height
        collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collabTableView.scrollToRow(at: IndexPath(row: (messages?.count ?? 0) - 1, section: 0), at: .top, animated: true)
        
        messageViewContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .bottom {
                
                constraint.constant = -36
            }
        }
        
        UIView.animate(withDuration: keyboardAnimationDuration as! Double) {

            self.view.layoutIfNeeded()
        }
    }
    
    internal func resetMessageContainerHeights () {
        
        textViewContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 34
            }
        }
        
        messageTextView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 34
            }
        }
    }
    
    @objc internal func sendMessage () {
        
        sendButton.isEnabled = false
        
        if messageTextView.text.leniantValidationOfTextEntered() {
            
            var message = Message()
            message.sender = currentUser.userID
            message.message = messageTextView.text
            message.timestamp = Date()
            
            if let collabID = collab?.collabID {
                
                firebaseCollab.sendMessage(collabID: collabID, message) { (error) in
                    
                    if error != nil {
                        
                        // do some stuff here
                    }
                    
                    else {
                        
                        self.sendButton.isEnabled = true
                        self.messageTextView.text = ""
                        
                        
                        self.resetMessageContainerHeights()
                    }
                }
            }
            
            else {
                
                //present error message or sumn
            }
            
            
        }
    }
}
