//
//  Message.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

struct Message {
    
    var sender: String = ""
    var message: String = ""
    var timestamp: Date!
    
    var readBy: [Member]?
}
