//
//  LocationSearchCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/25/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class LocationSearchCell: UITableViewCell {

    let locationNameLabel = UILabel()
    let locationAddressLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "locationSearchCell")
        
        self.backgroundColor = .clear
        
        configureLocationNameLabel()
        configureLocationAddressLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    //Handles the cell backgroundColor animation when the cell is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.backgroundColor = UIColor(hexString: "D8D8D8")?.lighten(byPercentage: 0.1)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        self.backgroundColor = .clear
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
            
            self.backgroundColor = .clear
        })
    }

    private func configureLocationNameLabel () {
        
        self.contentView.addSubview(locationNameLabel)
        locationNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationNameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 32.5),
            locationNameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -32.5),
            locationNameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 2.5),
            locationNameLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        locationNameLabel.textColor = .black
        locationNameLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
    }
    
    private func configureLocationAddressLabel () {
        
        self.contentView.addSubview(locationAddressLabel)
        locationAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationAddressLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 32.5),
            locationAddressLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -32.5),
            locationAddressLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -2.5),
            locationAddressLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        locationAddressLabel.textColor = UIColor(hexString: "AAAAAA")
        locationAddressLabel.font = UIFont(name: "Poppins-Italic", size: 12)
    }
}
