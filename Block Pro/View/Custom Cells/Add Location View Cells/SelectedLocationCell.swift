//
//  SelectedLocationCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/25/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class SelectedLocationCell: UITableViewCell {

    let locationNameTextField = UITextField()
    let locationAddressLabel = UILabel()
    let cancelButton = UIButton(type: .system)
    let saveLocationButton = UIButton(type: .system)
    let navigateToLocationButton = UIButton(type: .system)
    
    weak var cancelLocationSelectionDelegate: CancelLocationSelectionProtocol?
    weak var navigateToLocationDelegate: NavigateToLocationProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "selectedLocationCell")
        
        self.backgroundColor = .clear
        
        configureLocationNameLabel()
        configureLocationAddressLabel()
        configureCancelButton()
        configureSaveLocationButton()
        configureNavigationToLocationButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLocationNameLabel () {
        
        self.contentView.addSubview(locationNameTextField)
        locationNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationNameTextField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 32.5),
//            locationNameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -32.5),
            locationNameTextField.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            locationNameTextField.heightAnchor.constraint(equalToConstant: 38)
        
        ].forEach({ $0.isActive = true })
        
        locationNameTextField.delegate = self
        
        locationNameTextField.borderStyle = .none
        
        locationNameTextField.attributedPlaceholder = NSAttributedString(string: "Enter a name", attributes: [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 22.5) as Any, NSAttributedString.Key.foregroundColor : UIColor(hexString: "AAAAAA") as Any])
        
        locationNameTextField.textColor = .black
        locationNameTextField.font = UIFont(name: "Poppins-SemiBold", size: 25)
        
        
        
        locationNameTextField.returnKeyType = .done
    }
    
    private func configureLocationAddressLabel () {
        
        self.contentView.addSubview(locationAddressLabel)
        locationAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationAddressLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 32.5),
            locationAddressLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -32.5),
            locationAddressLabel.topAnchor.constraint(equalTo: locationNameTextField.bottomAnchor, constant: 0),
            locationAddressLabel.heightAnchor.constraint(equalToConstant: 38)
        
        ].forEach({ $0.isActive = true })
        
        locationAddressLabel.textColor = UIColor(hexString: "AAAAAA")
        locationAddressLabel.font = UIFont(name: "Poppins-Italic", size: 13)
    }
    
    private func configureCancelButton () {
        
        self.contentView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            cancelButton.leadingAnchor.constraint(equalTo: locationNameTextField.trailingAnchor, constant: 30),
            
            cancelButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -32.5),
            cancelButton.widthAnchor.constraint(equalToConstant: 25),
            cancelButton.heightAnchor.constraint(equalToConstant: 25),
            cancelButton.centerYAnchor.constraint(equalTo: locationNameTextField.centerYAnchor)
        
        ].forEach({ $0.isActive = true })
        
//        cancelButton.backgroundColor =
        cancelButton.tintColor = UIColor(hexString: "222222")
        
        cancelButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        
        cancelButton.layer.cornerRadius = 25 * 0.5
        cancelButton.clipsToBounds = true
        
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
    }
    
    private func configureSaveLocationButton () {
        
        self.addSubview(saveLocationButton)
        saveLocationButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            saveLocationButton.topAnchor.constraint(equalTo: self.locationAddressLabel.bottomAnchor, constant: 15),
            saveLocationButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            saveLocationButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 31),
//            saveLocationButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -65)
        
        ].forEach({ $0.isActive = true })
        
        saveLocationButton.backgroundColor = UIColor(hexString: "222222")
        saveLocationButton.tintColor = .white
        saveLocationButton.setTitle("Save Location", for: .normal)
        saveLocationButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 17)
        
        saveLocationButton.layer.cornerRadius = 12
        saveLocationButton.clipsToBounds = true
    }
    
    private func configureNavigationToLocationButton () {
        
        self.addSubview(navigateToLocationButton)
        navigateToLocationButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            navigateToLocationButton.leadingAnchor.constraint(equalTo: saveLocationButton.trailingAnchor, constant: 30),
            
//            navigateToLocationButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -32.5),
            navigateToLocationButton.widthAnchor.constraint(equalToConstant: 32.5),
            navigateToLocationButton.heightAnchor.constraint(equalToConstant: 32.5),
            navigateToLocationButton.centerXAnchor.constraint(equalTo: cancelButton.centerXAnchor, constant: 1.5),
            navigateToLocationButton.centerYAnchor.constraint(equalTo: saveLocationButton.centerYAnchor)
        
        ].forEach({ $0.isActive = true })
        
        navigateToLocationButton.tintColor = UIColor(hexString: "222222")
        navigateToLocationButton.setBackgroundImage(UIImage(systemName: "location.viewfinder"), for: .normal)
        
        navigateToLocationButton.addTarget(self, action: #selector(navigateButtonPressed), for: .touchUpInside)
    }
    
    @objc private func cancelButtonPressed () {
        
        cancelLocationSelectionDelegate?.selectionCancelled()
    }
    
    @objc private func navigateButtonPressed () {
        
        navigateToLocationDelegate?.navigateToLocation()
    }
}

extension SelectedLocationCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        
        return true
    }
}
