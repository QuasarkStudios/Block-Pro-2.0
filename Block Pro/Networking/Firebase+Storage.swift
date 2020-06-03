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
    
    let currentUser = CurrentUser.sharedInstance
    
    let collabStorageRef = Storage.storage().reference().child("Collabs")
    let profilePicturesRef = Storage.storage().reference().child("profilePictures")
    
    func saveProfilePictureToStorage (_ profilePicture: UIImage) {
        
        //let profilePicName = UUID().uuidString
        
        let profilePicJPEGData = profilePicture.jpegData(compressionQuality: 0.1)
        
        if let data = profilePicJPEGData {
            
            profilePicturesRef.child("\(currentUser.userID).jpeg").putData(data, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    
                    ProgressHUD.showError(error?.localizedDescription)
                }
                
                else {
                    
                    self.profilePicturesRef.child("\(Auth.auth().currentUser!.uid).jpeg").downloadURL { (url, error) in
                        
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
    
    func retrieveCurrentUsersProfilePicFromStorage (profilePicURL: String, completion: @escaping (() -> Void)) {
        
        let url = NSURL(string: profilePicURL)
        
        URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
            
            if error != nil {
                
                print(error?.localizedDescription)
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
    
    func retrieveUserProfilePicFromStorage (userID: String, completion: @escaping ((_ profilePic: UIImage?, _ userID: String) -> Void)) {
        
        profilePicturesRef.child("\(userID).jpeg").getData(maxSize: 3 * 1048576) { (data, error) in
            
            if error == nil {
                
                if let imageData = data {
                    
                    completion(UIImage(data: imageData), userID)
                }
                

            }
            
            else {
                
                print(error)
            }
        }
        
//        let url = NSURL(string: profilePicURL)
//
//        URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
//
//            if error != nil {
//
//                completion(nil)
//            }
//
//            else {
//
//                DispatchQueue.main.async {
//
//                    completion(UIImage(data: data!))
//                }
//            }
//        }.resume()
    }
    
    func saveNewCollabPhotosToStorage (collabID: String, collabPhoto: [String : Any])  {
        
        let photoData = UIImage.pngData(collabPhoto["photo"] as! UIImage)()
        
        if let data = photoData {
            
            collabStorageRef.child(collabID).child("photos").child("\(collabPhoto["photoID"]!)).png").putData(data, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    
                    print(error as Any)
                }
            }
        }
    }
    
    func retrieveCollabPhotosFromStoage (collabID: String, completion: @escaping ((_ photos: [UIImage]) -> Void)) {
        
        collabStorageRef.child(collabID).child("photos").getData(maxSize: 3 * 1048576) { (data, error) in
            
            if error != nil {
                
                
            }
            
            else {
                
                if let photoData = data {
                    
//                    let photos: [UIImage] =
                    
                    print(photoData)
                    
//                    completion(photos)
                }
            }
        }
    }
}
