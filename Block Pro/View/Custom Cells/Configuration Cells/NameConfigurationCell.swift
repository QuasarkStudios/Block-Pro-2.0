//
//  NameConfigurationCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/29/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class NameConfigurationCell: UITableViewCell {

    let nameLabel = UILabel()
    let textFieldContainer = UIView()
    let nameTextField = UITextField()
    
    weak var nameConfigurationDelegate: NameConfigurationProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "nameConfigurationCell")
        
        configureNameLabel()
        configureTextFieldContainer()
        configureNameTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNameLabel () {
        
        self.contentView.addSubview(nameLabel)
        nameLabel.configureConfigurationTitleLabelConstraints()
        
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .left
        nameLabel.text = "Name"
    }
    
    private func configureTextFieldContainer () {
        
        self.contentView.addSubview(textFieldContainer)
        textFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            textFieldContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            textFieldContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            textFieldContainer.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 10),
            textFieldContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        textFieldContainer.backgroundColor = .white
        
        textFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        textFieldContainer.layer.borderWidth = 1

        textFieldContainer.layer.cornerRadius = 10
        textFieldContainer.layer.cornerCurve = .continuous
        textFieldContainer.clipsToBounds = true
    }
    
    private func configureNameTextField () {
        
        self.textFieldContainer.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameTextField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 10),
            nameTextField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -10),
            nameTextField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor, constant: 0),
            nameTextField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        nameTextField.delegate = self
        
        nameTextField.borderStyle = .none
        nameTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        nameTextField.placeholder = "Enter here"
        nameTextField.returnKeyType = .done
//        nameTextField.autocapitalizationType = .none
        
        nameTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    @objc private func textChanged () {
        
        nameConfigurationDelegate?.nameEntered(nameTextField.text ?? "")
    }
}

extension NameConfigurationCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        return true
    }
}
