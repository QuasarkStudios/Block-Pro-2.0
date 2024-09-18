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
    var friendsListener: ListenerRegistration?
    
    var allCollabsListener: ListenerRegistration?
    var singularCollabListener: ListenerRegistration?
    
    var friends: [Friend] = []
    var collabs: [Collab] = []
    var membersProfilePics: [String : UIImage?] = [:]
    
    static let sharedInstance = FirebaseCollab()
    
    
    //MARK: - Create Collab
    
    func createCollab (collab: Collab, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let batch = db.batch()
        
        var collabData: [String : Any] = ["collabID" : collab.collabID, "dateCreated" : Date(), "creator" : currentUser.userID, "collabName" : collab.name, "collabObjective" : collab.objective as Any, "startTime" : collab.dates["startTime"] as Any, "deadline" : collab.dates["deadline"] as Any, "reminders" : collab.reminders, "photos" : collab.photoIDs]
        
        collabData["locations"] = setCollabLocations(collabID: collab.collabID, locations: collab.locations)
        
        collabData["voiceMemos"] = setCollabVoiceMemos(collabID: collab.collabID, voiceMemos: collab.voiceMemos)
        
        collabData["links"] = setCollabLinks(collabID: collab.collabID, links: collab.links)
        
        batch.setData(collabData, forDocument: db.collection("Collaborations").document(collab.collabID))
        
        setCollabMembers(collab.collabID, collab.addedMembers, batch) //Call here
        
//        print(collab.collabID)
        
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
    
    
    //MARK: - Edit Collab
    
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
    
    
    //MARK: - Set Collab Members
    
    private func setCollabMembers (_ collabID: String, _ addedMembers: [Any], _ batch: WriteBatch) {
        
        var memberIDs: [String] = []
        var members: [String : Any] = [:]
        
        var acceptedStatuses: [String : Any] = [:]
        var requestsSentOn: [String : Date] = [:]
        
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
        members["dateJoined"] = previouslyAddedMembers.first(where: { $0.userID == currentUser.userID })?.dateJoined ?? Date()
        
        batch.setData(members, forDocument: db.collection("Collaborations").document(collabID).collection("Members").document(currentUser.userID), merge: true)
        
        acceptedStatuses[currentUser.userID] = true
        requestsSentOn[currentUser.userID] = self.collabs.first(where: { $0.collabID == collabID })?.requestSentOn?[currentUser.userID]
        
        for member in addedMembers {
            
            if let friend = member as? Friend {
                
                memberIDs.append(friend.userID)
                
                members["userID"] = friend.userID
                members["firstName"] = friend.firstName
                members["lastName"] = friend.lastName
                members["username"] = friend.username
                members["role"] = "Member"
                members["dateJoined"] = previouslyAddedMembers.first(where: { $0.userID == friend.userID })?.dateJoined ?? NSNull()
                
                batch.setData(members, forDocument: db.collection("Collaborations").document(collabID).collection("Members").document(friend.userID), merge: true)
                
                acceptedStatuses[friend.userID] = self.collabs.first(where: { $0.collabID == collabID })?.accepted?[friend.userID] ?? NSNull()
                requestsSentOn[friend.userID] = self.collabs.first(where: { $0.collabID == collabID })?.requestSentOn?[friend.userID] ?? Date()
            }
            
            else if let member = member as? Member {
                
                memberIDs.append(member.userID)
                
                members["userID"] = member.userID
                members["firstName"] = member.firstName
                members["lastName"] = member.lastName
                members["username"] = member.username
                members["role"] = "Member"
                members["dateJoined"] = previouslyAddedMembers.first(where: { $0.userID == member.userID })?.dateJoined ?? NSNull()
                
                batch.setData(members, forDocument: db.collection("Collaborations").document(collabID).collection("Members").document(member.userID), merge: true)
                
                acceptedStatuses[member.userID] = self.collabs.first(where: { $0.collabID == collabID })?.accepted?[member.userID] ?? NSNull()
                requestsSentOn[member.userID] = self.collabs.first(where: { $0.collabID == collabID })?.requestSentOn?[member.userID] ?? Date()
            }
        }
        
        for previouslyAddedMember in previouslyAddedMembers {
            
            if memberIDs.contains(where: { $0 == previouslyAddedMember.userID }) == false {
                
                batch.updateData(["role" : "Inactive"], forDocument: db.collection("Collaborations").document(collabID).collection("Members").document(previouslyAddedMember.userID))
            }
        }
        
        let firebaseBlock = FirebaseBlock.sharedInstance
        firebaseBlock.removeInactiveCollabBlockMembers(collabID: collabID, currentCollabMembers: memberIDs)
        
        batch.setData(["Members" : memberIDs], forDocument: db.collection("Collaborations").document(collabID), merge: true)
        batch.updateData(["accepted" : acceptedStatuses], forDocument: db.collection("Collaborations").document(collabID))
        batch.updateData(["requestSentOn" : requestsSentOn], forDocument: db.collection("Collaborations").document(collabID))
    }
    
    
    //MARK: - Set Collab Locations
    
    private func setCollabLocations (collabID: String, locations: [Location]?) -> [String : [String : Any]] {

        var locationDict: [String : [String : Any]] = [:]

        for location in locations ?? [] {

            if let locationID = location.locationID {

                locationDict[locationID] = ["coordinates" : location.coordinates as Any, "name" : location.name as Any, "number" : location.number as Any, "url" : location.url?.absoluteString as Any, "address" : ["streetNumber" : location.streetNumber, "streetName" : location.streetName, "city" : location.city, "state": location.state, "zipCode" : location.zipCode, "country" : location.country]]
            }
        }

        return locationDict
    }
    
    
    //MARK: - Set Collab Voice Memos
    
    private func setCollabVoiceMemos (collabID: String, voiceMemos: [VoiceMemo]?) -> [String : [String : Any]]{
        
        var voiceMemoDict: [String : [String : Any]] = [:]
        
        for memo in voiceMemos ?? [] {
            
            if let memoID = memo.voiceMemoID {
                
                voiceMemoDict[memoID] = ["name" : memo.name as Any, "length" : memo.length as Any, "dateCreated" : memo.dateCreated as Any]
            }
        }
        
        return voiceMemoDict
    }
    
    
    //MARK: - Set Collab Links
    
    private func setCollabLinks (collabID: String, links: [Link]?) -> [String : [String : String?]] {
        
        var linksDict: [String : [String : String?]] = [:]
        
        for link in links ?? [] {
            
            if let linkID = link.linkID, let url = link.url {
                
                linksDict[linkID] = ["url" : url, "name" : link.name]
            }
        }
        
        return linksDict
    }
    
    
    //MARK: - Save Collab Photos
    
    private func saveCollabPhotosToStorage (_ collabID: String, _ photos: [String : UIImage?]?) {
        
        var count = 0
        
        for photo in photos ?? [:] {
            
            firebaseStorage.saveCollabPhotosToStorage(collabID, photo.key, photo.value)
            
            count += 1
        }
    }
    
    
    //MARK: - Edit Collab Photos
    
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
    
    
    //MARK: - Save Collab Voice Memos
    
    private func saveCollabVoiceMemosToStorage (_ collabID: String, _ voiceMemos: [VoiceMemo]?) {
        
        for voiceMemo in voiceMemos ?? [] {
            
            firebaseStorage.saveCollabVoiceMemosToStorage(collabID, voiceMemo.voiceMemoID ?? "")
        }
    }
    
    
    //MARK: - Edit Collab Voice Memos
    
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
    
    
    //MARK: - Save Collab Cover Photo
    
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
    
    
    //MARK: - Delete Collab Cover Photo
    
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
    
    
    //MARK: - Retrieve Collabs
    
    func retrieveCollabs (completion: @escaping ((_ collabs: [Collab]?, _ error: Error?) -> Void)) {
        
        allCollabsListener = db.collection("Collaborations").whereField("Members", arrayContains: currentUser.userID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(nil, error)
            }
            
            else {
                
                self.removeCollabsWhereUserInactive(snapshot: snapshot)
                
                if snapshot?.isEmpty != true {
                    
                    for document in snapshot?.documents ?? [] {
                        
                        let collab = self.configureCollab(document.data())
                        
                        if self.collabs.first(where: { $0.collabID == collab.collabID }) == nil {
                            
                            self.collabs.append(collab)
                        }
                        
                        else {
                            
                            self.handleCollabUpdate(collab)
                        }
                        
                        if let existingCollab = self.collabs.first(where: { $0.collabID == collab.collabID }) {
                            
                            self.retrieveCollabMembers(existingCollab) { (historicMembers, currentMembers, error) in

                                self.handleCollabMembersRetrievalCompletion(collab.collabID, historicMembers, currentMembers, error) { (collabMembers) in
                                    
//                                    completion(nil, collabMembers, nil)
                                }
                            }
                        }
                    }
                    
                    completion(self.collabs, nil)
                }
                
                else {
                    
                    self.collabs.removeAll()
                    
                    completion([], nil)
                }

                NotificationCenter.default.post(name: .didUpdateCollabs, object: nil)
            }
        })
    }
    
    
    //MARK: - Configure Collab
    
    private func configureCollab (_ data: [String : Any]?) -> Collab {
        
        var collab = Collab()
        
        collab.collabID = data?["collabID"] as! String
        collab.name = data?["collabName"] as! String
        collab.objective = data?["collabObjective"] as? String
        
        collab.coverPhotoID = data?["coverPhotoID"] as? String
        
        let dateCreated = data?["dateCreated"] as! Timestamp
        collab.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreated.seconds))
        
        collab.requestSentOn = parseRequestSentOn(data?["requestSentOn"] as? [String : Timestamp])
        collab.accepted = parseAcceptionStatuses(data?["accepted"] as? [String : Bool?])
        
        let startTime = data?["startTime"] as! Timestamp
        collab.dates["startTime"] = Date(timeIntervalSince1970: TimeInterval(startTime.seconds))
        
        if let deadline = data?["deadline"] as? Timestamp {
            
            collab.dates["deadline"] = Date(timeIntervalSince1970: TimeInterval(deadline.seconds))
        }
        
        collab.currentMembersIDs = data?["Members"] as? [String] ?? []
        
        let memberActivity: [String : Any]? = data?["memberActivity"] as? [String : Any]
        collab.memberActivity = parseCollabActivity(memberActivity: memberActivity)
        
        collab.reminders = data?["reminders"] as? [Int] ?? []
        
        collab.photoIDs = data?["photos"] as? [String] ?? []
        collab.locations = retrieveCollabLocations(data?["locations"] as? [String : Any])
        collab.voiceMemos = retrieveCollabVoiceMemos(data?["voiceMemos"] as? [String : Any])
        collab.links = retrieveCollabLinks(data?["links"] as? [String : Any])
        
        return collab
    }
    
    
    //MARK: - Handle Collab Update
    
    private func handleCollabUpdate (_ collab: Collab) {
        
        if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == collab.collabID }) {
            
            if collab.coverPhotoID != self.collabs[collabIndex].coverPhotoID {
                
                self.collabs[collabIndex].coverPhotoID = collab.coverPhotoID
                self.collabs[collabIndex].coverPhoto = nil
            }
            
            self.collabs[collabIndex].name = collab.name
            self.collabs[collabIndex].objective = collab.objective
            
            self.collabs[collabIndex].requestSentOn = collab.requestSentOn
            self.collabs[collabIndex].accepted = collab.accepted
            
            self.collabs[collabIndex].dates = collab.dates
            
            self.collabs[collabIndex].currentMembersIDs = collab.currentMembersIDs
            self.collabs[collabIndex].memberActivity = collab.memberActivity
            
            self.collabs[collabIndex].reminders = collab.reminders
            
            self.collabs[collabIndex].photoIDs = collab.photoIDs
            self.collabs[collabIndex].locations = collab.locations
            self.collabs[collabIndex].voiceMemos = collab.voiceMemos
            self.collabs[collabIndex].links = collab.links
        }
    }
    
    
    //MARK: - Remove Collabs Where User Inactive
    
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
    
    
    //MARK: - Retrieve Collab Members
    
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
                        
                        //Filters out members that are no longer active in the collab
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
    
    
    //MARK: - Handle Collab Members Retrieval Completion
    
    private func handleCollabMembersRetrievalCompletion (_ collabID: String, _ historicMembers: [Member], _ currentMembers: [Member], _ error: Error?, _ completion: (([String : [Member]]) -> Void)) {

        if error != nil {

            print(error as Any)
        }

        else {

            if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == collabID }) {

                self.collabs[collabIndex].historicMembers = historicMembers
                self.collabs[collabIndex].currentMembers = currentMembers
                
                let collabMembers = ["historicMembers" : historicMembers, "currentMembers" : currentMembers]

                completion(collabMembers)
            }
        }
    }
    
    
    //MARK: - Retrieve Collab Locations
    
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
    
    
    //MARK: - Retrieve Collab Voice Memos
    
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
    
    
    //MARK: - Retrieve Collab Links
    
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
    
    
    //MARK: - Mark Collab Request Notifications
    
    func markCollabRequestNotifications (_ collabRequests: [Collab]?) {
        
        let batch = db.batch()
        
        if let requests = collabRequests {
            
            for request in requests {
                
                if request.accepted?[currentUser.userID] as? Bool == nil {
                    
                    batch.updateData(["accepted." + currentUser.userID : false], forDocument: db.collection("Collaborations").document(request.collabID))
                }
            }
            
            batch.commit { (error) in
    
                if error != nil {
    
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    
    
    //MARK: - Accept Collab Request
    
    func acceptCollabRequest (_ collabID: String) {
        
        db.collection("Collaborations").document(collabID).updateData(["accepted." + currentUser.userID : true]) { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
        
        db.collection("Collaborations").document(collabID).collection("Members").document(currentUser.userID).updateData(["dateJoined" : Date()]) { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    
    //MARK: - Decline Collab Request
    
    func declineCollabRequest (_ collabRequest: Collab) {
        
        //Call updates to members first
        db.collection("Collaborations").document(collabRequest.collabID).updateData(["Members" : FieldValue.arrayRemove([currentUser.userID])]) { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
        
        db.collection("Collaborations").document(collabRequest.collabID).collection("Members").document(currentUser.userID).updateData(["role" : "Inactive"]) { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
        
        db.collection("Collaborations").document(collabRequest.collabID).updateData(["accepted." + currentUser.userID : FieldValue.delete()]) { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
        
        db.collection("Collaborations").document(collabRequest.collabID).updateData(["requestSentOn." + currentUser.userID : FieldValue.delete()]) { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    
    //MARK: - Monitor Collab
    
    func monitorCollab (collabID: String, completion: @escaping ((_ updatedCollab: [String : Any?]) -> Void)) {
        
        singularCollabListener = db.collection("Collaborations").document(collabID).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(["error" : error])
            }
            
            else {
                
                if let snapshotData = snapshot?.data() {
                    
                    let collab = self.configureCollab(snapshotData)
                    
                    self.handleCollabUpdate(collab) //Important
                    
                    completion(["collab" : collab])
                    
                    //Retrieves the cachedCollab because it has both the historic and currentMembers cached
                    if let cachedCollab = self.collabs.first(where: { $0.collabID == collabID }) {
                        
                        self.retrieveCollabMembers(cachedCollab) { (historicMembers, currentMembers, membersError) in
                            
                            if error != nil {
                                
                                completion(["error" : membersError])
                            }
                            
                            else {
                                
                                completion(["historicMembers" : historicMembers, "currentMembers" : currentMembers])
                            }
                        }
                    }
                }
            }
        })
    }
    
    
    //MARK: - Leave Collab
    
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
        
        else if let member = collab.currentMembers.first(where: { $0.userID == currentUser.userID }), let newLead = filteredMembers.first {
            
            if member.role == "Lead" {
                
                //Reassigning the "Lead" for the collab if the currentUser is currently the "Lead"
                batch.updateData(["role" : "Lead"], forDocument: db.collection("Collaborations").document(collab.collabID).collection("Members").document(newLead.userID))
            }
        }
        
        //Removing the currentUser from the "accepted" map
        batch.updateData(["accepted." + currentUser.userID : FieldValue.delete()], forDocument: db.collection("Collaborations").document(collab.collabID))
        
        //Removing the "requestSentOn" from the accepted map
        batch.updateData(["requestSentOn." + currentUser.userID : FieldValue.delete()], forDocument: db.collection("Collaborations").document(collab.collabID))
        
        //Will leave currentUser in the "memberActivity" map in case they are added again
        batch.updateData(["memberActivity.\(currentUser.userID)" : Date()], forDocument: db.collection("Collaborations").document(collab.collabID))
        
        //Changing the role of the currentUser
        batch.updateData(["role" : "Inactive"], forDocument: db.collection("Collaborations").document(collab.collabID).collection("Members").document(currentUser.userID))

        //Removing currentUser from the Members array in the conversation fields; not from the Members collection
        batch.updateData(["Members" : FieldValue.arrayRemove([currentUser.userID])], forDocument: db.collection("Collaborations").document(collab.collabID))

        //Removing the "dateJoined" value from the currentUser's document in this collab
        batch.updateData(["dateJoined" : FieldValue.delete()], forDocument: db.collection("Collaborations").document(collab.collabID).collection("Members").document(currentUser.userID))
        
        batch.commit { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                completion(nil)
            }
        }
    }
    
    
    //MARK: - Delete Collab
    
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
    
    
    //MARK: - Query Users
    
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
                        searchResult.isAccountDeleted = document.data()["isAccountDeleted"] as? Bool ?? false
                        
                        if searchResult.userID == self.currentUser.userID {
                            continue
                        } else if searchResult.isAccountDeleted {
                            continue
                        } else {
                            
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
    
    
    //MARK: - Retrieve Users Friends
    
    func retrieveUsersFriends () {
        
        friendsListener = db.collection("Users").document(currentUser.userID).collection("Friends").addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                ProgressHUD.showError(error?.localizedDescription)
            }
            
            else {
                
                var retrievedFriends: [Friend] = []
                
                for document in snapshot?.documents ?? [] {
                    
                    let friend = Friend()
                    
                    if let userID = document.data()["userID"] as? String {
                        
                        friend.userID = userID
                    }
                    
                    friend.firstName = document.data()["firstName"] as! String
                    friend.lastName = document.data()["lastName"] as! String
                    friend.username = document.data()["username"] as! String
                    
                    friend.accepted = document.data()["accepted"] as? Bool
                    friend.requestSentBy = document.data()["requestSentBy"] as! String
                    
                    if let requestSentOn = document.data()["requestSentOn"] as? Timestamp {
                        
                        friend.requestSentOn = Date(timeIntervalSince1970: TimeInterval(requestSentOn.seconds))
                    }
                    
                    if let dateOfFriendship = document.data()["dateOfFriendship"] as? Timestamp {
                        
                        friend.dateOfFriendship = Date(timeIntervalSince1970: TimeInterval(dateOfFriendship.seconds))
                    }
                    
                    if let profilePicture = self.friends.first(where: { $0.userID == friend.userID })?.profilePictureImage {
                        
                        friend.profilePictureImage = profilePicture
                    }
                    
                    retrievedFriends.append(friend)
                    
                    self.cacheFriendsProfilePicture(friend)
                }
                
                self.friends = retrievedFriends.sorted(by: { $0.lastName.lowercased() < $1.lastName.lowercased() })
                
                NotificationCenter.default.post(name: .didUpdateFriends, object: nil)
            }
        })
    }
    
    
    //MARK: - Send Friend Requests
    
    func sendFriendRequest (_ user: Any) {
        
        let currentUserData: [String : Any] = ["userID" : currentUser.userID, "firstName" : currentUser.firstName, "lastName" : currentUser.lastName, "username" : currentUser.username, "requestSentBy" : currentUser.userID, "requestSentOn" : Date()]
        
        var friendData: [String : Any] = [:]
        
        if let searchResult = user as? FriendSearchResult {
            
            friendData = ["userID" : searchResult.userID, "firstName" : searchResult.firstName, "lastName" : searchResult.lastName, "username" : searchResult.username, "requestSentBy" : currentUser.userID, "requestSentOn" : Date()]
        }
        
        else if let member = user as? Member {
            
            friendData = ["userID" : member.userID, "firstName" : member.firstName, "lastName" : member.lastName, "username" : member.username, "requestSentBy" : currentUser.userID, "requestSentOn" : Date()]
        }
        
        db.collection("Users").document(currentUser.userID).collection("Friends").document(friendData["userID"] as! String).setData(friendData) { (error) in
            
            if error != nil {
                
                print("error adding friend", error?.localizedDescription as Any)
            }
        }
        
        db.collection("Users").document(friendData["userID"] as! String).collection("Friends").document(currentUser.userID).setData(currentUserData) { (error) in
            
            if error != nil {
                
                print("error sending friend request", error?.localizedDescription as Any)
            }
        }
    }
    
    
    //MARK: - Mark Friend Requests
    
    func markFriendRequestNotifications (_ friendRequests: [Friend]?) {
        
        let batch = db.batch()
        
        if let requests = friendRequests {
            
            for request in requests {
                
                if request.accepted == nil {
                    
                    batch.updateData(["accepted" : false], forDocument: db.collection("Users").document(currentUser.userID).collection("Friends").document(request.userID))
                }
            }
            
            batch.commit { (error) in
    
                if error != nil {
    
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    
    
    //MARK: - Accept Friend Request
    
    func acceptFriendRequest (_ friendRequest: Friend) {
        
        db.collection("Users").document(currentUser.userID).collection("Friends").document(friendRequest.userID).updateData(["accepted" : true, "dateOfFriendship" : Date()]) { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
        
        db.collection("Users").document(friendRequest.userID).collection("Friends").document(currentUser.userID).updateData(["accepted" : true, "dateOfFriendship" : Date()]) { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    
    //MARK: - Decline Friend Request
    
    func declineFriendRequest (_ friendRequest: Friend) {
        
        db.collection("Users").document(currentUser.userID).collection("Friends").document(friendRequest.userID).delete { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
        
        db.collection("Users").document(friendRequest.userID).collection("Friends").document(currentUser.userID).delete { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    
    //MARK: - Cache Friend Profile Pictures
    
    func cacheFriendsProfilePicture (_ friend: Friend) {
        
        firebaseStorage.retrieveUserProfilePicFromStorage(userID: friend.userID) { (profilePicture, userID) in
            
            if let profilePic = profilePicture, let friendIndex = self.friends.firstIndex(where: { $0.userID == friend.userID }) {
                
                self.friends[friendIndex].profilePictureImage = profilePic
            }
        }
    }
    
    
    //MARK: - Delete Friend
    
    func deleteFriend (_ friend: Friend) {
        
        db.collection("Users").document(currentUser.userID).collection("Friends").document(friend.userID).delete { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
        }
        
        db.collection("Users").document(friend.userID).collection("Friends").document(currentUser.userID).delete { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
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
    
    
    //MARK: - Parse Request Sent On
    
    private func parseRequestSentOn (_ requestSentOn: [String : Timestamp]?) -> [String : Date] {
        
        var sentOnDict: [String : Date] = [:]
        
        if let requestDates = requestSentOn {
            
            for request in requestDates {
                
                let date = Date(timeIntervalSince1970: TimeInterval(request.value.seconds))
                sentOnDict[request.key] = date
            }
        }
        
        return sentOnDict
    }
    
    
    //MARK: - Parse Acception Statuses
    
    private func parseAcceptionStatuses (_ acceptionStatuses: [String : Bool?]?) -> [String : Bool?] {
        
        var acceptionStatusDict: [String : Bool?] = [:]
        
        if let statuses = acceptionStatuses {
            
            for status in statuses {
                
                acceptionStatusDict[status.key] = status.value
            }
        }
        
        return acceptionStatusDict
    }
    
    
    //MARK: - Parse Collab Activity
    
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
    
    
    //MARK: - Cache Member Profile Pics
    
    func cacheMemberProfilePics (userID: String, profilePic: UIImage?) {
         
        membersProfilePics[userID] = profilePic
    }
}
