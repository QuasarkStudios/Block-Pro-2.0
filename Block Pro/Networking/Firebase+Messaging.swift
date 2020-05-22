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

    var messageListener: ListenerRegistration?
    
    let currentUser = CurrentUser.sharedInstance
    
    func createConversation (members: [Friend], completion: @escaping ((_ error: Error?) -> Void)) {
        
        let batch = db.batch()
        let conversationID = UUID().uuidString
        var memberArray: [[String : String]] = []
        
        batch.setData(["conversationID" : conversationID], forDocument: db.collection("Conversations").document(conversationID))
        
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
            
            batch.setData(["conversationID" : conversationID], forDocument: db.collection("Users").document(member["userID"]!).collection("Conversations").document(conversationID))
            
            for addedMember in memberArray {
                
                batch.setData(addedMember, forDocument: db.collection("Users").document(member["userID"]!).collection("Conversations").document(conversationID).collection("Members").document(addedMember["userID"]!))
            }
        }
        
        batch.commit { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                completion(nil)
            }
        }
    }
    
    func retrieveAllMessages (collabID: String, completion: @escaping ((_ messages: [Message], _ error: Error?) -> Void)) {
        
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
                        
                        //messages.insert(message, at: 0)
                        
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
    
    func sendMessage (collabID: String, _ message: Message, completion: @escaping ((_ error: Error?) -> Void)) {
        
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
}
