//
//  Firebase+Messaging.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/21/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import Firebase

class FirebaseMessaging {
    
    lazy var db = Firestore.firestore()
    
    lazy var firebaseCollab = FirebaseCollab.sharedInstance
    lazy var firebaseStorage = FirebaseStorage()
    
    var conversationListener: ListenerRegistration?
    var conversationPreviewListeners: [ListenerRegistration] = []
    var conversationMembersListeners: [ListenerRegistration] = []

    //var conversations: [Conversation] = []
    
    var personalConversations: [Conversation] = []
    var collabConversations: [Conversation] = []
    
    //var conversationCovers: [String : UIImage] = [:]
    
    var messageListener: ListenerRegistration?
    
    let currentUser = CurrentUser.sharedInstance
    
    static let sharedInstance = FirebaseMessaging()
    
    func createPersonalConversation (members: [Friend], completion: @escaping ((_ conversationID: String?, _ error: Error?) -> Void)) {
        
        let batch = db.batch()
        let conversationID = UUID().uuidString
        //var memberArray: [[String : String]] = []
        var memberArray: [String] = []
        
        batch.setData(["conversationID" : conversationID, "dateCreated" : Date()], forDocument: db.collection("Conversations").document(conversationID), merge: true)
        
        for member in members {
            
            var memberToBeAdded: [String : String] = [:]
            
            memberToBeAdded["userID"] = member.userID
            memberToBeAdded["firstName"] = member.firstName
            memberToBeAdded["lastName"] = member.lastName
            memberToBeAdded["username"] = member.username
            memberToBeAdded["role"] = "Member"
            
            memberArray.append(member.userID)
            
            //batch.setData(["Members" : [member.userID]], forDocument: db.collection("Conversations").document(conversationID), merge: true)
            
            batch.setData(memberToBeAdded, forDocument: db.collection("Conversations").document(conversationID).collection("Members").document(memberToBeAdded["userID"]!), merge: true)
            
            //memberArray.append(memberToBeAdded)
            
            if member.userID == members.last?.userID {
                
                memberToBeAdded["userID"] = currentUser.userID
                memberToBeAdded["firstName"] = currentUser.firstName
                memberToBeAdded["lastName"] = currentUser.lastName
                memberToBeAdded["username"] = currentUser.username
                memberToBeAdded["role"] = "Lead"
                
                memberArray.append(currentUser.userID)
                
                //batch.setData(["Members" : [currentUser.userID]], forDocument: db.collection("Conversations").document(conversationID), merge: true)
                
                batch.setData(memberToBeAdded, forDocument: db.collection("Conversations").document(conversationID).collection("Members").document(memberToBeAdded["userID"]!), merge: true)
                //memberArray.append(memberToBeAdded)
            }
        }
        
        batch.setData(["Members" : memberArray], forDocument: db.collection("Conversations").document(conversationID), merge: true)
        
        
        
        //was used when a reference to the conversation was still being stored in each users document
        
//        for member in memberArray {
//
//            batch.setData(["conversationID" : conversationID, "dateCreated" : Date()], forDocument: db.collection("Users").document(member["userID"]!).collection("Conversations").document(conversationID))
//
//            for addedMember in memberArray {
//
//                batch.setData(addedMember, forDocument: db.collection("Users").document(member["userID"]!).collection("Conversations").document(conversationID).collection("Members").document(addedMember["userID"]!))
//            }
//        }
        
        
        batch.commit { (error) in
            
            if error != nil {
                
                completion(nil, error)
            }
            
            else {
                
                completion(conversationID, nil)
            }
        }
    }
    
    func saveConversationCoverPhoto (conversationID: String, coverPhotoID: String, coverPhoto: UIImage, completion: @escaping ((_ error: Error?) -> Void)) {
        
        //let coverPhotoID = UUID().uuidString
        
        self.firebaseStorage.saveConversationCoverPhoto(conversationID: conversationID, coverPhoto: coverPhoto) { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                self.db.collection("Conversations").document(conversationID).setData(["coverPhotoID" : coverPhotoID], merge: true) { (error) in
                    
                    if error != nil {
                        
                        completion(error)
                    }
                    
                    else {
                        
                        if let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversationID }) {

                            self.personalConversations[conversationIndex].coverPhotoID = coverPhotoID
                            self.personalConversations[conversationIndex].conversationCoverPhoto = coverPhoto
                        }
                        
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func deletePersonalConversationCoverPhoto (conversationID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        firebaseStorage.deletePersonalConversationCoverPhoto(conversationID: conversationID) { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                self.db.collection("Conversations").document(conversationID).updateData(["coverPhotoID" : FieldValue.delete()]) { (error) in
                    
                    if error != nil {
                        
                        completion(error)
                    }
                    
                    else {
                        
                        if let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversationID }) {
                            
                            self.personalConversations[conversationIndex].coverPhotoID = nil
                            self.personalConversations[conversationIndex].conversationCoverPhoto = nil
                        }
                        
                        completion(nil)
                    }
                }
            }
        }
    }
    
