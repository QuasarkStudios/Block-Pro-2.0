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
 
    @objc dynamic var name: String = ""
    @objc dynamic var start: String = ""
    @objc dynamic var end: String = ""
    //@objc dynamic var color: String = ""
}
