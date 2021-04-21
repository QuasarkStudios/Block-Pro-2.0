//
//  SidebarProtocol.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/18/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

protocol SidebarProtocol: AnyObject {
    
    func moveToProfileView ()
    
    func moveToFriendsView ()
    
    func moveToPrivacyView ()
    
    func userSignedOut ()
}
