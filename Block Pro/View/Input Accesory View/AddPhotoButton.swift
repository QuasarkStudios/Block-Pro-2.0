//
//  AddPhotoButton.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/3/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class AddAttachmentButton: UIButton {
    
     override init (frame: CGRect) {
         super.init(frame: frame)
         
         configureView()
     }
     
     convenience init () {
         self.init(frame: .zero)
         
         configureView()
     }
     
     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
     }
    
    private func configureView () {
        
        setImage(UIImage(named: "plus 3"), for: .normal)
        tintColor = UIColor(hexString: "222222")
        
        addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
    }
    
    func configureConstraints () {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        [
            //topAnchor.constraint(equalTo: superview!.topAnchor, constant: 2),
            //bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: 0),
            trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: -17.5),
            widthAnchor.constraint(equalToConstant: 25),
            heightAnchor.constraint(equalToConstant: 37)
            
        ].forEach( { $0.isActive = true } )
        
        for subview in superview?.subviews ?? [] {
            
            if let view = subview as? MessageTextViewContainer {
                
                bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0.5).isActive = true
            }
        }
    }
    
    @objc private func addButtonPressed () {
        
        NotificationCenter.default.post(name: .userDidAddMessageAttachment, object: nil)
    }
}
