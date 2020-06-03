//
//  SendButton.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class SendButton: UIButton {
    
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
        
        layer.cornerRadius = 14.5
        clipsToBounds = true
        
        setImage(UIImage(named: "paper_plane")?.withRenderingMode(.alwaysTemplate), for: .normal)
        imageEdgeInsets = UIEdgeInsets(top: 6, left: 7, bottom: 6, right: 6)
        
        tintColor = .white
        backgroundColor = UIColor(hexString: "222222")
        
        addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
    }
    
    func configureConstraints () {
        
        translatesAutoresizingMaskIntoConstraints = false

        [
         
        trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: -8/*-10*/),
        bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: -4),
        widthAnchor.constraint(equalToConstant: 29),
        heightAnchor.constraint(equalToConstant: 29)
         
        ].forEach { $0.isActive = true }
    }
    
    @objc private func sendButtonPressed () {
        
        NotificationCenter.default.post(name: .userDidSendMessage, object: nil)
    }
}
