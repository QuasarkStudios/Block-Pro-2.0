//
//  Firebase.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/31/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
//import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseStorage {
    
    let currentUser = CurrentUser.sharedInstance
    
    let profilePicturesRef = Storage.storage().reference().child("profilePictures")
    let collabStorageRef = Storage.storage().reference().child("Collabs")
    let conversationStorageRef = Storage.storage().reference().child("Conversations")
    
    func saveProfilePictureToStorage (_ profilePicture: UIImage) {
        
        //let profilePicName = UUID().uuidString
        
        let profilePicJPEGData = profilePicture.jpegData(compressionQuality: 0.2)
        
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
    
    //delete later
    private func saveProfilePictureToDatabase (_ profilePicURL: String) {
        
        let db = Firestore.firestore()
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["profilePicture": profilePicURL], merge: true)
    }
    
//    func retrieveCurrentUsersProfilePicFromStorage (profilePicURL: String, completion: @escaping (() -> Void)) {
//
//        let url = NSURL(string: profilePicURL)
//
//        URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
//
//            if error != nil {
//
//                print(error?.localizedDescription)
//            }
//
//            else {
//
//                DispatchQueue.main.async {
//
//                    let currentUser = CurrentUser.sharedInstance
//                    currentUser.profilePictureImage = UIImage(data: data!)
//
//                    completion()
//
//                    NotificationCenter.default.post(name: .didDownloadProfilePic, object: nil)
//                }
//            }
//        }.resume()
//    }
    
    func retrieveUserProfilePicFromStorage (userID: String, completion: @escaping ((_ profilePic: UIImage?, _ userID: String) -> Void)) {
        
        profilePicturesRef.child("\(userID).jpeg").getData(maxSize: 3 * 1048576) { (data, error) in
            
            if error != nil {
                
                if userID == self.currentUser.userID {
                    
                    self.currentUser.profilePictureImage = UIImage(named: "DefaultProfilePic")!
                    
                    NotificationCenter.default.post(name: .didDownloadProfilePic, object: nil)
                }
                
                completion(UIImage(named: "DefaultProfilePic"), userID)
            }
            
            else {
                
                if let imageData = data {
                    
                    if userID == self.currentUser.userID {
                        
                        self.currentUser.profilePictureImage = UIImage(data: data!)
                        
                        NotificationCenter.default.post(name: .didDownloadProfilePic, object: nil)
                    }
                    
                    completion(UIImage(data: imageData), userID)
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
    
    func saveCollabCoverPhoto (collabID: String, coverPhoto: UIImage, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let photoData = coverPhoto.jpegData(compressionQuality: 0.2)
        
        if let data = photoData {
            
            let uploadTask = collabStorageRef.child(collabID).child("CoverPhoto.jpeg").putData(data)
            
            uploadTask.observe(.failure) { (snapshot) in
                
                if let error = snapshot.error {
                    
                    completion(error)
                }
            }
            
            uploadTask.observe(.success) { (snapshot) in
                
                completion(nil)
            }
        }
    }
    
    func retrieveCollabCoverPhoto (collabID: String, completion: @escaping ((_ coverPhoto: UIImage?, _ error: Error?) -> Void)) {
        
        collabStorageRef.child(collabID).child("CoverPhoto.jpeg").getData(maxSize: 1048576) { (data, error) in
            
            if error != nil {
                
                completion(nil, error)
            }
            
            else {
                
                if let photoData = data {
                    
                    completion(UIImage(data: photoData), nil)
                }
            }
        }
    }
    
    func deleteCollabCoverPhoto (collabID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        collabStorageRef.child(collabID).child("CoverPhoto.jpeg").delete { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                completion(nil)
            }
        }
    }
    
    func saveNewCollabPhotosToStorage (_ collabID: String, _ photoID: String, _ photo: UIImage)  {
        
        let photoData = photo.jpegData(compressionQuality: 0.2)
        
        if let data = photoData {
            
            collabStorageRef.child(collabID).child("photos").child("\(photoID).jpeg").putData(data, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    
                    print(error as Any)
                }
            }
        }
    }
    
    func retrieveCollabPhotosFromStorage (collabID: String, photoID: String, completion: @escaping ((_ photos: UIImage?, _ error: Error?) -> Void)) {
        
        collabStorageRef.child(collabID).child("photos").child("\(photoID).jpeg").getData(maxSize: 1048576) { (data, error) in
            
            if error != nil {
                
                completion(nil, error)
            }
            
            else {
                
                if let photoData = data {
                    
                    completion(UIImage(data: photoData), nil)
                }
            }
        }
    }
    
    func saveConversationCoverPhoto (conversationID: String, coverPhoto: UIImage, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let photoData = coverPhoto.jpegData(compressionQuality: 0.2)
        
        if let data = photoData {
            
            let uploadTask = conversationStorageRef.child(conversationID).child("CoverPhoto.jpeg").putData(data)
            
            uploadTask.observe(.failure) { (snapshot) in
                
                if let error = snapshot.error {
                    
                    completion(error)
                }
            }
            
            uploadTask.observe(.success) { (snapshot) in
                
                completion(nil)
            }
        }
    }
    
    func retrievePersonalConversationCoverPhoto (conversationID: String, completion: @escaping ((_ coverPhoto: UIImage?, _ error: Error?) -> Void)) {
        
        conversationStorageRef.child(conversationID).child("CoverPhoto.jpeg").getData(maxSize: 1048576) { (data, error) in
            
            if error != nil {
                
                //print(error as Any)
                
                //completion(nil, error)
            }
            
            else {
                
                if let photoData = data {
                    
                    completion(UIImage(data: photoData), nil)
                }
            }
        }
    }
    
    func deletePersonalConversationCoverPhoto (conversationID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        conversationStorageRef.child(conversationID).child("CoverPhoto.jpeg").delete { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                completion(nil)
            }
        }
    }
    
    func savePersonalMessagePhoto (conversationID: String, messagePhoto: [String : Any], completion: @escaping ((_ error: Error?) -> Void)) {
        
        let photoID = messagePhoto["photoID"] as! String
        let photo = messagePhoto["photo"] as! UIImage//UIImage.pngData(messagePhoto["photo"] as! UIImage)()
        
        let photoData = photo.jpegData(compressionQuality: 0.2)
        
        if let data = photoData {
           
            let uploadTask = conversationStorageRef.child(conversationID).child("MessagePhotos").child(photoID + ".jpeg").putData(data)
            
            uploadTask.observe(.failure) { (snapshot) in
                
                if let error = snapshot.error {
                    
                    completion(error)
                }
            }
            
            uploadTask.observe(.success) { (snapshot) in
                
                completion(nil)
            }
        }
    }
    
    func retrievePersonalMessagePhoto (conversationID: String, photoID: String, completion: @escaping ((_ photo: UIImage?, _ error: Error?) -> Void)) {
        
        conversationStorageRef.child(conversationID).child("MessagePhotos").child(photoID + ".jpeg").getData(maxSize: 1048576) { (data, error) in
            
            if error != nil {
                
                print(error as Any)
                
                completion(nil, error)
            }
            
            else {
                
                if let photoData = data {
                    
                    completion(UIImage(data: photoData), nil)
                }
            }
        }
    }
    
    func saveCollabMessagePhoto (collabID: String, messagePhoto: [String : Any], completion: @escaping ((_ error: Error?) -> Void)) {
        
        let photoID = messagePhoto["photoID"] as! String
        let photo = messagePhoto["photo"] as! UIImage
        
        let photoData = photo.jpegData(compressionQuality: 0.2)
        
        if let data = photoData {
            
            let uploadTask = collabStorageRef.child(collabID).child("MessagePhotos").child(photoID + ".jpeg").putData(data)
            
            uploadTask.observe(.failure) { (snapshot) in
                
                if let error = snapshot.error {
                    
                    completion(error)
                }
            }
            
            uploadTask.observe(.success) { (snapshot) in
                
                completion(nil)
            }
        }
    }
    
    func retrieveCollabMessagePhoto (collabID: String, photoID: String, completion: @escaping ((_ photo: UIImage?, _ error: Error?) -> Void)) {
        
        collabStorageRef.child(collabID).child("MessagePhotos").child(photoID + ".jpeg").getData(maxSize: 1048576) { (data, error) in
            
            if error != nil {
                
                completion(nil, error)
            }
            
            else {
                
                if let photoData = data {
                    
                    completion(UIImage(data: photoData), nil)
                }
            }
        }
    }
}
