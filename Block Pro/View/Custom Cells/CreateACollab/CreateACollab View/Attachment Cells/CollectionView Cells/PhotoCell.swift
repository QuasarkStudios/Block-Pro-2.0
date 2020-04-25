//
//  PhotosCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/22/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowRadius = 2.5
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.75
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(hexString: "F4F4F4", withAlpha: 0.05)?.cgColor
        
        layer.cornerRadius = 12
        clipsToBounds = false
        
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.layer.cornerRadius = 12
        photoImageView.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            
            layer.cornerCurve = .continuous
            photoImageView.layer.cornerCurve = .continuous
        }
    }
}
