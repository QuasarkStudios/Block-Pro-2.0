//
//  Firebase.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/31/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseStorage {
    
    func saveProfilePictureToStorage (_ profilePicture: UIImage) {
        
        //let profilePicName = UUID().uuidString
        let profilePicData = UIImage.pngData(profilePicture)()
        
        let profilePicturesRef = Storage.storage().reference().child("profilePictures").child("\(Auth.auth().currentUser!.uid).png")//.child("\(profilePicName).png")
        
        if let data = profilePicData {
            
            profilePicturesRef.putData(data, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    
                    ProgressHUD.showError(error?.localizedDescription)
                }
                
                else {
                    
                    profilePicturesRef.downloadURL { (url, error) in
                        
                        if error != nil {
                            
                            ProgressHUD.showError(error?.localizedDescription)
                        }
                        
                        else {
                            
                            let currentUser = CurrentUser.sharedInstance
                            currentUser.profilePictureImage = profilePicture
                            
                            guard let profilePicURL = url?.absoluteString else { return }
                            
                                self.saveProfilePictureToDatabase(profilePicURL)
                        }
                    }
                }
            }
        }
        
        else {
            
            ProgressHUD.showError("Sorry, something went wrong. Please try again later!")
        }
    }
    
    private func saveProfilePictureToDatabase (_ profilePicURL: String) {
        
        let db = Firestore.firestore()
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["profilePicture": profilePicURL], merge: true)
    }
    
    func retrieveProfilePicFromStorage (profilePicURL: String, completion: @escaping (() -> Void)) {
        
        let url = NSURL(string: profilePicURL)
        
        URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
            
            if error != nil {
                
            }
            
            else {
                
                DispatchQueue.main.async {
                    
                    let currentUser = CurrentUser.sharedInstance
                    currentUser.profilePictureImage = UIImage(data: data!)
                    
                    completion()
                    
                    NotificationCenter.default.post(name: .didDownloadProfilePic, object: nil)
                }
            }
        }.resume()
    }
}

extension Notification.Name {
    
    static let didDownloadProfilePic = Notification.Name("didDownloadProfilePic")
}
