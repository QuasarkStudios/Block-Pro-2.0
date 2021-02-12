//
//  ProgressAnimationView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/8/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import Lottie

class ProgressAnimationView: UIView {

    let animationView = AnimationView(name: "progress-animation")
    var animationViewCenterYAnchor: NSLayoutConstraint?
    var animationViewHeightConstraint: NSLayoutConstraint?
    
    let animationTitleLabel = UILabel()
    
    var shrunkenHeight: CGFloat = 0
    var expandedHeight: CGFloat = 0
    
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

            animationView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            animationView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),

        ].forEach({ $0.isActive = true })

        animationViewCenterYAnchor = animationView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        animationViewCenterYAnchor?.isActive = true
        
        animationViewHeightConstraint = animationView.heightAnchor.constraint(equalToConstant: shrunkenHeight)
        animationViewHeightConstraint?.isActive = true
        
        animationView.alpha = 0
        animationView.contentMode = .scaleAspectFill
        
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
    }
    
    private func configureAnimationTitleLabel () {
        
        self.addSubview(animationTitleLabel)
        animationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
    
            animationTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            animationTitleLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 35),
            animationTitleLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            animationTitleLabel.heightAnchor.constraint(equalToConstant: 75)
        
        ].forEach({ $0.isActive = true })
        
        animationTitleLabel.alpha = 0
        animationTitleLabel.text = "No Blocks \n Yet"
        animationTitleLabel.textAlignment = .center
        animationTitleLabel.numberOfLines = 2
        animationTitleLabel.font = UIFont(name: "Poppins-SemiBold", size: 23)
    }
}
