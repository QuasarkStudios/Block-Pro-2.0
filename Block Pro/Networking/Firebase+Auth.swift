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
import SVProgressHUD

class FirebaseAuthentication {
    
    
    //MARK: - Sign In User with Email
    
    public func signInUserWithEmail (email: String, password: String, completion: @escaping ((_ error: Error?, _ userDataFound: Bool?) -> Void)) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
                completion(error, false)
            }
            
            else {
                
                self.retrieveSignedInUser(user?.user) { (error, userDataFound) in
                    
                    completion(error, userDataFound)
                }
            }
        }
    }
    
    
    //MARK: - Sign In User with Credential
    
    public func signInUserWithCredential (_ credential: AuthCredential, completion: @escaping ((_ authResult: User?, _ error: Error?) -> Void)) {
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
            if error != nil {
                
                completion(nil, error)
            }
            
            else {
                
                if let user = authResult?.user {
                
                    completion(user, nil)
                }
                
                else {
                    
                    SVProgressHUD.showError(withStatus: "Sorry, something went wrong while signing you in. Please try again later.")
                }
            }
        }
    }
    
    
    //MARK: - Retrieves User's Info from Database
    
    public func retrieveSignedInUser (_ user: User?, _ completion: @escaping ((_ error: Error?, _ userDataFound: Bool?) -> Void)) {
        
        if let signedInUser = user {
            
            let db = Firestore.firestore()
            
            db.collection("Users").document(signedInUser.uid).getDocument { (snapshot, error) in
                
                if error != nil {

                    completion(error, nil)
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
                        
                        completion(nil, true)
                    }
                    
                    else {
                        
                        completion (nil, false)
                    }
                }
            }
        }
    }
    
    
    //MARK: - Verify Email Address

    func verifyEmailAddress (_ email: String, completion: @escaping ((_ emailInUse: Bool?, _ error: NSError?) -> Void)) {
        
        Auth.auth().fetchSignInMethods(forEmail: email) { (signInMethods, error) in
            
            if error != nil {
                
                completion(nil, error as NSError?)
            }
            
            else {
                
                if signInMethods == nil {
                    
                    completion(false, nil)
                }
                
                else {
                    
                   completion(true, nil)
                }
            }
        }
    }
    
    
    //MARK: - Validate Username
    
    public func validateUsername (username: String, completion: @escaping ((_ snapshot: QuerySnapshot?, _ error: Error?) -> Void)) {
        
        let db = Firestore.firestore()
        
        db.collection("Users").whereField("username", isEqualTo: username.lowercased()).getDocuments { (snapshot, error) in
            
            if error != nil {
                
                completion(nil, error)
            }
            
            else {
                
                completion(snapshot, nil)
            }
        }
    }

    
    //MARK: - Create New User
    
    func createNewUser (newUser: NewUser, completion: @escaping ((_ error: NSError?) -> Void)) {

        Auth.auth().createUser(withEmail: newUser.email, password: newUser.password) { (authResult, error) in

            if error != nil {

                completion(error as NSError?)
            }

            else {

                self.saveNewUserData(newUser: newUser, userID: authResult?.user.uid, completion: completion)
            }
        }
    }
    
    
    //MARK: - Save New User Data
    
    func saveNewUserData (newUser: NewUser, userID: String? = Auth.auth().currentUser?.uid, completion: @escaping ((_ error: NSError?) -> Void)) {
        
        let db = Firestore.firestore()

        let accountCreated = Date()
        
        if let userID = userID {
            
            db.collection("Users").document(userID).setData(["userID" : userID, "firstName" : newUser.firstName, "lastName" : newUser.lastName, "username" : newUser.username.lowercased(), "accountCreated" : accountCreated]) { (error) in

                if error != nil {

                    completion(error as NSError?)
                }

                else {

                    let currentUser = CurrentUser.sharedInstance
                    currentUser.userSignedIn = true
                    currentUser.userID = userID
                    currentUser.firstName = newUser.firstName
                    currentUser.lastName = newUser.lastName
                    currentUser.username = newUser.username.lowercased()
                    currentUser.accountCreated = accountCreated

                    completion(nil)

                    InstanceID.instanceID().instanceID(handler: { (result, error) in

                        if error != nil {

                            print(error?.localizedDescription as Any)
                        }

                        else if let result = result {

                            db.collection("Users").document(userID).setData(["fcmToken" : result.token], merge: true)

                            currentUser.fcmToken = result.token
                        }
                    })
                }
            }
        }
        
        else {
            
            SVProgressHUD.showError(withStatus: "Sorry, something went wrong while creating your account. Please try again later.")
        }
    }
    
    
    //MARK: - Log Out User
    
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
    
    
    //MARK: - Get Error Code
    
    public func getErrorCode (_ error: NSError) -> AuthErrorCode? {
        
        return AuthErrorCode(rawValue: error.code)
    }
    
    
    //MARK: - Set New FCM Token
    
    func setNewFCMToken (fcmToken: String) {
        
        let currentUser = CurrentUser.sharedInstance
        currentUser.fcmToken = fcmToken
        
        Firestore.firestore().collection("Users").document(currentUser.userID).setData(["fcmToken" : fcmToken], merge: true)
    }
    
    
    //MARK: - Delete FCM Token
    
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
