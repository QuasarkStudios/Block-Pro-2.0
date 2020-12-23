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
    var name: String = ""
    var dateCreated: Date?
    
    var coverPhotoID: String?
    var coverPhoto: UIImage?
    
    var objective: String?
    
    var members: [Member] = []
    var memberActivity: [String : Any]?
    
    var dates: [String : Date] = [:]
    var reminders: [String : Date] = [:]
    
    var photoIDs: [String] = []
    var photos: [String : UIImage?] = [:]
    
    var locations: [Location]?
    
    var voiceMemos: [VoiceMemo]?
    
    var links: [Link]?
}
