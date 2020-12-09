//
//  CollabHomeSectionHeaderCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/2/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabHomeSectionHeaderCell: UITableViewCell {
    
    let sectionNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "collabHomeSectionHeaderCell")
        
        configureSectionNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSectionNameLabel () {
        
        self.contentView.addSubview(sectionNameLabel)
        sectionNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            sectionNameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            sectionNameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            sectionNameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
        
        ].forEach({ $0.isActive = true })
        
        sectionNameLabel.textColor = .black
        sectionNameLabel.textAlignment = .left
        sectionNameLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
}

