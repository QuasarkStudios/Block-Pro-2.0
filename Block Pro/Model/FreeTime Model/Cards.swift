//
//  Cards.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/22/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation
import RealmSwift

class Card: Object {
    
    @objc dynamic var taskLength: String = ""
    
    let tasks = List<Task>()
}
