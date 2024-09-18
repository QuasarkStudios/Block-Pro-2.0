//
//  CopiedAnimationView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/24/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import Lottie

class CopiedAnimationView: UIView {
    
    var dismissAnimationWorkItem: DispatchWorkItem?
    
    init () {
        super.init(frame: .zero)
        
        configureCopiedAnimation()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCopiedAnimation () {
        
        if let keyWindow = keyWindow {
            
            keyWindow.addSubview(self)
            self.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                self.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor),
                self.topAnchor.constraint(equalTo: keyWindow.topAnchor, constant: -40),
                self.widthAnchor.constraint(equalToConstant: 120),
                self.heightAnchor.constraint(equalToConstant: 32)
            
            ].forEach({ $0.isActive = true })
            
            self.backgroundColor = UIColor.white
            self.alpha = 0
            
            self.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
            self.layer.shadowOpacity = 0.4//0.5
            self.layer.shadowRadius = 2
            self.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            self.layer.cornerRadius = 16
            
            if #available(iOS 13.0, *) {
                self.layer.cornerCurve = .continuous
            }
            
            
            let copiedAnimationTitle = UILabel()
            
            self.addSubview(copiedAnimationTitle)
            copiedAnimationTitle.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                copiedAnimationTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
                copiedAnimationTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                copiedAnimationTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 13),
                copiedAnimationTitle.widthAnchor.constraint(equalToConstant: 65)
                
            ].forEach({ $0.isActive = true })
            
            copiedAnimationTitle.text = "Copied"
            copiedAnimationTitle.textAlignment = .center
            copiedAnimationTitle.font = UIFont(name: "Poppins-SemiBold", size: 16)
            
            
            let animationView = LottieAnimationView(name: "scissor-cutting-animated")
            
            self.addSubview(animationView)
            animationView.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                animationView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                animationView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                animationView.widthAnchor.constraint(equalToConstant: 50),
                animationView.heightAnchor.constraint(equalToConstant: 50)
            
            ].forEach({ $0.isActive = true })
            
            animationView.animationSpeed = 2
            animationView.loopMode = .loop
        }
    }
    
    func presentCopiedAnimation (topAnchor: CGFloat) {
        
        dismissAnimationWorkItem?.cancel() //Cancels the workItem that would've dismissed the container
        
        for subview in self.subviews {
            
            if let animationView = subview as? LottieAnimationView {

                animationView.stop() //To allow for the animation to be appear to be restarted if it is already ongoing
            }
        }
        
        keyWindow?.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .top {
                
                //Multiple copiedAnimationViews may be added as subviews to the keyWindow at once
                //This ensures that only this particular instance of the copiedAnimationView constraints are manipulated
                if constraint.firstItem as? CopiedAnimationView == self {
                    
                    constraint.constant = topAnchor
                }
            }
        }
        
        //Animating the constraint changes
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            
            keyWindow?.layoutIfNeeded()
        })
        
        //Animating the alpha change, then starting animation once completed
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            
            self.alpha = 1
            
        }) { (finished: Bool) in
            
            for subview in self.subviews {
                
                if let animationView = subview as? LottieAnimationView {

                    animationView.play()
                }
            }
            
            //Schedules the workItem that will dismiss the container
            self.dismissAnimationWorkItem = DispatchWorkItem(block: {
                
                self.dismissCopiedAnimation()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: self.dismissAnimationWorkItem!)
        }
    }
    
    func dismissCopiedAnimation () {
        
        for subview in self.subviews {
            
            if let animationView = subview as? LottieAnimationView {

                animationView.stop()
            }
        }
        
        keyWindow?.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .top {
                
                //Multiple copiedAnimationViews may be added as subviews to the keyWindow at once
                //This ensures that only this particular instance of the copiedAnimationView constraints are manipulated
                if constraint.firstItem as? CopiedAnimationView == self {
                    
                    constraint.constant = -40
                }
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            
            keyWindow?.layoutIfNeeded()
            
            self.alpha = 0
        })
    }
    
    func removeCopiedAnimation (remove: Bool) {

        dismissAnimationWorkItem?.cancel() //Cancels the workItem that would've dismissed the container
        dismissCopiedAnimation()

        if remove {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                self.removeFromSuperview()
            }
        }
    }
}
