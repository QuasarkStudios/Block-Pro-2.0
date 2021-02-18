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
    var textViewPlaceholderTextColor: UIColor
    var textViewTextColor: UIColor
    
    var tableView: UITableView?
    
    init(accesoryView: InputAccesoryView, textViewPlaceholderText: String, textViewPlaceholderTextColor: UIColor? = nil, textViewTextColor: UIColor = .black, tableView: UITableView?) {
        
        self.accesoryView = accesoryView
        
        self.textViewContainer = accesoryView.textViewContainer
        
        self.textViewPlaceholderText = textViewPlaceholderText
        
        if let textColor = textViewPlaceholderTextColor {
            
            self.textViewPlaceholderTextColor = textColor
        }
        
        else {
            
            if #available(iOS 13.0, *) {
                
                self.textViewPlaceholderTextColor = .placeholderText
            }
            
            else {
                
                self.textViewPlaceholderTextColor = .lightGray
            }
        }
        
        self.textViewTextColor = textViewTextColor
        
        self.tableView = tableView
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func keyboardBeingPresented (notification: NSNotification, keyboardHeight: inout CGFloat?, messagesCount: Int) {
        
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        keyboardHeight = keyboardFrame.cgRectValue.height
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight!, right: 0)
        tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight!, right: 0)
    
        if messagesCount > 0 {

            tableView?.scrollToRow(at: IndexPath(row: (messagesCount * 2) - 1, section: 0), at: .top, animated: true)
        }
    }
    
    func keyboardBeingDismissed (notification: NSNotification, keyboardHeight: inout CGFloat?, messagesCount: Int, textViewText: String) {
        
        let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSValue

        let messageViewHeight = (textViewContainer.frame.height + abs(setTextViewBottomAnchor())) + 5
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: messageViewHeight + 5, right: 0)
        tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: messageViewHeight, right: 0)
        
        accesoryView.size = CGSize(width: 0, height: messageViewHeight)
        
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
    
    func textViewBeganEditing (textView: UITextView, keyboardHeight: CGFloat?) {
        
        if textView.text == textViewPlaceholderText {
            
            textView.text = ""
            textView.textColor = textViewTextColor
        }
        
        let size = CGSize(width: textView.frame.width, height: .infinity)
        var estimatedSize = textView.sizeThatFits(size)
        
        if UIScreen.main.bounds.width == 320.0 {
            
            let newKeyboardHeight = ((keyboardHeight ?? 324) - accesoryView.size!.height) + estimatedSize.height
            
            if newKeyboardHeight > (UIScreen.main.bounds.height * 0.7) {
                
                let maxMessageViewHeight = (UIScreen.main.bounds.height * 0.7) - ((keyboardHeight ?? 324) - accesoryView.size!.height)
                
                textView.isScrollEnabled = true
                
                accesoryView.size = CGSize(width: 0, height: maxMessageViewHeight)
                
                estimatedSize = CGSize(width: 0, height: maxMessageViewHeight - 15)
            }
            
            else {
                
                textView.isScrollEnabled = false
                
                accesoryView.size = CGSize(width: 0, height: estimatedSize.height + 15)
            }
        }
        
        else {
            
            let newKeyboardHeight = ((keyboardHeight ?? 400) - accesoryView.size!.height) + estimatedSize.height
            
            if newKeyboardHeight > (UIScreen.main.bounds.height * 0.7) {
                
                let maxMessageViewHeight = (UIScreen.main.bounds.height * 0.7) - ((keyboardHeight ?? 400) - accesoryView.size!.height)
                
                textView.isScrollEnabled = true
                
                accesoryView.size = CGSize(width: 0, height: maxMessageViewHeight)
                
                estimatedSize = CGSize(width: 0, height: maxMessageViewHeight - 15)
            }
            
            else {
                
                textView.isScrollEnabled = false
                
                accesoryView.size = CGSize(width: 0, height: estimatedSize.height + 15)
            }
        }
        
        accesoryView.size = CGSize(width: 0, height: estimatedSize.height + 15) //15 is equal to the  10 point bottom anchor and a 5 point buffer on top
        
        textViewContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = estimatedSize.height
            }
        }
        
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
        
        let size = CGSize(width: textView.frame.width, height: .infinity)
        var estimatedSize = textView.sizeThatFits(size)
        
        if UIScreen.main.bounds.width == 320.0 {
            
            let newKeyboardHeight = ((keyboardHeight ?? 324) - accesoryView.size!.height) + estimatedSize.height
            
            if newKeyboardHeight > (UIScreen.main.bounds.height * 0.7) {
                
                let maxMessageViewHeight = (UIScreen.main.bounds.height * 0.7) - ((keyboardHeight ?? 324) - accesoryView.size!.height)
                
                textView.isScrollEnabled = true
                
                accesoryView.size = CGSize(width: 0, height: maxMessageViewHeight)
                
                estimatedSize = CGSize(width: 0, height: maxMessageViewHeight - 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top
            }
            
            else {
                
                textView.isScrollEnabled = false
                
                accesoryView.size = CGSize(width: 0, height: estimatedSize.height + 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top
            }
        }
        
        else {
            
            let newKeyboardHeight = ((keyboardHeight ?? 400) - accesoryView.size!.height) + estimatedSize.height
            
            if newKeyboardHeight > (UIScreen.main.bounds.height * 0.7) {
                
                let maxMessageViewHeight = (UIScreen.main.bounds.height * 0.7) - ((keyboardHeight ?? 400) - accesoryView.size!.height)
                
                textView.isScrollEnabled = true
                
                accesoryView.size = CGSize(width: 0, height: maxMessageViewHeight)
                
                estimatedSize = CGSize(width: 0, height: maxMessageViewHeight - 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top
            }
            
            else {
                
                textView.isScrollEnabled = false

                accesoryView.size = CGSize(width: 0, height: estimatedSize.height + 15) //15 is equal to the 10 point bottom anchor and a 5 point buffer on top
            }
        }

        textViewContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = estimatedSize.height
            }
        }
    }
    
    func textViewEndedEditing (textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = textViewPlaceholderText
            textView.textColor = textViewPlaceholderTextColor
        }
    }
    
    func validateTextChange () -> Bool {
        
        if textViewContainer.messageTextView.text != textViewPlaceholderText {
            
            return true
        }
        
        else {
            
            if (textViewContainer.messageTextView.text == textViewPlaceholderText) && (textViewContainer.messageTextView.textColor != textViewPlaceholderTextColor) {
                
                return true
            }
            
            else {
                
                return false
            }
        }
    }
    
    func messageSent (keyboardHeight: CGFloat?) {

        textViewContainer.messageTextView.text = ""
        textViewBeganEditing(textView: textViewContainer.messageTextView, keyboardHeight: keyboardHeight)
        
        resetMessageContainerHeights()
    }
    
   func setTextViewBottomAnchor () -> CGFloat {
        
        if (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 {
            
            return -36
        }
        
        else {
            
            return -10
        }
    }
    
    func resetMessageContainerHeights () {

        textViewContainer.constraints.forEach { (constraint) in

            if constraint.firstAttribute == .height {

                constraint.constant = 39
            }
        }
    }
}
