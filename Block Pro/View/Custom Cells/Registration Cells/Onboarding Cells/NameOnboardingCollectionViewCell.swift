//
//  NameOnboardingCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/4/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class NameOnboardingCollectionViewCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    let firstNameTextFieldContainer = UIView()
    let lastNameTextFieldContainer = UIView()
    
    let firstNameTextField = UITextField()
    let lastNameTextField = UITextField()
    
    let firstNameErrorLabel = UILabel()
    let lastNameErrorLabel = UILabel()
    
    var lastNameContainerTopAnchor: NSLayoutConstraint?
    
    weak var nameRegistrationDelegate: NameRegistration?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureTitleLabel()
        configureFirstNameTextFieldContainer()
        configureLastNameTextFieldContainer()
        configureFirstNameTextField()
        configureLastNameTextField()
        configureFirstNameErrorLabel()
        configureLastNameErrorLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTitleLabel () {
        
        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
//            titleLabel.heightAnchor.constraint(equalToConstant: 45)
        
        ].forEach({ $0.isActive = true })
        
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 16)
        titleLabel.textAlignment = .center
        titleLabel.text = "What's your name?"
    }
    
    
    
    private func configureFirstNameTextFieldContainer () {
        
        self.contentView.addSubview(firstNameTextFieldContainer)
        firstNameTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            firstNameTextFieldContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 50 : 40),
            firstNameTextFieldContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -50 : -40),
            firstNameTextFieldContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            firstNameTextFieldContainer.heightAnchor.constraint(equalToConstant: 46)
        
        ].forEach({ $0.isActive = true })
        
        firstNameTextFieldContainer.backgroundColor = .white
        
        firstNameTextFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        firstNameTextFieldContainer.layer.borderWidth = 1

        firstNameTextFieldContainer.layer.cornerRadius = 23
        firstNameTextFieldContainer.layer.cornerCurve = .continuous
        firstNameTextFieldContainer.clipsToBounds = true
    }
    
    private func configureLastNameTextFieldContainer () {
        
        self.contentView.addSubview(lastNameTextFieldContainer)
        lastNameTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            lastNameTextFieldContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:  UIScreen.main.bounds.width != 320 ? 50 : 40),
            lastNameTextFieldContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant:  UIScreen.main.bounds.width != 320 ? -50 : -40),
            lastNameTextFieldContainer.heightAnchor.constraint(equalToConstant: 46)
        
        ].forEach({ $0.isActive = true })
        
        lastNameContainerTopAnchor = lastNameTextFieldContainer.topAnchor.constraint(equalTo: firstNameTextFieldContainer.bottomAnchor, constant: 30)
        lastNameContainerTopAnchor?.isActive = true
        
        lastNameTextFieldContainer.backgroundColor = .white
        
        lastNameTextFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        lastNameTextFieldContainer.layer.borderWidth = 1

        lastNameTextFieldContainer.layer.cornerRadius = 23
        lastNameTextFieldContainer.layer.cornerCurve = .continuous
        lastNameTextFieldContainer.clipsToBounds = true
    }
    
    
    
    
    private func configureFirstNameTextField () {
        
        firstNameTextFieldContainer.addSubview(firstNameTextField)
        firstNameTextField.setOnboardingTextFieldConstraints()
        
        firstNameTextField.delegate = self
        
        firstNameTextField.borderStyle = .none
        firstNameTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        firstNameTextField.placeholder = "First Name"
        firstNameTextField.returnKeyType = .done
        firstNameTextField.autocorrectionType = .no
        firstNameTextField.autocapitalizationType = .none
        
        firstNameTextField.addTarget(self, action: #selector(firstNameTextChanged), for: .editingChanged)
    }
    
    private func configureLastNameTextField () {
        
        lastNameTextFieldContainer.addSubview(lastNameTextField)
        lastNameTextField.setOnboardingTextFieldConstraints()
        
        lastNameTextField.delegate = self
        
        lastNameTextField.borderStyle = .none
        lastNameTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        lastNameTextField.placeholder = "Last Name"
        lastNameTextField.returnKeyType = .done
        lastNameTextField.autocorrectionType = .no
        lastNameTextField.autocapitalizationType = .none
        
        lastNameTextField.addTarget(self, action: #selector(lastNameTextChanged), for: .editingChanged)
    }
    
    //MARK: - Configure Error Label
    
    private func configureFirstNameErrorLabel () {
        
        self.contentView.addSubview(firstNameErrorLabel)
        firstNameErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            firstNameErrorLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 70 : 50),
            firstNameErrorLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -70 : -50),
            firstNameErrorLabel.topAnchor.constraint(equalTo: firstNameTextFieldContainer.bottomAnchor, constant: 7.5),
            firstNameErrorLabel.heightAnchor.constraint(equalToConstant: 15)
        
        ].forEach({ $0.isActive = true })
        
        firstNameErrorLabel.alpha = 0
        firstNameErrorLabel.adjustsFontSizeToFitWidth = true
        firstNameErrorLabel.font = UIFont(name: "Poppins-Regular", size: 13)
        firstNameErrorLabel.textColor = .systemRed
//        firstNameErrorLabel.text = "Please enter in your first name"
    }
    
    private func configureLastNameErrorLabel () {
        
        self.contentView.addSubview(lastNameErrorLabel)
        lastNameErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            lastNameErrorLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 70 : 50),
            lastNameErrorLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -70 : -50),
            lastNameErrorLabel.topAnchor.constraint(equalTo: lastNameTextFieldContainer.bottomAnchor, constant: 7.5),
            lastNameErrorLabel.heightAnchor.constraint(equalToConstant: 15)
        
        ].forEach({ $0.isActive = true })
        
        lastNameErrorLabel.alpha = 0
        lastNameErrorLabel.adjustsFontSizeToFitWidth = true
        lastNameErrorLabel.font = UIFont(name: "Poppins-Regular", size: 13)
        lastNameErrorLabel.textColor = .systemRed
    }
    
    @objc private func firstNameTextChanged () {
        
        nameRegistrationDelegate?.firstNameEntered(firstName: firstNameTextField.text ?? "")
    }
    
    @objc private func lastNameTextChanged () {
        
        nameRegistrationDelegate?.lastNameEntered(lastName: lastNameTextField.text ?? "")
    }
    
    func presentFirstNameErrorLabel (present: Bool) {
        
        lastNameContainerTopAnchor?.constant = present ? 40 : 30
        
        UIView.animate(withDuration: 0.3) {
            
            self.contentView.layoutIfNeeded()
            
            self.firstNameErrorLabel.alpha = present ? 1 : 0
        }
    }
    
    func presentLastNameErrorLabel (present: Bool){
        
        UIView.animate(withDuration: 0.3) {
            
            self.lastNameErrorLabel.alpha = present ? 1 : 0
        }
    }
}

extension NameOnboardingCollectionViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        presentFirstNameErrorLabel(present: false)
        presentLastNameErrorLabel(present: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        
        return true
    }
}
