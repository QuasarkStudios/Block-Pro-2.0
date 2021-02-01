//
//  Block.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/29/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

struct Block {
    
    var blockID: String?
    
    var creator: String?
    
    var dateCreated: Date?
    
    var name: String?
    
    var starts: Date?
    var ends: Date?
    
    var members: [Member]?
    
    var reminders: [Int]?
    
    var photoIDs: [String]?
    var photos: [String : UIImage?]?
    
    var locations: [Location]?
    
    var voiceMemos: [VoiceMemo]?
    
    var links: [Link]?
    
    var position: BlockPosition = .centered
    
    var status: BlockStatus?
}
