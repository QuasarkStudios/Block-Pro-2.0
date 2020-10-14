//
//  Firebase+Collab.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/12/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
//import Firebase
import FirebaseFirestore

class FirebaseCollab {
    
    let firebaseStorage = FirebaseStorage()
    
    let currentUser = CurrentUser.sharedInstance
    
    var db = Firestore.firestore()
    lazy var userRef = db.collection("Users").document(currentUser.userID)
    var friendListener: ListenerRegistration?

    var messageListener: ListenerRegistration?
    
    var friends: [Friend] = []
    var collabs: [Collab] = []
    var membersProfilePics: [String : UIImage?] = [:]
    //var collabRequests: [CollabRequest] = []
    
    static let sharedInstance = FirebaseCollab()
    
    func createCollab (collabInfo: NewCollab, completion: @escaping (() -> Void)) {
        
        let batch = db.batch()
        
        let collabID = UUID().uuidString
        let photoIDs: [String] = Array(repeating: UUID().uuidString, count: collabInfo.photos.count)
        
        let collabData: [String : Any] = ["collabID" : collabID, "collabName" : collabInfo.name, "dateCreated" : Date(), "collabObjective" : collabInfo.objective, "startTime" : collabInfo.dates["startTime"]!, "deadline" : collabInfo.dates["deadline"]!, "reminders" : "will be set up later", "photos" : photoIDs]
        let memberCollabData: [String : Any] = ["collabID" : collabID, "collabName" : collabInfo.name,  "dateCreated" : Date(), "collabObjective" : collabInfo.objective, "startTime" : collabInfo.dates["startTime"]!, "deadline" : collabInfo.dates["deadline"]!, "reminders" : "will be set up later"]
        
        batch.setData(collabData, forDocument: db.collection("Collaborations").document(collabID))
        
        var memberDictArray: [[String : String]] = []
        var memberUserIDArray: [String] = []
        
        for member in collabInfo.members {
            
            var memberToBeAdded: [String : String] = [:]
            
            memberToBeAdded["userID"] = member.userID
            memberToBeAdded["firstName"] = member.firstName
            memberToBeAdded["lastName"] = member.lastName
            memberToBeAdded["username"] = member.username
            memberToBeAdded["role"] = "Member"
            
            batch.setData(memberToBeAdded, forDocument: db.collection("Collaborations").document(collabID).collection("Members").document(member.userID))
            memberDictArray.append(memberToBeAdded)
            memberUserIDArray.append(member.userID)
            
            //The person who created the collab
            if member.userID == collabInfo.members.last?.userID {
                
                memberToBeAdded["userID"] = currentUser.userID
                memberToBeAdded["firstName"] = currentUser.firstName
                memberToBeAdded["lastName"] = currentUser.lastName
                memberToBeAdded["username"] = currentUser.username
                memberToBeAdded["role"] = "Lead"
                
                batch.setData(memberToBeAdded, forDocument: db.collection("Collaborations").document(collabID).collection("Members").document(memberToBeAdded["userID"]!))
                memberDictArray.append(memberToBeAdded)
                memberUserIDArray.append(currentUser.userID)
            }
        }

        //Saving members userID to a memberArray
        batch.setData(["Members" : memberUserIDArray], forDocument: db.collection("Collaborations").document(collabID), merge: true)
        
        for member in collabInfo.members {

            batch.setData(memberCollabData, forDocument: db.collection("Users").document(member.userID).collection("CollabRequests").document(collabID))

            for addedMember in memberDictArray {

                batch.setData(addedMember, forDocument: db.collection("Users").document(member.userID).collection("CollabRequests").document(collabID).collection("Members").document(addedMember["userID"]!))
            }
        }

        //Sets the leader collab data
        //batch.setData(memberCollabData, forDocument: db.collection("Users").document(currentUser.userID).collection("Collabs").document(collabID))


        //Setting the members for the collab to the leaders collab document
//        for addedMember in memberArray {
//
//            batch.setData(addedMember, forDocument: db.collection("Users").document(currentUser.userID).collection("Collabs").document(collabID).collection("Members").document(addedMember["userID"]!))
//        }

        commitBatch(batch: batch) {

            var count = 0

            for photo in collabInfo.photos {

                let photoDict: [String : Any] = ["photoID" : photoIDs[count], "photo" : photo]

                self.firebaseStorage.saveNewCollabPhotosToStorage(collabID: collabID, collabPhoto: photoDict)

                count += 1
            }

            completion()
        }
    }
    
