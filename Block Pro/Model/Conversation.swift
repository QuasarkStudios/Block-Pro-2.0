//
//  Conversation.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/22/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

struct Conversation {
    
    var conversationID: String = ""
    var conversationName: String?
    
    var coverPhotoID: String?
    var conversationCoverPhoto: UIImage?
    
    var dateCreated: Date?
    
    var messagePreview: Message?
    var messagePreviewLoaded: Bool = false
    
    var currentMembersIDs: [String] = []
    var currentMembers: [Member] = []
    var historicMembers: [Member] = []
    var membersLoaded: Bool = false
    
    var memberGainedAccessOn: [String : Any]?
    var memberActivity: [String : Any]?
    
    var accepted: [String: Bool?]?
}
