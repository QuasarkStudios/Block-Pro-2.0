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
    var dateCreated: Date?
    
    var messagePreview: Message?
    var members: [Member] = []
    
}
