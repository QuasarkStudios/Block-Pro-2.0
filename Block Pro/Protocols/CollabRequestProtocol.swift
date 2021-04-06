//
//  CollabRequestProtocol.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/4/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

protocol CollabRequestProtocol: AnyObject {
    
    func acceptCollabRequest (_ collabRequest: Collab)
    
    func declineCollabRequest ( _ collabRequest: Collab)
}
