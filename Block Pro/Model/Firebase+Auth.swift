//
//  Firebase+Auth.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/30/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import Firebase

class UserAuthentication {
    
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
    
    
    //MARK: - Retrieves User's Info from Database
    
    public func retrieveSignedInUser (_ user: User?, _ completion: @escaping ((_ error: Error?) -> Void)) {
        
        if let signedInUser = user {
            
            let db = Firestore.firestore()
            
            db.collection("Users").document(signedInUser.uid).getDocument { (snapshot, error) in
                
                if error != nil {

                    completion(error)
                }
                
                else {
                    
                    let currentUser = CurrentUser.sharedInstance
                    
                    currentUser.userID = snapshot?["userID"] as! String
                    currentUser.firstName = snapshot?["firstName"] as! String
                    currentUser.lastName = snapshot?["lastName"] as! String
                    currentUser.username = snapshot?["username"] as! String
                    currentUser.accountCreated = snapshot?["accountCreated"] as! String
                    
                    currentUser.profilePictureURL = snapshot?["profilePicture"] as? String
                    
                    completion(nil)
                }
            }
        }
    }
    
    
    //MARK: - Registration Process

    public func validateUsername (username: String, completion: @escaping ((_ snapshot: QuerySnapshot?, _ error: Error?) -> Void)) {
        
        let db = Firestore.firestore()
        
        db.collection("Users").whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
            
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
        
        db.collection("Users").document(userID).setData(["userID" : userID, "firstName" : newUser.firstName, "lastName" : newUser.lastName, "username" : newUser.username, "accountCreated" : formatter.string(from: Date())])
        
        completion()
    }
}
