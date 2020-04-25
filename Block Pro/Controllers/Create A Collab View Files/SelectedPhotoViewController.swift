//
//  SelectedPhotoViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/22/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol PhotoEdited: AnyObject {
    
    func photoChanged (changedPhoto: UIImage)
    
    func photoDeleted (deletedPhoto: UIImage)
}

class SelectedPhotoViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var selectedPhotoImageView: UIImageView!
    
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var selectedPhoto: UIImage?
    
    weak var photoEditedDelegate: PhotoEdited?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    private func configureView () {

        navBar.configureNavBar()
        
        selectedPhotoImageView.image = selectedPhoto
        selectedPhotoImageView.contentMode = .scaleAspectFill
        
        changeButton.layer.cornerRadius = 12
        deleteButton.layer.cornerRadius = 10
        
        if #available(iOS 13.0, *) {
            
            changeButton.layer.cornerCurve = .continuous
            deleteButton.layer.cornerCurve = .continuous
        }
    }
    
    private func changePhoto () {
        
        let photoAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        photoAlert.view.tintColor = .black

        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { (takePhoto) in

            let imagePicker = UIImagePickerController()
            imagePicker.navigationBar.configureNavBar()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }

        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default) { (chooseFromLibrary) in

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        photoAlert.addAction(takePhotoAction)
        photoAlert.addAction(chooseFromLibraryAction)
        photoAlert.addAction(cancelAction)

        present(photoAlert, animated: true)
    }

    @IBAction func cancelBButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func changeButton(_ sender: Any) {
        
        changePhoto()
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        
        if let photo = selectedPhoto {
            
            photoEditedDelegate?.photoDeleted(deletedPhoto: photo)
            dismiss(animated: true, completion: nil)
        }
        
        else {
            
            dismiss(animated: true) {
                SVProgressHUD.showError(withStatus: "Sorry, something went wrong deleting this photo")
            }
        }
    }
}

extension SelectedPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] {
            
            selectedImageFromPicker = editedImage as? UIImage
        }
        
        else if let originalImage = info[.originalImage] {
            
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            photoEditedDelegate?.photoChanged(changedPhoto: selectedImage)
            
            selectedPhoto = selectedImage
            selectedPhotoImageView.image = selectedImage
        }
        
        else {
            
            SVProgressHUD.showError(withStatus: "Sorry, something went wrong selecting this photo")
        }
        
        dismiss(animated: true, completion: nil)
    }
}
