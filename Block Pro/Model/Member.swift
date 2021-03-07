//
//  Member.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/23/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

struct Member {
    
    var userID: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var username: String = ""
    var role: String = ""
    
    var accepted: Bool?
    var dateJoined: Date?
    
    var profilePictureImage: UIImage?
}
