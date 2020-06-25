//
//  InputAccesoryViewMethods.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class InputAccesoryViewMethods {
    
    var accesoryView: InputAccesoryView
    
    var textViewContainer: MessageTextViewContainer
    
    var textViewPlaceholderText: String
    
    var tableView: UITableView?
    
    init(accesoryView: InputAccesoryView, textViewPlaceholderText: String, tableView: UITableView?) {
        
        self.accesoryView = accesoryView
        
        self.textViewContainer = accesoryView.textViewContainer
        
        self.textViewPlaceholderText = textViewPlaceholderText
        
        self.tableView = tableView
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func keyboardBeingPresented (notification: NSNotification, keyboardHeight: inout CGFloat?, messagesCount: Int, topBarHeight: CGFloat) {
        
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        
        keyboardHeight = keyboardFrame.cgRectValue.height
            
        let bottomInset: CGFloat = keyboardHeight! - (accesoryView.configureSize().height - topBarHeight)
        
        tableView?.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: bottomInset, right: 0)
        tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: bottomInset, right: 0)
    
        if messagesCount > 0 {

            tableView?.scrollToRow(at: IndexPath(row: (messagesCount * 2) - 1, section: 0), at: .top, animated: true)
        }
    }
    
    func keyboardBeingDismissed (notification: NSNotification, keyboardHeight: inout CGFloat?, messagesCount: Int, textViewText: String) {
        
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSValue
        
        keyboardHeight = keyboardFrame.cgRectValue.height
        
        tableView?.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        
        if messagesCount > 0 {
            
            tableView?.scrollToRow(at: IndexPath(row: (messagesCount * 2) - 1, section: 0), at: .top, animated: true)
        }
        
        if textViewText == "" || textViewText == textViewPlaceholderText/*"Send a message"*/ {
            
            tableView?.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
            tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
            
            accesoryView.size = accesoryView.configureSize()
        }
        
        else {
            
            let messageViewHeight = (textViewContainer.frame.height + abs(setTextViewBottomAnchor())) + 5
            
            tableView?.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: messageViewHeight, right: 0)
            tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: messageViewHeight, right: 0)
            
            accesoryView.size = CGSize(width: 0, height: messageViewHeight)
        }
        
        accesoryView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .bottom {
                
                if (constraint.firstItem as? MessageTextViewContainer) != nil {
                    
                    constraint.constant = setTextViewBottomAnchor()
                }
            }
        }
        
        UIView.animate(withDuration: keyboardAnimationDuration as! Double) {
            
            self.accesoryView.layoutIfNeeded()
        }
    }
    
    func textViewBeganEditing (textView: UITextView) {
        
        if textView.text == textViewPlaceholderText/*"Send a message"*/ {
            
            textView.text = ""
            textView.textColor = .black
        }
        
        #warning("fix bug that causes the twxt view to be too larger than the max height when lots of text we=as previously entered, all code needed for this fix should be in textviewtextchanged func below")
        
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        accesoryView.size = CGSize(width: 0, height: estimatedSize.height + 15) //15 is equal to the  10 point bottom anchor and a 5 point buffer on top
        
        textViewContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = estimatedSize.height
            }
        }
        
