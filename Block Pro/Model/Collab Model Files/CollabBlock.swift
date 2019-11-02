//
//  CollabBlock.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/1/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation

class CollabBlock {
    
    var blockID: String = ""
    
    var creator: [String : String] = ["userID" : "", "firstName" : "", "lastName" : ""]
    var name: String = ""
    var blockCategory: String = ""
    
    var startHour: String = ""
    var startMinute: String = ""
    var startPeriod: String = ""
    
    var endHour: String = ""
    var endMinute: String = ""
    var endPeriod: String = ""
    
    var notificationSettings: [String : [String : Any]] = [:]
}
