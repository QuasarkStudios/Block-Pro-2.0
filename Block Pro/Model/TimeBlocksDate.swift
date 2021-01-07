//
//  TimeBlocksDate.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/5/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation
import RealmSwift

class TimeBlocksDate: Object {
    
    @objc dynamic var timeBlocksDate: String = ""
    
    let timeBlocks = List<Block2>()
}
