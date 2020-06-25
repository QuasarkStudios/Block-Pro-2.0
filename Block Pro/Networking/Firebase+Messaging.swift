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

    var conversations: [Conversation] = []
    
    var messageListener: ListenerRegistration?
    
    let currentUser = CurrentUser.sharedInstance
    
    func createPersonalConversation (members: [Friend], completion: @escaping ((_ conversationID: String?, _ error: Error?) -> Void)) {
        
        let batch = db.batch()
        let conversationID = UUID().uuidString
        //var memberArray: [[String : String]] = []
        
        batch.setData(["conversationID" : conversationID, "dateCreated" : Date()], forDocument: db.collection("Conversations").document(conversationID))
        
        for member in members {
            
            var memberToBeAdded: [String : String] = [:]
            
            memberToBeAdded["userID"] = member.userID
            memberToBeAdded["firstName"] = member.firstName
            memberToBeAdded["lastName"] = member.lastName
            memberToBeAdded["username"] = member.username
            memberToBeAdded["role"] = "Member"
            
            batch.setData(["Members" : [member.userID]], forDocument: db.collection("Conversations").document(conversationID), merge: true)
            
            batch.setData(memberToBeAdded, forDocument: db.collection("Conversations").document(conversationID).collection("Members").document(memberToBeAdded["userID"]!))
            
            //memberArray.append(memberToBeAdded)
            
            if member.userID == members.last?.userID {
                
                memberToBeAdded["userID"] = currentUser.userID
                memberToBeAdded["firstName"] = currentUser.firstName
                memberToBeAdded["lastName"] = currentUser.lastName
                memberToBeAdded["username"] = currentUser.username
                memberToBeAdded["role"] = "Lead"
                
                batch.setData(["Members" : [currentUser.userID]], forDocument: db.collection("Conversations").document(conversationID), merge: true)
                
                batch.setData(memberToBeAdded, forDocument: db.collection("Conversations").document(conversationID).collection("Members").document(memberToBeAdded["userID"]!))
                //memberArray.append(memberToBeAdded)
            }
        }
        
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
    
    func retrievePersonalConversations (completion: @escaping ((_ conversations: [Conversation], _ error: Error?) -> Void)) {
        
        conversationListener = db.collection("Users").document(currentUser.userID).collection("Conversations").addSnapshotListener { (snapshot, error) in
            
            //self.conversations.removeAll()
            
            if error != nil {
                
                print(error as Any)
                
                completion([], error)
            }
            
            else {
                
                if snapshot?.isEmpty != true {
                    
                    for document in snapshot!.documents {
                        
                        let conversationID: String = document.data()["conversationID"] as! String
                        let conversationName: String? = document.data()["conversationName"] as? String
                        let dateCreatedTimestamp: Timestamp = document.data()["dateCreated"] as! Timestamp
                        let lastTimeActiveTimestamp: Timestamp? = document.data()["lastTimeActive"] as? Timestamp
                        
                        if let conversationIndex = self.conversations.firstIndex(where: { $0.conversationID == conversationID })  {
                            
                            self.conversations[conversationIndex].conversationName = conversationName//document.data()["conversationName"] as? String
                            
                            if lastTimeActiveTimestamp != nil {
                                
                                self.conversations[conversationIndex].lastTimeCurrentUserWasActive = Date(timeIntervalSince1970: TimeInterval(lastTimeActiveTimestamp!.seconds))
                            }
                        }
                        
                        else {
                            
                            var conversation = Conversation()
                            
                            conversation.conversationID = conversationID//document.data()["conversationID"] as! String
                            conversation.conversationName = conversationName//document.data()["conversationName"] as? String
                            
                            //var timestamp: Timestamp? = document.data()["dateCreated"] as! Timestamp//snapshot!.documents.first!["dateCreated"] as! Timestamp
                            conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreatedTimestamp.seconds))
                            
                            //timestamp = document.data()["lastTimeActive"] as? Timestamp
                            
                            if lastTimeActiveTimestamp != nil {
                               
                                conversation.lastTimeCurrentUserWasActive = Date(timeIntervalSince1970: TimeInterval(lastTimeActiveTimestamp!.seconds))
                            }
                            
                            self.conversations.append(conversation)
                        }
                        
                        
                        self.retrievePersonalConversationMembers(conversationID) { (members, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                                
                                //completion([], error)
                            }
                            
                            else {
                                
                                let conversationIndex = self.conversations.firstIndex(where: {$0.conversationID == conversationID})
                                
                                self.conversations[conversationIndex!].members = members
                                
                                NotificationCenter.default.post(name: .didRetrieveConversationMembers, object: nil)
                            }
                        }
                        
                        self.retrievePersonalConversationPreview(conversationID) { (message, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                                
                                //completion([], error)
                            }
                            
                            else {
                                
                                let conversationIndex = self.conversations.firstIndex(where: {$0.conversationID == conversationID})
                                
                                self.conversations[conversationIndex!].messagePreview = message
                                
                                NotificationCenter.default.post(name: .didRetrieveConversationPreview, object: nil)
                            }
                        }
                    }
        
                    completion(self.conversations, nil)
                }
            }
        }
    }
    
    func retrievePersonalConversation2 (completion: @escaping ((_ conversations: [Conversation], _ error: Error?) -> Void)) {
        
        conversationListener = db.collection("Conversations").whereField("Members", arrayContains: currentUser.userID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                print(error as Any)
                
                completion([], error)
            }
            
            else {
                
                if snapshot?.isEmpty != true {
                    
                    for document in snapshot!.documents {
                        
                        print("check")
                    }
                }
            }
        })
    }
    
    private func retrievePersonalConversationMembers (_ conversationID: String, completion: @escaping ((_ members: [Member], _ error: Error?) -> Void)) {
        
        let listener = db.collection("Users").document(currentUser.userID).collection("Conversations").document(conversationID).collection("Members").addSnapshotListener { (snapshot, error) in
            
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
                        let lastTimeActiveTimestamp: Timestamp? = document.data()["lastTimeActive"] as? Timestamp; #warning("configure")
                        
                        if let conversationIndex = self.conversations.firstIndex(where: { $0.conversationID == collabID }) {
                            
                            self.conversations[conversationIndex].conversationName = collabName
                            
                            if lastTimeActiveTimestamp != nil {
                                
                                self.conversations[conversationIndex].lastTimeCurrentUserWasActive = Date(timeIntervalSince1970: TimeInterval(lastTimeActiveTimestamp!.seconds))
                            }
                        }
                        
                        else {
                            
                            var conversation = Conversation()
                            
                            conversation.conversationID = collabID
                            conversation.conversationName = collabName
                            conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(startTime.seconds))
                            
                            if lastTimeActiveTimestamp != nil {
                                
                                conversation.lastTimeCurrentUserWasActive = Date(timeIntervalSince1970: TimeInterval(lastTimeActiveTimestamp!.seconds))
                            }
                            
                            self.conversations.append(conversation)
                        }
                        
//                        var conversation = Conversation()
//                        conversation.conversationID = document.data()["collabID"] as! String
//                        conversation.conversationName = document.data()["collabName"] as? String
//
//                        let timestamp = document.data()["startTime"] as! Timestamp
//                        conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
//
//
//
//                        self.conversations.append(conversation)
                        
                        self.retrieveCollabConversationMembers(collabID) { (members, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                            }
                                
                            else {
                                
                                let conversationIndex = self.conversations.firstIndex(where: {$0.conversationID == collabID})
                                
                                self.conversations[conversationIndex!].members = members
                                
                                NotificationCenter.default.post(name: .didRetrieveConversationMembers, object: nil)
                            }
                        }
                        
                        self.retrieveCollabConversationPreview(collabID) { (message, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                            }
                            
                            else {
                                
                                let conversationIndex = self.conversations.firstIndex(where: {$0.conversationID == collabID})
                                
                                self.conversations[conversationIndex!].messagePreview = message
                                
                                NotificationCenter.default.post(name: .didRetrieveConversationPreview, object: nil)
                            }
                        }
                    }
                    
                    completion(self.conversations, nil)
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
    
    func monitorPersonalConversation (conversationID: String, completion:  @escaping ((_ conversationName: String?, _ conversationMembers: [Member]?, _ error: Error?) -> Void)) {
        
        conversationListener = db.collection("Users").document(currentUser.userID).collection("Conversations").document(conversationID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(nil, nil, error)
            }
            
            else {

                let conversationName = snapshot!.data()!["conversationName"] as? String
                
                completion(conversationName, nil, nil)
            }
        })
        
        retrievePersonalConversationMembers(conversationID) { (members, error) in
            
            if error != nil {
                
                completion(nil, nil, error)
            }
            
            else {
                
                completion(nil, members, nil)
            }
        }
    }
    
    func monitorCollabConversation (collabID: String, completion: @escaping ((_ collabName: String?, _ collabMembers: [Member]?, _ error: Error?) -> Void)) {
        
        conversationListener = db.collection("Users").document(currentUser.userID).collection("Collabs").document(collabID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(nil, nil, error)
            }
            
            else {
                
                let collabName = snapshot!.data()!["collabName"] as? String
                
                completion(collabName, nil, nil)
            }
        })
        
        retrieveCollabConversationMembers(collabID) { (members, error) in
            
            if error != nil {
                
                completion(nil, nil, error)
            }
            
            else {
                
                completion(nil, members, nil)
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
    
    func readMessages (conversationID: String? = nil, collabID: String? = nil) {
        
        let currentDate = Date()
        
        //let lastTimeActive: [String : Any] = ["lastTimeMembersWereActive" : [currentUserID : Date()]]
        
        if let conversation = conversationID {
            
            //db.collection("Users").document(currentUser.userID).collection("Conversations").document(conversation).setData(["lastTimeActive" : currentDate], merge: true)
            
//            db.collection("Conversations").document(conversation).setData(["lastTimeMembersWereActive" : [currentUser.userID : currentDate]], merge: true)
            
            db.collection("Users").document(currentUser.userID).collection("Conversations").document(conversation).updateData(["lastTimeActive" : currentDate])
            
            db.collection("Conversations").document(conversation).updateData(["lastTimeMembersWereActive" : [currentUser.userID : currentDate]])
        }
        
        else if let collab = collabID {
            
//            db.collection("Users").document(currentUser.userID).collection("Collabs").document(collab).setData(["lastTimeActive" : currentDate])
            
//            db.collection("Collaborations").document(collab).setData(["lastTimeMembersWereActive" : [currentUser.userID : currentDate]], merge: true)
            
            db.collection("Users").document(currentUser.userID).collection("Collabs").document(collab).updateData(["lastTimeActive" : currentDate])
            
            db.collection("Collaborations").document(collab).updateData(["lastTimeMembersWereActive" : [currentUser.userID : currentDate]])
        }
    }
    
    func updateConversationName (conversationID: String, members: [Member], name: String?, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let batch = db.batch()
        
        batch.updateData(["conversationName" : name as Any], forDocument: db.collection("Conversations").document(conversationID))
        
        for member in members {
            
            batch.updateData(["conversationName" : name as Any], forDocument: db.collection("Users").document(member.userID).collection("Conversations").document(conversationID))
        }
        
        batch.commit { (error) in
            
            if error != nil {

                completion(error)
            }

            else {

                completion(nil)
            }
        }
        
//        db.collection("Conversations").document(conversationID).updateData(["conversationName" : name]) { (error) in
//
//            if error != nil {
//
//                completion(error)
//            }
//
//            else {
//
//                completion(nil)
//            }
//        }
    }
}
