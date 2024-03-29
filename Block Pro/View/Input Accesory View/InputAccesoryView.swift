//
//  InputAccesoryView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/4/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class InputAccesoryView: UIView {
    
    let textViewContainer = MessageTextViewContainer()
    let addAttachmentButton = AddAttachmentButton(type: .system)

    var size: CGSize? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    weak var parentViewController: AnyObject? {
        didSet {
            
            textViewContainer.parentViewController = parentViewController!
        }
    }

    
    init(textViewPlaceholderText: String, textViewPlaceholderTextColor: UIColor? = nil, showsAddButton: Bool) {
        super.init(frame: .zero)
        
        configureView(showsAddButton)
        
        textViewContainer.messageTextView.placeholderText = textViewPlaceholderText
        textViewContainer.messageTextView.placeholderTextColor = textViewPlaceholderTextColor
        
        self.autoresizingMask = .flexibleHeight
        
        size = configureSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return size ?? CGSize(width: 0, height: 0)
    }
    
    private func configureView (_ showsAddButton: Bool) {
        
        backgroundColor = UIColor(hexString: "ffffff", withAlpha: 0.95)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textViewContainer)
        textViewContainer.configureConstraints(showsAddButton)
        
        if showsAddButton {

            addSubview(addAttachmentButton)
            addAttachmentButton.configureConstraints()
        }
    }
    
    func configureSize () -> CGSize {
        
        if (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 {
            
            return CGSize(width: 0, height: 77)
        }
        
        else {
            
            return CGSize(width: 0, height: 51)
        }
    }
}
