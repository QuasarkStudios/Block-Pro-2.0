//
//  Firebase+Auth.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/30/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

class FirebaseAuthentication {
    
    //MARK: - Log In User Function
    
    public func logInUser (email: String, password: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                self.retrieveSignedInUser(user?.user) { (error) in
                    
                    completion(error)
                }
            }
        }
    }
    
    public func logOutUser (completion: ((_ error: Error?) -> Void)) {
        
        do {
            
            try Auth.auth().signOut()
            
            let currentUser = CurrentUser.sharedInstance
            currentUser.userSignedIn = false
            
            deleteFCMToken()
            
            completion(nil)
            
        } catch let signOutError as NSError {
            
            completion(signOutError)
        }
    }
    
    
    //MARK: - Retrieves User's Info from Database
    
    public func retrieveSignedInUser (_ user: User?, _ completion: @escaping ((_ error: Error?) -> Void)) {
        
        if let signedInUser = user {
            
            let db = Firestore.firestore()
            
            db.collection("Users").document(signedInUser.uid).getDocument { (snapshot, error) in
                
                if error != nil {

                    completion(error)
                }
                
                else {
                    
                    if snapshot?.exists == true {
                        
                        let currentUser = CurrentUser.sharedInstance
                        
                        currentUser.userSignedIn = true
                        
                        currentUser.userID = snapshot?["userID"] as! String
                        currentUser.firstName = snapshot?["firstName"] as! String
                        currentUser.lastName = snapshot?["lastName"] as! String
                        currentUser.username = snapshot?["username"] as! String
                        
                        if let timestamp = snapshot?["accountCreated"] as? Timestamp {
                            
                            let accountCreated = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                            currentUser.accountCreated = accountCreated
                        }
                        
                        InstanceID.instanceID().instanceID(handler: { (result, error) in

                            if error != nil {

                                print(error?.localizedDescription as Any)
                            }

                            else if let result = result {

                                if let fcmToken = snapshot?["fcmToken"] as? String, fcmToken == result.token {

                                    currentUser.fcmToken = fcmToken
                                }

                                else {

                                    self.setNewFCMToken(fcmToken: result.token)
                                }
                            }
                        })
                        
//                        currentUser.profilePictureURL = snapshot?["profilePicture"] as? String
                        
                        completion(nil)
                    }
                    
                    else {
                        
                        completion (nil)
                    }
                }
            }
        }
    }
    
    
    //MARK: - Registration Process

    public func validateUsername (username: String, completion: @escaping ((_ snapshot: QuerySnapshot?, _ error: Error?) -> Void)) {
        
        let db = Firestore.firestore()
        
        db.collection("Users").whereField("username", isEqualTo: username.lowercased()).getDocuments { (snapshot, error) in
            
            if error != nil {
                
                completion(nil, error)
            }
            
            else {
                
                if snapshot?.isEmpty == false {
                    
                    completion(snapshot, nil)
                }
                
                else {
                    
                    completion(nil, nil)
                }
            }
        }
    }
    
    
    public func validateAccountInfoAndRegisterNewUser (email: String, password: String, completion: @escaping ((_ userID: String?,
        _ error: Error?) -> Void)) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            if error != nil {

                completion(nil, error)
            }
            
            else {
                
                if let userID = authResult?.user.uid {
                    
                    completion(userID, nil)
                }
                
                else {
                    
                    completion(nil, nil)
                }
            }
        }
    }
    
    
    public func getErrorCode (_ error: NSError) -> AuthErrorCode? {
        
        return AuthErrorCode(rawValue: error.code)
    }
    
    
    public func createNewUser (userID: String, newUser: NewUser, completion: (() -> Void)) {
        
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        
//        db.collection("Users").document(userID).setData(["userID" : userID, "firstName" : newUser.firstName, "lastName" : newUser.lastName, "username" : newUser.username.lowercased(), "accountCreated" : formatter.string(from: Date())])
        
        #warning("not tested yet, it honestly looks like this whole function needs more testing.... where is the currentUser singleton set")
        db.collection("Users").document(userID).setData(["userID" : userID, "firstName" : newUser.firstName, "lastName" : newUser.lastName, "username" : newUser.username.lowercased(), "accountCreated" : Date()]) { (error) in
            
            if error == nil {
                
                InstanceID.instanceID().instanceID(handler: { (result, error) in

                    if error != nil {

                        print(error?.localizedDescription as Any)
                    }

                    else if let result = result {

                        db.collection("Users").document(userID).setData(["fcmToken" : result.token], merge: true)
                    }
                })
                
//                InstanceID.instanceID().getID { (fcmToken, error) in
//
//                    if error != nil {
//
//                        print(error?.localizedDescription as Any)
//                    }
//
//                    else if let token = fcmToken {
//
//                        db.collection("Users").document(userID).setData(["fcmToken" : token], merge: true)
//                    }
//                }
            }
        }
        
        completion()
    }
    
    func setNewFCMToken (fcmToken: String) {
        
        let currentUser = CurrentUser.sharedInstance
        currentUser.fcmToken = fcmToken
        
        Firestore.firestore().collection("Users").document(currentUser.userID).setData(["fcmToken" : fcmToken], merge: true)
    }
    
    func deleteFCMToken () {
        
        let currentUser = CurrentUser.sharedInstance
        
        Firestore.firestore().collection("Users").document(currentUser.userID).updateData(["fcmToken" : FieldValue.delete()])
        
        InstanceID.instanceID().deleteID { (error) in
            
            if error != nil {
                
                print("error deleting fcm instance id: ", error?.localizedDescription as Any)
            }
        }
    }
}
