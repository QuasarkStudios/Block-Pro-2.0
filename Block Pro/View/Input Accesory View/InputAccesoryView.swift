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
    
    var parentViewController: Any? {
        didSet {
            
            textViewContainer.parentViewController = parentViewController!
        }
    }

    
//    override init (frame: CGRect) {
//        super.init(frame: frame)
//
//        configureView()
//
//        self.autoresizingMask = .flexibleHeight
//        size = configureSize()
//    }
//
//    convenience init () {
//        self.init(frame: .zero)
//
//        configureView()
//
//        size = configureSize()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    init(showsAddButton: Bool, textViewPlaceholderText: String) {
        super.init(frame: .zero)

        configureView(showsAddButton)
        
        textViewContainer.messageTextView.placeholderText = textViewPlaceholderText
        
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
        
//        isHidden = true
//        alpha = 0
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
        
        //iPhone 11 Pro Max & iPhone 11
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {

            return CGSize(width: 0, height: 75)
        }
            
        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            return CGSize(width: 0, height: 75)
        }
            
        //Every other iPhone
        else  {
            
            return CGSize(width: 0, height: 50)
        }
    }
}
