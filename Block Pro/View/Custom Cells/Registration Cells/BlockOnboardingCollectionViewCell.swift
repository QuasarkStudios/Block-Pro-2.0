//
//  BlockOnboardingCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/30/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import Lottie

class BlockOnboardingCollectionViewCell: UICollectionViewCell {
    
    lazy var animationView = AnimationView(name: "block-onboarding-animation")
    let blockLabel = UILabel()
    
    var heightForLabel: CGFloat {
        
        let onboardingMessageWithTheGreatestRequiredHeight = onboardingMessages.sorted(by: { $0.estimateHeightForLongestOnboardingMessage().height > $1.estimateHeightForLongestOnboardingMessage().height }).first
        
        return onboardingMessageWithTheGreatestRequiredHeight!.estimateHeightForLongestOnboardingMessage().height
    }
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureBlockLabel()
        configureAnimationView()
    }
    
    required init? (coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBlockLabel () {
        
        self.contentView.addSubview(blockLabel)
        blockLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            blockLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 40 : 20),
            blockLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -40 : -20),
            blockLabel.heightAnchor.constraint(equalToConstant: heightForLabel),
            blockLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        
        blockLabel.numberOfLines = 0
        blockLabel.font = UIFont(name: "Poppins-SemiBold", size: UIScreen.main.bounds.width != 320 ? 18 : 16)
        blockLabel.textAlignment = .center
        blockLabel.text = onboardingMessages[0]
    }
    
    private func configureAnimationView () {
        
        self.contentView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            animationView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            animationView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            animationView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            animationView.bottomAnchor.constraint(equalTo: blockLabel.topAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
    }
}
