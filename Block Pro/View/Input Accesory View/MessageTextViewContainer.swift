//
//  MessageTextViewContainer.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/4/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class MessageTextViewContainer: UIView {
    
    let messageTextView = MessageTextView()
    let sendButton = SendButton()
    
    weak var parentViewController: AnyObject? {
        didSet {
            
            messageTextView.parentViewController = parentViewController!
        }
    }
    
    var constraintsInitiallyConfigured: Bool = false
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
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
        
        backgroundColor = .white
        layer.cornerRadius = 19.5
        clipsToBounds = true
        layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        layer.borderWidth = 1
        
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        
        addSubview(messageTextView)
        addSubview(sendButton)
    }
    
    func configureConstraints (_ showsAddButton: Bool) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        let proposedTrailingAnchor: CGFloat = showsAddButton ? -55 : -13
        
        constraints.append(leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: 13))
        constraints.append(trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: proposedTrailingAnchor))
        constraints.append(heightAnchor.constraint(equalToConstant: 39))
        
        if (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 {
            
            constraints.append(bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: -36))
        }
        
        else {
            
            constraints.append(bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: -10))
        }
        
        constraints.forEach { $0.isActive = true }
        
        messageTextView.configureConstraints()
        sendButton.configureConstraints()
    }
}
