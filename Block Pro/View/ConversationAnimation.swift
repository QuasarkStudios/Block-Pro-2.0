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

    let conversationAnimationView = AnimationView(name: "conversation-animation")
    let conversationAnimationTitle = UILabel()
    
    var loadingCount: Int = 1
    
    init (){
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAnimationView () {
        
        self.addSubview(conversationAnimationView)
        
        conversationAnimationView.translatesAutoresizingMaskIntoConstraints = false

        [

            conversationAnimationView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            conversationAnimationView.topAnchor.constraint(equalTo: self.topAnchor, constant: animationViewTopAnchor),
            conversationAnimationView.widthAnchor.constraint(equalToConstant: animationViewWidth),
            conversationAnimationView.heightAnchor.constraint(equalToConstant: self.frame.height)

        ].forEach({ $0.isActive = true })
        
        conversationAnimationView.loopMode = .loop
        conversationAnimationView.play()
        conversationAnimationView.backgroundBehavior = .pauseAndRestore
        
        conversationAnimationView.backgroundColor = .clear
    }
    
    func configureAnimationTitle () {
        
        self.addSubview(conversationAnimationTitle)
        
        conversationAnimationTitle.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            conversationAnimationTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            conversationAnimationTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            conversationAnimationTitle.topAnchor.constraint(equalTo: conversationAnimationView.bottomAnchor, constant: animationTitleTopAnchor),
            conversationAnimationTitle.heightAnchor.constraint(equalToConstant: 75)
        
        ].forEach({ $0.isActive = true })
        
        conversationAnimationTitle.text = "Loading."
        conversationAnimationTitle.textAlignment = .center
        conversationAnimationTitle.numberOfLines = 2
        
        let fontSize: CGFloat = UIScreen.main.bounds.height == 896.0 ? 25.0 : 23.0
        conversationAnimationTitle.font = UIFont(name: "Poppins-SemiBold", size: fontSize)
    }
    
    @objc func loadingAnimation () {
        
        if loadingCount == 0 {
            
            conversationAnimationTitle.text = "Loading."
            loadingCount += 1
        }
        
        else if loadingCount == 1 {
            
            conversationAnimationTitle.text = "Loading.."
            loadingCount += 1
        }
        
        else if loadingCount == 2 {
            
            conversationAnimationTitle.text = "Loading..."
            loadingCount = 0
        }
    }
    
    var containerHeight: CGFloat {
        
        //iPhone 11 Pro Max and iPhone 11
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {

            return 512
        }

        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {

            return 395
        }

        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {

            return 428
        }

        //iPhone SE 2
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {

            return 326
        }

        //iPhone SE
        else {

            return 232
        }
    }
    
    var animationViewTopAnchor: CGFloat {
        
        //iPhone 11 Pro Max and iPhone 11
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {

            return -65
        }

        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {

            return -50
        }

        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {

            return -65
        }

        //iPhone SE 2
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {

            return -40
        }

        //iPhone SE
        else {

            return -25
        }
    }
    
    var animationViewWidth: CGFloat {
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {

            return UIScreen.main.bounds.width + 175
        }

        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {

            return UIScreen.main.bounds.width + 125
        }

        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {

            return UIScreen.main.bounds.width + 100
        }

        //iPhone SE 2
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {

            return UIScreen.main.bounds.width + 50
        }

        //iPhone SE
        else {

            return UIScreen.main.bounds.width
        }
    }
    
    var animationTitleTopAnchor: CGFloat {
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            return -60
        }
            
        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {
            
            return -50
        }
            
        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            return -50
        }
            
        //iPhone SE 2
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {
            
            return -35
        }
            
        //iPhone SE
        else {
            
            return -25
        }
    }
}
