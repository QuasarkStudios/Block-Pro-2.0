//
//  Firebase+Collab.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/12/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import Firebase

class FirebaseCollab {
    
    let firebaseStorage = FirebaseStorage()
    
    let currentUser = CurrentUser.sharedInstance
    
    var db = Firestore.firestore()
    lazy var userRef = db.collection("Users").document(currentUser.userID)
    var friendListener: ListenerRegistration?

    var friends: [Friend] = []
    var collabs: [Collab] = []
    
    static let sharedInstance = FirebaseCollab()
    
    func createCollab (collabInfo: NewCollab, completion: @escaping (() -> Void)) {
        
        let batch = db.batch()
        
        let collabID = UUID().uuidString
        let photoIDs: [String] = Array(repeating: UUID().uuidString, count: collabInfo.photos.count)
        
        let collabData: [String : Any] = ["collabID" : collabID, "collabName" : collabInfo.name, "collabObjective" : collabInfo.objective, "startTime" : collabInfo.dates["startTime"]!, "deadline" : collabInfo.dates["deadline"]!, "reminders" : "will be set up later", "photos" : photoIDs]
        
        batch.setData(collabData, forDocument: db.collection("Collaborations").document(collabID))
        
        
        var memberArray: [[String : String]] = []
        
        for member in collabInfo.members {
            
            var memberToBeAdded: [String : String] = [:]
            
            memberToBeAdded["userID"] = member.userID
            memberToBeAdded["firstName"] = member.firstName
            memberToBeAdded["lastName"] = member.lastName
            memberToBeAdded["username"] = member.username
            memberToBeAdded["role"] = "Member"
            
            batch.setData(memberToBeAdded, forDocument: db.collection("Collaborations").document(collabID).collection("Members").document(member.userID))
            memberArray.append(memberToBeAdded)
            
            if member.userID == collabInfo.members.last?.userID {
                
                memberToBeAdded["userID"] = currentUser.userID
                memberToBeAdded["firstName"] = currentUser.firstName
                memberToBeAdded["lastName"] = currentUser.lastName
                memberToBeAdded["username"] = currentUser.username
                memberToBeAdded["role"] = "Lead"
                
                batch.setData(memberToBeAdded, forDocument: db.collection("Collaborations").document(collabID).collection("Members").document(member.userID))
                memberArray.append(memberToBeAdded)
            }
        }
        
        for member in collabInfo.members {
            
            batch.setData(collabData, forDocument: db.collection("Users").document(member.userID).collection("CollabRequests").document(collabID))
            
            for addedMember in memberArray {
                
                if member.userID != addedMember["userID"] {
                    
                    batch.setData(addedMember, forDocument: db.collection("Users").document(member.userID).collection("CollabRequests").document(collabID).collection("Members").document(addedMember["userID"]!))
                }
            }
        }
        
        batch.setData(collabData, forDocument: db.collection("Users").document(currentUser.userID).collection("Collabs").document(collabID))
        
        for addedMember in memberArray {
            
            if currentUser.userID != addedMember["userID"] {
                
                batch.setData(addedMember, forDocument: db.collection("Users").document(currentUser.userID).collection("Collabs").document(collabID).collection("Members").document(addedMember["userID"]!))
            }
        }
        
        
        
        batch.commit { (error) in
            
            if error != nil {
                
                ProgressHUD.showError(error?.localizedDescription)
            }
            
            else {
                    
                var count = 0
                
                for photo in collabInfo.photos {
                    
                    let photoDict: [String : Any] = ["photoID" : photoIDs[count], "photo" : photo]
                    
                    self.firebaseStorage.saveNewCollabPhotosToStorage(collabID: collabID, collabPhoto: photoDict)
                    
                    count += 1
                }
                
                completion()
            }
        }
    }
    
    func retrieveCollabs () {
        
        userRef.collection("Collabs").addSnapshotListener { (snapshot, error) in
            
            self.collabs.removeAll()
            
            if error != nil {
                
                print(error as Any)
            }
            
            else {
                
                if snapshot?.isEmpty == true {
                    
                    print("no collabs")
                }
                
                else {
                    
                    for document in snapshot!.documents {
                        
                        var collab = Collab()
                        
                        collab.collabID = document.data()["collabID"] as! String
                        collab.name = document.data()["collabName"] as! String
                        collab.objective = document.data()["collabObjective"] as! String
                        collab.photoIDs = document.data()["photos"] as! [String]
                        
                        let startTime = document.data()["startTime"] as! Timestamp
                        collab.dates["startTime"] = Date(timeIntervalSince1970: TimeInterval(startTime.seconds))
                        
                        let deadline = document.data()["deadline"] as! Timestamp
                        collab.dates["deadline"] = Date(timeIntervalSince1970: TimeInterval(deadline.seconds))
                        
                        self.userRef.collection("Collabs").document(collab.collabID).collection("Members").getDocuments { (snapshot, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                            }
                            
                            else {
                                
                                if snapshot?.isEmpty != true {
                                    
                                    for document in snapshot!.documents {
                                        
                                        var member = Member()
                                        
                                        member.userID = document.data()["userID"] as! String
                                        member.firstName = document.data()["firstName"] as! String
                                        member.lastName = document.data()["lastName"] as! String
                                        member.username = document.data()["username"] as! String
                                        member.role = document.data()["role"] as! String
                                        
                                        collab.members.append(member)
                                    }
                                }
                            }
                            
                            self.collabs.append(collab)
                            self.collabs = self.collabs.sorted(by: {$0.dates["deadline"]! > $1.dates["deadline"]!})
                        }
                    }
                }
            }
        }
    }
    
    func retrieveUsersFriends () {
        
        friendListener = db.collection("Users").document(currentUser.userID).collection("Friends").addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                ProgressHUD.showError(error?.localizedDescription)
            }
            
            else {
                
                if snapshot?.isEmpty == true {
                    
                    print("you have no friends")
                }
                
                else {
                    
                    self.friends.removeAll()
                    
                    for document in snapshot!.documents {
                        
                        let friend = Friend()
                        
                        friend.userID = document.data()["friendID"] as! String
                        friend.firstName = document.data()["firstName"] as! String
                        friend.lastName = document.data()["lastName"] as! String
                        friend.username = document.data()["username"] as! String
                        
                        self.friends.append(friend)
                        
                        self.cacheFriendProfileImages(friend: friend)
                    }
                    
                    
                    self.friends = self.friends.sorted(by: {$0.lastName.lowercased() < $1.lastName.lowercased()})
                }
            }
        })
    }
    
    func cacheFriendProfileImages (friend: Friend) {
            
        firebaseStorage.retrieveFriendsProfilePicFromStorage(friend: friend) { (profilePic) in
            
            if let profilePic = profilePic {
                
                friend.profilePictureImage = profilePic
            }
        }

        
        
//        if let profilePicURL = profilePicURL {
//
//            firebaseStorage.retrieveFriendsProfilePicFromStorage(profilePicURL: profilePicURL) { (profilePic) in
//
//                if let profilePic = profilePic {
//
//                    self.friendsProfileImageCache.setObject(profilePic, forKey: friendID as AnyObject)
//                }
//            }
//        }
//
//        else {
//
//            friendsProfileImageCache.setObject(UIImage(named: "DefaultProfilePic")!, forKey: friendID as AnyObject)
//        }
    }
}
