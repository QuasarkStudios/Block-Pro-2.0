//
//  MessagesAnimationView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/12/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import Lottie

class MessagesAnimationView: UIView {

    let animationView = AnimationView(name: "chat-bubbles-animation")
    let animationTitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        configureAnimationView()
        configureAnimationTitleLabel()
    }
    
    private func configureAnimationView () {
        
        self.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            animationView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            animationView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            animationView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            animationView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        
        ].forEach({ $0.isActive = true })
        
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
    }
    
    private func configureAnimationTitleLabel () {
        
        self.addSubview(animationTitleLabel)
        animationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            animationTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            animationTitleLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: -85),
            animationTitleLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            animationTitleLabel.heightAnchor.constraint(equalToConstant: 75)
        
        ].forEach({ $0.isActive = true })
        
        animationTitleLabel.alpha = 0
        animationTitleLabel.text = "No Messages \n Yet"
        animationTitleLabel.textAlignment = .center
        animationTitleLabel.numberOfLines = 2
        animationTitleLabel.font = UIFont(name: "Poppins-SemiBold", size: 23)
    }
    
    func removeNoMessagesAnimation () {
        
        //Ensures the noMessagesAnimation is present
        if self.alpha != 0 {
            
            animationView.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                    
                    constraint.constant = 0
                }
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                
                self.layoutIfNeeded()
                
                self.animationTitleLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                
                self.alpha = 0
                
            } completion: { (finished: Bool) in
                
                self.animationView.stop()
            }
        }
    }
}
