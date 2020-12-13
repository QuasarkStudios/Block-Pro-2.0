//
//  NewCollab.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/23/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

struct NewCollab {
    
    var collabID: String = ""
    
    var name: String = ""
    var objective: String?
    var members: [Friend] = []
    var dates: [String : Date] = [:]
    var reminders: [String : Date] = [:]
    
    var photos: [UIImage]?
    var locations: [Location]?
    var voiceMemos: [VoiceMemo]?
    var links: [Link]?
}
