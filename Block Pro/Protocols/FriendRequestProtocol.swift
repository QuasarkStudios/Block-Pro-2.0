//
//  FriendRequestProtocol.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/31/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

protocol FriendRequestProtocol: AnyObject {
    
    func acceptFriendRequest (_ friendRequest: Friend)
    
    func declineFriendRequest ( _ friendRequest: Friend)
}
