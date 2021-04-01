//
//  Notification+Extension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/22/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation


extension Notification.Name {
    
    static let didDownloadProfilePic = Notification.Name("didDownloadProfilePic")
    
    static let userDidSendMessage = Notification.Name("userDidSendMessage")
    
    static let userDidAddMessageAttachment = Notification.Name("userDidAddMessageAttachment")
    
    static let didUpdateFriends = Notification.Name("didUpdateFriends")
}
