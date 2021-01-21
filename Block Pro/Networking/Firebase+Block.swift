//
//  Firebase+Block.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/14/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirebaseBlock {
    
    let firebaseStorage = FirebaseStorage()
    
    let currentUser = CurrentUser.sharedInstance
    
    var db = Firestore.firestore()
    
    func createCollabBlock (collabID: String, block: Block, completion: @escaping ((_ error: Error?) -> Void)) {
        
        var memberIDs: [String] = [currentUser.userID]
        block.members?.forEach({ memberIDs.append($0.userID) })
        
        var blockData: [String : Any] = ["blockName" : block.name as Any, "dateCreated" : Date(), "creator" : currentUser.userID, "startTime" : block.starts as Any, "endTime" : block.ends as Any, "members" : memberIDs, "photos" : block.photoIDs as Any]
        
        blockData["locations"] = setBlockLocations(block.locations)
        
        blockData["voiceMemos"] = setBlockVoiceMemos(block.voiceMemos)
        
        blockData["links"] = setBlockLinks(block.links)
        
        db.collection("Collaborations").document(collabID).collection("Blocks").document(block.blockID!).setData(blockData) { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                self.saveCollabBlockPhotosToStorage(collabID, block.blockID!, block.photos)
                
                self.saveCollabBlockVoiceMemosToStorage(collabID, block.blockID!, block.voiceMemos)
                
                completion(nil)
            }
        }
    }
    
    private func setBlockLocations (_ locations: [Location]?) -> [String : [String : Any]]? {
        
        var locationsDict: [String : [String : Any]] = [:]
        
        for location in locations ?? [] {
            
            if let locationID = location.locationID {
                
                locationsDict[locationID] = ["coordinates" : location.coordinates as Any, "name" : location.name as Any, "number" : location.number as Any, "url" : location.url?.absoluteString as Any, "address" : ["streetNumber" : location.streetNumber, "streetName" : location.streetName, "city" : location.city, "state": location.state, "zipCode" : location.zipCode, "country" : location.country]]
            }
        }
        
        if locationsDict.isEmpty {
            
            return nil
        }
        
        else {
            
            return locationsDict
        }
    }
    
    private func setBlockVoiceMemos (_ voiceMemos: [VoiceMemo]?) -> [String : [String : Any]]? {
        
        var voiceMemosDict: [String : [String : Any]] = [:]
        
        for memo in voiceMemos ?? [] {
            
            if let memoID = memo.voiceMemoID {
                
                voiceMemosDict[memoID] = ["name" : memo.name as Any, "length" : memo.length as Any, "dateCreated" : memo.dateCreated as Any]
            }
        }
        
        if voiceMemosDict.isEmpty {
            
            return nil
        }
        
        else {
            
            return voiceMemosDict
        }
    }
    
    private func setBlockLinks (_ links: [Link]?) -> [String : [String : String?]]? {
        
        var linksDict: [String : [String : String?]] = [:]
        
        for link in links ?? [] {
            
            if let linkID = link.linkID, let url = link.url {
                
                linksDict[linkID] = ["url" : url, "name" : link.name]
            }
        }
        
        if linksDict.isEmpty {
            
            return nil
        }
        
        else {
            
            return linksDict
        }
    }
    
    private func saveCollabBlockPhotosToStorage (_ collabID: String, _ blockID: String, _ photos: [String : UIImage?]?) {
        
        var count = 0
        
        for photo in photos ?? [:] {
            
            firebaseStorage.saveCollabBlockPhotosToStorage(collabID, blockID, photo.key, photo.value)
            
            count += 1
        }
    }
    
    private func saveCollabBlockVoiceMemosToStorage (_ collabID: String, _ blockID: String, _ voiceMemos: [VoiceMemo]?) {
        
        for voiceMemo in voiceMemos ?? [] {
            
            firebaseStorage.saveCollabBlockVoiceMemosToStorage(collabID, blockID, voiceMemo.voiceMemoID ?? "")
        }
    }
    
    func retrieveCollabBlocks (_ collab: Collab, completion: @escaping ((_ error: Error?, _ blocks: [Block]?) -> Void)) {
        
        db.collection("Collaborations").document(collab.collabID).collection("Blocks").addSnapshotListener { (snapshot, error) in
            
            if error != nil {
                
                completion(error, nil)
            }
            
            else {
                
                var blocks: [Block] = []
                
                for document in snapshot?.documents ?? [] {
                    
                    var block = Block()
                    
                    block.blockID = document.documentID
                    
                    block.creator = document.data()["creator"] as? String
                    
                    let dateCreated = document.data()["dateCreated"] as! Timestamp
                    block.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreated.seconds))
                    
                    block.name = document.data()["blockName"] as? String
                    
                    let starts = document.data()["startTime"] as! Timestamp
                    let ends = document.data()["endTime"] as! Timestamp
                    
                    block.starts = Date(timeIntervalSince1970: TimeInterval(starts.seconds))
                    block.ends = Date(timeIntervalSince1970: TimeInterval(ends.seconds))

                    block.members = []
                    
                    for retrievedMember in document.data()["members"] as? [String] ?? [] {
                        
                        if let member = collab.members.first(where: { $0.userID == retrievedMember }) {
                            
                            block.members?.append(member)
                        }
                    }
                    
                    block.reminders = document.data()["reminders"] as? [Int]
                    
                    block.photoIDs = document.data()["photos"] as? [String]
                    
                    block.locations = self.retrieveBlockLocations(document: document)
                    
                    block.voiceMemos = self.retrieveBlockVoiceMemos(document: document)
                    
                    block.links = self.retrieveBlockLinks(document: document)
                    
                    blocks.append(block)
                }
                
                completion(nil, blocks)
            }
        }
    }
    
    private func retrieveBlockLocations (document: QueryDocumentSnapshot) -> [Location]? {
        
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
    
    private func retrieveBlockVoiceMemos (document: QueryDocumentSnapshot) -> [VoiceMemo]? {
        
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
    
    private func retrieveBlockLinks (document: QueryDocumentSnapshot) -> [Link]? {
        
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
}
