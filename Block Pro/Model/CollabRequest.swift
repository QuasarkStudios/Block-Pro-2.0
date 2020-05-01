//
//  CollabRequest.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

struct CollabRequest {
    
    var collabID: String = ""
    
    var name: String = ""
    var objective: String = ""
    var members: [Member] = []
    var dates: [String : Date] = [:]
    var reminder: [String : Date] = [:]
}
