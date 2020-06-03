//
//  SendPhotoMessageViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class SendPhotoMessageViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var photoImageView: UIImageView!
    
    let messageInputAccesoryView = InputAccesoryView(showsAddButton: false, textViewPlaceholderText: "Add a caption")
    let textViewContainer = MessageTextViewContainer()
    
    var selectedPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.configureNavBar()
        
        photoImageView.image = selectedPhoto ?? nil
        
        configureTextViewContainer()
    }
    
    override var inputAccessoryView: UIView? {
        get {
           return messageInputAccesoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func configureTextViewContainer () {
        
        messageInputAccesoryView.isHidden = false
        messageInputAccesoryView.alpha = 1
        
        //messageInputAccesoryView.showsAddButton = false
        //messageInputAccesoryView.addSubview(te)
    }
}
