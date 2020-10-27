//
//  CreateCollabLocationsCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/17/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol CreateCollabLocationsCellProtocol: AnyObject {
    
    func attachLocationSelected()
}

class CreateCollabLocationsCell: UITableViewCell {

    let locationsLabel = UILabel()
    let locationContainer = UIView()
    
    let attachLocationButton = UIButton()
    let attachmentImage = UIImageView(image: UIImage(named: "attach")?.withRenderingMode(.alwaysTemplate))
    let attachLocationLabel = UILabel()
    
    weak var createCollabLocationsCellDelegate: CreateCollabLocationsCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        configureLocationsLabel()
        configureLocationContainer()
        configureAttachButton()
    }

    private func configureLocationsLabel () {
        
        self.contentView.addSubview(locationsLabel)
        locationsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            locationsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            locationsLabel.widthAnchor.constraint(equalToConstant: 75),
            locationsLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        locationsLabel.text = "Locations"
        locationsLabel.textColor = .black
        locationsLabel.textAlignment = .center
        locationsLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
    
    private func configureLocationContainer () {
        
        self.contentView.addSubview(locationContainer)
        locationContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            locationContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            locationContainer.topAnchor.constraint(equalTo: locationsLabel.bottomAnchor, constant: 10),
            locationContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
        
        ].forEach({ $0.isActive = true })
        
        locationContainer.backgroundColor = .white
        
        locationContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        locationContainer.layer.borderWidth = 1

        locationContainer.layer.cornerRadius = 10
        locationContainer.layer.cornerCurve = .continuous
        locationContainer.clipsToBounds = true
    }
    
    private func configureAttachButton () {
        
        locationContainer.addSubview(attachLocationButton)
        attachLocationButton.addSubview(attachmentImage)
        attachLocationButton.addSubview(attachLocationLabel)
        
        attachLocationButton.translatesAutoresizingMaskIntoConstraints = false
        attachmentImage.translatesAutoresizingMaskIntoConstraints = false
        attachLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            attachLocationButton.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 0),
            attachLocationButton.trailingAnchor.constraint(equalTo: locationContainer.trailingAnchor, constant: 0),
            attachLocationButton.topAnchor.constraint(equalTo: locationContainer.topAnchor, constant: 0),
            attachLocationButton.bottomAnchor.constraint(equalTo: locationContainer.bottomAnchor, constant: 0),
            
            attachmentImage.leadingAnchor.constraint(equalTo: attachLocationButton.leadingAnchor, constant: 20),
            attachmentImage.centerYAnchor.constraint(equalTo: attachLocationButton.centerYAnchor),
            attachmentImage.widthAnchor.constraint(equalToConstant: 25),
            attachmentImage.heightAnchor.constraint(equalToConstant: 25),
            
            attachLocationLabel.leadingAnchor.constraint(equalTo: attachLocationButton.leadingAnchor, constant: 10),
            attachLocationLabel.trailingAnchor.constraint(equalTo: attachLocationButton.trailingAnchor, constant: -10),
            attachLocationLabel.centerYAnchor.constraint(equalTo: attachLocationButton.centerYAnchor),
            attachLocationLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        attachLocationButton.backgroundColor = .clear
        attachLocationButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
        
        attachmentImage.tintColor = .black
        attachmentImage.isUserInteractionEnabled = false
        
        attachLocationLabel.text = "Attach Locations"
        attachLocationLabel.textColor = .black
        attachLocationLabel.textAlignment = .center
        attachLocationLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        attachLocationLabel.isUserInteractionEnabled = false
    }
    
    @objc private func attachButtonPressed () {
        
        createCollabLocationsCellDelegate?.attachLocationSelected()
    }
}
