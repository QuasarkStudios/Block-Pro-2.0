//
//  AudioVisualizerBarCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 11/12/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class AudioVisualizerBarCell: UITableViewCell {

    let barView = UIView()
//    let barViewHeightConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "audioVisualizerBarCell")
        
        
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBar () {
        
        self.contentView.addSubview(barView)
        barView.translatesAutoresizingMaskIntoConstraints = false
    }

}
