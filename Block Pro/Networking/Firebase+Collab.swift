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
    
    var allCollabsListener: ListenerRegistration?
    var singularCollabListener: ListenerRegistration?
    
    var friends: [Friend] = []
    var collabs: [Collab] = []
    var membersProfilePics: [String : UIImage?] = [:]
    //var collabRequests: [CollabRequest] = []
    
    static let sharedInstance = FirebaseCollab()
    
    func createCollab (collab: Collab, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let batch = db.batch()
        
        var collabData: [String : Any] = ["collabID" : collab.collabID, "dateCreated" : Date(), "creator" : currentUser.userID, "collabName" : collab.name, "collabObjective" : collab.objective as Any, "startTime" : collab.dates["startTime"] as Any, "deadline" : collab.dates["deadline"] as Any, "reminders" : collab.reminders, "photos" : collab.photoIDs]
        
        collabData["locations"] = setCollabLocations(collabID: collab.collabID, locations: collab.locations)
        
        collabData["voiceMemos"] = setCollabVoiceMemos(collabID: collab.collabID, voiceMemos: collab.voiceMemos)
        
        collabData["links"] = setCollabLinks(collabID: collab.collabID, links: collab.links)
        
        batch.setData(collabData, forDocument: db.collection("Collaborations").document(collab.collabID))
        
        setCollabMembers(collab.collabID, collab.addedMembers, batch) //Call here
        
        print(collab.collabID)
        
        batch.commit { (error) in

            if error != nil {

                completion(error)
            }

            else {

                self.saveCollabPhotosToStorage(collab.collabID, collab.photos)

                self.saveCollabVoiceMemosToStorage(collab.collabID, collab.voiceMemos)

                completion(nil)
            }
        }
    }
    
    func editCollab (collab: Collab, completion: @escaping ((_ error: Error?) -> Void)) {
        
        if let cachedCollab = collabs.first(where: { $0.collabID == collab.collabID }) {
            
            editCollabPhotosSavedInStorage(cachedCollab: cachedCollab, editedCollab: collab)
            
            editCollabVoiceMemosSavedInStorage(cachedCollab: cachedCollab, editedCollab: collab)
            
            let batch = db.batch()
            
            var collabData = ["collabName" : collab.name, "collabObjective" : collab.objective as Any, "startTime" : collab.dates["startTime"] as Any, "deadline" : collab.dates["deadline"] as Any, "reminders" : collab.reminders, "photos" : collab.photoIDs]
            
            collabData["locations"] = setCollabLocations(collabID: collab.collabID, locations: collab.locations)
            
            collabData["voiceMemos"] = setCollabVoiceMemos(collabID: collab.collabID, voiceMemos: collab.voiceMemos)
            
            collabData["links"] = setCollabLinks(collabID: collab.collabID, links: collab.links)
            
            batch.updateData(collabData, forDocument: db.collection("Collaborations").document(collab.collabID))
            
            setCollabMembers(collab.collabID, collab.addedMembers, batch)
            
            batch.commit { (error) in
                
                if error != nil {
                    
                    completion(error)
                }
                
                else {
                    
                    completion(nil)
                }
            }
        }
    }
    
    private func setCollabMembers (_ collabID: String, _ addedMembers: [Any], _ batch: WriteBatch) {
        
        var memberIDs: [String] = []
        var members: [String : Any] = [:]
        
        var previouslyAddedMembers: [Member] = []
        
        if let cachedCollabMembers = collabs.first(where: { $0.collabID == collabID })?.currentMembers {
            
            for cachedMember in cachedCollabMembers {
                
                previouslyAddedMembers.append(cachedMember)
            }
        }
        
        memberIDs.append(currentUser.userID)
        
        members["userID"] = currentUser.userID
        members["firstName"] = currentUser.firstName
        members["lastName"] = currentUser.lastName
        members["username"] = currentUser.username
        members["role"] = "Lead"
        
        members["accepted"] = true
        members["dateJoined"] = previouslyAddedMembers.first(where: { $0.userID == currentUser.userID })?.dateJoined ?? Date()
        
        batch.setData(members, forDocument: db.collection("Collaborations").document(collabID).collection("Members").document(currentUser.userID), merge: true)
        
        for member in addedMembers {
            
            if let friend = member as? Friend {
                
                memberIDs.append(friend.userID)
                
                members["userID"] = friend.userID
                members["firstName"] = friend.firstName
                members["lastName"] = friend.lastName
                members["username"] = friend.username
                members["role"] = "Member"
                
                members["accepted"] = previouslyAddedMembers.first(where: { $0.userID == friend.userID })?.accepted
                members["dateJoined"] = previouslyAddedMembers.first(where: { $0.userID == friend.userID })?.dateJoined ?? Date()
                
                batch.setData(members, forDocument: db.collection("Collaborations").document(collabID).collection("Members").document(friend.userID), merge: true)
            }
            
            else if let member = member as? Member {
                
                memberIDs.append(member.userID)
                
                members["userID"] = member.userID
                members["firstName"] = member.firstName
                members["lastName"] = member.lastName
                members["username"] = member.username
                members["role"] = "Member"
                
                members["accepted"] = previouslyAddedMembers.first(where: { $0.userID == member.userID })?.accepted //member.accepted//false
                members["dateJoined"] = previouslyAddedMembers.first(where: { $0.userID == member.userID })?.dateJoined ?? Date()
                
                batch.setData(members, forDocument: db.collection("Collaborations").document(collabID).collection("Members").document(member.userID), merge: true)
            }
        }
        
        let firebaseBlock = FirebaseBlock.sharedInstance
        firebaseBlock.removeInactiveCollabBlockMembers(collabID: collabID, currentCollabMembers: memberIDs)
        
        batch.setData(["Members" : memberIDs], forDocument: db.collection("Collaborations").document(collabID), merge: true)
    }
    
    private func setCollabLocations (collabID: String, locations: [Location]?) -> [String : [String : Any]] {

        var locationDict: [String : [String : Any]] = [:]

        for location in locations ?? [] {

            if let locationID = location.locationID {

                locationDict[locationID] = ["coordinates" : location.coordinates as Any, "name" : location.name as Any, "number" : location.number as Any, "url" : location.url?.absoluteString as Any, "address" : ["streetNumber" : location.streetNumber, "streetName" : location.streetName, "city" : location.city, "state": location.state, "zipCode" : location.zipCode, "country" : location.country]]
            }
        }

        return locationDict
    }
    
    private func setCollabVoiceMemos (collabID: String, voiceMemos: [VoiceMemo]?) -> [String : [String : Any]]{
        
        var voiceMemoDict: [String : [String : Any]] = [:]
        
        for memo in voiceMemos ?? [] {
            
            if let memoID = memo.voiceMemoID {
                
                voiceMemoDict[memoID] = ["name" : memo.name as Any, "length" : memo.length as Any, "dateCreated" : memo.dateCreated as Any]
            }
        }
        
        return voiceMemoDict
    }
    
    private func setCollabLinks (collabID: String, links: [Link]?) -> [String : [String : String?]] {
        
        var linksDict: [String : [String : String?]] = [:]
        
        for link in links ?? [] {
            
            if let linkID = link.linkID, let url = link.url {
                
                linksDict[linkID] = ["url" : url, "name" : link.name]
            }
        }
        
        return linksDict
    }
    
    private func saveCollabPhotosToStorage (_ collabID: String, _ photos: [String : UIImage?]?) {
        
        var count = 0
        
        for photo in photos ?? [:] {
            
            firebaseStorage.saveCollabPhotosToStorage(collabID, photo.key, photo.value)
            
            count += 1
        }
    }
    
    private func editCollabPhotosSavedInStorage (cachedCollab: Collab, editedCollab: Collab) {
        
        for photoID in cachedCollab.photoIDs {
            
            if !editedCollab.photoIDs.contains(photoID) {
                
                firebaseStorage.deleteCollabPhoto(editedCollab.collabID, photoID: photoID) { (error) in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription as Any)
                    }
                }
            }
        }
        
        for photo in editedCollab.photos {
            
            if !cachedCollab.photoIDs.contains(photo.key) {
                
                firebaseStorage.saveCollabPhotosToStorage(editedCollab.collabID, photo.key, photo.value)
            }
        }
    }
    
    private func saveCollabVoiceMemosToStorage (_ collabID: String, _ voiceMemos: [VoiceMemo]?) {
        
        for voiceMemo in voiceMemos ?? [] {
            
            firebaseStorage.saveCollabVoiceMemosToStorage(collabID, voiceMemo.voiceMemoID ?? "")
        }
    }
    
    private func editCollabVoiceMemosSavedInStorage (cachedCollab: Collab, editedCollab: Collab) {
        
        for voiceMemo in cachedCollab.voiceMemos ?? [] {
            
            if !(editedCollab.voiceMemos?.contains(where: { $0.voiceMemoID == voiceMemo.voiceMemoID }) ?? false) {
                
                firebaseStorage.deleteCollabVoiceMemo(editedCollab.collabID, voiceMemoID: voiceMemo.voiceMemoID ?? "") { (error) in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription as Any)
                    }
                }
            }
        }
        
        for voiceMemo in editedCollab.voiceMemos ?? [] {
            
            if !(cachedCollab.voiceMemos?.contains(where: { $0.voiceMemoID == voiceMemo.voiceMemoID }) ?? false) {
                
                firebaseStorage.saveCollabVoiceMemosToStorage(editedCollab.collabID, voiceMemo.voiceMemoID ?? "")
            }
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
    
    func retrieveCollabs (completion: @escaping ((_ collabs: [Collab]?, _ members: [String : [Member]]?, _ error: Error?) -> Void)) {
        
        allCollabsListener = db.collection("Collaborations").whereField("Members", arrayContains: currentUser.userID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(nil, nil, error)
            }
            
            else {
                
                self.removeCollabsWhereUserInactive(snapshot: snapshot)
                
                if snapshot?.isEmpty != true {
                    
                    for document in snapshot?.documents ?? [] {
                        
                        let collab = self.configureCollab(document)
                        
                        if self.collabs.first(where: { $0.collabID == collab.collabID }) == nil {
                            
                            self.collabs.append(collab)
                        }
                        
                        else {
                            
                            //handle update here
                        }
                        
                        if let existingCollab = self.collabs.first(where: { $0.collabID == collab.collabID }) {
                            
                            self.retrieveCollabMembers(existingCollab) { (historicMembers, currentMembers, error) in
                                
                                self.handleCollabMembersRetrievalCompletion(collab.collabID, historicMembers, currentMembers, error) { (collabMembers) in
                                    
                                    completion(nil, collabMembers, nil)
                                }
                            }
                        }
                    }
                    
                    completion(self.collabs, nil, nil)
                }
                
                else {
                    
                    self.collabs.removeAll()
                    
                    completion([], nil, nil)
                }
            }
        })
    }
    
    private func removeCollabsWhereUserInactive (snapshot: QuerySnapshot?) {
        
        if snapshot?.documents.count != collabs.count {
            
            collabs.forEach { (collab) in
                
                var currentUserInCollab: Bool = false
                
                for document in snapshot?.documents ?? [] {
                    
                    if document.data()["collabID"] as? String == collab.collabID {
                        
                        currentUserInCollab = true
                        break
                    }
                }
                
                if !currentUserInCollab {
                    
                    collabs.removeAll(where: { $0.collabID == collab.collabID })
                }
            }
        }
    }
    
    private func configureCollab (_ document: DocumentSnapshot) -> Collab {
        
        var collab = Collab()
        
        collab.collabID = document.data()?["collabID"] as! String
        collab.name = document.data()?["collabName"] as! String
        collab.objective = document.data()?["collabObjective"] as? String
        
        let dateCreated = document.data()?["dateCreated"] as! Timestamp
        collab.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreated.seconds))
        
        collab.coverPhotoID = document.data()?["coverPhotoID"] as? String
        
        collab.photoIDs = document.data()?["photos"] as? [String] ?? []
        
        let startTime = document.data()?["startTime"] as! Timestamp
        collab.dates["startTime"] = Date(timeIntervalSince1970: TimeInterval(startTime.seconds))
        
        if let deadline = document.data()?["deadline"] as? Timestamp {
            
            collab.dates["deadline"] = Date(timeIntervalSince1970: TimeInterval(deadline.seconds))
        }
        
        collab.currentMembersIDs = document.data()?["Members"] as? [String] ?? []
        
        let memberActivity: [String : Any]? = document.data()?["memberActivity"] as? [String : Any]
        collab.memberActivity = self.parseCollabActivity(memberActivity: memberActivity)
        
        collab.reminders = document.data()?["reminders"] as? [Int] ?? []
        
        collab.locations = self.retrieveCollabLocations(document.data()?["locations"] as? [String : Any])
        
        collab.voiceMemos = self.retrieveCollabVoiceMemos(document.data()?["voiceMemos"] as? [String : Any])
        
        collab.links = self.retrieveCollabLinks(document.data()?["links"] as? [String : Any])
        
        return collab
    }
    
    func retrieveCollabs2 () {
        
        //userRef.collection("Collabs").addSnapshotListener { (snapshot, error) in
        allCollabsListener = db.collection("Collaborations").whereField("Members", arrayContains: currentUser.userID).addSnapshotListener { (snapshot, error) in
        
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
                        
                        let dateCreated = document.data()["dateCreated"] as! Timestamp
                        collab.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreated.seconds))
                        
                        collab.coverPhotoID = document.data()["coverPhotoID"] as? String
                        
                        collab.photoIDs = document.data()["photos"] as? [String] ?? []
                        
                        let startTime = document.data()["startTime"] as! Timestamp
                        collab.dates["startTime"] = Date(timeIntervalSince1970: TimeInterval(startTime.seconds))
                        
                        if let deadline = document.data()["deadline"] as? Timestamp {
                            
                            collab.dates["deadline"] = Date(timeIntervalSince1970: TimeInterval(deadline.seconds))
                        }
                        
                        collab.currentMembersIDs = document.data()["Members"] as? [String] ?? []
                        
                        let memberActivity: [String : Any]? = document.data()["memberActivity"] as? [String : Any]
                        collab.memberActivity = self.parseCollabActivity(memberActivity: memberActivity)
                        
                        collab.reminders = document.data()["reminders"] as? [Int] ?? []
                        
                        collab.locations = self.retrieveCollabLocations(document.data()["locations"] as? [String : Any])
                        
                        collab.voiceMemos = self.retrieveCollabVoiceMemos(document.data()["voiceMemos"] as? [String : Any])
                        
                        collab.links = self.retrieveCollabLinks(document.data()["links"] as? [String : Any])
                        
                        
                        #warning("temp fix for the tableview of the home view being overpopulated with data")
                        if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == collab.collabID }) {
                            
                        }
                        
                        else {
                            
                            self.collabs.append(collab)
                            self.collabs = self.collabs.sorted(by: {$0.dates["deadline"] ?? Date() > $1.dates["deadline"] ?? Date()})
                        }
                        
                        #warning("will need to move this to seperate function as well as configure way to sort historic members from current members modeling the way I did it with conversation :) i believe in you")
                        //when reconfiguring this in its seperate func, make sure you use the retrieve members func from the messaging firebase class
                        //self.userRef.collection("Collabs").document(collab.collabID).collection("Members").getDocuments { (snapshot, error) in
                        self.db.collection("Collaborations").document(collab.collabID).collection("Members").getDocuments{ (snapshot, error) in
                        
                            if error != nil {
                                
                                print(error as Any)
                            }
                            
                            else {
                                
                                if snapshot?.isEmpty != true {
                                    
                                    var historicMembers: [Member] = []
                                    
                                    for document in snapshot!.documents {
                                        
                                        var member = Member()
                                        
                                        member.userID = document.data()["userID"] as! String
                                        member.firstName = document.data()["firstName"] as! String
                                        member.lastName = document.data()["lastName"] as! String
                                        member.username = document.data()["username"] as! String
                                        member.role = document.data()["role"] as! String
                                        
                                        if let dateJoined = document.data()["dateJoined"] as? Timestamp {
                                            
                                            member.dateJoined = Date(timeIntervalSince1970: TimeInterval(dateJoined.seconds))
                                        }
                                        
                                        member.accepted = document.data()["accepted"] as? Bool
                                        
                                        historicMembers.append(member)
                                    }
                                    
                                    if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == collab.collabID }) {
                                        
                                        self.collabs[collabIndex].historicMembers = historicMembers
                                        
                                        self.collabs[collabIndex].currentMembers = self.filterCurrentMembers(currentMembers: collab.currentMembersIDs, historicMembers: self.collabs[collabIndex].historicMembers)
                                    }
                                    
//                                    self.collabs.append(collab)
//                                    self.collabs = self.collabs.sorted(by: {$0.dates["deadline"]! > $1.dates["deadline"]!})
                                }
                                
