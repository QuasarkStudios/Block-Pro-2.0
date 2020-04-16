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
    
    let profilePicturesRef = Storage.storage().reference().child("profilePictures")
    
    func saveProfilePictureToStorage (_ profilePicture: UIImage) {
        
        //let profilePicName = UUID().uuidString
        let profilePicData = UIImage.pngData(profilePicture)()
        
        //.child("\(profilePicName).png")
        
        if let data = profilePicData {
            
            profilePicturesRef.child("\(Auth.auth().currentUser!.uid).png").putData(data, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    
                    ProgressHUD.showError(error?.localizedDescription)
                }
                
                else {
                    
                    self.profilePicturesRef.child("\(Auth.auth().currentUser!.uid).png").downloadURL { (url, error) in
                        
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
    
    func retrieveFriendsProfilePicFromStorage (friend: Friend, completion: @escaping ((_ profilePic: UIImage?) -> Void)) {
        
        profilePicturesRef.child("\(friend.friendID).png").getData(maxSize: 3 * 1048576) { (data, error) in
            
            if error == nil {
                
                if let imageData = data {
                    
                    completion(UIImage(data: imageData))
                }
                

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
}

extension Notification.Name {
    
    static let didDownloadProfilePic = Notification.Name("didDownloadProfilePic")
}
