//
//  CollabMemberProtocol.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/22/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

protocol CollabMemberProtocol: AnyObject {
    
    func moveToProfileView (_ member: Member, _ memberContainerView: UIView)
}
