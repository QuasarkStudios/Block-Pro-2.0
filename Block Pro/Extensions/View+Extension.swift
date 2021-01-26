//
//  View+Extension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/12/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

extension UIView {
    
    func configureProfilePicContainer (clip: Bool = false, shadowRadius: CGFloat = 2.5) {
        
        layer.shadowRadius = shadowRadius
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.75
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(hexString: "F4F4F4", withAlpha: 0.05)?.cgColor
        
        layer.cornerRadius = 0.5 * self.bounds.width
        layer.masksToBounds = false
        clipsToBounds = clip
    }
    
    func performCopyAnimationOnView () {
        
        let vibrateMethods = VibrateMethods()
        vibrateMethods.quickVibration()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
        }) { (finished: Bool) in
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                
                self.transform = .identity
            })
        }
    }
    
    func configureTitleLabelConstraints () {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor, constant: 30),
            self.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: 0),
            self.widthAnchor.constraint(equalToConstant: 125),
            self.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
    }
    
    func setCollabBlockColor (_ block: Block?) {
        
        switch block?.status {

            case .completed:

                self.backgroundColor = UIColor(hexString: "2ECC70", withAlpha: 0.80)

            case .inProgress:

                self.backgroundColor = UIColor(hexString: "5065A0", withAlpha: 0.75)

            case .needsHelp:

                self.backgroundColor = UIColor(hexString: "FFCC02", withAlpha: 0.75)

            case .late:

                self.backgroundColor = UIColor(hexString: "E84D3C", withAlpha: 0.75)

            default:

                self.backgroundColor = UIColor(hexString: "AAAAAA", withAlpha: 0.75)
        }
    }
}
