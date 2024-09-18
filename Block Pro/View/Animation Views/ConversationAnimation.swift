//
//  ConversationAnimation.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/31/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import Lottie

class ConversationAnimation: UIView {

    let conversationAnimationView = LottieAnimationView(name: "conversation-animation")
    let conversationAnimationTitle = UILabel()
    
    var loadingCount: Int = 1
    
    var containerHeight: CGFloat? {
        didSet {
            
            configureAnimationView()
            configureAnimationTitle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAnimationView () {
        
        self.addSubview(conversationAnimationView)
        conversationAnimationView.translatesAutoresizingMaskIntoConstraints = false

        [

            conversationAnimationView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            conversationAnimationView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            conversationAnimationView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            conversationAnimationView.heightAnchor.constraint(equalToConstant: containerHeight! * 0.8)

        ].forEach({ $0.isActive = true })
        
        conversationAnimationView.contentMode = .scaleAspectFill
        conversationAnimationView.loopMode = .loop
        conversationAnimationView.backgroundBehavior = .pauseAndRestore
        
        conversationAnimationView.play()
    }
    
    func configureAnimationTitle () {
        
        let proposedHeightOfLabel = containerHeight! * 0.2
        
        self.addSubview(conversationAnimationTitle)
        conversationAnimationTitle.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            conversationAnimationTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            conversationAnimationTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            conversationAnimationTitle.topAnchor.constraint(equalTo: conversationAnimationView.bottomAnchor, constant: 0),
            conversationAnimationTitle.heightAnchor.constraint(equalToConstant: proposedHeightOfLabel > 70 ? proposedHeightOfLabel : 70)
        
        ].forEach({ $0.isActive = true })
        
        conversationAnimationTitle.text = "Loading.\n"
        conversationAnimationTitle.textAlignment = .center
        conversationAnimationTitle.numberOfLines = 2

        conversationAnimationTitle.font = UIFont(name: "Poppins-SemiBold", size: 25)
    }
    
    @objc func loadingAnimation () {
        
        if loadingCount == 0 {
            
            conversationAnimationTitle.text = "Loading.\n"
            loadingCount += 1
        }
        
        else if loadingCount == 1 {
            
            conversationAnimationTitle.text = "Loading..\n"
            loadingCount += 1
        }
        
        else if loadingCount == 2 {
            
            conversationAnimationTitle.text = "Loading...\n"
            loadingCount = 0
        }
    }
}
