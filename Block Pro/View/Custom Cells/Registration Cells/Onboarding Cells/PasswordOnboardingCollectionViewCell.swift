//
//  PasswordOnboardingCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/6/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class PasswordOnboardingCollectionViewCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    let passwordTextFieldContainer = UIView()
    let passwordTextField = UITextField()
    let secureTextButtonContainer = UIView()
    let secureTextButton = UIButton(type: .system)
    let errorLabel = UILabel()
    
    weak var passwordRegistrationDelegate: PasswordRegistration?
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureTitleLabel()
        configurePasswordTextFieldContainer()
        configurePasswordTextField()
        configureSecureTextButtonContainer()
        configureSecureTextButton()
        configureErrorLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implmented")
    }
    
    private func configureTitleLabel () {
        
        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
        
        ].forEach({ $0.isActive = true })
        
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 16)
        titleLabel.textAlignment = .center
        titleLabel.text = "Almost done!\nNow just create your password!"//"Cool username!\nNow just create your password!"
    }
    
    
    private func configurePasswordTextFieldContainer () {
        
        self.contentView.addSubview(passwordTextFieldContainer)
        passwordTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            passwordTextFieldContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 50 : 40),
            passwordTextFieldContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -67.5 : -57.5/*-50 : -40*/),
            passwordTextFieldContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            passwordTextFieldContainer.heightAnchor.constraint(equalToConstant: 46)
        
        ].forEach({ $0.isActive = true })
        
        passwordTextFieldContainer.backgroundColor = .white
        
        passwordTextFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        passwordTextFieldContainer.layer.borderWidth = 1

        passwordTextFieldContainer.layer.cornerRadius = 23
        passwordTextFieldContainer.layer.cornerCurve = .continuous
        passwordTextFieldContainer.clipsToBounds = true
    }
    
    
    private func configurePasswordTextField () {
        
        passwordTextFieldContainer.addSubview(passwordTextField)
        passwordTextField.setOnboardingTextFieldConstraints()
        
        passwordTextField.delegate = self
        
        passwordTextField.borderStyle = .none
        passwordTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        passwordTextField.placeholder = "Password"
        passwordTextField.returnKeyType = .done
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        
        passwordTextField.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)
    }
    
    
    private func configureSecureTextButtonContainer () {
        
        self.contentView.addSubview(secureTextButtonContainer)
        secureTextButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            secureTextButtonContainer.leadingAnchor.constraint(equalTo: passwordTextFieldContainer.trailingAnchor, constant: 0),
            secureTextButtonContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            secureTextButtonContainer.centerYAnchor.constraint(equalTo: passwordTextFieldContainer.centerYAnchor, constant: 0),
            secureTextButtonContainer.heightAnchor.constraint(equalToConstant: 46)
            
        ].forEach({ $0.isActive = true })
    }
    
    
    private func configureSecureTextButton () {
        
        secureTextButtonContainer.addSubview(secureTextButton)
        secureTextButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            secureTextButton.centerXAnchor.constraint(equalTo: secureTextButtonContainer.centerXAnchor, constant: 0),
            secureTextButton.centerYAnchor.constraint(equalTo: secureTextButtonContainer.centerYAnchor, constant: 0),
            secureTextButton.widthAnchor.constraint(equalToConstant: 30),
            secureTextButton.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        secureTextButton.tintColor = UIColor(hexString: "D8D8D8")
        
        secureTextButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        secureTextButton.setImage(UIImage(systemName: "eye"), for: .highlighted)
        
        secureTextButton.addTarget(self, action: #selector(secureTextButtonPressed), for: .touchUpInside)
    }
    
    
    private func configureErrorLabel () {
        
        self.contentView.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            errorLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 70 : 50),
            errorLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -70 : -50),
            errorLabel.topAnchor.constraint(equalTo: passwordTextFieldContainer.bottomAnchor, constant: 7.5),
        
        ].forEach({ $0.isActive = true })
        
        errorLabel.numberOfLines = 0
        errorLabel.adjustsFontSizeToFitWidth = true
        errorLabel.font = UIFont(name: "Poppins-Regular", size: 13)
    }
    
    
    @objc private func passwordTextChanged () {
        
        passwordRegistrationDelegate?.passwordEntered(password: passwordTextField.text ?? "")
    }
    
    
    @objc private func secureTextButtonPressed () {
        
        if passwordTextField.isSecureTextEntry {
            
            passwordTextField.isSecureTextEntry = false
            
            secureTextButton.setImage(UIImage(systemName: "eye"), for: .normal)
            secureTextButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .highlighted)
        }
        
        else {
            
            passwordTextField.isSecureTextEntry = true
            
            secureTextButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
            secureTextButton.setImage(UIImage(systemName: "eye"), for: .highlighted)
        }
    }
}

extension PasswordOnboardingCollectionViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.transition(with: errorLabel, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.errorLabel.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        
        return true
    }
}
