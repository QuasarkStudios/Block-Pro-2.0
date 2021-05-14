//
//  UsernameOnboardingCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/6/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

class UsernameOnboardingCollectionViewCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    let usernameTextFieldContainer = UIView()
    let usernameTextField = UITextField()
    let errorLabel = UILabel()
    let progressView = UIView()
    
    var userFirstName: String? {
        didSet {
            
            if let name = userFirstName {
                
                titleLabel.text = "Great, nice to meet you \(name)!"
                titleLabel.text! += "\nNow create your username!"
            }
        }
    }
    
    var iProgressAttached: Bool = false
    
    weak var usernameRegistrationDelegate: UsernameRegistration?
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureTitleLabel()
        configureUsernameTextFieldContainer()
        configureUsernameTextField()
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
        
        ].forEach({ $0.isActive = true })
        
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 16)
        titleLabel.textAlignment = .center
        titleLabel.text = "Great! Now create your username!"
    }
    
    
    private func configureUsernameTextFieldContainer () {
        
        self.contentView.addSubview(usernameTextFieldContainer)
        usernameTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            usernameTextFieldContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 50 : 40),
            usernameTextFieldContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -50 : -40),
            usernameTextFieldContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            usernameTextFieldContainer.heightAnchor.constraint(equalToConstant: 46)
        
        ].forEach({ $0.isActive = true })
        
        usernameTextFieldContainer.backgroundColor = .white
        
        usernameTextFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        usernameTextFieldContainer.layer.borderWidth = 1

        usernameTextFieldContainer.layer.cornerRadius = 23
        usernameTextFieldContainer.layer.cornerCurve = .continuous
        usernameTextFieldContainer.clipsToBounds = true
    }
    
    
    private func configureUsernameTextField () {
        
        usernameTextFieldContainer.addSubview(usernameTextField)
        usernameTextField.setOnboardingTextFieldConstraints()
        
        usernameTextField.delegate = self
        
        usernameTextField.borderStyle = .none
        usernameTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        usernameTextField.placeholder = "Username"
        usernameTextField.returnKeyType = .done
        usernameTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none
        
        usernameTextField.addTarget(self, action: #selector(usernameTextChanged), for: .editingChanged)
    }
    
    
    private func configureErrorLabel () {
        
        self.contentView.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            errorLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UIScreen.main.bounds.width != 320 ? 70 : 50),
            errorLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: UIScreen.main.bounds.width != 320 ? -70 : -50),
            errorLabel.topAnchor.constraint(equalTo: usernameTextFieldContainer.bottomAnchor, constant: 7.5),
        
        ].forEach({ $0.isActive = true })
        
        errorLabel.numberOfLines = 0
        errorLabel.adjustsFontSizeToFitWidth = true
        errorLabel.font = UIFont(name: "Poppins-Regular", size: 13)
    }
    
    
    private func configureProgressView () {
        
        self.contentView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressView.leadingAnchor.constraint(equalTo: usernameTextFieldContainer.trailingAnchor, constant: 0),
            progressView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            progressView.centerYAnchor.constraint(equalTo: usernameTextFieldContainer.centerYAnchor, constant: 0),
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
    
    
    @objc private func usernameTextChanged () {
        
        usernameRegistrationDelegate?.usernameEntered(username: usernameTextField.text ?? "")
    }
}

extension UsernameOnboardingCollectionViewCell: UITextFieldDelegate {
    
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
