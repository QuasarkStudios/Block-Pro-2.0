//
//  MessageTextView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class MessageTextView: UITextView, UITextViewDelegate {
    
    var parentViewController: Any? {
        didSet {
            
            if let textViewDelegate = parentViewController as? MessagingViewController {
                
                delegate = textViewDelegate
            }
        }
    }
    
    var placeholderText: String? {
        didSet {
            
            text = placeholderText!
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        configureView()
    }
    
//    override init (frame: CGRect) {
//        super.init(frame: frame)
//
//        //configureView()
//    }
    
    convenience init () {
        self.init(frame: .zero)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureView () {
        
        //delegate = self
        font = UIFont(name: "Poppins-SemiBold", size: 14)
        text = placeholderText ?? "Send a message"//"Send a message"
        isScrollEnabled = false
        showsVerticalScrollIndicator = false
        
        if #available(iOS 13.0, *) {
            textColor = .placeholderText
        } else {
            textColor = .lightGray
        }
    }
    
    func configureConstraints () {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: 10),
            trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: -55),
            topAnchor.constraint(equalTo: superview!.topAnchor, constant: 0),
            //heightAnchor.constraint(equalToConstant: 37)
        bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: 0)

        ].forEach { $0.isActive = true }
    }
}
