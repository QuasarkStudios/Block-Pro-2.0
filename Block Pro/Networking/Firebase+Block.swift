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
    
    var cachedPersonalBlocks: [Block] = []
    var cachedCollabBlocks: [Block] = []
    
    var personalBlocksListener: ListenerRegistration?
    var collabBlocksListener: ListenerRegistration?
    var blockListener: ListenerRegistration?
    
    static let sharedInstance = FirebaseBlock()
    
    
    //MARK: - Create Blocks
    
    func createPersonalBlock (block: Block, _ completion: @escaping ((_ error: Error?) -> Void)) {
        
        var blockData: [String : Any] = ["blockName" : block.name as Any, "dateCreated" : Date(), "startTime" : block.starts as Any, "endTime" : block.ends as Any, "photos" : block.photoIDs as Any]
        
        blockData["locations"] = setBlockLocations(block.locations)
        
        blockData["voiceMemos"] = setBlockVoiceMemos(block.voiceMemos)
        
        blockData["links"] = setBlockLinks(block.links)
        
        db.collection("Users").document(currentUser.userID).collection("Blocks").document(block.blockID!).setData(blockData) { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                self.savePersonalBlockPhotosToStorage(block.blockID!, block.photos)
                
                self.savePersonalBlockVoiceMemosToStorage(block.blockID!, block.voiceMemos)
                
                completion(nil)
            }
        }
    }
    
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
    
    
    //MARK: - Edit Blocks
    
    func editPersonalBlock (block: Block, _ completion: @escaping ((_ error: Error?) -> Void)) {
        
        if let cachedBlock = cachedPersonalBlocks.first(where: { $0.blockID == block.blockID }) {
            
            editPersonalBlockPhotosSavedInStorage(cachedBlock: cachedBlock, editedBlock: block)
            
            editPersonalBlockVoiceMemosSavedInStorage(cachedBlock: cachedBlock, editedBlock: block)
            
            var blockData: [String : Any] = ["blockName" : block.name as Any, "startTime" : block.starts as Any, "endTime" : block.ends as Any, "photos" : block.photoIDs as Any]
            
            blockData["locations"] = setBlockLocations(block.locations)
            
            blockData["voiceMemos"] = setBlockVoiceMemos(block.voiceMemos)
            
            blockData["links"] = setBlockLinks(block.links)
            
            db.collection("Users").document(currentUser.userID).collection("Blocks").document(block.blockID!).updateData(blockData) { (error) in
                
                if error != nil {
                    
                    completion(error)
                }
                
                else {
                    
                    completion(nil)
                }
            }
        }
    }
    
    func editCollabBlock (collabID: String, block: Block, completion: @escaping ((_ error: Error?) -> Void)) {
        
        if let cachedBlock = cachedCollabBlocks.first(where: { $0.blockID == block.blockID }) {
            
            editCollabBlockPhotosSavedInStorage(collabID: collabID, cachedBlock: cachedBlock, editedBlock: block)
            
            editCollabBlockVoiceMemosSavedInStorage(collabID: collabID, cachedBlock: cachedBlock, editedBlock: block)
            
            var memberIDs: [String] = []
            block.members?.forEach({ memberIDs.append($0.userID) })
            
            var blockData: [String : Any] = ["blockName" : block.name as Any, "startTime" : block.starts as Any, "endTime" : block.ends as Any, "members" : memberIDs, "photos" : block.photoIDs as Any]
            
            blockData["locations"] = setBlockLocations(block.locations)
            
            blockData["voiceMemos"] = setBlockVoiceMemos(block.voiceMemos)
            
            blockData["links"] = setBlockLinks(block.links)
            
            db.collection("Collaborations").document(collabID).collection("Blocks").document(block.blockID!).updateData(blockData) { (error) in
                
                if error != nil {
                    
                    completion(error)
                }
                
                else {
                    
                    completion(nil)
                }
            }
        }
    }
    
    
    //MARK: - Set Block Locations
    
    private func setBlockLocations (_ locations: [Location]?) -> [String : [String : Any]]? {
        
        var locationsDict: [String : [String : Any]] = [:]
        
        for location in locations ?? [] {
            
            if let locationID = location.locationID {
                
                locationsDict[locationID] = ["coordinates" : location.coordinates as Any, "name" : location.name as Any, "number" : location.number as Any, "url" : location.url?.absoluteString as Any, "address" : ["streetNumber" : location.streetNumber, "streetName" : location.streetName, "city" : location.city, "state": location.state, "zipCode" : location.zipCode, "country" : location.country]]
            }
        }
        
        return locationsDict
    }
    
    
    //MARK: - Set Block Voice Memos
    
    private func setBlockVoiceMemos (_ voiceMemos: [VoiceMemo]?) -> [String : [String : Any]]? {
        
        var voiceMemosDict: [String : [String : Any]] = [:]
        
        for memo in voiceMemos ?? [] {
            
            if let memoID = memo.voiceMemoID {
                
                voiceMemosDict[memoID] = ["name" : memo.name as Any, "length" : memo.length as Any, "dateCreated" : memo.dateCreated as Any]
            }
        }
        
        return voiceMemosDict
    }
    
    
    //MARK: - Set Block Links
    
    private func setBlockLinks (_ links: [Link]?) -> [String : [String : String?]]? {
        
        var linksDict: [String : [String : String?]] = [:]
        
        for link in links ?? [] {
            
            if let linkID = link.linkID, let url = link.url {
                
                linksDict[linkID] = ["url" : url, "name" : link.name]
            }
        }
        
        return linksDict
    }
    
    
    //MARK: - Save Block Photos
    
    
    private func savePersonalBlockPhotosToStorage (_ blockID: String, _ photos: [String : UIImage?]?) {
        
        var count = 0
        
        for photo in photos ?? [:] {
            
            firebaseStorage.savePersonalBlockPhotosToStorage(blockID, photo.key, photo.value)
            
            count += 1
        }
    }
    
    private func saveCollabBlockPhotosToStorage (_ collabID: String, _ blockID: String, _ photos: [String : UIImage?]?) {
        
        var count = 0
        
        for photo in photos ?? [:] {
            
            firebaseStorage.saveCollabBlockPhotosToStorage(collabID, blockID, photo.key, photo.value)
            
            count += 1
        }
    }
    
    
    //MARK: - Edit Block Photos
    
    private func editPersonalBlockPhotosSavedInStorage (cachedBlock: Block, editedBlock: Block) {
        
        for photoID in cachedBlock.photoIDs ?? [] {
            
            //If a photo has been deleted
            if !(editedBlock.photoIDs?.contains(photoID) ?? false) {
                
                firebaseStorage.deletePersonalBlockPhoto(editedBlock.blockID ?? "", photoID) { (error) in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription as Any)
                    }
                }
            }
        }
        
        for photo in editedBlock.photos ?? [:] {
            
            //If a photo has been added
            if !(cachedBlock.photoIDs?.contains(photo.key) ?? false) {
                
                firebaseStorage.savePersonalBlockPhotosToStorage(editedBlock.blockID ?? "", photo.key, photo.value)
            }
        }
    }
    
    private func editCollabBlockPhotosSavedInStorage (collabID: String, cachedBlock: Block, editedBlock: Block) {
        
        for photoID in cachedBlock.photoIDs ?? [] {
            
            //If a photo has been deleted
            if !(editedBlock.photoIDs?.contains(photoID) ?? false) {
                
                firebaseStorage.deleteCollabBlockPhoto(collabID, editedBlock.blockID ?? "", photoID) { (error) in
                    
                    print(error?.localizedDescription as Any)
                }
            }
        }
        
        for photo in editedBlock.photos ?? [:] {
            
            //If a photo has been added
            if !(cachedBlock.photoIDs?.contains(photo.key) ?? false) {
                
                firebaseStorage.saveCollabBlockPhotosToStorage(collabID, editedBlock.blockID ?? "", photo.key, photo.value)
            }
        }
    }
    
    
    //MARK: - Save Block Voice Memos
    
    private func savePersonalBlockVoiceMemosToStorage (_ blockID: String, _ voiceMemos: [VoiceMemo]?) {
        
        for voiceMemo in voiceMemos ?? [] {
            
            firebaseStorage.savePersonalBlockVoiceMemosToStorage(blockID, voiceMemo.voiceMemoID ?? "")
        }
    }
    
    private func saveCollabBlockVoiceMemosToStorage (_ collabID: String, _ blockID: String, _ voiceMemos: [VoiceMemo]?) {
        
        for voiceMemo in voiceMemos ?? [] {
            
            firebaseStorage.saveCollabBlockVoiceMemosToStorage(collabID, blockID, voiceMemo.voiceMemoID ?? "")
        }
    }
    
    
    //MARK: - Edit Block Voice Memos
    
    private func editPersonalBlockVoiceMemosSavedInStorage (cachedBlock: Block, editedBlock: Block) {
        
        for voiceMemo in cachedBlock.voiceMemos ?? [] {
            
            //If a voice memo has been deleted
            if !(editedBlock.voiceMemos?.contains(where: { $0.voiceMemoID == voiceMemo.voiceMemoID }) ?? false) {
                
                firebaseStorage.deletePersonalBlockVoiceMemo(editedBlock.blockID ?? "", voiceMemoID: voiceMemo.voiceMemoID ?? "") { (error) in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription as Any)
                    }
                }
            }
        }
        
        for voiceMemo in editedBlock.voiceMemos ?? [] {
            
            //If a voice memo has been added
            if !(cachedBlock.voiceMemos?.contains(where: { $0.voiceMemoID == voiceMemo.voiceMemoID }) ?? false) {
                
                firebaseStorage.savePersonalBlockVoiceMemosToStorage(editedBlock.blockID ?? "", voiceMemo.voiceMemoID ?? "")
            }
        }
    }
    
    private func editCollabBlockVoiceMemosSavedInStorage (collabID: String, cachedBlock: Block, editedBlock: Block) {
        
        for voiceMemo in cachedBlock.voiceMemos ?? [] {
            
            //If a voice memo has been deleted
            if !(editedBlock.voiceMemos?.contains(where: { $0.voiceMemoID == voiceMemo.voiceMemoID }) ?? false) {
                
                firebaseStorage.deleteCollabBlockVoiceMemo(collabID, editedBlock.blockID ?? "", voiceMemo.voiceMemoID ?? "") { (error) in
                    
                    print(error?.localizedDescription as Any)
                }
            }
        }
        
        for voiceMemo in editedBlock.voiceMemos ?? [] {
            
            //If a voice memo has been added
            if !(cachedBlock.voiceMemos?.contains(where: { $0.voiceMemoID == voiceMemo.voiceMemoID }) ?? false) {
                
                firebaseStorage.saveCollabBlockVoiceMemosToStorage(collabID, editedBlock.blockID ?? "", voiceMemo.voiceMemoID ?? "")
            }
        }
    }
    
    
    //MARK: - Retrieve Blocks
    
    func retrievePersonalBlocks (_ completion: @escaping ((_ error: Error?, _ blocks: [Block]?) -> Void)) {
        
        personalBlocksListener = db.collection("Users").document(currentUser.userID).collection("Blocks").addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                
                completion(error, nil)
            }
            
            else {
                
                var blocks: [Block] = []
                
                for document in snapshot?.documents ?? [] {
                    
                    blocks.append(self.configureBlock(document))
                }
                
                self.cachedPersonalBlocks = blocks
                
                completion(nil, blocks)
            }
        })
    }
    
    func retrieveCollabBlocks (_ collab: Collab, completion: @escaping ((_ error: Error?, _ blocks: [Block]?) -> Void)) {
        
        collabBlocksListener = db.collection("Collaborations").document(collab.collabID).collection("Blocks").addSnapshotListener { (snapshot, error) in
            
            if error != nil {
                
                completion(error, nil)
            }
            
            else {
                
                var blocks: [Block] = []
                
                for document in snapshot?.documents ?? [] {
        
                    blocks.append(self.configureBlock(collab: collab, document))
                }
                
                self.cachedCollabBlocks = blocks
                
                completion(nil, blocks)
            }
        }
    }
    
    
    //MARK: - Configure Block
    
    private func configureBlock (collab: Collab? = nil, _ document: DocumentSnapshot) -> Block {
        
        var block = Block()
        
        block.blockID = document.documentID
        
        block.creator = document.data()?["creator"] as? String
        
        let dateCreated = document.data()?["dateCreated"] as! Timestamp
        block.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreated.seconds))
        
        block.name = document.data()?["blockName"] as? String
        
        let starts = document.data()?["startTime"] as! Timestamp
        let ends = document.data()?["endTime"] as! Timestamp
        
        block.starts = Date(timeIntervalSince1970: TimeInterval(starts.seconds))
        block.ends = Date(timeIntervalSince1970: TimeInterval(ends.seconds))

        block.members = []
        
        for retrievedMember in document.data()?["members"] as? [String] ?? [] {
            
            if let member = collab?.currentMembers.first(where: { $0.userID == retrievedMember }) {
                
                block.members?.append(member)
            }
        }
        
        block.photoIDs = document.data()?["photos"] as? [String]

        block.locations = self.retrieveBlockLocations(document.data()?["locations"] as? [String : Any])
        
        block.voiceMemos = self.retrieveBlockVoiceMemos(document.data()?["voiceMemos"] as? [String : Any])
        
        block.links = self.retrieveBlockLinks(document.data()?["links"] as? [String : Any])
        
        let statusArray: [String : BlockStatus] = ["notStarted" : .notStarted, "inProgress" : .inProgress, "completed" : .completed, "needsHelp" : .needsHelp, "late" : .late]
        
        if let blockStatus = document.data()?["status"] as? String, let status = statusArray[blockStatus] {
            
            block.status = status
        }
        
        return block
    }
    
    
    //MARK: - Retrieve Block Locations
    
    private func retrieveBlockLocations (_ locations: [String : Any]?) -> [Location]? {
        
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
    
    
    //MARK: - Retrieve Block Voice Memos
    
    private func retrieveBlockVoiceMemos (_ voiceMemos: [String : Any]?) -> [VoiceMemo]? {
        
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
    
    
    //MARK: - Retrieve Block Links
    
    private func retrieveBlockLinks (_ links: [String : Any]?) -> [Link]? {
        
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
    
    
    //MARK: - Set Block Status
    
    func setPersonalBlockStatus (_ blockID: String, _ status: BlockStatus, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let statusArray: [BlockStatus : String] = [.notStarted : "notStarted", .inProgress : "inProgress", .completed : "completed", .needsHelp : "needsHelp", .late : "late"]
        
        db.collection("Users").document(currentUser.userID).collection("Blocks").document(blockID).updateData(["status" : statusArray[status] as Any]) { (error) in
            
            if error != nil {
                
                completion(error)
            }
        }
    }
    
    func setCollabBlockStatus (_ collabID: String, blockID: String, status: BlockStatus, completion: @escaping ((_ error: Error?) -> Void)) {
        
        let statusArray: [BlockStatus : String] = [.notStarted : "notStarted", .inProgress : "inProgress", .completed : "completed", .needsHelp : "needsHelp", .late : "late"]
        
        db.collection("Collaborations").document(collabID).collection("Blocks").document(blockID).updateData(["status" : statusArray[status] as Any]) { (error) in
            
            if error != nil {
                
                completion(error)
            }
        }
    }
    
    
    //MARK: - Monitor Collab Block
    
    func monitorCollabBlock (_ collab: Collab, _ blockID: String, completion: @escaping ((_ block: Block?, _ error: Error?) -> Void)) {

        blockListener = db.collection("Collaborations").document(collab.collabID).collection("Blocks").document(blockID).addSnapshotListener { (snapshot, error) in

            if error != nil {

                completion(nil, error)
            }

            else {
                
                if let snapshotData = snapshot?.data() {

                    var block = Block()
                    
                    block.blockID = snapshot?.documentID

                    block.creator = snapshotData["creator"] as? String

                    let dateCreated = snapshotData["dateCreated"] as! Timestamp
                    block.dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreated.seconds))

                    block.name = snapshotData["blockName"] as? String

                    let starts = snapshotData["startTime"] as! Timestamp
                    let ends = snapshotData["endTime"] as! Timestamp

                    block.starts = Date(timeIntervalSince1970: TimeInterval(starts.seconds))
                    block.ends = Date(timeIntervalSince1970: TimeInterval(ends.seconds))

                    block.members = []

                    for retrievedMember in snapshotData["members"] as? [String] ?? [] {

                        if let member = collab.currentMembers.first(where: { $0.userID == retrievedMember }) {
                            
                            block.members?.append(member)
                        }
                    }

                    block.photoIDs = snapshotData["photos"] as? [String]

                    block.locations = self.retrieveBlockLocations(snapshotData["locations"] as? [String : Any])

                    block.voiceMemos = self.retrieveBlockVoiceMemos(snapshotData["voiceMemos"] as? [String : Any])

                    block.links = self.retrieveBlockLinks(snapshotData["links"] as? [String : Any])

                    let statusArray: [String : BlockStatus] = ["notStarted" : .notStarted, "inProgress" : .inProgress, "completed" : .completed, "needsHelp" : .needsHelp, "late" : .late]

                    if let blockStatus = snapshotData["status"] as? String, let status = statusArray[blockStatus] {

                        block.status = status
                    }
                    
                    completion(block, nil)
                }
                
                else {
                    
                    completion(nil, nil)
                }
            }
        }
    }
    
    
    //MARK: - Delete Block
    
    func deletePersonalBlock (_ block: Block, completion: @escaping ((_ error: Error?) -> Void)) {
        
        db.collection("Users").document(currentUser.userID).collection("Blocks").document(block.blockID ?? "").delete { (error) in
            
            if error != nil {
                
                completion(error)
            }
            
            else {
                
                self.deletePersonalBlockPhotos(block)
                
                self.deletePersonalBlockVoiceMemos(block)
                
                completion(nil)
            }
        }
    }
    
    func deleteCollabBlock (_ collabID: String, _ block: Block, completion: @escaping ((_ error: Error?) -> Void)) {
        
        db.collection("Collaborations").document(collabID).collection("Blocks").document(block.blockID ?? "").delete { (error) in

            if error != nil {

                completion(error)
            }

            else {

                self.deleteCollabBlockPhotos(collabID, block)
                
                self.deleteCollabBlockVoiceMemos(collabID, block)
                
                completion(nil)
            }
        }
    }
    
    
    //MARK: - Delete Block Photos
    
    private func deletePersonalBlockPhotos (_ block: Block) {
        
        for photoID in block.photoIDs ?? [] {
            
            firebaseStorage.deletePersonalBlockPhoto(block.blockID ?? "", photoID) { (error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    
    private func deleteCollabBlockPhotos (_ collabID: String, _ block: Block) {
        
        for photoID in block.photoIDs ?? [] {
            
            firebaseStorage.deleteCollabBlockPhoto(collabID, block.blockID ?? "", photoID) { (error) in
                
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    
    //MARK: - Delete Block Voice Memos
    
    private func deletePersonalBlockVoiceMemos (_ block: Block) {
        
        for voiceMemo in block.voiceMemos ?? [] {
            
            firebaseStorage.deletePersonalBlockVoiceMemo(block.blockID ?? "", voiceMemoID: voiceMemo.voiceMemoID ?? "") { (error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    
    private func deleteCollabBlockVoiceMemos (_ collabID: String, _ block: Block) {
        
        for voiceMemo in block.voiceMemos ?? [] {
            
            firebaseStorage.deleteCollabBlockVoiceMemo(collabID, block.blockID ?? "", voiceMemo.voiceMemoID ?? "") { (error) in
                
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    
    //MARK: - Remove Inactive Block Members
    
    func removeInactiveCollabBlockMembers (collabID: String, currentCollabMembers: [String]) {
        
        let batch = db.batch()
        
        for block in cachedCollabBlocks {
            
            var membersRemoved: Bool = false
            var members: [String] = []
            block.members?.forEach({ members.append($0.userID) })
            
            members.removeAll(where: { (member) -> Bool in
                
                if currentCollabMembers.contains(where: { $0 == member }) == false {
                    
                    membersRemoved = true
                    return true
                }
                
                else {
                    
                    return false
                }
            })
            
            if membersRemoved {
                
                batch.updateData(["members" : members], forDocument: db.collection("Collaborations").document(collabID).collection("Blocks").document(block.blockID ?? ""))
            }
        }
        
        batch.commit()
    }
}
