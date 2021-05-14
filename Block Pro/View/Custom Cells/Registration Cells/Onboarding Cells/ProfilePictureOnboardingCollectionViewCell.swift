//
//  ProfilePictureOnboardingCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/7/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class ProfilePictureOnboardingCollectionViewCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    let stackView = UIStackView()
    let profilePictureContainer = UIView()
    let buttonContainer = UIView()
    let profilePicture = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic")!, shadowRadius: 2, shadowOpacity: 0.35, borderColor: UIColor(hexString: "F4F4F4", withAlpha: 0.1)!.cgColor)
    let add_DoneButton = UIButton(type: .system)
    let skip_ChangeButton = UIButton(type: .system)
    
    var itemHeight: CGFloat? {
        didSet {
            
            if let height = itemHeight {
                
                configureProfilePicture(height)
            }
        }
    }
    
    var add_DoneButtonWidthConstraint: NSLayoutConstraint?
    
    weak var profilePictureRegistrationDelegate: ProfilePictureRegistration?
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureTitleLabel()
        configureStackView()
        configureProfilePictureContainer()
        configureButtonContainer()
        configureAdd_DoneButton()
        configureSkip_ChangeButton()
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
        titleLabel.text = "Would you like to add a\nprofile picture?"
    }
    
    
    private func configureStackView () {
        
        self.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        stackView.addArrangedSubview(profilePictureContainer)
        stackView.addArrangedSubview(buttonContainer)
    }
    
    
    private func configureProfilePictureContainer () {
        
        profilePictureContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            profilePictureContainer.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0),
            profilePictureContainer.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
    }
    
    
    private func configureButtonContainer () {
        
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            buttonContainer.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0),
            buttonContainer.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
    }
    
    
    private func configureProfilePicture (_ height: CGFloat) {
        
        profilePictureContainer.addSubview(profilePicture)
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            profilePicture.centerXAnchor.constraint(equalTo: profilePictureContainer.centerXAnchor, constant: 0),
            profilePicture.centerYAnchor.constraint(equalTo: profilePictureContainer.centerYAnchor, constant: 0),
            profilePicture.widthAnchor.constraint(equalToConstant: (height / 2) - (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 95 : 75)),
            profilePicture.heightAnchor.constraint(equalToConstant: (height / 2) - (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 95 : 75))
        
        ].forEach({ $0.isActive = true })
        
    }
    
    
    private func configureAdd_DoneButton () {
        
        buttonContainer.addSubview(add_DoneButton)
        add_DoneButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            add_DoneButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 30),
            add_DoneButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor, constant: 0),
            add_DoneButton.heightAnchor.constraint(equalToConstant: 45)
        
        ].forEach({ $0.isActive = true })
        
        add_DoneButtonWidthConstraint = add_DoneButton.widthAnchor.constraint(equalToConstant: 200)
        add_DoneButtonWidthConstraint?.isActive = true
        
        add_DoneButton.backgroundColor = UIColor(hexString: "222222")
        add_DoneButton.tintColor = .white
        add_DoneButton.layer.cornerRadius = 22.5
        add_DoneButton.layer.cornerCurve = .continuous
        
        add_DoneButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 15)
        add_DoneButton.setTitle("Add profile picture", for: .normal)
        
        add_DoneButton.addTarget(self, action: #selector(add_ChangeButtonPressed), for: .touchUpInside)
    }
    
    
    private func configureSkip_ChangeButton () {
        
        buttonContainer.addSubview(skip_ChangeButton)
        skip_ChangeButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            skip_ChangeButton.topAnchor.constraint(equalTo: add_DoneButton.bottomAnchor, constant: 25),
            skip_ChangeButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor, constant: 0),
            skip_ChangeButton.widthAnchor.constraint(equalToConstant: 200),
        
        ].forEach({ $0.isActive = true })
        
        skip_ChangeButton.tintColor = .lightGray
        
        skip_ChangeButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        skip_ChangeButton.setTitle("Skip for now", for: .normal)
        
        skip_ChangeButton.addTarget(self, action: #selector(skip_DoneButtonPressed), for: .touchUpInside)
    }
    
    
    func profilePictureAdded (_ profilePic: UIImage) {
        
        profilePicture.profilePic = profilePic
        
        add_DoneButtonWidthConstraint?.constant = 140
        add_DoneButton.setTitle("Done", for: .normal)
        add_DoneButton.removeTarget(self, action: #selector(add_ChangeButtonPressed), for: .touchUpInside)
        add_DoneButton.addTarget(self, action: #selector(skip_DoneButtonPressed), for: .touchUpInside)
        
        skip_ChangeButton.setTitle("Change profile picture", for: .normal)
        skip_ChangeButton.removeTarget(self, action: #selector(skip_DoneButtonPressed), for: .touchUpInside)
        skip_ChangeButton.addTarget(self, action: #selector(add_ChangeButtonPressed), for: .touchUpInside)
    }
    
    
    @objc private func add_ChangeButtonPressed () {
        
        profilePictureRegistrationDelegate?.addProfilePicture()
    }
    
    
    @objc private func skip_DoneButtonPressed () {
        
        profilePictureRegistrationDelegate?.skipProfilePicture()
    }
}
