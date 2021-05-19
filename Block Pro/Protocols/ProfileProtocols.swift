//
//  ProfileProtocols.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/14/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

protocol ProfileProtocol: AnyObject {
    
    func profilePictureEdited (profilePic: UIImage?)
    
    func presentFriends ()
}
