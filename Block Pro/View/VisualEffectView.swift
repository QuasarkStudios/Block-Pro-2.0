//
//  VisualEffectView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class VisualEffectView: UIVisualEffectView {

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
    
    convenience init () {
        self.init(frame: .zero)
        
        //configureVisualEffect()
        
        configureBlur()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //configureVisualEffect()
        
        configureBlur()
    }

    private func configureVisualEffect () {
        
        let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: nil)
        let visualEffectView = UIVisualEffectView()
        let blurEffect = UIBlurEffect(style: .extraLight)
        
        visualEffectView.frame = bounds
        //visualEffectView.effect = nil
        
        animator.addAnimations {
            visualEffectView.effect = blurEffect
        }
        
        animator.fractionComplete = 0.3
        animator.stopAnimation(true)
        animator.finishAnimation(at: .current)
        
        //animator.fractionComplete = 0.3
        
        addSubview(visualEffectView)
        
        print(animator.fractionComplete)
    }
    
    private func configureBlur () {
        
        let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: nil)
        let blurEffect = UIBlurEffect(style: .extraLight)
        
        animator.addAnimations {
            self.effect = blurEffect
        }
        
        animator.fractionComplete = 0.3
        animator.stopAnimation(true)
        animator.finishAnimation(at: .current)
    }

}
