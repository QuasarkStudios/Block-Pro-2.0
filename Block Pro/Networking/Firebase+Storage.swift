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
import SVProgressHUD

class FirebaseStorage {
    
    let currentUser = CurrentUser.sharedInstance
    
    let profilePicturesRef = Storage.storage().reference().child("profilePictures")
    let usersStorageRef = Storage.storage().reference().child("Users")
    let collabStorageRef = Storage.storage().reference().child("Collabs")
    let conversationStorageRef = Storage.storage().reference().child("Conversations")
    
    func saveProfilePictureToStorage (_ profilePicture: UIImage) {
        
        let profilePicJPEGData = profilePicture.jpegData(compressionQuality: 0.2)
        
        if let data = profilePicJPEGData {
            
            profilePicturesRef.child("\(currentUser.userID).jpeg").putData(data, metadata: nil) { [weak self] (metadata, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    self?.currentUser.profilePictureImage = profilePicture
                }
            }
        }
        
        else {
            
            SVProgressHUD.showError(withStatus: "Sorry, something went wrong. Please try again later!")
        }
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
                    
                    self.currentUser.profilePictureRetrieved = true
                    self.currentUser.profilePictureImage = nil//UIImage(named: "DefaultProfilePic")!
                    
                    NotificationCenter.default.post(name: .didDownloadProfilePic, object: nil)
                }
                
