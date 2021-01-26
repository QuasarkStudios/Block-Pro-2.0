//
//  SelectedBlockEdit_DeleteCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/26/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class SelectedBlockEdit_DeleteCell: UITableViewCell {

    let editButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)
    
    weak var blockEdited_DeletedDelegate: BlockEdited_DeletedProtocol?
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "selectedBlockEdit_DeleteCell")
        
        configureEditButton()
        configureDeleteButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    private func configureDeleteButton () {
        
        self.contentView.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            deleteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -42.5),
            deleteButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - (80 + 40)) / 2),
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
    
    @objc private func editButtonPressed () {
        
        blockEdited_DeletedDelegate?.editBlockSelected()
    }
    
    @objc private func deleteButtonPressed () {
        
        blockEdited_DeletedDelegate?.deleteBlockSelected()
    }
}
