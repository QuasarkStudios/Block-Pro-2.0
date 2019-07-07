//
//  Block.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/19/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation
import RealmSwift

class Block: Object {
 
    @objc dynamic var blockID = UUID().uuidString
    @objc dynamic var notificationID: String = ""
    
    @objc dynamic var name: String = ""
    @objc dynamic var blockCategory: String = ""
    
    @objc dynamic var startHour: String = ""
    @objc dynamic var startMinute: String = ""
    @objc dynamic var startPeriod: String = ""
    
    @objc dynamic var endHour: String = ""
    @objc dynamic var endMinute: String = ""
    @objc dynamic var endPeriod: String = ""
    
    @objc dynamic var note1: String = ""
    @objc dynamic var note2: String = ""
    @objc dynamic var note3: String = ""
    
    var dateForTimeBlock = LinkingObjects(fromType: TimeBlocksDate.self, property: "timeBlocks")
    
    override static func primaryKey() -> String? {
        return "blockID"
    }
}
