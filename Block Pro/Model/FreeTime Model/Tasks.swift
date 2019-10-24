//
//  Tasks.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/22/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    
    @objc dynamic var taskID = UUID().uuidString
    
    @objc dynamic var name: String = ""
    @objc dynamic var dateCreated: Date?
    @objc dynamic var done: Bool = false
    
    var lengthOfTask = LinkingObjects(fromType: Card.self, property: "tasks")
    
    override static func primaryKey() -> String {
        return "taskID"
    }
}