//                                else {
//
//                                    self.collabs.append(collab)
//                                    self.collabs = self.collabs.sorted(by: {$0.dates["deadline"]! > $1.dates["deadline"]!})
//                                }
                            }
                        }
                        
//                        self.retrieveCollabLocations(collab.collabID)
                        
//                        self.retrieveCollabVoiceMemos(collab.collabID)
                    }
                }
            }
        }
    }
    
    
    private func retrieveCollabMembers (_ collab: Collab, completion: @escaping ((_ historicMembers: [Member], _ currentMembers: [Member], _ error: Error?) -> Void)) {
        
        var retrieveMembers: Bool = false
        
        if collab.currentMembersIDs.count != collab.currentMembers.count {
            
            retrieveMembers = true
        }
        
        else {
            
            for memberID in collab.currentMembersIDs {
                
                if !(collab.currentMembers.contains(where: { $0.userID == memberID })) {
                    
                    retrieveMembers = true
                    break
                }
            }
        }
        
        if retrieveMembers {
            
            db.collection("Collaborations").document(collab.collabID).collection("Members").getDocuments { (snapshot, error) in
                
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
                            
                            member.accepted = document.data()["accepted"] as? Bool
                            
                            if let dateJoined = document.data()["dateJoined"] as? Timestamp {
                                
                                member.dateJoined = Date(timeIntervalSince1970: TimeInterval(dateJoined.seconds))
                            }
                            
                            //Adds users friends before general collab members
                            if self.friends.contains(where: { $0.userID == member.userID }) {
                                
                                historicMembers.insert(member, at: 0)
                            }
                            
                            else {
                                
                                historicMembers.append(member)
                            }
                        }
                        
                        //Filters out members that are no longer active in the conversation
                        let currentMembers = self.filterCurrentMembers(currentMembers: collab.currentMembersIDs, historicMembers: historicMembers)
                        
                        completion(historicMembers, currentMembers, nil)
                    }
                    
                    else {
                        
                        completion([], [], nil)
                    }
                }
            }
        }
    }
    
    private func handleCollabMembersRetrievalCompletion (_ collabID: String, _ historicMembers: [Member], _ currentMembers: [Member], _ error: Error?, _ completion: (([String : [Member]]) -> Void)) {
        
        if error != nil {
            
            print(error as Any)
        }
        
        else {
            
            if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == collabID }) {
                
                self.collabs[collabIndex].historicMembers = historicMembers
                self.collabs[collabIndex].currentMembers = currentMembers
//                self.collabs[collabIndex]
                
                let collabMembers = ["historicMembers" : historicMembers, "currentMembers" : currentMembers]
                
                completion(collabMembers)
            }
        }
    }
    
    private func retrieveCollabLocations (_ locations: [String : Any]?) -> [Location]? {
        
        var locationArray: [Location] = []
        
        locations?.forEach { (retrievedLocation) in
            
            var location = Location()
            location.locationID = retrievedLocation.key
            
            if let values = retrievedLocation.value as? [String : Any] {
                
                location.coordinates = values["coordinates"] as? [String : Double]
                
                location.name = values["name"] as? String
                location.number = values["number"] as? String
                
                if let urlString = values["url"] as? String {
                    
                    location.url = URL(string: urlString)
                }
                
                let address = values["address"] as? [String : String]
                location.streetNumber = address?["streetNumber"]
                location.streetName = address?["streetName"]
                location.city = address?["city"]
                location.state = address?["state"]
                location.zipCode = address?["zipCode"]
                location.country = address?["country"]
                
                location.address = location.parseAddress()
            }
            
            locationArray.append(location)
        }
        
        return locationArray
    }
    
    
    private func retrieveCollabVoiceMemos (_ voiceMemos: [String : Any]?) -> [VoiceMemo]? {
        
        var voiceMemoArray: [VoiceMemo] = []
        
        voiceMemos?.forEach { (retrievedVoiceMemo) in
            
            var voiceMemo = VoiceMemo()
            voiceMemo.voiceMemoID = retrievedVoiceMemo.key
            
            if let values = retrievedVoiceMemo.value as? [String : Any] {
                
                voiceMemo.name = values["name"] as? String
                voiceMemo.length = values["length"] as? Double
                
                let dateCreated = values["dateCreated"] as! Timestamp
                voiceMemo.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreated.seconds))
            }
            
            voiceMemoArray.append(voiceMemo)
        }
        
        return voiceMemoArray
    }
    
    
    private func retrieveCollabLinks (_ links: [String : Any]?) -> [Link]? {
        
        var linkArray: [Link] = []
        
        links?.forEach { (retrievedLink) in
            
            var link = Link()
            link.linkID = retrievedLink.key
            
            if let values = retrievedLink.value as? [String : Any] {
                
                link.url = values["url"] as? String
                link.name = values["name"] as? String
            }
            
            linkArray.append(link)
        }
        
        return linkArray
    }
    
    func monitorCollab (collabID: String, completion: @escaping ((_ updatedCollab: [String : Any?]) -> Void)) {
        
        singularCollabListener = db.collection("Collaborations").document(collabID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(["error" : error])
            }
            
            else {
                
                if let snapshotData = snapshot?.data() {
                    
                    if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == snapshot?.documentID }) {
                        
                        self.collabs[collabIndex].name = snapshotData["collabName"] as! String
                        self.collabs[collabIndex].objective = snapshotData["collabObjective"] as? String
                        
                        if self.collabs[collabIndex].coverPhotoID != snapshotData["coverPhotoID"] as? String {
                            
                            self.collabs[collabIndex].coverPhotoID = snapshotData["coverPhotoID"] as? String
                            self.collabs[collabIndex].coverPhoto = nil
                        }
                        
                        let startTime = snapshotData["startTime"] as! Timestamp
                        self.collabs[collabIndex].dates["startTime"] = Date(timeIntervalSince1970: TimeInterval(startTime.seconds))
                        
                        let deadline = snapshotData["deadline"] as! Timestamp
                        self.collabs[collabIndex].dates["deadline"] = Date(timeIntervalSince1970: TimeInterval(deadline.seconds))
                        
                        self.collabs[collabIndex].currentMembersIDs = snapshotData["Members"] as? [String] ?? []
                        
                        let memberActivity: [String : Any]? = snapshotData["memberActivity"] as? [String : Any]
                        self.collabs[collabIndex].memberActivity = self.parseCollabActivity(memberActivity: memberActivity)
                        
                        self.collabs[collabIndex].reminders = snapshotData["reminders"] as? [Int] ?? []
                        
                        self.collabs[collabIndex].photoIDs = snapshotData["photos"] as? [String] ?? []
                        self.collabs[collabIndex].locations = self.retrieveCollabLocations(snapshotData["locations"] as? [String : Any])
                        self.collabs[collabIndex].voiceMemos = self.retrieveCollabVoiceMemos(snapshotData["voiceMemos"] as? [String : Any])
                        self.collabs[collabIndex].links = self.retrieveCollabLinks(snapshotData["links"] as? [String : Any])
                        
                        completion(["collab" : self.collabs[collabIndex]])
                        
                        self.retrieveCollabMembers(self.collabs[collabIndex]) { (historicMembers, currentMembers, membersError) in
                            
                            if error != nil {
                                
                                completion(["error" : membersError])
                            }
                            
                            else {
                                
                                completion(["historicMembers" : historicMembers, "currentMembers" : currentMembers])
                            }
                        }
                    }
                }
                
                else {
                    
                    //collab deleted
                }
            }
        })
    }
    
    func leaveCollab (_ collab: Collab, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let batch = db.batch()
        
        var filteredMembers = collab.currentMembers
        filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
        
        if let member = collab.currentMembers.first(where: { $0.userID == currentUser.userID }), let newLead = filteredMembers.max(by: { $0.dateJoined ?? Date() > $1.dateJoined ?? Date()}) {
            
            if member.role == "Lead" {
                
                //Reassigning the "Lead" for the collab if the currentUser is currently the "Lead"
                batch.updateData(["role" : "Lead"], forDocument: db.collection("Collaborations").document(collab.collabID).collection("Members").document(newLead.userID))
            }
        }
        
        //Changing the role of the currentUser
        batch.updateData(["role" : "Inactive"], forDocument: db.collection("Collaborations").document(collab.collabID).collection("Members").document(currentUser.userID))

        //Removing currentUser from the Members array in the conversation fields; not from the Members collection
        batch.updateData(["Members" : FieldValue.arrayRemove([currentUser.userID])], forDocument: db.collection("Collaborations").document(collab.collabID))

        //Removing the "dateJoined" value from the currentUser's document in this collab
        batch.updateData(["dateJoined" : FieldValue.delete()], forDocument: db.collection("Collaborations").document(collab.collabID).collection("Members").document(currentUser.userID))
        
        //Will leave currentUser in the "memberActivity" map in case they are added again
        batch.updateData(["memberActivity.\(currentUser.userID)" : Date()], forDocument: db.collection("Collaborations").document(collab.collabID))
        
        batch.commit { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                completion(nil)
            }
        }
    }
    
    func deleteCollab (_ collab: Collab, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let batch = db.batch()
        
        batch.updateData(["Members" : []], forDocument: db.collection("Collaborations").document(collab.collabID))
        
        for member in collab.currentMembersIDs {
            
            batch.updateData(["role" : "Inactive"], forDocument: db.collection("Collaborations").document(collab.collabID).collection("Members").document(member))
        }
        
        batch.commit { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
                
                completion(error)
            }
            
            else {
                
                completion(nil)
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
                        collabRequest.objective = document.data()["collabObjective"] as? String ?? ""
                        
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
    
//    func acceptCollabRequest (collab: CollabRequest, completion: @escaping (() -> Void)) {
//
//        let batch = db.batch()
//
//        let memberCollabData: [String : Any] = ["collabID" : collab.collabID, "collabName" : collab.name, "collabObjective" : collab.objective, "startTime" : collab.dates["startTime"]!, "deadline" : collab.dates["deadline"]!, "reminders" : "will be set up later"]
//
//        batch.setData(memberCollabData, forDocument: userRef.collection("Collabs").document(collab.collabID))
//
//        userRef.collection("CollabRequests").document(collab.collabID).collection("Members").getDocuments { (snapshot, error) in
//
//            if error != nil {
//
//                print(error?.localizedDescription as Any)
//            }
//
//            else {
//
//                if snapshot?.isEmpty != true {
//
//                    for document in snapshot!.documents {
//
//                        let member: [String : Any] = ["userID" : document.data()["userID"] as! String, "firstName" : document.data()["firstName"] as! String, "lastName" : document.data()["lastName"] as! String, "username" : document.data()["username"] as! String, "role" : document.data()["role"] as! String]
//
//                        batch.setData(member, forDocument: self.userRef.collection("Collabs").document(collab.collabID).collection("Members").document(member["userID"] as! String))
//
//                        self.userRef.collection("CollabRequests").document(collab.collabID).collection("Members").document(member["userID"] as! String).delete()
//                    }
//
//                    batch.deleteDocument(self.userRef.collection("CollabRequests").document(collab.collabID))
//
//                    self.commitBatch(batch: batch, completion: completion)
//                }
//
//                else {
//
//                    self.commitBatch(batch: batch, completion: completion)
//                }
//            }
//        }
//    }
    
    func queryUsers (_ username: String, completion: @escaping ((_ results: [FriendSearchResult]?, _ error: Error?) -> Void)) {
        
        db.collection("Users").getDocuments { (snapshot, error) in
            
            if error != nil {
                
                completion(nil, error)
            }
            
            else {
                
                var searchResults: [FriendSearchResult] = []
                
                for document in snapshot?.documents ?? [] {
                    
                    if (document.data()["username"] as? String)?.localizedCaseInsensitiveContains(username) ?? false {
                        
                        let searchResult = FriendSearchResult()
                        searchResult.userID = document.data()["userID"] as? String ?? ""
                        searchResult.firstName = document.data()["firstName"] as? String ?? ""
                        searchResult.lastName = document.data()["lastName"] as? String ?? ""
                        searchResult.username = document.data()["username"] as? String ?? ""
                        
                        if searchResult.userID == self.currentUser.userID {
                            
                            continue
                        }
                        
                        else {
                            
//                            if self.friends.first(where: { $0.userID == searchResult.userID && $0.accepted == true }) == nil {
//
//                                if self.friends.contains(where: { $0.userID == searchResult.userID }) == nil {
//
//
//                                }
//
//                                searchResults.append(searchResult)
//
//                            }
                            
                            if self.friends.contains(where: { $0.userID == searchResult.userID }) {
                                
                                searchResults.append(searchResult)
                            }
                            
                            else {
                                
                                searchResults.insert(searchResult, at: 0)
                            }
                            
                            if searchResults.count == 15 {
                                
                                break
                            }
                        }
                    }
                }
                
                completion(searchResults, nil)
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
                        
                        if let userID = document.data()["userID"] as? String {
                            
                            friend.userID = userID
                        }
                        
                        else if let userID = document.data()["friendID"] as? String { #warning("Will be deleted once I move over to new database")
                            
                            friend.userID = userID
                        }
                        
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
    
    func sendFriendRequest (_ user: Any) {
        
        let currentUserData: [String : Any] = ["userID" : currentUser.userID, "firstName" : currentUser.firstName, "lastName" : currentUser.lastName, "username" : currentUser.username, "requestSentBy" : currentUser.userID]
        
        var friendData: [String : String] = [:]
        
        if let searchResult = user as? FriendSearchResult {
            
            friendData = ["userID" : searchResult.userID, "firstName" : searchResult.firstName, "lastName" : searchResult.lastName, "username" : searchResult.username, "requestSentBy" : currentUser.userID]
        }
        
        else if let member = user as? Member {
            
            friendData = ["userID" : member.userID, "firstName" : member.firstName, "lastName" : member.lastName, "username" : member.username, "requestSentBy" : currentUser.userID]
        }
        
        db.collection("Users").document(currentUser.userID).collection("Friends").document(friendData["userID"]!).setData(friendData) { (error) in
            
            if error != nil {
                
                print("error adding friend", error?.localizedDescription as Any)
            }
        }
        
        db.collection("Users").document(friendData["userID"]!).collection("Friends").document(currentUser.userID).setData(currentUserData) { (error) in
            
            if error != nil {
                
                print("error sending friend request", error?.localizedDescription as Any)
            }
        }
    }
    
    func cacheFriendProfileImages (friend: Friend) {
            
        firebaseStorage.retrieveUserProfilePicFromStorage(userID: friend.userID) { (profilePic, userID) in
            
            if let profilePic = profilePic {
                
                friend.profilePictureImage = profilePic
            }
        }
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
