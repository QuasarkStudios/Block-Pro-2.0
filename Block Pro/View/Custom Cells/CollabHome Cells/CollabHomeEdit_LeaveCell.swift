//
//  CollabHomeEdit_LeaveCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/25/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabHomeEdit_LeaveCell: UITableViewCell {

    let editButton = UIButton(type: .system)
    let leaveButton = UIButton(type: .system)
    
    let currentUser = CurrentUser.sharedInstance
    
    var collab: Collab? {
        didSet {
            
            editButton.removeFromSuperview()
            leaveButton.removeFromSuperview()
            
            if let currentMember = collab?.currentMembers.first(where: { $0.userID == currentUser.userID }), currentMember.role == "Lead" {
                
                configureEditButton()
                configureLeaveButton(false)
            }
            
            else {
                
                configureLeaveButton(true)
            }
        }
    }
    
    weak var collabViewController: AnyObject?
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "collabHomeEditLeaveCell")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder) has not been implemented")
    }
    
    private func configureEditButton () {
        
        self.contentView.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            editButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 42.5),
            editButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - (80 + 40)) / 2),
            editButton.heightAnchor.constraint(equalToConstant: 40)
        
        ].forEach({ $0.isActive = true })
        
        editButton.backgroundColor = UIColor(hexString: "222222")
        
        editButton.layer.cornerRadius = 20
        editButton.layer.cornerCurve = .continuous
        editButton.clipsToBounds = true
        
        editButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        editButton.tintColor = .white
        editButton.setTitle("Edit", for: .normal)
        
        editButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
    }
    
    private func configureLeaveButton (_ onlyButton: Bool) {
        
        self.contentView.addSubview(leaveButton)
        leaveButton.translatesAutoresizingMaskIntoConstraints = false
        
        if onlyButton {
            
            [
            
                leaveButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 42.5),
                leaveButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -42.5),
                leaveButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                leaveButton.heightAnchor.constraint(equalToConstant: 40)
            
            ].forEach({ $0.isActive = true })
        }
        
        else {
            
            [
            
                leaveButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -42.5),
                leaveButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                leaveButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - (80 + 40)) / 2),
                leaveButton.heightAnchor.constraint(equalToConstant: 40)
            
            ].forEach({ $0.isActive = true })
        }
        
        leaveButton.backgroundColor = .flatRed()
        
        leaveButton.layer.cornerRadius = 20
        leaveButton.layer.cornerCurve = .continuous
        leaveButton.clipsToBounds = true
        
        leaveButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        leaveButton.tintColor = .white
        leaveButton.setTitle("Leave", for: .normal)
        
        leaveButton.addTarget(self, action: #selector(leaveButtonPressed), for: .touchUpInside)
    }
    
    @objc private func editButtonPressed () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.editCollabButtonPressed()
        }
    }
    
    @objc private func leaveButtonPressed () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.leaveCollabButtonPressed()
        }
    }
}
