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
    
    func createCollab (collab: NewCollab, completion: @escaping (() -> Void)) {
        
        let batch = db.batch()
        
        let collabID = UUID().uuidString
        var photoIDs: [String] = []
        
        for _ in collab.photos ?? [] {
            
            photoIDs.append(UUID().uuidString)
        }
        
        let collabData: [String : Any] = ["collabID" : collabID, "collabName" : collab.name, "dateCreated" : Date(), "collabObjective" : collab.objective as Any, "startTime" : collab.dates["startTime"]!, "deadline" : collab.dates["deadline"]!, "reminders" : "will be set up later", "photos" : photoIDs]
        let memberCollabData: [String : Any] = ["collabID" : collabID, "collabName" : collab.name,  "dateCreated" : Date(), "collabObjective" : collab.objective as Any, "startTime" : collab.dates["startTime"]!, "deadline" : collab.dates["deadline"]!, "reminders" : "will be set up later"]
        
        batch.setData(collabData, forDocument: db.collection("Collaborations").document(collabID))
        
        var memberDictArray: [[String : String]] = []
        var memberUserIDArray: [String] = []
        
        #warning("collab wont be retrieved if at least one member isnt added by the creator; currently thinking of allowing for creator to create a collab with no members but this loop will have to be rewritten in order to allow for that")
        for member in collab.members {
            
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
            if member.userID == collab.members.last?.userID {
                
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
        
        for member in collab.members {

            batch.setData(memberCollabData, forDocument: db.collection("Users").document(member.userID).collection("CollabRequests").document(collabID))

            for addedMember in memberDictArray {

                batch.setData(addedMember, forDocument: db.collection("Users").document(member.userID).collection("CollabRequests").document(collabID).collection("Members").document(addedMember["userID"]!))
            }
        }

        if let locations = collab.locations {
            
            setCollabLocations(collabID: collabID, locations: locations, batch: batch)
        }
        
        if let voiceMemos = collab.voiceMemos {
            
            setCollabVoiceMemos(collabID: collabID, voiceMemos: voiceMemos, batch: batch)
        }
        
        if let links = collab.links {
            
            setCollabLinks(collabID: collabID, links: links, batch: batch)
        }
        
        print(collabID)
        
        
        //Sets the leader collab data
        //batch.setData(memberCollabData, forDocument: db.collection("Users").document(currentUser.userID).collection("Collabs").document(collabID))


        //Setting the members for the collab to the leaders collab document
//        for addedMember in memberArray {
//
//            batch.setData(addedMember, forDocument: db.collection("Users").document(currentUser.userID).collection("Collabs").document(collabID).collection("Members").document(addedMember["userID"]!))
//        }

        commitBatch(batch: batch) {

            self.saveNewCollabPhotosToStorage(collabID, photoIDs, collab.photos)

            self.saveNewCollabVoiceMemosToStorage(collabID, collab.voiceMemos)

            completion()
        }
    }
    
    private func setCollabLocations (collabID: String, locations: [Location], batch: WriteBatch) {

        var locationDict: [String : [String : Any]] = [:]

        for location in locations {

            if let locationID = location.locationID {

                locationDict[locationID] = ["coordinates" : location.coordinates as Any, "name" : location.name as Any, "number" : location.number as Any, "url" : location.url?.absoluteString as Any, "address" : ["streetNumber" : location.streetNumber, "streetName" : location.streetName, "city" : location.city, "state": location.state, "zipCode" : location.zipCode, "country" : location.country]]
            }
        }

        batch.setData(["locations": locationDict], forDocument: db.collection("Collaborations").document(collabID), merge: true)
    }
    
    private func setCollabVoiceMemos (collabID: String, voiceMemos: [VoiceMemo], batch: WriteBatch) {
        
        var voiceMemoDict: [String : [String : Any]] = [:]
        
        for memo in voiceMemos {
            
            if let memoID = memo.voiceMemoID {
                
                voiceMemoDict[memoID] = ["name" : memo.name as Any, "length" : memo.length as Any, "dateCreated" : memo.dateCreated as Any]
            }
        }
        
        batch.setData(["voiceMemos" : voiceMemoDict], forDocument: db.collection("Collaborations").document(collabID), merge: true)
    }
    
    private func setCollabLinks (collabID: String, links: [Link], batch: WriteBatch) {
        
        var linksDict: [String : [String : String?]] = [:]
        
        for link in links {
            
            if let linkID = link.linkID, let url = link.url {
                
                linksDict[linkID] = ["url" : url, "name" : link.name]
            }
        }
        
        if !linksDict.isEmpty {
            
            batch.setData(["links" : linksDict], forDocument: db.collection("Collaborations").document(collabID), merge: true)
        }
    }
    
//    private func setCollabLocations (collabID: String, locations: [Location], batch: WriteBatch) {
//
//        for location in locations {
//
//            var locationDict: [String : Any] = [:]
//
//            locationDict["locationID"] = location.locationID
//
//            locationDict["coordinates"] = location.coordinates
//
//            locationDict["name"] = location.name
//            locationDict["number"] = location.number
//            locationDict["url"] = location.url?.absoluteString
//
//            locationDict["address"] = ["streetNumber" : location.streetNumber, "streetName" : location.streetName, "city" : location.city, "state": location.state, "zipCode" : location.zipCode, "country" : location.country]
//
//            batch.setData(locationDict, forDocument: db.collection("Collaborations").document(collabID).collection("Locations").document(location.locationID ?? ""))
//        }
//    }
    
    //    private func setCollabVoiceMemos (collabID: String, voiceMemos: [VoiceMemo], batch: WriteBatch) {
    //
    //        for memo in voiceMemos {
    //
    //            var voiceMemoDict: [String : Any] = [:]
    //
    //            voiceMemoDict["voiceMemoID"] = memo.voiceMemoID
    //            voiceMemoDict["name"] = memo.name
    //            voiceMemoDict["length"] = memo.length
    //            voiceMemoDict["dateCreated"] = memo.dateCreated
    //
    //            batch.setData(voiceMemoDict, forDocument: db.collection("Collaborations").document(collabID).collection("Voice Memos").document(memo.voiceMemoID ?? ""))
    //        }
    //    }
    
    private func saveNewCollabPhotosToStorage (_ collabID: String, _ photoIDs: [String], _ photos: [UIImage]?) {
        
        var count = 0

        for photo in photos ?? [] {

            self.firebaseStorage.saveNewCollabPhotosToStorage(collabID, photoIDs[count], photo)

            count += 1
        }
    }
    
    private func saveNewCollabVoiceMemosToStorage (_ collabID: String, _ voiceMemos: [VoiceMemo]?) {
        
        for voiceMemo in voiceMemos ?? [] {
            
            firebaseStorage.saveNewCollabVoiceMemosToStorage(collabID, voiceMemo.voiceMemoID ?? "")
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
                        
                        let dateCreated = document.data()["dateCreated"] as! Timestamp
                        collab.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreated.seconds))
                        
                        collab.coverPhotoID = document.data()["coverPhotoID"] as? String
                        
                        collab.photoIDs = document.data()["photos"] as? [String] ?? []
                        
                        let startTime = document.data()["startTime"] as! Timestamp
                        collab.dates["startTime"] = Date(timeIntervalSince1970: TimeInterval(startTime.seconds))
                        
                        if let deadline = document.data()["deadline"] as? Timestamp {
                            
                            collab.dates["deadline"] = Date(timeIntervalSince1970: TimeInterval(deadline.seconds))
                        }
                        
                        let memberActivity: [String : Any]? = document.data()["memberActivity"] as? [String : Any]
                        collab.memberActivity = self.parseCollabActivity(memberActivity: memberActivity)
                        
                        
                        collab.locations = self.retrieveCollabLocations(document: document)
                        
                        collab.voiceMemos = self.retrieveCollabVoiceMemos(document: document)
                        
                        collab.links = self.retrieveCollabLinks(document: document)
                        
                        
                        #warning("temp fix for the tableview of the home view being overpopulated with data")
                        if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == collab.collabID }) {
                            
                        }
                        
                        else {
                            
                            self.collabs.append(collab)
                            self.collabs = self.collabs.sorted(by: {$0.dates["deadline"] ?? Date() > $1.dates["deadline"] ?? Date()})
                        }
                        
                        #warning("will need to move this to seperate function as well as configure way to sort historic members from current members modeling the way I did it with conversation :) i believe in you")
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
                                        
                                        historicMembers.append(member)
                                    }
                                    
                                    if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == collab.collabID }) {
                                        
                                        self.collabs[collabIndex].members = historicMembers
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
    

    private func retrieveCollabLocations (document: QueryDocumentSnapshot) -> [Location]? {

        if let locations = document.data()["locations"] as? [String : Any] {
            
            var locationArray: [Location] = []
            
            locations.forEach { (retrievedLocation) in
                
                var location = Location()
                location.locationID = retrievedLocation.key
                
                if let values = retrievedLocation.value as? [String : Any] {
                    
                    location.locationID = values["locationID"] as? String
                    
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
        
        return nil
    }

    
    private func retrieveCollabVoiceMemos (document: QueryDocumentSnapshot) -> [VoiceMemo]? {
        
        if let voiceMemos = document.data()["voiceMemos"] as? [String : Any] {
            
            var voiceMemoArray: [VoiceMemo] = []
            
            voiceMemos.forEach { (retrievedVoiceMemo) in
                
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
        
        else {
            
            return nil
        }
    }
    
    private func retrieveCollabLinks (document: QueryDocumentSnapshot) -> [Link]? {
        
        if let links = document.data()["links"] as? [String : Any] {
            
            var linkArray: [Link] = []
            
            links.forEach { (retrievedLink) in
                
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
        
        else {
            
            return nil
        }
    }
    
    //    private func retrieveCollabLocations (_ collabID: String) {
    //
    //        db.collection("Collaborations").document(collabID).collection("Locations").getDocuments { (snapshot, error) in
    //
    //            if error != nil {
    //
    //                print(error as Any)
    //            }
    //
    //            else {
    //
    //                if snapshot?.isEmpty != true {
    //
    //                    var locations: [Location] = []
    //
    //                    for document in snapshot?.documents ?? [] {
    //
    //                        var location = Location()
    //
    //                        location.locationID = document.data()["locationID"] as? String
    //
    //                        location.coordinates = document.data()["coordinates"] as? [String : Double]
    //
    //                        location.name = document.data()["name"] as? String
    //                        location.number = document.data()["number"] as? String
    //
    //                        if let urlString = document.data()["url"] as? String {
    //
    //                            location.url = URL(string: urlString)
    //                        }
    //
    //                        let address = document.data()["address"] as? [String : String]
    //                        location.streetNumber = address?["streetNumber"]
    //                        location.streetName = address?["streetName"]
    //                        location.city = address?["city"]
    //                        location.state = address?["state"]
    //                        location.zipCode = address?["zipCode"]
    //                        location.country = address?["country"]
    //
    //                        location.address = location.parseAddress()
    //
    //                        locations.append(location)
    //                    }
    //
    //                    if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == collabID }) {
    //
    //                        self.collabs[collabIndex].locations = locations
    //                    }
    //                }
    //            }
    //        }
    //    }
        
    
//    private func retrieveCollabVoiceMemos (_ collabID: String) {
//
//        db.collection("Collaborations").document(collabID).collection("Voice Memos").getDocuments { (snapshot, error) in
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
//                    var voiceMemos: [VoiceMemo] = []
//
//                    for document in snapshot?.documents ?? [] {
//
//                        var voiceMemo = VoiceMemo()
//
//                        voiceMemo.voiceMemoID = document.data()["voiceMemoID"] as? String
//                        voiceMemo.name = document.data()["name"] as? String
//                        voiceMemo.length = document.data()["length"] as? Double
//
//                        let dateCreated = document.data()["dateCreated"] as! Timestamp
//                        voiceMemo.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreated.seconds))
//
//                        voiceMemos.append(voiceMemo)
//                    }
//
//                    if let collabIndex = self.collabs.firstIndex(where: { $0.collabID == collabID }){
//
//                        self.collabs[collabIndex].voiceMemos = voiceMemos
//                    }
//                }
//            }
//        }
//    }
    
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
