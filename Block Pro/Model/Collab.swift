//
//  NewCollab.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/11/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

struct Collab {
    
    var collabID: String = ""
    var creator: String?
    var dateCreated: Date?
    
    var name: String = ""
    var objective: String?
    
    var coverPhotoID: String?
    var coverPhoto: UIImage?
    
    var dates: [String : Date] = [:]
    
    var addedMembers: [Any] = []
    
    var currentMembersIDs: [String] = []
    var currentMembers: [Member] = []
    var historicMembers: [Member] = []
    
    var memberActivity: [String : Any]?
    
    var reminders: [Int] = []
    
    var photoIDs: [String] = []
    var photos: [String : UIImage?] = [:]
    
    var locations: [Location]?
    
    var voiceMemos: [VoiceMemo]?
    
    var links: [Link]?
    
    var accepted: Bool?
    var requestSentBy: String = ""
    var requestSentOn: Date?
}
