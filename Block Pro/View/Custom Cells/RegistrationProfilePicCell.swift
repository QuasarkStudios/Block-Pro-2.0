//
//  RegistrationProfilePicCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol AddProfilePicture: AnyObject {
    
    func presentImagePickerController ()
    
    func skipButtonPressed ()
}

class RegistrationProfilePicCell: UICollectionViewCell {

    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var addProfilePictureButton: UIButton!
    
    @IBOutlet weak var skipButton: UIButton!
    
    weak var addProfilePictureDelegate: AddProfilePicture?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureImageView()
        
        addProfilePictureButton.addTarget(self, action: #selector(addProfilePicture), for: .touchUpInside)
        
        skipButton.layer.cornerRadius = 22.5
        skipButton.clipsToBounds = true
    }

    private func configureImageView () {
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(addProfilePicture))
        
        profileImage.addGestureRecognizer(tap)
        profileImage.isUserInteractionEnabled = true
        
        profileImage.layer.cornerRadius = 0.5 * profileImage.bounds.width
        profileImage.clipsToBounds = true
    }
    
    @objc private func addProfilePicture () {
        
        addProfilePictureDelegate?.presentImagePickerController()
        
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        
        addProfilePictureDelegate?.skipButtonPressed()
    }
    
}