//    func retrievePersonalConversations (completion: @escaping ((_ conversations: [Conversation], _ error: Error?) -> Void)) {
//
//        conversationListener = db.collection("Users").document(currentUser.userID).collection("Conversations").addSnapshotListener { (snapshot, error) in
//
//            //self.conversations.removeAll()
//
//            if error != nil {
//
//                print(error as Any)
//
//                completion([], error)
//            }
//
//            else {
//
//                if snapshot?.isEmpty != true {
//
//                    for document in snapshot!.documents {
//
//                        let conversationID: String = document.data()["conversationID"] as! String
//                        let conversationName: String? = document.data()["conversationName"] as? String
//                        let conversationHasCoverPhoto: Bool? = document.data()["conversationHasCoverPhoto"] as? Bool
//                        let dateCreatedTimestamp: Timestamp = document.data()["dateCreated"] as! Timestamp
//                        let lastTimeActiveTimestamp: Timestamp? = document.data()["lastTimeActive"] as? Timestamp
//
//                        if let conversationIndex = self.conversations.firstIndex(where: { $0.conversationID == conversationID })  {
//
//                            self.conversations[conversationIndex].conversationName = conversationName//document.data()["conversationName"] as? String
//                            self.conversations[conversationIndex].conversationHasCoverPhoto = conversationHasCoverPhoto
//
//                            if lastTimeActiveTimestamp != nil {
//
//                                //self.conversations[conversationIndex].lastTimeCurrentUserWasActive = Date(timeIntervalSince1970: TimeInterval(lastTimeActiveTimestamp!.seconds))
//                            }
//                        }
//
//                        else {
//
//                            var conversation = Conversation()
//
//                            conversation.conversationID = conversationID//document.data()["conversationID"] as! String
//                            conversation.conversationName = conversationName//document.data()["conversationName"] as? String
//                            conversation.conversationHasCoverPhoto = conversationHasCoverPhoto
//
//                            //var timestamp: Timestamp? = document.data()["dateCreated"] as! Timestamp//snapshot!.documents.first!["dateCreated"] as! Timestamp
//                            conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreatedTimestamp.seconds))
//
//                            //timestamp = document.data()["lastTimeActive"] as? Timestamp
//
//                            if lastTimeActiveTimestamp != nil {
//
//                                //conversation.lastTimeCurrentUserWasActive = Date(timeIntervalSince1970: TimeInterval(lastTimeActiveTimestamp!.seconds))
//                            }
//
//                            self.conversations.append(conversation)
//                        }
//
//
//                        self.retrievePersonalConversationMembers(conversationID) { (members, error) in
//
//                            if error != nil {
//
//                                print(error as Any)
//
//                                //completion([], error)
//                            }
//
//                            else {
//
//                                let conversationIndex = self.conversations.firstIndex(where: {$0.conversationID == conversationID})
//
//                                self.conversations[conversationIndex!].members = members
//
//                                NotificationCenter.default.post(name: .didRetrieveConversationMembers, object: nil)
//                            }
//                        }
//
//                        self.retrievePersonalConversationPreview(conversationID) { (message, error) in
//
//                            if error != nil {
//
//                                print(error as Any)
//
//                                //completion([], error)
//                            }
//
//                            else {
//
//                                let conversationIndex = self.conversations.firstIndex(where: {$0.conversationID == conversationID})
//
//                                self.conversations[conversationIndex!].messagePreview = message
//
//                                NotificationCenter.default.post(name: .didRetrieveConversationPreview, object: nil)
//                            }
//                        }
//                    }
//
//                    completion(self.conversations, nil)
//                }
//            }
//        }
//    }
    
    func retrievePersonalConversations2 (completion: @escaping ((_ conversations: [Conversation], _ error: Error?) -> Void)) {
        
        conversationListener = db.collection("Conversations").whereField("Members", arrayContains: currentUser.userID).addSnapshotListener ({ (snapshot, error) in
            
            if error != nil {
                
                print(error as Any)
                
                completion([], error)
            }
            
            else {
                
                if snapshot?.isEmpty != true {
                    
                    for document in snapshot!.documents {
                        
                        let conversationID: String = document.data()["conversationID"] as! String
                        let conversationName: String? = document.data()["conversationName"] as? String
                        let coverPhotoID: String? = document.data()["coverPhotoID"] as? String
                        let dateCreatedTimestamp: Timestamp = document.data()["dateCreated"] as! Timestamp
                        let memberActivity: [String : Any]? = document.data()["memberActivity"] as? [String : Any]
                        
                        if let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversationID }) {
                            
                            self.personalConversations[conversationIndex].conversationName = conversationName
                            self.personalConversations[conversationIndex].coverPhotoID = coverPhotoID
                            self.personalConversations[conversationIndex].memberActivity = self.parseConversationActivity(memberActivity: memberActivity)
                        }
                        
                        else {
                            
                            var conversation = Conversation()
                            
                            conversation.conversationID = conversationID
                            conversation.conversationName = conversationName
                            conversation.coverPhotoID = coverPhotoID
                            conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreatedTimestamp.seconds))
                            conversation.memberActivity = self.parseConversationActivity(memberActivity: memberActivity)
                            
                            self.personalConversations.append(conversation)
                        }
                        
                        self.retrievePersonalConversationMembers(conversationID) { (members, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                            }
                            
                            else {
                                
                                let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversationID })
                                
                                self.personalConversations[conversationIndex!].members = members
                                
                                NotificationCenter.default.post(name: .didRetrieveConversationMembers, object: nil)
                            }
                        }
                        
                        self.retrievePersonalConversationPreview(conversationID) { (message, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                            }
                            
                            else {
                                
                                let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversationID })
                                
                                self.personalConversations[conversationIndex!].messagePreview = message
                                
                                NotificationCenter.default.post(name: .didRetrieveConversationPreview, object: nil)
                            }
                        }
                    }
                    
                    completion(self.personalConversations, nil)
                }
            }
        })
    }
    
    private func retrievePersonalConversationMembers (_ conversationID: String, completion: @escaping ((_ members: [Member], _ error: Error?) -> Void)) {
        
        let listener = db.collection("Conversations").document(conversationID).collection("Members").addSnapshotListener { (snapshot, error) in
            
            if error != nil {
                
                print(error as Any)
                
                completion([], error)
            }
            
            else {
                
                if snapshot?.isEmpty != true {
                    
                    var members: [Member] = []
                    
                    for document in snapshot!.documents {
                        
                        var member = Member()
                        
                        member.userID = document.data()["userID"] as! String
                        member.firstName = document.data()["firstName"] as! String
                        member.lastName = document.data()["lastName"] as! String
                        member.username = document.data()["username"] as! String
                        member.role = document.data()["role"] as! String
                        
                        members.append(member)
                    }
                    
                    completion(members, nil)
                }
                
                else {
                    
                    completion([], nil)
                }
            }
        }
        
        conversationMembersListeners.append(listener)
    }
    
    private func retrievePersonalConversationPreview (_ conversationID: String, completion: @escaping ((_ message: Message?, _ error: Error?) -> Void)) {
        
        let listener = db.collection("Conversations").document(conversationID).collection("Messages").order(by: "timestamp", descending: true).limit(to: 1).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {

                print(error as Any)

                completion(nil, error)
            }

            else {

                if snapshot?.isEmpty != true {

                    var message = Message()
                    message.messageID = snapshot!.documents.first!.documentID
                    message.message = snapshot!.documents.first!["message"] as? String
                    message.sender = snapshot!.documents.first!["sender"] as! String
                    
                    let timestamp = snapshot!.documents.first!["timestamp"] as! Timestamp
                    message.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                    
                    completion(message, nil)
                }
                
                else {
                    
                    completion(nil, nil)
                }
            }
        })
        
        conversationPreviewListeners.append(listener)
    }
    
    func retrieveCollabConversations (completion: @escaping ((_ conversations: [Conversation], _ error: Error?) -> Void)) {
        
        conversationListener = db.collection("Users").document(currentUser.userID).collection("Collabs").addSnapshotListener({ (snapshot, error) in
            
//            self.conversations.removeAll()
            
            if error != nil {
                
                print(error as Any)
                
                completion([], nil)
            }
                
            else {
                
                if snapshot?.isEmpty != true {
                        
                    for document in snapshot!.documents {
                        
                        let collabID = document.data()["collabID"] as! String
                        let collabName = document.data()["collabName"] as? String
                        let startTime = document.data()["startTime"] as! Timestamp
                        let lastTimeMembersActiveTimestamp: [String : Timestamp]? = document.data()["lastTimeMembersWereActive"] as? [String : Timestamp]; #warning("configure")
                        
                        if let conversationIndex = self.collabConversations.firstIndex(where: { $0.conversationID == collabID }) {
                            
                            self.collabConversations[conversationIndex].conversationName = collabName
                            
//                            if lastTimeActiveTimestamp != nil {
//
//                                self.conversations[conversationIndex].lastTimeCurrentUserWasActive = Date(timeIntervalSince1970: TimeInterval(lastTimeActiveTimestamp!.seconds))
//                            }
                        }
                        
                        else {
                            
                            var conversation = Conversation()
                            
                            conversation.conversationID = collabID
                            conversation.conversationName = collabName
                            conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(startTime.seconds))
                            
//                            if lastTimeActiveTimestamp != nil {
//                                
//                                conversation.lastTimeCurrentUserWasActive = Date(timeIntervalSince1970: TimeInterval(lastTimeActiveTimestamp!.seconds))
//                            }
                            
                            self.collabConversations.append(conversation)
                        }
                        
                        self.retrieveCollabConversationMembers(collabID) { (members, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                            }
                                
                            else {
                                
                                let conversationIndex = self.collabConversations.firstIndex(where: {$0.conversationID == collabID})
                                
                                self.collabConversations[conversationIndex!].members = members
                                
                                NotificationCenter.default.post(name: .didRetrieveConversationMembers, object: nil)
                            }
                        }
                        
                        self.retrieveCollabConversationPreview(collabID) { (message, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                            }
                            
                            else {
                                
                                let conversationIndex = self.collabConversations.firstIndex(where: {$0.conversationID == collabID})
                                
                                self.collabConversations[conversationIndex!].messagePreview = message
                                
                                NotificationCenter.default.post(name: .didRetrieveConversationPreview, object: nil)
                            }
                        }
                    }
                    
                    completion(self.collabConversations, nil)
                }
            }
        })
    }

    private func retrieveCollabConversationMembers (_ collabID: String, completion: @escaping ((_ members: [Member], _ error: Error?) -> Void)) {
        
        #warning("thisll have to be changed to be an observor to monitor for updates in members")
        
        let collab = firebaseCollab.collabs.first(where: { $0.collabID == collabID })
        var conversationMembers: [Member] = []
        
        for member in collab?.members ?? [] {
            
            conversationMembers.append(member)
        }
        
        completion(conversationMembers, nil)
    }
    
    private func retrieveCollabConversationPreview (_ collabID: String, completion: @escaping ((_ message: Message?, _ error: Error?) -> Void)) {
        
        let listener = db.collection("Collaborations").document(collabID).collection("Messages").order(by: "timestamp", descending: true).limit(to: 1).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {

                print(error as Any)

                completion(nil, error)
            }

            else {

                if snapshot?.isEmpty != true {

                    var message = Message()
                    message.messageID = snapshot!.documents.first!.documentID
                    message.message = snapshot!.documents.first!["message"] as? String
                    message.sender = snapshot!.documents.first!["sender"] as! String
                    
                    let timestamp = snapshot!.documents.first!["timestamp"] as! Timestamp
                    message.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                    
                    completion(message, nil)
                }
                
                else {
                    
                    completion(nil, nil)
                }
            }
        })
        
        conversationPreviewListeners.append(listener)
    }
    
    func retrieveAllPersonalMessages (conversationID: String, completion: @escaping ((_ messages: [Message], _ error: Error?) -> Void)) {
        
        messageListener = db.collection("Conversations").document(conversationID).collection("Messages").addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion([], error)
            }
            
            else {
                
                if snapshot?.isEmpty != true {
                    
                    var messages: [Message] = []
                    
                    for document in snapshot!.documents {
                        
                        var message = Message()
                        message.messageID = document.documentID
                        message.sender = document.data()["sender"] as! String
                        message.message = document.data()["message"] as? String
                        message.messagePhoto = document.data()["photo"] as? [String : Any]
                        
                        let timestamp = document.data()["timestamp"] as! Timestamp
                        message.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                        
                        messages.append(message)
                    }
                    
                    //messages = messages.sorted(by: { $0.timestamp < $1.timestamp })
                    
                    completion(messages, nil)
                }
                
                else {
                    
                    completion([], nil)
                }
            }
        })
    }
    
    func retrieveAllCollabMessages (collabID: String, completion: @escaping ((_ messages: [Message], _ error: Error?) -> Void)) {
        
        messageListener = db.collection("Collaborations").document(collabID).collection("Messages").addSnapshotListener { (snapshot, error) in
            
            if error != nil {
                
                completion([], error)
            }
            
            else {
                
                if snapshot?.isEmpty != true {
                    
                    var messages: [Message] = []
                    
                    for document in snapshot!.documents {
                        
                        var message = Message()
                        message.messageID = document.documentID
                        message.sender = document.data()["sender"] as! String
                        message.message = document.data()["message"] as? String
                        message.messagePhoto = document.data()["photo"] as? [String : Any]
                        
                        let timestamp = document.data()["timestamp"] as! Timestamp
                        message.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                        
                        messages.append(message)
                    }
                    
                    //messages = messages.sorted(by: { $0.timestamp < $1.timestamp })
                    
                    completion(messages, nil)
                }
                
                else {
                    
                    completion([], nil)
                }
            }
        }
    }
    
    func monitorPersonalConversation (conversationID: String, completion:  @escaping ((_ updatedConvo: [String : Any?]/*_ conversationName: String?, _ conversationHasACover: Bool?, _ conversationActivity: [String : Any]?, _ conversationMembers: [Member]?, _ error: Error?*/) -> Void)) {
        
        conversationListener = db.collection("Conversations").document(conversationID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(["error" : error])
                
                //completion(nil, nil, nil, error)
            }
            
            else {
                
                if snapshot != nil {
                    
                    let conversationName = snapshot!.data()?["conversationName"] as? String
                    let coverPhotoID = snapshot!.data()?["coverPhotoID"] as? String
                    let conversationActivity = self.parseConversationActivity(memberActivity: snapshot!.data()?["memberActivity"] as? [String : Any])
                    
                    if let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversationID }) {
                        
                        if coverPhotoID != self.personalConversations[conversationIndex].coverPhotoID {
                            
                            self.personalConversations[conversationIndex].conversationCoverPhoto = nil
                        }
                        
                        self.personalConversations[conversationIndex].conversationName = conversationName
                        self.personalConversations[conversationIndex].coverPhotoID = coverPhotoID
                        self.personalConversations[conversationIndex].memberActivity = conversationActivity
                        
//                        if coverPhotoID == nil {
//                            
//                            self.personalConversations[conversationIndex].coverPhotoID = nil
//                            
//                            //left off with an issue where if a user deletes then adds new a cover, any users will active in the convo will be updated back to the previously deleted cover
//                        }
                    }
                    
                    completion(["conversationName" : conversationName, "coverPhotoID" : coverPhotoID, "conversationActivity" : conversationActivity])
                    
                    //completion(conversationName, conversationActivity, nil, nil)
                }
            }
        })
        
        retrievePersonalConversationMembers(conversationID) { (members, error) in
            
            if error != nil {
                
                completion(["error" : error])
                
                //completion(nil, nil, nil, error)
            }
            
            else {
                
                completion(["members" : members])
                
                //completion(nil, nil, members, nil)
            }
        }
    }
    
    func monitorCollabConversation (collabID: String, completion: @escaping ((_ collabName: String?, _ collabActivity: [String : Any]?, _ collabMembers: [Member]?, _ error: Error?) -> Void)) {
        
        conversationListener = db.collection("Users").document(currentUser.userID).collection("Collabs").document(collabID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(nil, nil, nil, error)
            }
            
            else {
                
                if snapshot != nil {
                    
                    let collabName = snapshot!.data()?["collabName"] as? String
                    let collabActivity = self.parseConversationActivity(memberActivity: snapshot!.data()?["memberActivity"] as? [String : Any])
                    
                    completion(collabName, collabActivity, nil, nil)
                }
            }
        })
        
        retrieveCollabConversationMembers(collabID) { (members, error) in
            
            if error != nil {
                
                completion(nil, nil, nil, error)
            }
            
            else {
                
                completion(nil, nil, members, nil)
            }
        }
    }
    
    func sendPersonalMessage (conversationID: String, _ message: Message, completion: @escaping ((_ error: Error?) -> Void)) {
        
        var photoDict = message.messagePhoto != nil ? message.messagePhoto : nil
        photoDict?.removeValue(forKey: "photo")
        
        let messageDict: [String : Any] = ["sender" : message.sender, "message" : message.message as Any, "photo" : photoDict as Any, "timestamp" : message.timestamp as Any]
        
        if let photoID = message.messagePhoto?["photoID"] as? String, let photo = message.messagePhoto?["photo"] as? UIImage {

            self.firebaseStorage.savePersonalMessagePhoto(conversationID: conversationID, messagePhoto: ["photoID" : photoID, "photo" : photo]) { (error) in
                
                if error != nil {
                    
                    completion(error)
                }
                
                else {
                    
                    self.db.collection("Conversations").document(conversationID).collection("Messages").addDocument(data: messageDict) { (error) in
                        
                        if error != nil {
                            
                            completion(error)
                        }
                        
                        else {
                            
                            completion(nil)
                        }
                    }
                }
            }
        }
        
        else {
        
            self.db.collection("Conversations").document(conversationID).collection("Messages").addDocument(data: messageDict) { (error) in
                
                if error != nil {
                    
                    completion(error)
                }
                
                else {
                    
                    completion(nil)
                }
            }
        }
    }
    
    func sendCollabMessage (collabID: String, _ message: Message, completion: @escaping ((_ error: Error?) -> Void)) {
        
        var photoDict = message.messagePhoto != nil ? message.messagePhoto : nil
        photoDict?.removeValue(forKey: "photo")
        
        let messageDict: [String : Any] = ["sender" : message.sender, "message" : message.message as Any, "photo" : photoDict as Any, "timestamp" : message.timestamp as Any]
        
        if let photoID = message.messagePhoto?["photoID"] as? String, let photo = message.messagePhoto?["photo"] as? UIImage {
            
            self.firebaseStorage.saveCollabMessagePhoto(collabID: collabID, messagePhoto: ["photoID" : photoID, "photo" : photo]) { (error) in
                
                if error != nil {
                    
                    completion(error)
                }
                
                else {
                    
                    self.db.collection("Collaborations").document(collabID).collection("Messages").addDocument(data: messageDict) { (error) in
                        
                        if error != nil {
                            
                            completion(error)
                        }
                        
                        else {
                            
                            completion(nil)
                        }
                    }
                }
            }
        }
        
        else {
            
            self.db.collection("Collaborations").document(collabID).collection("Messages").addDocument(data: messageDict) { (error) in
                
                if error != nil {
                    
                    completion(error)
                }
                
                else {
                    
                    completion(nil)
                }
            }
        }
    }
    
