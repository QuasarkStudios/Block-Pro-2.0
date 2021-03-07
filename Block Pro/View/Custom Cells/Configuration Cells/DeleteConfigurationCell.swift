//
//  DeleteConfigurationCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/6/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class DeleteConfigurationCell: UITableViewCell {

    let deleteButton = UIButton(type: .system)
    
    weak var configureCollabViewController: AnyObject?
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "deleteConfigurationCell")
        
        configureDeleteButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureDeleteButton () {
        
        self.contentView.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            deleteButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 42.5),
            deleteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -42.5),
            deleteButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 40)
        
        ].forEach({ $0.isActive = true })
        
        deleteButton.backgroundColor = .flatRed()
        
        deleteButton.layer.cornerRadius = 20
        deleteButton.layer.cornerCurve = .continuous
        deleteButton.clipsToBounds = true
        
        deleteButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        deleteButton.tintColor = .white
        deleteButton.setTitle("Delete", for: .normal)
        
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
    }
    
    @objc private func deleteButtonPressed () {
        
        if let viewController = configureCollabViewController as? ConfigureCollabViewController {
            
            viewController.presentDeleteCollabAlert()
        }
    }
}
