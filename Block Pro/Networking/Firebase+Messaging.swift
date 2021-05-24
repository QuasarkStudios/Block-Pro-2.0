//
//  Firebase+Messaging.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/21/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirebaseMessaging {
    
    lazy var db = Firestore.firestore()
    
    lazy var firebaseCollab = FirebaseCollab.sharedInstance
    lazy var firebaseStorage = FirebaseStorage()
    
    var allPersonalConversationsListener: ListenerRegistration?
    var allCollabConversationsListener: ListenerRegistration?
    
    var monitorPersonalConversationListener: ListenerRegistration?
    var monitorCollabConversationListener: ListenerRegistration?
    
    var personalConversationPreviewListenersDict: [String : ListenerRegistration] = [:]
    var collabConversationPreviewListenersDict: [String : ListenerRegistration] = [:]
    
    var personalConversations: [Conversation] = []
    var collabConversations: [Conversation] = []
    
    var messageListener: ListenerRegistration?
    
    let currentUser = CurrentUser.sharedInstance
    
    static let sharedInstance = FirebaseMessaging()
    
    
    //MARK: - Creating Conversation Functions
    
    func createPersonalConversation (members: [Friend], completion: @escaping ((_ conversationID: String?, _ error: Error?) -> Void)) {
        
        var batch = db.batch()
        let conversationID = UUID().uuidString
        let dateCreated = Date()
        
        batch.setData(["conversationID" : conversationID, "dateCreated" : dateCreated], forDocument: db.collection("Conversations").document(conversationID), merge: true)
        
        batch = setConversationMembers(conversationID, members, dateCreated, batch)
        
        batch.commit { (error) in
            
            if error != nil {
                
                completion(nil, error)
            }
            
            else {
                
                completion(conversationID, nil)
            }
        }
    }
    
    private func setConversationMembers (_ conversationID: String, _ members: [Friend], _ dateCreated: Date, _ batch: WriteBatch) -> WriteBatch {
        
        var membersArray: [String] = []
        var memberDict: [String : String] = [:]
        
        //Setting data for the current user
        membersArray.append(currentUser.userID)
        
        memberDict["userID"] = currentUser.userID
        memberDict["firstName"] = currentUser.firstName
        memberDict["lastName"] = currentUser.lastName
        memberDict["username"] = currentUser.username
        memberDict["role"] = "Lead"
        
        batch.setData(memberDict, forDocument: db.collection("Conversations").document(conversationID).collection("Members").document(currentUser.userID), merge: true)
        
        batch.setData(["memberGainedAccessOn" : [(currentUser.userID): dateCreated]], forDocument: db.collection("Conversations").document(conversationID), merge: true)
        
        //Setting the data for all other users in the conversation
        for member in members {
            
            membersArray.append(member.userID)
            
            memberDict["userID"] = member.userID
            memberDict["firstName"] = member.firstName
            memberDict["lastName"] = member.lastName
            memberDict["username"] = member.username
            memberDict["role"] = "Member"
            
            batch.setData(memberDict, forDocument: db.collection("Conversations").document(conversationID).collection("Members").document(member.userID), merge: true)
            
            batch.setData(["memberGainedAccessOn" : [(member.userID) : dateCreated]], forDocument: db.collection("Conversations").document(conversationID), merge: true)
        }
        
        //Setting the memberID's in the conversations document
        batch.setData(["Members" : membersArray], forDocument: db.collection("Conversations").document(conversationID), merge: true)
        
        return batch
    }
    
    
    //MARK: - Retrieval Personal Conversations
    
    func retrievePersonalConversations (completion: @escaping ((_ conversations: [Conversation]?, _ convoMembers: [String : [Member]]?, _ messagePreview: [String : Any]?, _ error: Error?) -> Void)) {
        
        allPersonalConversationsListener = db.collection("Conversations").whereField("Members", arrayContains: currentUser.userID).addSnapshotListener ({ (snapshot, error) in
            
            if error != nil {
                
                print(error as Any)
                
                completion(nil, nil, nil, error)
            }
            
            else {
                
                self.removePersonalConversationsWhereUserInactive(snapshot: snapshot)
                
                if snapshot?.isEmpty != true {
                    
                    for document in snapshot?.documents ?? [] {
                        
                        let conversation = self.configurePersonalConversation(document)
                        
                        //If this convo hasn't been added to the personalConversations array yet
                        if self.personalConversations.first(where: { $0.conversationID == conversation.conversationID }) == nil {
                            
                            self.personalConversations.append(conversation)
                            
                            //Adds a listener that will monitor this conversations messages
                            self.retrievePersonalConversationPreview(conversation) { (message, error) in
                                
                                self.handlePersonalConversationPreviewRetrievalCompletion(conversation.conversationID, message, error) { (messagePreview) in
                                    
                                    completion(nil, nil, messagePreview, nil)
                                }
                            }
                        }
                        
                        //If this conversation has already been added to the personalConversation array
                        else {
                            
                            self.handlePersonalConversationUpdate(conversation)
                        }
                        
                        if let existingConversation = self.personalConversations.first(where: { $0.conversationID == conversation.conversationID }) {
                            
                            //Grabs a snapshot of the members of a conversation only if they haven't been retrieved yet or have changed
                            self.retrievePersonalConversationMembers(existingConversation) { (historicMembers, currentMembers, error) in
                                
                                self.handlePersonalConversationMembersRetrievalCompletion(existingConversation.conversationID, historicMembers, currentMembers, error) { (convoMembers) in
                                    
                                    completion(nil, convoMembers, nil, nil)
                                }
                            }
                        }
                    }
                    
                    completion(self.personalConversations, nil, nil, nil)
                }
                
                else {
                    
                    self.personalConversations.removeAll()
                    
                    completion([], nil, nil, nil) //No conversations found
                }
            }
        })
    }
    
    
    //MARK: - Configure Personal Conversation Function
    
    private func configurePersonalConversation (_ document: DocumentSnapshot) -> Conversation {
        
        var conversation = Conversation()
        
        conversation.conversationID = document.data()?["conversationID"] as? String ?? ""
        conversation.conversationName = document.data()?["conversationName"] as? String
        conversation.coverPhotoID = document.data()?["coverPhotoID"] as? String
        conversation.currentMembersIDs = document.data()?["Members"] as? [String] ?? []
        conversation.memberGainedAccessOn = document.data()?["memberGainedAccessOn"] as! [String : Timestamp]
        
        let dateCreatedTimestamp: Timestamp = document.data()?["dateCreated"] as! Timestamp
        conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreatedTimestamp.seconds))
        
        let memberActivity: [String : Any]? = document.data()?["memberActivity"] as? [String : Any]
        conversation.memberActivity = self.parseConversationActivity(memberActivity: memberActivity)
        
        return conversation
    }
    
    
    //MARK: - Handle Personal Conversation Update Function
    
    private func handlePersonalConversationUpdate (_ conversation: Conversation) {
        
        //Updates all the properties of a conversation that are subject to changes
        if let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
            
            //Indicative that that cover photo has changed
            if conversation.coverPhotoID != self.personalConversations[conversationIndex].coverPhotoID {
                
                self.personalConversations[conversationIndex].coverPhotoID = conversation.coverPhotoID
                self.personalConversations[conversationIndex].conversationCoverPhoto = nil
            }
            
            self.personalConversations[conversationIndex].conversationName = conversation.conversationName
            self.personalConversations[conversationIndex].currentMembersIDs = conversation.currentMembersIDs
            self.personalConversations[conversationIndex].memberGainedAccessOn = conversation.memberGainedAccessOn
            self.personalConversations[conversationIndex].memberActivity = conversation.memberActivity
        }
    }
    
    
    //MARK: - Remove Personal Conversation Function
    
    private func removePersonalConversationsWhereUserInactive (snapshot: QuerySnapshot?) {
        
        if snapshot?.documents.count != personalConversations.count {
            
            personalConversations.forEach { (conversation) in
                
                var currentUserMemberInConversation: Bool = false
                
                //Looks for conversations that are stored in the personalConversation array but were not retrieved in the snapshot
                for document in snapshot?.documents ?? [] {
                    
                    if document.data()["conversationID"] as? String == conversation.conversationID {
                        
                        currentUserMemberInConversation = true
                        break
                    }
                }
                
                if !currentUserMemberInConversation {
                    
                    personalConversations.removeAll(where: { $0.conversationID == conversation.conversationID })
                    
                    personalConversationPreviewListenersDict[conversation.conversationID]?.remove()
                    personalConversationPreviewListenersDict.removeValue(forKey: conversation.conversationID)
                }
            }
        }
    }

    
    //MARK: - Retrieve Personal Conversation Members
    
    private func retrievePersonalConversationMembers (_ personalConversation: Conversation, completion: @escaping ((_ historicMembers: [Member], _ currentMembers: [Member], _ error: Error?) -> Void)) {
        
        var retrieveMembers: Bool = false
        
        //If the count of the currentMemberIDs and the currentMembers don't equal each other
        if personalConversation.currentMembersIDs.count != personalConversation.currentMembers.count {
            
            retrieveMembers = true
        }
        
        else {
            
            for memberID in personalConversation.currentMembersIDs {
                
                //If there is a member that isn't in the currentMemberIDs array
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
                            
                            //Adds users friends before general conversation members
                            if self.firebaseCollab.friends.contains(where: { $0.userID == member.userID }) {
                                
                                historicMembers.insert(member, at: 0)
                            }
                            
                            else {
                                
                                historicMembers.append(member)
                            }
                        }
                        
                        //Filters out members that are no longer active in the conversation
                        let currentMembers = self.filterCurrentMembers(currentMembers: personalConversation.currentMembersIDs, historicMembers: historicMembers)
                        
                        completion(historicMembers, currentMembers, nil)
                    }
                    
                    else {
                        
                        completion([], [], nil)
                    }
                }
            }
        }
    }
    
    private func handlePersonalConversationMembersRetrievalCompletion (_ conversationID: String, _ historicMembers: [Member], _ currentMembers: [Member], _ error: Error?, _ completion: ((_ convoMembers: [String : [Member]]) -> Void)) {
        
        if error != nil {
            
            print(error as Any)
        }
        
        else {
            
            if let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversationID }) {
                
                self.personalConversations[conversationIndex].historicMembers = historicMembers
                self.personalConversations[conversationIndex].currentMembers = currentMembers
                self.personalConversations[conversationIndex].membersLoaded = true
                
                let convoMembers = ["historicMembers" : historicMembers, "currentMembers" : currentMembers]
                
                completion(convoMembers)
            }
        }
    }
    
    
    //MARK: - Retrieve Personal Conversation Preview
    
    private func retrievePersonalConversationPreview (_ conversation: Conversation, completion: @escaping ((_ message: Message?, _ error: Error?) -> Void)) {
        
        let listener = db.collection("Conversations").document(conversation.conversationID).collection("Messages").order(by: "timestamp", descending: true).limit(to: 1).whereField("timestamp", isGreaterThanOrEqualTo: conversation.memberGainedAccessOn?[currentUser.userID] as! Timestamp).addSnapshotListener({ (snapshot, error) in
            
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
                    self.retrieveMessageBlocks(&message, snapshot!.documents.first!["blocks"] as? [String : Any])
                    
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
        
        personalConversationPreviewListenersDict[conversation.conversationID] = listener
    }
    
    private func handlePersonalConversationPreviewRetrievalCompletion (_ conversationID: String, _ message: Message?, _ error: Error?, _ completion: ((_ messagePreview: [String : Any]?) -> Void)) {
        
        if error != nil {
            
            print(error as Any)
        }
        
        else {
            
            if let conversationIndex = self.personalConversations.firstIndex(where: { $0.conversationID == conversationID }) {
                
                self.personalConversations[conversationIndex].messagePreview = message
                self.personalConversations[conversationIndex].messagePreviewLoaded = true
                
                let messagePreview: [String : Any] = ["conversationID" : conversationID, "message" : message as Any]
                
                completion(messagePreview)
            }
        }
    }
    
    
    //MARK: - Retrieve Collab Conversations
    
    func retrieveCollabConversations (completion: @escaping ((_ conversations: [Conversation]?, _ collabMembers: [String : [Member]]?, _ messagePreview: [String : Any]?, _ error: Error?) -> Void)) {
        
        allCollabConversationsListener = db.collection("Collaborations").whereField("Members", arrayContains: currentUser.userID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                print(error as Any)
                
                completion(nil, nil, nil, error)
            }
                
            else {
                
                self.removeCollabConversationsWhereUserInactive(snapshot: snapshot)
                
                if snapshot?.isEmpty != true {
                    
                    for document in snapshot?.documents ?? [] {
                        
                        let conversation = self.configureCollabConversation(document)
                        
                        if conversation.accepted?[self.currentUser.userID] == true {
                            
                            //If this convo hasn't been added to the collabConversations array yet
                            if self.collabConversations.first(where: { $0.conversationID == conversation.conversationID }) == nil {
                                
                                self.collabConversations.append(conversation)
                                
                                //Adds a listener that will monitor this conversations messages
                                self.retrieveCollabConversationPreview(conversation.conversationID) { (message, error) in
                                    
                                    self.handleCollabConversationPreviewRetrievalCompletion(conversation.conversationID, message, error) { (messagePreview) in
                                        
                                        completion(nil, nil, messagePreview, nil)
                                    }
                                }
                            }
                            
                            //If this conversation has already been added to the collabConversation array
                            else {
                                
                                self.handleCollabConversationUpdate(conversation)
                            }
                            
                            if let existingConversation = self.collabConversations.first(where: { $0.conversationID == conversation.conversationID }) {
                                
                                //Grabs a snapshot of the members of a conversation only if they haven't been retrieved yet or have changed
                                self.retrieveCollabConversationMembers(existingConversation) { (historicMembers, currentMembers, error) in
                                    
                                    self.handleCollabConversationMembersRetrievalCompletion(conversation.conversationID, historicMembers, currentMembers, error) { (convoMembers) in
                                        
                                        completion(nil, convoMembers, nil, nil)
                                    }
                                }
                            }
                        }
                    }
                    
                    completion(self.collabConversations, nil, nil, nil)
                }
                
                else {
                    
                    self.collabConversations.removeAll()
                    
                    completion([], nil, nil, nil) //No collabs found
                }
            }
        })
    }
    
    
    //MARK: - Configure Collab Conversation Function
    
    private func configureCollabConversation (_ document: DocumentSnapshot) -> Conversation {
        
        var conversation = Conversation()
        
        conversation.conversationID = document.data()?["collabID"] as? String ?? ""
        conversation.conversationName = document.data()?["collabName"] as? String
        conversation.coverPhotoID = document.data()?["coverPhotoID"] as? String
        conversation.currentMembersIDs = document.data()?["Members"] as? [String] ?? []
        
        let dateCreatedTimestamp: Timestamp = document.data()?["dateCreated"] as! Timestamp
        conversation.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreatedTimestamp.seconds))
        
        let memberActivity: [String : Any]? = document.data()?["memberActivity"] as? [String : Any]
        conversation.memberActivity = self.parseConversationActivity(memberActivity: memberActivity)
        
        conversation.accepted = parseCollabAcceptionStatuses(document.data()?["accepted"] as? [String : Bool?])
        
        return conversation
    }
    
    
    //MARK: - Handle Collab Conversation Update Function
    
    private func handleCollabConversationUpdate (_ conversation: Conversation) {
        
        //Updates all the properties of a conversation that are subject to changes
        if let conversationIndex = self.collabConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
            
            //Indicative that that cover photo has changed
            if conversation.coverPhotoID != self.collabConversations[conversationIndex].coverPhotoID {
                
                self.collabConversations[conversationIndex].coverPhotoID = conversation.coverPhotoID
                self.collabConversations[conversationIndex].conversationCoverPhoto = nil
            }
            
            self.collabConversations[conversationIndex].conversationName = conversation.conversationName
            self.collabConversations[conversationIndex].currentMembersIDs = conversation.currentMembersIDs
            self.collabConversations[conversationIndex].memberGainedAccessOn = conversation.memberGainedAccessOn
            self.collabConversations[conversationIndex].memberActivity = conversation.memberActivity
            self.collabConversations[conversationIndex].accepted = conversation.accepted
        }
    }
    
    
    //MARK: - Remove Collab Conversation Function
    
    func removeCollabConversationsWhereUserInactive (snapshot: QuerySnapshot?) {
        
        if snapshot?.documents.count != collabConversations.count {
            
            collabConversations.forEach { (conversation) in
                
                var currentUserMemberInConversation: Bool = false
                
                //Looks for conversations that are stored in the collabConversation array but were not retrieved in the snapshot
                for document in snapshot?.documents ?? [] {
                    
                    if document.data()["conversationID"] as? String == conversation.conversationID {
                        
                        currentUserMemberInConversation = true
                        break
                    }
                }
                
                if !currentUserMemberInConversation {
                    
                    collabConversations.removeAll(where: { $0.conversationID == conversation.conversationID })
                    
                    collabConversationPreviewListenersDict[conversation.conversationID]?.remove()
                    collabConversationPreviewListenersDict.removeValue(forKey: conversation.conversationID)
                }
            }
        }
    }
 
    
    //MARK: - Retrieve Collab Conversation Members
    
    private func retrieveCollabConversationMembers (_ collabConversation: Conversation, completion: @escaping ((_ historicMembers: [Member], _ currentMembers: [Member], _ error: Error?) -> Void)) {
        
        var retrieveMembers: Bool = false
        
        //If the count of the currentMemberIDs and the currentMembers don't equal each other
        if collabConversation.currentMembersIDs.count != collabConversation.currentMembers.count {
            
            retrieveMembers = true
        }
        
        else {
            
            for memberID in collabConversation.currentMembersIDs {
                
                //If there is a member that isn't in the currentMemberIDs array
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
                            
                            //Adds users friends before general conversation members
                            if self.firebaseCollab.friends.contains(where: { $0.userID == member.userID }) {
                                
                                historicMembers.insert(member, at: 0)
                            }
                            
                            else {
                                
                                historicMembers.insert(member, at: 0)
                            }
                        }
                        
                        //Filters out members that are no longer active in the conversation
                        let currentMembers = self.filterCurrentMembers(currentMembers: collabConversation.currentMembersIDs, historicMembers: historicMembers)
                        
                        completion(historicMembers, currentMembers, nil)
                    }
                    
                    else {
                        
                        completion([], [], nil)
                    }
                }
            }
        }
    }
    
    private func handleCollabConversationMembersRetrievalCompletion (_ collabID: String, _ historicMembers: [Member], _ currentMembers: [Member], _ error: Error?, _ completion: (([String : [Member]]) -> Void)) {
        
        if error != nil {
            
            print(error as Any)
        }
        
        else {
            
            if let conversationIndex = self.collabConversations.firstIndex(where: { $0.conversationID == collabID }) {
                
                self.collabConversations[conversationIndex].historicMembers = historicMembers
                self.collabConversations[conversationIndex].currentMembers = currentMembers
                self.collabConversations[conversationIndex].membersLoaded = true
                
                let convoMembers = ["historicMembers" : historicMembers, "currentMembers" : currentMembers]
                
                completion(convoMembers)
            }
        }
    }
    
    
    //MARK: - Retrieve Collab Conversation Preview
    
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
                    self.retrieveMessageBlocks(&message, snapshot!.documents.first!["blocks"] as? [String : Any])
                    
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
        
        collabConversationPreviewListenersDict[collabID] = listener
    }
    
    private func handleCollabConversationPreviewRetrievalCompletion (_ collabID: String, _ message: Message?, _ error: Error?, _ completion: ((_ messagePreview: [String : Any]?) -> Void)) {
        
        if error != nil {
            
            print(error as Any)
        }
        
        else {
            
            if let conversationIndex = self.collabConversations.firstIndex(where: { $0.conversationID == collabID }) {
                
                self.collabConversations[conversationIndex].messagePreview = message
                self.collabConversations[conversationIndex].messagePreviewLoaded = true
                
                let messagePreview: [String : Any] = ["conversationID" : collabID, "message" : message as Any]
                
                completion(messagePreview)
            }
        }
    }
    
    
    //MARK: - Retrieve Messages Functions
    
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
                        self.retrieveMessageBlocks(&message, document.data()["blocks"] as? [String : Any])

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
                        self.retrieveMessageBlocks(&message, document.data()["blocks"] as? [String : Any])

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
        }
    }
    
    
    //MARK: - Conversation Monitoring Functions
    
    func monitorPersonalConversation (conversationID: String, completion:  @escaping ((_ updatedConvo: [String : Any?]) -> Void)) {
        
        monitorPersonalConversationListener = db.collection("Conversations").document(conversationID).addSnapshotListener({ (snapshot, error) in
            
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

                            self.personalConversations[conversationIndex].coverPhotoID = coverPhotoID
                            self.personalConversations[conversationIndex].conversationCoverPhoto = nil
                        }

                        self.personalConversations[conversationIndex].conversationName = conversationName
                        self.personalConversations[conversationIndex].currentMembersIDs = currentMembersIDs
                        self.personalConversations[conversationIndex].memberActivity = memberActivity

                        completion(["conversationID" : conversationID, "conversationName" : conversationName, "coverPhotoID" : coverPhotoID, "currentMembersIDs" : self.personalConversations[conversationIndex].currentMembersIDs, "memberActivity" : memberActivity])

                        self.retrievePersonalConversationMembers(self.personalConversations[conversationIndex]) { (historicMembers, currentMembers, error) in

                            if error != nil {

                                completion(["error" : error])
                            }

                            else {

                                self.personalConversations[conversationIndex].historicMembers = historicMembers
                                self.personalConversations[conversationIndex].currentMembers = currentMembers

                                completion(["conversationID" : conversationID, "historicMembers" : historicMembers, "currentMembers": currentMembers])
                            }
                        }
                    }
                }
            }
        })
    }
    
    func monitorCollabConversation (collabID: String, completion: @escaping ((_ updatedConvo: [String : Any?]) -> Void)) {
        
        monitorCollabConversationListener = db.collection("Collaborations").document(collabID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(["error" : error])
            }
            
            else {
                
                if snapshot != nil {
                    
                    let collabName = snapshot!.data()?["collabName"] as? String
                    let coverPhotoID = snapshot!.data()?["coverPhotoID"] as? String
                    let currentMembersIDs: [String] = snapshot!.data()?["Members"] as? [String] ?? []
                    let memberActivity = self.parseConversationActivity(memberActivity: snapshot!.data()?["memberActivity"] as? [String : Any])
                    
                    if let conversationIndex = self.collabConversations.firstIndex(where: { $0.conversationID == collabID }) {
                        
                        if coverPhotoID != self.collabConversations[conversationIndex].coverPhotoID {
                            
                            self.collabConversations[conversationIndex].coverPhotoID = coverPhotoID
                            self.collabConversations[conversationIndex].conversationCoverPhoto = nil
                        }
                        
                        self.collabConversations[conversationIndex].conversationName = collabName
                        self.collabConversations[conversationIndex].currentMembersIDs = currentMembersIDs
                        self.collabConversations[conversationIndex].memberActivity = memberActivity
                        
                        completion(["collabName" : collabName, "coverPhotoID" : coverPhotoID, "currentMembersIDs" : self.collabConversations[conversationIndex].currentMembersIDs, "memberActivity" : memberActivity])
                        
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
    
    
    //MARK: - Filter Current Members Function
    
    private func filterCurrentMembers (currentMembers: [String], historicMembers: [Member]) -> [Member] {

        var members: [Member] = []

        historicMembers.forEach { (member) in

            if currentMembers.contains(member.userID) {

                members.append(member)
            }
        }

        return members
    }
    
    
    //MARK: - Filter Photo Messages Function
    
    func filterPhotoMessages (messages: [Message]?) -> [Message] {
        
        var messagesWithPhotos: [Message] = []
        
        for message in messages ?? [] {
            
            if message.messagePhoto != nil {
                
                messagesWithPhotos.append(message)
            }
        }
        
        return messagesWithPhotos
    }
    
    
    //MARK: - Filter Schedule Messages Function
    
    func filterScheduleMessages (messages: [Message]?) -> [Message] {
        
        var messagesWithSchedules: [Message] = []
        
        for message in messages ?? [] {
            
            if message.messageBlocks != nil {
                
                messagesWithSchedules.append(message)
            }
        }
        
        return messagesWithSchedules
    }
    
    
    //MARK: - Send Messages Functions
    
    func sendPersonalMessage (conversationID: String, _ message: Message, completion: @escaping ((_ error: Error?) -> Void)) {
        
        var photoDict = message.messagePhoto != nil ? message.messagePhoto : nil
        photoDict?.removeValue(forKey: "photo")
        
        let blocksDict = setMessageBlocks(message)
        
        let messageDict: [String : Any] = ["sender" : message.sender, "message" : message.message as Any, "photo" : photoDict as Any, "blocks" : blocksDict as Any, "timestamp" : message.timestamp as Any]
        
        //If this is a photoMessage
        if let photoID = message.messagePhoto?["photoID"] as? String, let photo = message.messagePhoto?["photo"] as? UIImage {

            //Saves the photo first
            self.firebaseStorage.savePersonalMessagePhoto(conversationID: conversationID, messagePhoto: ["photoID" : photoID, "photo" : photo]) { (error) in
                
                if error != nil {
                    
                    completion(error)
                }
                
                else {
                    
                    //Sends the message after the photo is saved
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
        
        //If this is just a regular message or a schedule message
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
        
        let blocksDict = setMessageBlocks(message)
        
        let messageDict: [String : Any] = ["sender" : message.sender, "message" : message.message as Any, "photo" : photoDict as Any, "blocks" : blocksDict as Any, "timestamp" : message.timestamp as Any]
        
        //If this is a photoMessage
        if let photoID = message.messagePhoto?["photoID"] as? String, let photo = message.messagePhoto?["photo"] as? UIImage {
            
            //Saves the photo first
            self.firebaseStorage.saveCollabMessagePhoto(collabID: collabID, messagePhoto: ["photoID" : photoID, "photo" : photo]) { (error) in
                
                if error != nil {
                    
                    completion(error)
                }
                
                else {
                    
                    //Sends the message after the photo is saved
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
        
        //If this is just a regular message or a schedule message
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
    
    
    //MARK: - Set Message Blocks
    
    private func setMessageBlocks (_ message: Message) -> [String : Any]? {
        
        if let dateForBlocks = message.dateForBlocks, let blocks = message.messageBlocks {
            
            var blocksDict: [String : Any] = [:]
            
            let statusArray: [BlockStatus : String] = [.notStarted : "notStarted", .inProgress : "inProgress", .completed : "completed", .needsHelp : "needsHelp", .late : "late"]
            
            blocksDict["dateForBlocks"] = dateForBlocks
            
            for block in blocks {
                
                if let blockID = block.blockID, let name = block.name, let dateCreated = block.dateCreated, let starts = block.starts, let ends = block.ends {
                    
                    if let status = block.status {
                        
                        blocksDict[blockID] = ["name" : name, "dateCreated" : dateCreated, "startTime" : starts, "endTime" : ends, "status" : statusArray[status] as Any]
                    }
                    
                    else {
                        
                        blocksDict[blockID] = ["name" : name, "dateCreated" : dateCreated, "startTime" : starts, "endTime" : ends]
                    }
                }
            }
            
            return blocksDict
        }
        
        else {
            
            return nil
        }
    }
    
    
    //MARK: - Retrieve Message Blocks
    
    private func retrieveMessageBlocks (_ message: inout Message, _ blocks: [String : Any]?) {
        
        if let blocks = blocks {
            
            var blockArray: [Block] = []
            
            let statusArray: [String : BlockStatus] = ["notStarted" : .notStarted, "inProgress" : .inProgress, "completed" : .completed, "needsHelp" : .needsHelp, "late" : .late]
            
            blocks.forEach { (retrievedBlock) in
                
                if retrievedBlock.key != "dateForBlocks" {
                    
                    var block = Block()
                    
                    block.blockID = retrievedBlock.key
                    
                    if let values = retrievedBlock.value as? [String : Any] {
                        
                        block.name = values["name"] as? String
                        
                        if let dateCreated = values["dateCreated"] as? Timestamp, let starts = values["startTime"] as? Timestamp, let ends = values["endTime"] as? Timestamp {
                            
                            block.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreated.seconds))
                            block.starts = Date(timeIntervalSince1970: TimeInterval(starts.seconds))
                            block.ends = Date(timeIntervalSince1970: TimeInterval(ends.seconds))
                        }
                        
                        if let status = values["status"] as? String {
                            
                            block.status = statusArray[status]
                        }
                    }
                    
                    blockArray.append(block)
                }
            }
            
            if let date = blocks["dateForBlocks"] as? Timestamp {
                
                message.dateForBlocks = Date(timeIntervalSince1970: TimeInterval(date.seconds))
            }
            
            message.messageBlocks = blockArray
        }
    }
    
    
    //MARK: - Set Activity Status Function
    
    func setActivityStatus (conversationID: String? = nil, collabID: String? = nil, _ status: Any) {
        
        if let conversation = conversationID {
            
            db.collection("Conversations").document(conversation).updateData(["memberActivity.\(currentUser.userID)" : status])
        }
        
        else if let collab = collabID {
                
            db.collection("Collaborations").document(collab).updateData(["memberActivity.\(currentUser.userID)" : status])
        }
    }
    
    
    //MARK: - Save Cover Photo Function
    
    func savePersonalConversationCoverPhoto (conversationID: String, coverPhotoID: String, coverPhoto: UIImage, completion: @escaping ((_ error: Error?) -> Void)) {
        
        self.firebaseStorage.saveConversationCoverPhoto(conversationID: conversationID, coverPhoto: coverPhoto) { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                let batch = self.db.batch()
                
                batch.setData(["coverPhotoID" : coverPhotoID], forDocument: self.db.collection("Conversations").document(conversationID), merge: true)
                
                //Creating a message notifying the conversation that a user changed the cover photo
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
    
    
    //MARK: - Delete Cover Photo Function
    
    func deletePersonalConversationCoverPhoto (conversationID: String, completion: @escaping ((_ error: Error?) -> Void)) {
        
        firebaseStorage.deletePersonalConversationCoverPhoto(conversationID: conversationID) { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                let batch = self.db.batch()
                
                batch.updateData(["coverPhotoID" : FieldValue.delete()], forDocument: self.db.collection("Conversations").document(conversationID))
                
                //Creating a message notifying the conversation that a user deleted the cover photo
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
    
    
    //MARK: - Update Conversation Name Function
    
    func updateConversationName (conversationID: String, name: String?, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let batch = db.batch()
        
        batch.updateData(["conversationName" : name as Any], forDocument: db.collection("Conversations").document(conversationID))
        
        let memberUpdatedName = name != nil ? true : false
        
        //Creating a message notifying the conversation that a user updated the conversation name
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
    
    
    //MARK: - Add New Members Function
    
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
                            let messageDict: [String : Any] = ["sender" : addedMember.userID, "memberJoiningConversation" : true, "timestamp" : Date()]
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
    
    
    //MARK: - Delete Messages Function
    
    func deleteMessages (conversations: [Conversation], compeletion: @escaping ((_ error: Error?) -> Void)) {
        
        let batch = db.batch()
        
        for convo in conversations {
            
            batch.updateData(["memberGainedAccessOn.\(currentUser.userID)" : Date()], forDocument: db.collection("Conversations").document(convo.conversationID))
        }
        
        batch.commit { (error) in
            
            if error != nil {
                
                compeletion(error)
            }
            
            else {
                
                compeletion(nil)
            }
        }
    }
    
    
    //MARK: - Leave Conversation Function
    
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
    
    
    //MARK: - Parse Conversation Activity Function
    
    private func parseConversationActivity (memberActivity: [String : Any]?) -> [String : Any]? {
        
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
    
    
    //MARK: - Parse Collab Acception Statuses
    
    private func parseCollabAcceptionStatuses (_ acceptionStatuses: [String : Bool?]?) -> [String : Bool?] {
        
        var acceptionStatusDict: [String : Bool?] = [:]
        
        if let statuses = acceptionStatuses {
            
            for status in statuses {
                
                acceptionStatusDict[status.key] = status.value
            }
        }
        
        return acceptionStatusDict
    }
    
    
    //MARK: - Convert Timestamp Function
    
    func convertTimestampToDate (_ timestamp: Any) -> Date {
        
        if let timestamp = timestamp as? Timestamp {
            
            return Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
        }
        
        else {
            
            return Date()
        }
    }
}