//        messageTextView.constraints.forEach { (constraint) in
//
//            if constraint.firstAttribute == .height {
//
//                constraint.constant = estimatedSize.height
//            }
//        }
        
        accesoryView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute  == .bottom {
                
                if (constraint.firstItem as? MessageTextViewContainer) != nil {
                    
                    constraint.constant = -10 //Setting the bottom anchor for the textView
                }
                
            }
        }
        
        UIView.animate(withDuration: 0.3) {

            self.accesoryView.layoutIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            
            let endOfTextView = textView.endOfDocument
            textView.selectedTextRange = textView.textRange(from: endOfTextView, to: endOfTextView) //Setting the cursor to the end
        }
    }
    
    func textViewTextChanged (textView: UITextView, keyboardHeight: CGFloat?) {
        
//        let size = CGSize(width: messageTextView.frame.width, height: .infinity)
        let size = CGSize(width: textView.frame.width, height: .infinity)
        var estimatedSize = textView.sizeThatFits(size)
        
        if UIScreen.main.bounds.width == 320.0 {
            
            let newKeyboardHeight = ((keyboardHeight ?? 324) - accesoryView.size!.height) + estimatedSize.height
            
            if newKeyboardHeight > (UIScreen.main.bounds.height * 0.7) {
                
                let maxMessageViewHeight = (UIScreen.main.bounds.height * 0.7) - ((keyboardHeight ?? 324) - accesoryView.size!.height)
                
//                messageTextView.isScrollEnabled = true
                textView.isScrollEnabled = true
                
                accesoryView.size = CGSize(width: 0, height: maxMessageViewHeight)
                
                estimatedSize = CGSize(width: 0, height: maxMessageViewHeight - 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top
            }
            
            else {
                
//                messageTextView.isScrollEnabled = false
                textView.isScrollEnabled = false
                
                accesoryView.size = CGSize(width: 0, height: estimatedSize.height + 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top

            }
        }
        
        else {
            
            let newKeyboardHeight = ((keyboardHeight ?? 400) - accesoryView.size!.height) + estimatedSize.height
            
            if newKeyboardHeight > (UIScreen.main.bounds.height * 0.7) {
                
                let maxMessageViewHeight = (UIScreen.main.bounds.height * 0.7) - ((keyboardHeight ?? 400) - accesoryView.size!.height)
                
//                messageTextView.isScrollEnabled = true
                textView.isScrollEnabled = true
                
                accesoryView.size = CGSize(width: 0, height: maxMessageViewHeight)
                
                estimatedSize = CGSize(width: 0, height: maxMessageViewHeight - 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top
            }
            
            else {
                
//                messageTextView.isScrollEnabled = false
                textView.isScrollEnabled = false

                accesoryView.size = CGSize(width: 0, height: estimatedSize.height + 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top
            }
        }

        textViewContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = estimatedSize.height
            }
        }
        
//        textView.constraints.forEach { (constraint) in
//
//            if constraint.firstAttribute == .height {
//
//                constraint.constant = estimatedSize.height
//            }
//        }
    }
    
    func textViewEndedEditing (textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = textViewPlaceholderText//"Send a message"
            
            if #available(iOS 13.0, *) {
                textView.textColor = .placeholderText
            } else {
                textView.textColor = .lightGray
            }
        }
    }
    
    func validateTextChange () -> Bool {
        
        if textViewContainer.messageTextView.text != textViewPlaceholderText/*"Send a message"*/ {
            
            return true
        }
        
        else {
            
            if #available(iOS 13.0, *) {
                
                if (textViewContainer.messageTextView.text == textViewPlaceholderText/*"Send a message"*/) && (textViewContainer.messageTextView.textColor != UIColor.placeholderText) {
                    
                    return true
                }
                
                else {
                    
                    return false
                }
                
            }
            
            else {
                
                if (textViewContainer.messageTextView.text == textViewPlaceholderText/*"Send a message"*/) && (textViewContainer.messageTextView.textColor != UIColor.lightGray) {
                    
                    return true
                }
                
                else {
                    
                    return false
                }
            }
        }
    }
    
    func messageSent (messagesCount: Int = 0) {
        
        //self.sendButton.isEnabled = true
        textViewContainer.messageTextView.text = ""
        textViewBeganEditing(textView: textViewContainer.messageTextView)
        
        resetMessageContainerHeights()
        
        if messagesCount > 0 {
            
            //tableView?.scrollToRow(at: IndexPath(row: (messagesCount * 2) - 1, section: 0), at: .top, animated: true)
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
    
    func resetMessageContainerHeights () {

        textViewContainer.constraints.forEach { (constraint) in

            if constraint.firstAttribute == .height {

                constraint.constant = 37//35
            }
        }

//        messageTextView.constraints.forEach { (constraint) in
//
//            if constraint.firstAttribute == .height {
//
//                constraint.constant = 37//35
//            }
//        }
    }
}
