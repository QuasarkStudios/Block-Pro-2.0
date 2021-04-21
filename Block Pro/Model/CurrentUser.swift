//
//  UserSingleton.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/19/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation

class CurrentUser {
    
    var userSignedIn: Bool = false
    
    var userID: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var username: String = ""
    var accountCreated: Date?
    
    var profilePictureRetrieved: Bool = false
    var profilePictureImage: UIImage?
    
    var fcmToken: String = ""
    
    static let sharedInstance = CurrentUser()
}