    func saveCollabCoverPhoto (collabID: String, coverPhotoID: String, coverPhoto: UIImage, completion: @escaping ((_ error: Error?) -> Void)) {
        
        self.firebaseStorage.saveCollabCoverPhoto(collabID: collabID, coverPhoto: coverPhoto) { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                let batch = self.db.batch()
                
                batch.setData(["coverPhotoID" : coverPhotoID], forDocument: self.db.collection("Collaborations").document(collabID), merge: true)
                
                let messageDict: [String : Any] = ["sender" : self.currentUser.userID, "memberUpdatedConversationCover" : true, "timestamp" : Date()]
                batch.setData(messageDict, forDocument: self.db.collection("Collaborations").document(collabID).collection("Messages").document(UUID().uuidString))
                
                batch.commit { (error) in
                    
                    if error != nil {
                        
                        completion(error)
                    }
                    
                    else {
                        
                        if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == collabID }) {
                            
                            self.collabs[collabIndex].coverPhotoID = coverPhotoID
                            self.collabs[collabIndex].coverPhoto = coverPhoto
                            
                            print("check")
                            
                            completion(nil)
                        }
                        
                        else {
                            
                            print("fuck")
                        }
                    }
                }
            }
        }
    }
    
    func deleteCollabCoverPhoto (collabID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        firebaseStorage.deleteCollabCoverPhoto(collabID: collabID) { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                let batch = self.db.batch()
                
                batch.updateData(["coverPhotoID" : FieldValue.delete()], forDocument: self.db.collection("Collaborations").document(collabID))
                
                //Creating a message notifying the conversation that a user deleted the cover photo
                let messageDict: [String : Any] = ["sender" : self.currentUser.userID, "memberUpdatedConversationCover" : false, "timestamp" : Date()]
                batch.setData(messageDict, forDocument: self.db.collection("Collaborations").document(collabID).collection("Messages").document(UUID().uuidString))
                
                batch.commit { (error) in
                    
                    if error != nil {
                        
                        completion(error)
                    }
                    
                    else {
                        
                        if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == collabID }) {

                            self.collabs[collabIndex].coverPhotoID = nil
                            self.collabs[collabIndex].coverPhoto = nil
                        }

                        completion(nil)
                    }
                }
            }
        }
    }
    
    func retrieveCollabs () {
        
        //userRef.collection("Collabs").addSnapshotListener { (snapshot, error) in
        db.collection("Collaborations").whereField("Members", arrayContains: currentUser.userID).addSnapshotListener { (snapshot, error) in
        
//            self.collabs.removeAll()
            
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
                        collab.objective = document.data()["collabObjective"] as? String
                        
                        collab.coverPhotoID = document.data()["coverPhotoID"] as? String
                        
//                        collab.photoIDs = document.data()["photos"] as! [String]
                        
                        let startTime = document.data()["startTime"] as! Timestamp
                        collab.dates["startTime"] = Date(timeIntervalSince1970: TimeInterval(startTime.seconds))
                        
                        let memberActivity: [String : Any]? = document.data()["memberActivity"] as? [String : Any]
                        collab.memberActivity = self.parseCollabActivity(memberActivity: memberActivity)
                        
                        let deadline = document.data()["deadline"] as! Timestamp
                        collab.dates["deadline"] = Date(timeIntervalSince1970: TimeInterval(deadline.seconds))
                        
                        //self.userRef.collection("Collabs").document(collab.collabID).collection("Members").getDocuments { (snapshot, error) in
                        self.db.collection("Collaborations").document(collab.collabID).collection("Members").getDocuments{ (snapshot, error) in
                        
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
                                    
                                    self.collabs.append(collab)
                                    self.collabs = self.collabs.sorted(by: {$0.dates["deadline"]! > $1.dates["deadline"]!})
                                }
                                
                                else {
                                    
                                    self.collabs.append(collab)
                                    self.collabs = self.collabs.sorted(by: {$0.dates["deadline"]! > $1.dates["deadline"]!})
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func retrieveCollabRequests (completion: @escaping ((_ requests: [CollabRequest]) -> Void)) {
        
        userRef.collection("CollabRequests").getDocuments { (snapshot, error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
            
            else {
                
                if snapshot?.isEmpty == false {
                    
                    var collabRequests: [CollabRequest] = []
                    
                    for document in snapshot!.documents {
                        
                        var collabRequest = CollabRequest()
                        
                        collabRequest.collabID = document.data()["collabID"] as! String
                        collabRequest.name = document.data()["collabName"] as! String
                        collabRequest.objective = document.data()["collabObjective"] as! String
                        
                        let startTime = document.data()["startTime"] as! Timestamp
                        collabRequest.dates["startTime"] = Date(timeIntervalSince1970: TimeInterval(startTime.seconds))
                        
                        let deadline = document.data()["deadline"] as! Timestamp
                        collabRequest.dates["deadline"] = Date(timeIntervalSince1970: TimeInterval(deadline.seconds))
                        
                        collabRequests.append(collabRequest)
                    }
                    
                    completion(collabRequests)
                }
            }
        }
    }
    
    func acceptCollabRequest (collab: CollabRequest, completion: @escaping (() -> Void)) {
        
        let batch = db.batch()
        
        let memberCollabData: [String : Any] = ["collabID" : collab.collabID, "collabName" : collab.name, "collabObjective" : collab.objective, "startTime" : collab.dates["startTime"]!, "deadline" : collab.dates["deadline"]!, "reminders" : "will be set up later"]
        
        batch.setData(memberCollabData, forDocument: userRef.collection("Collabs").document(collab.collabID))
        
        userRef.collection("CollabRequests").document(collab.collabID).collection("Members").getDocuments { (snapshot, error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
            
            else {
                
                if snapshot?.isEmpty != true {
                    
                    for document in snapshot!.documents {
                        
                        let member: [String : Any] = ["userID" : document.data()["userID"] as! String, "firstName" : document.data()["firstName"] as! String, "lastName" : document.data()["lastName"] as! String, "username" : document.data()["username"] as! String, "role" : document.data()["role"] as! String]
                        
                        batch.setData(member, forDocument: self.userRef.collection("Collabs").document(collab.collabID).collection("Members").document(member["userID"] as! String))
                        
                        self.userRef.collection("CollabRequests").document(collab.collabID).collection("Members").document(member["userID"] as! String).delete()
                    }
                    
                    batch.deleteDocument(self.userRef.collection("CollabRequests").document(collab.collabID))
                    
                    self.commitBatch(batch: batch, completion: completion)
                }
                
                else {
                    
                    self.commitBatch(batch: batch, completion: completion)
                }
            }
        }
    }
    
    //doesnt handle errors soooo add that eventually
    private func commitBatch (batch: WriteBatch, completion: @escaping (() -> Void)) {
        
        batch.commit { (error) in

            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
            
            else {
                
                completion()
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
            
        firebaseStorage.retrieveUserProfilePicFromStorage(userID: friend.userID) { (profilePic, userID) in
            
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
    
    private func parseCollabActivity (memberActivity: [String : Any]?) -> [String : Any]? {
        
        var memberActivityDict: [String : Any] = [:]
        
        if let activities = memberActivity {
            
            for status in activities {
                
                //Evident the user was active some time in the past
                if let statusTimestamp = status.value as? Timestamp {
                    
                    memberActivityDict[status.key] = Date(timeIntervalSince1970: TimeInterval(statusTimestamp.seconds))
                }
                
                //Evident the user is current active
                else {
                    
                    memberActivityDict[status.key] = status.value
                }
            }
        }
        
        return !memberActivityDict.isEmpty ? memberActivityDict : nil
    }
    
    func cacheMemberProfilePics (userID: String, profilePic: UIImage?) {
         
        membersProfilePics[userID] = profilePic
    }
}
