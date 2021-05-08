//
//  EmailOnboardingCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/1/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

class EmailOnboardingCollectionViewCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    let emailTextFieldContainer = UIView()
    let emailTextField = UITextField()
    let errorLabel = UILabel()
    let progressView = UIView()
    
    var iProgressAttached: Bool = false
    
    weak var emailAddressRegistrationDelegate: EmailAddressRegistration?
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureTitleLabel()
        configureEmailTextFieldContainer()
        configureEmailTextField()
        configureErrorLabel()
        configureProgressView()
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
        
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 16)
        titleLabel.textAlignment = .center
        titleLabel.text = "What about your email?"
    }
    
    //MARK: - Configure Email TextField Container
    
    private func configureEmailTextFieldContainer () {
        
        self.contentView.addSubview(emailTextFieldContainer)
        emailTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            emailTextFieldContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 50 : 40),
            emailTextFieldContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -50 : -40),
            emailTextFieldContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            emailTextFieldContainer.heightAnchor.constraint(equalToConstant: 46)
        
        ].forEach({ $0.isActive = true })
        
        emailTextFieldContainer.backgroundColor = .white
        
        emailTextFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        emailTextFieldContainer.layer.borderWidth = 1

        emailTextFieldContainer.layer.cornerRadius = 23
        emailTextFieldContainer.layer.cornerCurve = .continuous
        emailTextFieldContainer.clipsToBounds = true
    }
    
    
    //MARK: - Configure Email TextField
    
    private func configureEmailTextField () {
        
        emailTextFieldContainer.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            emailTextField.leadingAnchor.constraint(equalTo: emailTextFieldContainer.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: emailTextFieldContainer.trailingAnchor, constant: -10),
            emailTextField.topAnchor.constraint(equalTo: emailTextFieldContainer.topAnchor, constant: 0),
            emailTextField.bottomAnchor.constraint(equalTo: emailTextFieldContainer.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        emailTextField.delegate = self
        
        emailTextField.borderStyle = .none
        emailTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        emailTextField.placeholder = "E-mail Address"
        emailTextField.returnKeyType = .done
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        
        emailTextField.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
    }
    
    
    //MARK: - Configure Error Label
    
    private func configureErrorLabel () {
        
        self.contentView.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            errorLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 70 : 50),
            errorLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -70 : -50),
            errorLabel.topAnchor.constraint(equalTo: emailTextFieldContainer.bottomAnchor, constant: 7.5),
//            errorLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        errorLabel.numberOfLines = 0
        errorLabel.adjustsFontSizeToFitWidth = true
        errorLabel.font = UIFont(name: "Poppins-Regular", size: 13)
//        errorLabel.textColor = .systemRed
//        errorLabel.text = "Please enter in your E-mail Address"
    }
    
    private func configureProgressView () {
        
        self.contentView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressView.leadingAnchor.constraint(equalTo: emailTextFieldContainer.trailingAnchor, constant: 0),
            progressView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            progressView.centerYAnchor.constraint(equalTo: emailTextFieldContainer.centerYAnchor, constant: 0),
            progressView.heightAnchor.constraint(equalToConstant: 46)
        
        ].forEach({ $0.isActive = true })
    }
    
    func displayProgress () {
        
        if !iProgressAttached {
            
            let iProgress: iProgressHUD = iProgressHUD()
            
            iProgress.isShowModal = false
            iProgress.isShowCaption = false
            iProgress.isTouchDismiss = false
            iProgress.boxColor = .clear
            
            iProgress.indicatorSize = 80
            iProgress.indicatorColor = .black
            
            iProgress.attachProgress(toView: progressView)
            
            progressView.updateIndicator(style: .circleStrokeSpin)
            
            iProgressAttached = true
        }
        
        progressView.showProgress()
    }
    
    @objc private func emailTextChanged () {
        
        emailAddressRegistrationDelegate?.emailAddressEntered(email: emailTextField.text ?? "")
    }
}

extension EmailOnboardingCollectionViewCell: UITextFieldDelegate {
    
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