                completion(nil/*UIImage(named: "DefaultProfilePic")*/, userID)
            }
            
            else {
                
                if let imageData = data {
                    
                    if userID == self.currentUser.userID {
                        
                        self.currentUser.profilePictureRetrieved = true
                        self.currentUser.profilePictureImage = UIImage(data: imageData)
                        
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
    
    func saveCollabPhotosToStorage (_ collabID: String, _ photoID: String, _ photo: UIImage?)  {
        
        let photoData = photo?.jpegData(compressionQuality: 0.2)
        
        if let data = photoData {
            
            collabStorageRef.child(collabID).child("photos").child("\(photoID).jpeg").putData(data, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
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
    
    func saveCollabVoiceMemosToStorage (_ collabID: String, _ voiceMemoID: String) {
        
        let voiceMemoURL = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent(voiceMemoID + ".m4a")
        
        collabStorageRef.child(collabID).child("voiceMemos").child("\(voiceMemoID).m4a").putFile(from: voiceMemoURL, metadata: nil) { (metadata, error) in

            if error != nil {

                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func retrieveCollabVoiceMemoFromStorage (_ collabID: String, _ voiceMemoID: String, completion: @escaping ((_ progress: Double?, _ error: Error?) -> Void)) {
        
//        1048576 * 10
        
        let voiceMemoURL = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent(voiceMemoID + ".m4a")
        
        let downloadTask = collabStorageRef.child(collabID).child("voiceMemos").child("\(voiceMemoID).m4a").write(toFile: voiceMemoURL)
        
        downloadTask.observe(.progress) { (snapshot) in
            
            completion(snapshot.progress?.fractionCompleted, nil)
        }
        
        downloadTask.observe(.success) { (snapshot) in
            
            completion(nil, nil)
        }
        
        downloadTask.observe(.failure) { (snapshot) in
            
            if let error = snapshot.error {
                
                completion(nil, error)
            }
        }
    }
    
    func deleteCollabPhoto (_ collabID: String, photoID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        collabStorageRef.child(collabID).child("photos").child("\(photoID).jpeg").delete { (error) in
            
            completion(error)
        }
    }
    
    func deleteCollabVoiceMemo (_ collabID: String, voiceMemoID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        collabStorageRef.child(collabID).child("voiceMemos").child(voiceMemoID + ".m4a").delete { (error) in
            
            completion(error)
        }
    }
    
    func savePersonalBlockPhotosToStorage (_ blockID: String, _ photoID: String, _ photo: UIImage?) {
        
        if let data = photo?.jpegData(compressionQuality: 0.2) {
            
            usersStorageRef.child(currentUser.userID).child("blocks").child(blockID).child("photos").child("\(photoID).jpeg").putData(data, metadata: nil) { (metatdata, error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    
    func saveCollabBlockPhotosToStorage (_ collabID: String, _ blockID: String, _ photoID: String, _ photo: UIImage?) {
        
        let photoData = photo?.jpegData(compressionQuality: 0.2)
        
        if let data = photoData {
            
            collabStorageRef.child(collabID).child("blocks").child(blockID).child("photos").child("\(photoID).jpeg").putData(data, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    
    func retrievePersonalBlockPhotoFromStorage (_ blockID: String, _ photoID: String, completion: @escaping ((_ error: Error?, _ photo: UIImage?) -> Void)) {
        
        usersStorageRef.child(currentUser.userID).child("blocks").child(blockID).child("photos").child("\(photoID).jpeg").getData(maxSize: 1048576) { (data, error) in
            
            if error != nil {
                
                completion(error, nil)
            }
            
            else {
                
                if let photoData = data {
                    
                    completion(nil, UIImage(data: photoData))
                }
            }
        }
    }
    
    func retrieveCollabBlockPhotoFromStorage (_ collabID: String, _ blockID: String, _ photoID: String, completion: @escaping ((_ error: Error?, _ photo: UIImage?) -> Void)) {
        
        collabStorageRef.child(collabID).child("blocks").child(blockID).child("photos").child("\(photoID).jpeg").getData(maxSize: 1048576) { (data, error) in
            
            if error != nil {
                
                completion(error, nil)
            }
            
            else {
                
                if let photoData = data {
                    
                    completion(nil, UIImage(data: photoData))
                }
            }
        }
    }
    
    func savePersonalBlockVoiceMemosToStorage (_ blockID: String, _ voiceMemoID: String) {
        
        let voiceMemoURL = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent(voiceMemoID + ".m4a")
        
        usersStorageRef.child(currentUser.userID).child("blocks").child(blockID).child("voiceMemos").child("\(voiceMemoID).m4a").putFile(from: voiceMemoURL, metadata: nil) { (metadata, error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func saveCollabBlockVoiceMemosToStorage (_ collabID: String, _ blockID: String, _ voiceMemoID: String) {
        
        let voiceMemoURL = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent(voiceMemoID + ".m4a")
        
        collabStorageRef.child(collabID).child("blocks").child(blockID).child("voiceMemos").child("\(voiceMemoID).m4a").putFile(from: voiceMemoURL, metadata: nil) { (metatdata, error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func retrievePersonalBlockVoiceMemosFromStorage (_ blockID: String, _ voiceMemoID: String, completion: @escaping ((_ progress: Double?, _ error: Error?) -> Void)) {
        
        let voiceMemoURL = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent(voiceMemoID + ".m4a")
        
        let downloadTask = usersStorageRef.child(currentUser.userID).child("blocks").child(blockID).child("voiceMemos").child(voiceMemoID + ".m4a").write(toFile: voiceMemoURL)
        
        downloadTask.observe(.progress) { (snapshot) in
            
            completion(snapshot.progress?.fractionCompleted, nil)
        }
        
        downloadTask.observe(.success) { (snapshot) in
            
            completion(nil, nil)
        }
        
        downloadTask.observe(.failure) { (snapshot) in
            
            if let error = snapshot.error {
                
                completion(nil, error)
            }
        }
    }
    
    func retrieveCollabBlockVoiceMemosFromStorage (_ collabID: String, _ blockID: String, _ voiceMemoID: String, completion: @escaping ((_ progress: Double?, _ error: Error?) -> Void)) {
        
        let voiceMemoURL = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent(voiceMemoID + ".m4a")
        
        let downloadTask = collabStorageRef.child(collabID).child("blocks").child(blockID).child("voiceMemos").child(voiceMemoID + ".m4a").write(toFile: voiceMemoURL)
        
        downloadTask.observe(.progress) { (snapshot) in
            
            completion(snapshot.progress?.fractionCompleted, nil)
        }
        
        downloadTask.observe(.success) { (snapshot) in
            
            completion(nil, nil)
        }
        
        downloadTask.observe(.failure) { (snapshot) in
            
            if let error = snapshot.error {
                
                completion(nil, error)
            }
        }
    }
    
    func deletePersonalBlockPhoto (_ blockID: String, _ photoID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        usersStorageRef.child(currentUser.userID).child("blocks").child(blockID).child("photos").child(photoID + ".jpeg").delete { (error) in
            
            completion(error)
        }
    }
    
    func deleteCollabBlockPhoto (_ collabID: String, _ blockID: String, _ photoID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        collabStorageRef.child(collabID).child("blocks").child(blockID).child("photos").child(photoID + ".jpeg").delete { (error) in
            
            completion(error)
        }
    }
    
    func deletePersonalBlockVoiceMemo (_ blockID: String, voiceMemoID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        usersStorageRef.child(currentUser.userID).child("blocks").child(blockID).child("voiceMemos").child(voiceMemoID + ".m4a").delete { (error) in
            
            completion(error)
        }
    }
    
    func deleteCollabBlockVoiceMemo (_ collabID: String, _ blockID: String, _ voiceMemoID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        collabStorageRef.child(collabID).child("blocks").child(blockID).child("voiceMemos").child(voiceMemoID + ".m4a").delete { (error) in
            
            completion(error)
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
    
    func getStorageErrorCode (_ error: NSError) -> StorageErrorCode? {
        
        return StorageErrorCode(rawValue: error.code)
    }
}
