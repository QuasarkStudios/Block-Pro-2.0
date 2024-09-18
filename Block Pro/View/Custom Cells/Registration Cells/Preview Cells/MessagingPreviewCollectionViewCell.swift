//
//  MessagingPreviewCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/30/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import Lottie

class MessagingPreviewCollectionViewCell: UICollectionViewCell {
    
    let animationView = LottieAnimationView(name: "conversation-animation")
    let messagingLabel = UILabel()

    var heightForLabel: CGFloat {

        let onboardingMessageWithTheGreatestRequiredHeight = onboardingMessages.sorted(by: { $0.estimateHeightForLongestPreviewMessage().height > $1.estimateHeightForLongestPreviewMessage().height }).first

        return onboardingMessageWithTheGreatestRequiredHeight!.estimateHeightForLongestPreviewMessage().height
    }
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureMessagingLabel()
        configureAnimationView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureMessagingLabel () {
        
        self.contentView.addSubview(messagingLabel)
        messagingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            messagingLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 40 : 20),
            messagingLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -40 : -20),
            messagingLabel.heightAnchor.constraint(equalToConstant: heightForLabel),
            messagingLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        messagingLabel.numberOfLines = 0
        messagingLabel.font = UIFont(name: "Poppins-SemiBold", size: UIScreen.main.bounds.width != 320 ? 18 : 16)
        messagingLabel.textAlignment = .center
        messagingLabel.text = onboardingMessages[1]
    }
    
    private func configureAnimationView () {
        
        self.contentView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            animationView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            animationView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            animationView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            animationView.bottomAnchor.constraint(equalTo: messagingLabel.topAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
    }
}
