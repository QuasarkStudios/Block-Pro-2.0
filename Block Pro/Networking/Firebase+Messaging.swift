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
    
    var conversationListener: ListenerRegistration?
    var conversationPreviewListener: ListenerRegistration?
    var conversationMembersListener: ListenerRegistration?

    var conversations: [Conversation] = []
    
    var messageListener: ListenerRegistration?
    
    let currentUser = CurrentUser.sharedInstance
    
    func createPersonalConversation (members: [Friend], completion: @escaping ((_ conversationID: String?, _ error: Error?) -> Void)) {
        
        let batch = db.batch()
        let conversationID = UUID().uuidString
        var memberArray: [[String : String]] = []
        
        batch.setData(["conversationID" : conversationID, "dateCreated" : Date()], forDocument: db.collection("Conversations").document(conversationID))
        
        for member in members {
            
            var memberToBeAdded: [String : String] = [:]
            
            memberToBeAdded["userID"] = member.userID
            memberToBeAdded["firstName"] = member.firstName
            memberToBeAdded["lastName"] = member.lastName
            memberToBeAdded["username"] = member.username
            memberToBeAdded["role"] = "Member"
            
            batch.setData(memberToBeAdded, forDocument: db.collection("Conversations").document(conversationID).collection("Members").document(memberToBeAdded["userID"]!))
            memberArray.append(memberToBeAdded)
            
            if member.userID == members.last?.userID {
                
                memberToBeAdded["userID"] = currentUser.userID
                memberToBeAdded["firstName"] = currentUser.firstName
                memberToBeAdded["lastName"] = currentUser.lastName
                memberToBeAdded["username"] = currentUser.username
                memberToBeAdded["role"] = "Lead"
                
                batch.setData(memberToBeAdded, forDocument: db.collection("Conversations").document(conversationID).collection("Members").document(memberToBeAdded["userID"]!))
                memberArray.append(memberToBeAdded)
            }
        }
        
        for member in memberArray {
            
            batch.setData(["conversationID" : conversationID, "dateCreated" : Date()], forDocument: db.collection("Users").document(member["userID"]!).collection("Conversations").document(conversationID))
            
            for addedMember in memberArray {
                
                batch.setData(addedMember, forDocument: db.collection("Users").document(member["userID"]!).collection("Conversations").document(conversationID).collection("Members").document(addedMember["userID"]!))
            }
        }
        
        
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
            
            self.conversations.removeAll()
            
            if error != nil {
                
                print(error as Any)
                
                completion([], error)
            }
            
            else {
                
                if snapshot?.isEmpty != true {
                    
                    for document in snapshot!.documents {
                        
                        var conversation = Conversation()
                        
                        conversation.conversationID = document.data()["conversationID"] as! String
                        conversation.conversationName = document.data()["conversationName"] as? String
                        
                        var timestamp: Timestamp? = document.data()["dateCreated"] as! Timestamp//snapshot!.documents.first!["dateCreated"] as! Timestamp
                        conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(timestamp!.seconds))
                        
                        timestamp = document.data()["lastTimeActive"] as? Timestamp
                        
                        if timestamp != nil {
                           
                            conversation.lastTimeCurrentUserWasActive = Date(timeIntervalSince1970: TimeInterval(timestamp!.seconds))
                        }
                        
                        self.conversations.append(conversation)
                        
                        self.retrievePersonalConversationMembers(conversation.conversationID) { (members, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                                
                                //completion([], error)
                            }
                            
                            else {
                                
                                let conversationIndex = self.conversations.firstIndex(where: {$0.conversationID == conversation.conversationID})
                                
                                self.conversations[conversationIndex!].members = members
                                
                                NotificationCenter.default.post(name: .didRetrieveConversationMembers, object: nil)
                            }
                        }
                        
                        self.retrievePersonalConversationPreview(conversation.conversationID) { (message, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                                
                                //completion([], error)
                            }
                            
                            else {
                                
                                let conversationIndex = self.conversations.firstIndex(where: {$0.conversationID == conversation.conversationID})
                                
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
    
    private func retrievePersonalConversationMembers (_ conversationID: String, completion: @escaping ((_ members: [Member], _ error: Error?) -> Void)) {
        
        conversationMembersListener = db.collection("Users").document(currentUser.userID).collection("Conversations").document(conversationID).collection("Members").addSnapshotListener { (snapshot, error) in
            
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
    }
    
    private func retrievePersonalConversationPreview (_ conversationID: String, completion: @escaping ((_ message: Message?, _ error: Error?) -> Void)) {
        
        conversationPreviewListener = db.collection("Conversations").document(conversationID).collection("Messages").order(by: "timestamp", descending: true).limit(to: 1).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {

                print(error as Any)

                completion(nil, error)
            }

            else {

                if snapshot?.isEmpty != true {

                    var message = Message()
                    message.message = snapshot!.documents.first!["message"] as! String
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
    }
    
    func retrieveCollabConversations (completion: @escaping ((_ conversations: [Conversation], _ error: Error?) -> Void)) {
        
        conversationListener = db.collection("Users").document(currentUser.userID).collection("Collabs").addSnapshotListener({ (snapshot, error) in
            
            self.conversations.removeAll()
            
            if error != nil {
                
                print(error as Any)
                
                completion([], nil)
            }
                
            else {
                
                if snapshot?.isEmpty != true {
                        
                    for document in snapshot!.documents {
                        
                        var conversation = Conversation()
                        conversation.conversationID = document.data()["collabID"] as! String
                        conversation.conversationName = document.data()["collabName"] as? String
                        
                        let timestamp = document.data()["dateCreated"] as! Timestamp
                        conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                        
                        //conversation.lastTimeMembersWereActive = document.data()["lastTimeMembersWereActive"] as! [String : Any]
                        
                        //print(conversation.lastTimeMembersWereActive)
                        
                        self.conversations.append(conversation)
                        
                        self.retrieveCollabConversationMembers(conversation.conversationID) { (members, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                            }
                                
                            else {
                                
                                let conversationIndex = self.conversations.firstIndex(where: {$0.conversationID == conversation.conversationID})
                                
                                self.conversations[conversationIndex!].members = members
                                
                                NotificationCenter.default.post(name: .didRetrieveConversationMembers, object: nil)
                            }
                        }
                        
                        self.retrieveCollabConversationPreview(conversation.conversationID) { (message, error) in
                            
                            if error != nil {
                                
                                print(error as Any)
                            }
                            
                            else {
                                
                                let conversationIndex = self.conversations.firstIndex(where: {$0.conversationID == conversation.conversationID})
                                
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
        
        let collab = firebaseCollab.collabs.first(where: { $0.collabID == collabID })
        var conversationMembers: [Member] = []
        
        for member in collab?.members ?? [] {
            
            conversationMembers.append(member)
        }
        
        completion(conversationMembers, nil)
    }
    
    private func retrieveCollabConversationPreview (_ collabID: String, completion: @escaping ((_ message: Message?, _ error: Error?) -> Void)) {
        
        conversationPreviewListener = db.collection("Collaborations").document(collabID).collection("Messages").order(by: "timestamp", descending: true).limit(to: 1).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {

                print(error as Any)

                completion(nil, error)
            }

            else {

                if snapshot?.isEmpty != true {

                    var message = Message()
                    message.message = snapshot!.documents.first!["message"] as! String
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
                        message.sender = document.data()["sender"] as! String
                        message.message = document.data()["message"] as! String
                        //message.readBy = document.data()["readBy"] as? [String]
                        
                        let timestamp = document.data()["timestamp"] as! Timestamp
                        message.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                        
                        messages.append(message)
                    }
                    
                    messages = messages.sorted(by: { $0.timestamp < $1.timestamp })
                    
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
                        message.sender = document.data()["sender"] as! String
                        message.message = document.data()["message"] as! String
                        
                        let timestamp = document.data()["timestamp"] as! Timestamp
                        message.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                        
                        messages.append(message)
                    }
                    
                    messages = messages.sorted(by: { $0.timestamp < $1.timestamp })
                    
                    completion(messages, nil)
                }
                
                else {
                    
                    completion([], nil)
                }
            }
        }
    }
    
    func sendPersonalMessage (conversationID: String, _ message: Message, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let message: [String : Any] = ["sender" : message.sender, "message" : message.message, "timestamp" : message.timestamp as Any, /*"readBy" : message.readBy as Any*/]
        
        db.collection("Conversations").document(conversationID).collection("Messages").addDocument(data: message) { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                completion(nil)
            }
        }
    }
    
    func sendCollabMessage (collabID: String, _ message: Message, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let message: [String : Any] = ["sender" : message.sender, "message" : message.message, "timestamp" : message.timestamp as Any]
        
        db.collection("Collaborations").document(collabID).collection("Messages").addDocument(data: message) { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                completion(nil)
            }
        }
    }
    
    func readMessages (conversationID: String? = nil, collabID: String? = nil) {
        
        let currentDate = Date()
        
        //let lastTimeActive: [String : Any] = ["lastTimeMembersWereActive" : [currentUserID : Date()]]
        
        if let conversation = conversationID {
            
            db.collection("Users").document(currentUser.userID).collection("Conversations").document(conversation).setData(["lastTimeActive" : currentDate], merge: true)
            
            db.collection("Conversations").document(conversation).setData(["lastTimeMembersWereActive" : [currentUser.userID : currentDate]], merge: true)
        }
        
        else if let collab = collabID {
            
            db.collection("Users").document(currentUser.userID).collection("Collabs").document(collab).setData(["lastTimeActive" : currentDate])
            
            db.collection("Collaborations").document(collab).setData(["lastTimeMembersWereActive" : [currentUser.userID : currentDate]], merge: true)
        }
        
        
    }
}