//    func readMessages (personalConversation: Conversation? = nil, collabConversation: Conversation? = nil) {
//        
//        if let conversation = personalConversation {
//                
//            db.collection("Conversations").document(conversation.conversationID).updateData(["lastTimeMembersWereActive.\(currentUser.userID)" : Date()])
//        }
//        
//        else if let collab = collabConversation {
//                
//            db.collection("Conversations").document(collab.conversationID).updateData(["lastTimeMembersWereActive.\(currentUser.userID)" : Date()])
//        }
//    }
    
    func setActivityStatus (personalConversation: Conversation? = nil, collabConversation: Conversation? = nil, _ status: Any) {
        
        if let conversation = personalConversation {
            
            db.collection("Conversations").document(conversation.conversationID).updateData(["memberActivity.\(currentUser.userID)" : status])
        }
        
        else if let collab = collabConversation {
                
            db.collection("Conversations").document(collab.conversationID).updateData(["memberActivity.\(currentUser.userID)" : status])
        }
    }
    
    func updateConversationName (conversationID: String, members: [Member], name: String?, completion: @escaping ((_ error: Error?) -> Void)) {
        
        db.collection("Conversations").document(conversationID).updateData(["conversationName" : name as Any]) { (error) in

            if error != nil {

                completion(error)
            }

            else {

                completion(nil)
            }
        }
    }
    
    private func parseConversationActivity (memberActivity: [String : Any]?) -> [String : Any]? {
        
        var memberActivityDict: [String : Any] = [:]
        
        if let activities = memberActivity {
            
            for status in activities {
                
                if let statusTimestamp = status.value as? Timestamp {
                    
                    memberActivityDict[status.key] = Date(timeIntervalSince1970: TimeInterval(statusTimestamp.seconds))
                }
                
                else {
                    
                    memberActivityDict[status.key] = status.value
                }
            }
        }
        
        return !memberActivityDict.isEmpty ? memberActivityDict : nil
    }
}
