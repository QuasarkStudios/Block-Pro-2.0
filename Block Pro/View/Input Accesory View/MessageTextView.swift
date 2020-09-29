//
//  MessageTextView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class MessageTextView: UITextView, UITextViewDelegate {
    
    weak var parentViewController: AnyObject? {
        didSet {
            
            if let textViewDelegate = parentViewController as? MessagingViewController {
                
                delegate = textViewDelegate
            }
            
            else if let textViewDelegate = parentViewController as? SendPhotoMessageViewController {
                
                delegate = textViewDelegate
            }
            
            else if let textViewDelegate = parentViewController as? CollabViewController {
                
                delegate = textViewDelegate
            }
        }
    }
    
    var placeholderText: String? {
        didSet {
            
            text = placeholderText!
        }
    }
    
    var placeholderTextColor: UIColor?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        configureView()
    }
    
    convenience init () {
        self.init(frame: .zero)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureView () {
        
        font = UIFont(name: "Poppins-Medium", size: 15.5)
        text = placeholderText ?? "Send a message"
        isScrollEnabled = false
        showsVerticalScrollIndicator = false
        
        if placeholderTextColor != nil {
            
            textColor = placeholderTextColor
        }
        
        else {
            
            if #available(iOS 13.0, *) {
                textColor = .placeholderText
            }
            
            else {
                textColor = .lightGray
            }
        }
    }
    
    func configureConstraints () {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: 10),
            trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: -55),
            topAnchor.constraint(equalTo: superview!.topAnchor, constant: 0),
            bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: 0)

        ].forEach { $0.isActive = true }
    }
}
