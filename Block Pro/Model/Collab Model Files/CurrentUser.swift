//
//  UserSingleton.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/19/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation

class CurrentUser {
    
    var userID: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var username: String = ""
    var accountCreated: String = ""
    
    var profilePictureURL: String?
    var profilePictureImage: UIImage?
    
    static let sharedInstance = CurrentUser()
}