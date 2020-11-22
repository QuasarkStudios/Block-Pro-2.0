//
//  ProfileViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/1/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol ProfileView: AnyObject {
    
    func profilePicChanged (_ image: UIImage)
}

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var addProfilePictureButton: UIButton!
    
    let currentUser = CurrentUser.sharedInstance
    
    lazy var tabBar = CustomTabBar.sharedInstance
    
    weak var profileViewDelegate: ProfileView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureImageView()
        
        addProfilePictureButton.addTarget(self, action: #selector(addProfilePicture), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationItem.title = "Profile"
        
        if let profilePicture = currentUser.profilePictureImage {
            
            profileImage.image = profilePicture
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        configureTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBar.previousNavigationController = navigationController
    }
    
    private func configureImageView () {
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(addProfilePicture))
        
        profileImage.addGestureRecognizer(tap)
        profileImage.isUserInteractionEnabled = true
        
        profileImage.layer.cornerRadius = 0.5 * profileImage.bounds.width
        profileImage.clipsToBounds = true
    }
    
    func configureTabBar () {

        tabBarController?.tabBar.isHidden = true
        tabBarController?.delegate = tabBar
        
        tabBar.tabBarController = tabBarController
        tabBar.currentNavigationController = self.navigationController
        
        tabBar.configureActiveTabBarGestureRecognizers(self.view)
        
        if tabBar.previousNavigationController == tabBar.currentNavigationController {
            
            tabBar.shouldHide = true
        }
        
        view.addSubview(tabBar)
    }

    private func presentImageController () {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func addProfilePicture () {
        
        presentImageController()
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] {
            
            selectedImageFromPicker = editedImage as? UIImage
        }
        
        else if let originalImage = info[.originalImage] {
            
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            let firebaseStorage = FirebaseStorage()
            firebaseStorage.saveProfilePictureToStorage(selectedImage)
            
            profileImage.image = selectedImage
            
            profileViewDelegate?.profilePicChanged(selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        <#code#>
//    }
}
