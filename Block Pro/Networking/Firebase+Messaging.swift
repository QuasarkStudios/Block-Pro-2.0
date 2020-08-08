//
//  Firebase+Messaging.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/21/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
//import Firebase
import FirebaseFirestore

class FirebaseMessaging {
    
    lazy var db = Firestore.firestore()
    
    lazy var firebaseCollab = FirebaseCollab.sharedInstance
    lazy var firebaseStorage = FirebaseStorage()
    
    var personalConversationListener: ListenerRegistration?
    var personalConversationPreviewListeners: [ListenerRegistration] = []
    var personalConversationMembersListeners: [ListenerRegistration] = []
    
    var collabConversationListener: ListenerRegistration?
    var collabConversationPreviewListeners: [ListenerRegistration] = []
    var collabConversationMembersListeners: [ListenerRegistration] = []
    
    var personalConversations: [Conversation] = []
    var collabConversations: [Conversation] = []
    
    var messageListener: ListenerRegistration?
    
    let currentUser = CurrentUser.sharedInstance
    
    static let sharedInstance = FirebaseMessaging()
    
    func createPersonalConversation (members: [Friend], completion: @escaping ((_ conversationID: String?, _ error: Error?) -> Void)) {
        
        let batch = db.batch()
        let conversationID = UUID().uuidString
        let dateCreated = Date()
        var memberArray: [String] = []
        
        batch.setData(["conversationID" : conversationID, "dateCreated" : dateCreated], forDocument: db.collection("Conversations").document(conversationID), merge: true)
        
        for member in members {
            
            var memberToBeAdded: [String : String] = [:]
            
            memberToBeAdded["userID"] = member.userID
            memberToBeAdded["firstName"] = member.firstName
            memberToBeAdded["lastName"] = member.lastName
            memberToBeAdded["username"] = member.username
            memberToBeAdded["role"] = "Member"
            
            memberArray.append(member.userID)
            
            batch.setData(memberToBeAdded, forDocument: db.collection("Conversations").document(conversationID).collection("Members").document(member.userID), merge: true)
            
            batch.setData(["memberGainedAccessOn" : [(member.userID) : dateCreated]], forDocument: db.collection("Conversations").document(conversationID), merge: true)
            
            if member.userID == members.last?.userID {
                
                memberToBeAdded["userID"] = currentUser.userID
                memberToBeAdded["firstName"] = currentUser.firstName
                memberToBeAdded["lastName"] = currentUser.lastName
                memberToBeAdded["username"] = currentUser.username
                memberToBeAdded["role"] = "Lead"
                
                memberArray.append(currentUser.userID)
                
                batch.setData(memberToBeAdded, forDocument: db.collection("Conversations").document(conversationID).collection("Members").document(currentUser.userID), merge: true)
                
                batch.setData(["memberGainedAccessOn" : [(currentUser.userID): dateCreated]], forDocument: db.collection("Conversations").document(conversationID), merge: true)
            }
        }
        
        batch.setData(["Members" : memberArray], forDocument: db.collection("Conversations").document(conversationID), merge: true)
        
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
        
        self.firebaseStorage.saveConversationCoverPhoto(conversationID: conversationID, coverPhoto: coverPhoto) { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                let batch = self.db.batch()
                
                batch.setData(["coverPhotoID" : coverPhotoID], forDocument: self.db.collection("Conversations").document(conversationID), merge: true)
                
                let messageDict: [String : Any] = ["sender" : self.currentUser.userID, "memberUpdatedConversationCover" : true, "timestamp" : Date()]
                batch.setData(messageDict, forDocument: self.db.collection("Conversations").document(conversationID).collection("Messages").document(UUID().uuidString))
                
                batch.commit { (error) in
                    
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
                
                let batch = self.db.batch()
                
                batch.updateData(["coverPhotoID" : FieldValue.delete()], forDocument: self.db.collection("Conversations").document(conversationID))
                
                let messageDict: [String : Any] = ["sender" : self.currentUser.userID, "memberUpdatedConversationCover" : false, "timestamp" : Date()]
                batch.setData(messageDict, forDocument: self.db.collection("Conversations").document(conversationID).collection("Messages").document(UUID().uuidString))
                
                batch.commit { (error) in
                    
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
    
    func retrievePersonalConversations (completion: @escaping ((_ conversations: [Conversation], _ error: Error?) -> Void)) {
        
        personalConversationListener = db.collection("Conversations").whereField("Members", arrayContains: currentUser.userID).addSnapshotListener ({ (snapshot, error) in
            
            if error != nil {
                
                print(error as Any)
                
                completion([], error)
            }
            
            else {
                
                if snapshot?.isEmpty != true {
                    
                    self.removePersonalConversationsWhereUserInactive(snapshot: snapshot)
                    
                    for document in snapshot?.documents ?? [] {
                        
                        let conversationID: String = document.data()["conversationID"] as? String ?? ""
                        let conversationName: String? = document.data()["conversationName"] as? String
                        let coverPhotoID: String? = document.data()["coverPhotoID"] as? String
                        let dateCreatedTimestamp: Timestamp = document.data()["dateCreated"] as! Timestamp
                        let currentMembersIDs: [String] = document.data()["Members"] as? [String] ?? []
                        let memberGainedAccessOn: [String : Timestamp] = document.data()["memberGainedAccessOn"] as! [String : Timestamp]
                        let memberActivity: [String : Any]? = document.data()["memberActivity"] as? [String : Any]
                        
                        if let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversationID }) {
                            
                            self.personalConversations[conversationIndex].conversationName = conversationName
                            self.personalConversations[conversationIndex].coverPhotoID = coverPhotoID
                            self.personalConversations[conversationIndex].currentMembersIDs = currentMembersIDs
                            self.personalConversations[conversationIndex].memberGainedAccessOn = memberGainedAccessOn
                            self.personalConversations[conversationIndex].memberActivity = self.parseConversationActivity(memberActivity: memberActivity)
                        }
                        
                        else {
                            
                            var conversation = Conversation()
                            
                            conversation.conversationID = conversationID
                            conversation.conversationName = conversationName
                            conversation.coverPhotoID = coverPhotoID
                            conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreatedTimestamp.seconds))
                            conversation.currentMembersIDs = currentMembersIDs
                            conversation.memberGainedAccessOn = memberGainedAccessOn
                            conversation.memberActivity = self.parseConversationActivity(memberActivity: memberActivity)
                            
                            self.personalConversations.append(conversation)
                        }
                        
                        if let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversationID }) {
                            
                            self.retrievePersonalConversationMembers(self.personalConversations[conversationIndex]) { (historicMembers, currentMembers, error) in
                                
                                if error != nil {
                                    
                                    print(error as Any)
                                }
                                
                                else {
                                    
                                    self.personalConversations[conversationIndex].historicMembers = historicMembers
                                    self.personalConversations[conversationIndex].currentMembers = currentMembers
                                    
                                    NotificationCenter.default.post(name: .didRetrieveConversationMembers, object: nil)
                                }
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
    
    func removePersonalConversationsWhereUserInactive (snapshot: QuerySnapshot?) {
        
        if snapshot?.documents.count != personalConversations.count {
            
            personalConversations.forEach { (conversation) in
                
                var currentUserMemberInConversation: Bool = false
                
                for document in snapshot?.documents ?? [] {
                    
                    if document.data()["conversationID"] as? String == conversation.conversationID {
                        
                        currentUserMemberInConversation = true
                        break
                    }
                }
                
                if !currentUserMemberInConversation {
                    
                    personalConversations.removeAll(where: { $0.conversationID == conversation.conversationID })
                }
            }
        }
    }
    
    private func retrievePersonalConversationMembers (_ personalConversation: Conversation, completion: @escaping ((_ historicMembers: [Member], _ currentMembers: [Member], _ error: Error?) -> Void)) {
        
        var retrieveMembers: Bool = false
        
        if personalConversation.currentMembersIDs.count != personalConversation.currentMembers.count {
            
            retrieveMembers = true
        }
        
        else {
            
            for memberID in personalConversation.currentMembersIDs {
                
                if personalConversation.currentMembers.contains(where: { $0.userID == memberID }) == false {
                    
                    retrieveMembers = true
                    break
                }
            }
        }
        
        if retrieveMembers {
            
            db.collection("Conversations").document(personalConversation.conversationID).collection("Members").getDocuments { (snapshot, error) in
                
                if error != nil {
                    
                    completion([], [], error)
                }
                
                else {
                    
                    if snapshot?.isEmpty != true {
                        
                        var historicMembers: [Member] = []
                        
                        for document in snapshot?.documents ?? [] {
                            
                            var member = Member()
                            
                            member.userID = document.data()["userID"] as! String
                            member.firstName = document.data()["firstName"] as! String
                            member.lastName = document.data()["lastName"] as! String
                            member.username = document.data()["username"] as! String
                            member.role = document.data()["role"] as! String
                            
                            if self.firebaseCollab.friends.contains(where: { $0.userID == member.userID }) {
                                
                                historicMembers.insert(member, at: 0)
                            }
                            
                            else {
                                
                                historicMembers.append(member)
                            }
                        }
                        
                        let currentMembers = self.filterCurrentMembers(currentMembers: personalConversation.currentMembersIDs, historicMembers: historicMembers)
                        
                        completion(historicMembers, currentMembers, nil)
                    }
                    
                    else {
                        
                        completion([], [], nil)
                    }
                }
            }
        }
        
        else {
            
            //completion(personalConversation.historicMembers, personalConversation.currentMembers, nil)
        }
        
        //personalConversationMembersListeners.append(listener)
    }
    
    private func filterCurrentMembers (currentMembers: [String], historicMembers: [Member]) -> [Member] {
        
        var members: [Member] = []
        
        historicMembers.forEach { (member) in
            
            if currentMembers.contains(member.userID) {
                
                members.append(member)
            }
        }
        
        return members
    }
    
    private func retrievePersonalConversationPreview (_ conversationID: String, completion: @escaping ((_ message: Message?, _ error: Error?) -> Void)) {
        
        let conversation = personalConversations.first(where: { $0.conversationID == conversationID })
        
        let listener = db.collection("Conversations").document(conversationID).collection("Messages").order(by: "timestamp", descending: true).limit(to: 1).whereField("timestamp", isGreaterThanOrEqualTo: conversation?.memberGainedAccessOn?[currentUser.userID] as! Timestamp).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {

                print(error as Any)

                completion(nil, error)
            }

            else {

                if snapshot?.isEmpty != true {

                    var message = Message()
                    message.messageID = snapshot!.documents.first!.documentID
                    message.sender = snapshot!.documents.first!["sender"] as! String
                    message.message = snapshot!.documents.first!["message"] as? String
                    message.messagePhoto = snapshot!.documents.first!["photo"] as? [String : Any]
                    message.memberUpdatedConversationCover = snapshot!.documents.first!["memberUpdatedConversationCover"] as? Bool
                    message.memberUpdatedConversationName = snapshot!.documents.first!["memberUpdatedConversationName"] as? Bool
                    message.memberJoiningConversation = snapshot!.documents.first!["memberJoiningConversation"] as? Bool
                    
                    let timestamp = snapshot!.documents.first!["timestamp"] as! Timestamp
                    message.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                    
                    completion(message, nil)
                }
                
                else {
                    
                    completion(nil, nil)
                }
            }
        })
        
        personalConversationPreviewListeners.append(listener)
    }
    
    func retrieveCollabConversations (completion: @escaping ((_ conversations: [Conversation], _ error: Error?) -> Void)) {
        
        collabConversationListener = db.collection("Collaborations").whereField("Members", arrayContains: currentUser.userID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                print(error as Any)
                
                completion([], nil)
            }
                
            else {
                
                if snapshot?.isEmpty != true {
                        
                    //self.removeCollabConversationsWhereUserInactive(snapshot: snapshot)
                    
                    for document in snapshot?.documents ?? [] {
                        
                        let collabID = document.data()["collabID"] as! String
                        let collabName = document.data()["collabName"] as? String
                        let dateCreated = document.data()["dateCreated"] as! Timestamp
                        let currentMembersIDs: [String] = document.data()["Members"] as? [String] ?? []
                        let memberActivity: [String : Any]? = document.data()["memberActivity"] as? [String : Any]
                        
                        if let conversationIndex = self.collabConversations.firstIndex(where: { $0.conversationID == collabID }) {
                            
                            self.collabConversations[conversationIndex].conversationName = collabName
                            self.collabConversations[conversationIndex].currentMembersIDs = currentMembersIDs
                            self.collabConversations[conversationIndex].memberActivity = self.parseConversationActivity(memberActivity: memberActivity)
                        }
                        
                        else {
                            
                            var conversation = Conversation()
                            
                            conversation.conversationID = collabID
                            conversation.conversationName = collabName
                            conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreated.seconds))
                            conversation.currentMembersIDs = currentMembersIDs
                            conversation.memberActivity = self.parseConversationActivity(memberActivity: memberActivity)
                            
                            self.collabConversations.append(conversation)
                        }
                        
                        if let conversationIndex = self.collabConversations.firstIndex(where: { $0.conversationID == collabID }) {
                            
                            self.retrieveCollabConversationMembers(self.collabConversations[conversationIndex]) { (historicMembers, currentMembers, error) in
                                
                                if error != nil {
                                    
                                    print(error as Any)
                                }
                                
                                else {
                                    
                                    self.collabConversations[conversationIndex].historicMembers = historicMembers
                                    self.collabConversations[conversationIndex].currentMembers = currentMembers
                                
                                    NotificationCenter.default.post(name: .didRetrieveConversationMembers, object: nil)
                                }
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
    
    func removeCollabConversationsWhereUserInactive (snapshot: QuerySnapshot?) {
        
        if snapshot?.documents.count != collabConversations.count {
            
            collabConversations.forEach { (conversation) in
                
                var currentUserMemberInConversation: Bool = false
                
                for document in snapshot?.documents ?? [] {
                    
                    if document.data()["conversationID"] as? String == conversation.conversationID {
                        
                        currentUserMemberInConversation = true
                        break
                    }
                }
                
                if !currentUserMemberInConversation {
                    
                    collabConversations.removeAll(where: { $0.conversationID == conversation.conversationID })
                }
            }
        }
    }
    
    private func retrieveCollabConversationMembers (_ collabConversation: Conversation, completion: @escaping ((_ historicMembers: [Member], _ currentMembers: [Member], _ error: Error?) -> Void)) {
        
        var retrieveMembers: Bool = false
        
        if collabConversation.currentMembersIDs.count != collabConversation.currentMembers.count {
            
            retrieveMembers = true
        }
        
        else {
            
            for memberID in collabConversation.currentMembersIDs {
                
                if collabConversation.currentMembers.contains(where: { $0.userID == memberID }) == false {
                    
                    retrieveMembers = true
                    break
                }
            }
        }
        
        if retrieveMembers {
            
            db.collection("Collaborations").document(collabConversation.conversationID).collection("Members").getDocuments { (snapshot, error) in
                
                if error != nil {
                    
                    print(error as Any)
                    
                    completion([], [], error)
                }
                
                else {
                    
                    if snapshot?.isEmpty != true {
                        
                        var historicMembers: [Member] = []
                        
                        for document in snapshot?.documents ?? [] {
                            
                            var member = Member()
                            
                            member.userID = document.data()["userID"] as! String
                            member.firstName = document.data()["firstName"] as! String
                            member.lastName = document.data()["lastName"] as! String
                            member.username = document.data()["username"] as! String
                            member.role = document.data()["role"] as! String
                            
                            if self.firebaseCollab.friends.contains(where: { $0.userID == member.userID }) {
                                
                                historicMembers.insert(member, at: 0)
                            }
                            
                            else {
                                
                                historicMembers.insert(member, at: 0)
                            }
                        }
                        
                        let currentMembers = self.filterCurrentMembers(currentMembers: collabConversation.currentMembersIDs, historicMembers: historicMembers)
                        
                        completion(historicMembers, currentMembers, nil)
                    }
                    
                    else {
                        
                        completion([], [], nil)
                    }
                }
            }
        }
        
        //collabConversationMembersListeners.append(listener)
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
                    message.sender = snapshot!.documents.first!["sender"] as! String
                    message.message = snapshot!.documents.first!["message"] as? String
                    message.messagePhoto = snapshot!.documents.first!["photo"] as? [String : Any]
                    message.memberJoiningConversation = snapshot!.documents.first!["memberJoiningConversation"] as? Bool
                    
                    let timestamp = snapshot!.documents.first!["timestamp"] as! Timestamp
                    message.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                    
                    completion(message, nil)
                }
                
                else {
                    
                    completion(nil, nil)
                }
            }
        })
        
        collabConversationPreviewListeners.append(listener)
    }
    
    func retrieveAllPersonalMessages (conversationID: String, completion: @escaping ((_ messages: [Message], _ error: Error?) -> Void)) {
        
        let conversation = personalConversations.first(where: { $0.conversationID == conversationID })
        
        messageListener = db.collection("Conversations").document(conversationID).collection("Messages").whereField("timestamp", isGreaterThanOrEqualTo: conversation?.memberGainedAccessOn?[currentUser.userID] as! Timestamp).addSnapshotListener({ (snapshot, error) in
            
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
                        message.memberUpdatedConversationCover = document.data()["memberUpdatedConversationCover"] as? Bool
                        message.memberUpdatedConversationName = document.data()["memberUpdatedConversationName"] as? Bool
                        message.memberJoiningConversation = document.data()["memberJoiningConversation"] as? Bool
                        
                        let timestamp = document.data()["timestamp"] as! Timestamp
                        message.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                        
                        messages.append(message)
                    }
                    
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
                    
                    completion(messages, nil)
                }
                
                else {
                    
                    completion([], nil)
                }
            }
        }
    }
    
    func monitorPersonalConversation (conversationID: String, completion:  @escaping ((_ updatedConvo: [String : Any?]) -> Void)) {
        
        personalConversationListener = db.collection("Conversations").document(conversationID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(["error" : error])
            }
            
            else {
                
                if snapshot != nil {
                    
                    let conversationName = snapshot!.data()?["conversationName"] as? String
                    let coverPhotoID = snapshot!.data()?["coverPhotoID"] as? String
                    let currentMembersIDs: [String] = snapshot!.data()?["Members"] as? [String] ?? []
                    let memberActivity = self.parseConversationActivity(memberActivity: snapshot!.data()?["memberActivity"] as? [String : Any])
                    
                    if let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversationID }) {
                        
                        if coverPhotoID != self.personalConversations[conversationIndex].coverPhotoID {
                            
                            self.personalConversations[conversationIndex].conversationCoverPhoto = nil
                        }
                        
                        self.personalConversations[conversationIndex].conversationName = conversationName
                        self.personalConversations[conversationIndex].coverPhotoID = coverPhotoID
                        self.personalConversations[conversationIndex].currentMembersIDs = currentMembersIDs
                        self.personalConversations[conversationIndex].memberActivity = memberActivity
                        
                        completion(["conversationName" : conversationName, "coverPhotoID" : coverPhotoID, "currentMembersIDs" : self.personalConversations[conversationIndex].currentMembersIDs, "memberActivity" : memberActivity])
                        
                        self.retrievePersonalConversationMembers(self.personalConversations[conversationIndex]) { (historicMembers, currentMembers, error) in
                            
                            if error != nil {
                                
                                completion(["error" : error])
                            }
                            
                            else {
                                
                                self.personalConversations[conversationIndex].historicMembers = historicMembers
                                self.personalConversations[conversationIndex].currentMembers = currentMembers
                                
                                completion(["historicMembers" : historicMembers, "currentMembers": currentMembers])
                            }
                        }
                    }
                }
            }
        })
    }
    
    func monitorCollabConversation (collabID: String, completion: @escaping ((_ updatedConvo: [String : Any?]) -> Void)) {
        
        collabConversationListener = db.collection("Collaborations").document(collabID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(["error" : error])
            }
            
            else {
                
                if snapshot != nil {
                    
                    let collabName = snapshot!.data()?["collabName"] as? String
                    let coverPhotoID = snapshot!.data()?["coverPhotoID"] as? String
                    let memberActivity = self.parseConversationActivity(memberActivity: snapshot!.data()?["memberActivity"] as? [String : Any])
                    
                    if let conversationIndex = self.collabConversations.firstIndex(where: { $0.conversationID == collabID }) {
                        
                        if coverPhotoID != self.collabConversations[conversationIndex].coverPhotoID {
                            
                            self.collabConversations[conversationIndex].conversationCoverPhoto = nil
                        }
                        
                        self.collabConversations[conversationIndex].conversationName = collabName
                        self.collabConversations[conversationIndex].coverPhotoID = coverPhotoID
                        self.collabConversations[conversationIndex].memberActivity = memberActivity
                        
                        completion(["collabName" : collabName, "coverPhotoID" : coverPhotoID, "memberActivity" : memberActivity])
                        
                        self.retrieveCollabConversationMembers(self.collabConversations[conversationIndex]) { (historicMembers, currentMembers, error) in
                            
                            if error != nil {
                                
                                completion(["error" : error])
                            }
                            
                            else {
                                
                                self.collabConversations[conversationIndex].historicMembers = historicMembers
                                self.collabConversations[conversationIndex].currentMembers = currentMembers
                                
                                completion(["historicMembers" : historicMembers, "currentMembers" : currentMembers])
                            }
                        }
                    }
                }
            }
        })
    }
    
    func filterPhotoMessages (messages: [Message]?) -> [Message] {
        
        var messagesWithPhotos: [Message] = []
        
        for message in messages ?? [] {
            
            if message.messagePhoto != nil {
                
                messagesWithPhotos.append(message)
            }
        }
        
        return messagesWithPhotos
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
    
    func setActivityStatus (conversationID: String? = nil, collabID: String? = nil, _ status: Any) {
        
        if let conversation = conversationID {
            
            db.collection("Conversations").document(conversation).updateData(["memberActivity.\(currentUser.userID)" : status])
        }
        
        else if let collab = collabID {
                
            db.collection("Collaborations").document(collab).updateData(["memberActivity.\(currentUser.userID)" : status])
        }
    }
    
    func updateConversationName (conversationID: String, name: String?, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let batch = db.batch()
        
        batch.updateData(["conversationName" : name as Any], forDocument: db.collection("Conversations").document(conversationID))
        
        let memberUpdatedName = name != nil ? true : false
        
        let messageDict: [String : Any] = ["sender" : currentUser.userID, "memberUpdatedConversationName" : memberUpdatedName, "timestamp" : Date()]
        batch.setData(messageDict, forDocument: db.collection("Conversations").document(conversationID).collection("Messages").document(UUID().uuidString))
        
        batch.commit { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                completion(nil)
            }
        }
    }
    
    func addNewConversationMembers (conversationID: String, membersToBeAdded: [Friend], completion: @escaping ((_ error: Error?, _ fullConversation: Bool) -> Void)) {
        
        db.collection("Conversations").document(conversationID).getDocument { (snapshot, error) in
            
            if error != nil {
                
                completion(error, false)
            }
            
            else {
                
                if let currentMembers = snapshot?.data()?["Members"] as? [String] {
                    
                    if currentMembers.count + membersToBeAdded.count <= 6 {
                        
                        let batch = self.db.batch()
                        
                        for addedMember in membersToBeAdded {
                            
                            var member: [String : String] = [:]
                            
                            member["userID"] = addedMember.userID
                            member["firstName"] = addedMember.firstName
                            member["lastName"] = addedMember.lastName
                            member["username"] = addedMember.username
                            member["role"] = "Member"
                            
                            batch.setData(member, forDocument: self.db.collection("Conversations").document(conversationID).collection("Members").document(addedMember.userID))
                            
                            batch.updateData(["Members" : FieldValue.arrayUnion([addedMember.userID])], forDocument: self.db.collection("Conversations").document(conversationID))
                            
                            batch.updateData(["memberGainedAccessOn.\(addedMember.userID)" : Date()], forDocument: self.db.collection("Conversations").document(conversationID))
                            
                            //Sending a message to the chat notifying the members that a new member is joining
                            let messageDict: [String : Any] = ["sender" : addedMember.userID, "memberJoiningConversation" : true, "timestamp" : Date().addingTimeInterval(-60)]
                            batch.setData(messageDict, forDocument: self.db.collection("Conversations").document(conversationID).collection("Messages").document(UUID().uuidString))
                        }
                        
                        batch.commit { (error) in
                            
                            if error != nil {
                                
                                completion(error, false)
                            }
                            
                            else {
                                
                                completion(nil, false)
                            }
                        }
                    }
                    
                    else {
                        
                        completion(nil, true) //Too many members
                    }
                }
            }
        }
    }
    
    func deleteMessages (conversationID: String, compeletion: @escaping ((_ error: Error?) -> Void)) {
        
        db.collection("Conversations").document(conversationID).updateData(["memberGainedAccessOn.\(currentUser.userID)" : Date()]) { (error) in
            
            if error != nil {
                
                compeletion(error)
            }
            
            else {
                
                compeletion(nil)
            }
        }
    }
    
    func leaveConversation (conversationID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let batch = db.batch()
        
        //Changing role of the currentUser
        batch.updateData(["role" : "Inactive"], forDocument: db.collection("Conversations").document(conversationID).collection("Members").document(currentUser.userID))

        //Removing currentUser from the Members array in the conversation fields; not from the Members collection
        batch.updateData(["Members" : FieldValue.arrayRemove([currentUser.userID])], forDocument: db.collection("Conversations").document(conversationID))

        //Removing the currentUser from the "memberGainedAccessOn" map
        batch.updateData(["memberGainedAccessOn.\(currentUser.userID)" : FieldValue.delete()], forDocument: db.collection("Conversations").document(conversationID))
        
        //Will leave currentUser in the "memberActivity" map in case they are added again
        batch.updateData(["memberActivity.\(currentUser.userID)" : Date()], forDocument: db.collection("Conversations").document(conversationID))
        
        //Sending a message to the chat notifying the members that the currentUser is leaving
        let messageDict: [String : Any] = ["sender" : currentUser.userID, "memberJoiningConversation" : false, "timestamp" : Date()]
        batch.setData(messageDict, forDocument: db.collection("Conversations").document(conversationID).collection("Messages").document(UUID().uuidString))
        
        batch.commit { (error) in
            
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
    
    func convertTimestampToDate (_ timestamp: Any) -> Date {
        
        if let timestamp = timestamp as? Timestamp {
            
            return Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
        }
        
        else {
            
            return Date()
        }
    }
}
