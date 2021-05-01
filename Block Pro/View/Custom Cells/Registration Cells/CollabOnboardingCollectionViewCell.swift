//
//  CollabOnboardingCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/30/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import Lottie

class CollabOnboardingCollectionViewCell: UICollectionViewCell {
    
    lazy var animationView = AnimationView(name: "home-animation")
    let collabLabel = UILabel()
    
    var heightForLabel: CGFloat {
        
        let onboardingMessageWithTheGreatestRequiredHeight = onboardingMessages.sorted(by: { $0.estimateHeightForLongestOnboardingMessage().height > $1.estimateHeightForLongestOnboardingMessage().height }).first
        
        return onboardingMessageWithTheGreatestRequiredHeight!.estimateHeightForLongestOnboardingMessage().height
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
            
        configureCollabLabel()
        configureAnimationView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollabLabel () {

        self.contentView.addSubview(collabLabel)
        collabLabel.translatesAutoresizingMaskIntoConstraints = false

        [

            collabLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 40 : 20),
            collabLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -40 : -20),
            collabLabel.heightAnchor.constraint(equalToConstant: heightForLabel),
            collabLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)

        ].forEach({ $0.isActive = true })
        
        collabLabel.numberOfLines = 0
        collabLabel.font = UIFont(name: "Poppins-SemiBold", size: UIScreen.main.bounds.width != 320 ? 18 : 16)
        collabLabel.textAlignment = .center
        collabLabel.text = onboardingMessages[2]
    }

    private func configureAnimationView () {

        self.contentView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false

        [

            animationView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            animationView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            animationView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            animationView.bottomAnchor.constraint(equalTo: collabLabel.topAnchor, constant: 0)

        ].forEach({ $0.isActive = true })

        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
    }
}
