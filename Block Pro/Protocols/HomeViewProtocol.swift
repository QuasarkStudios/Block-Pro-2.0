//
//  HomeViewProtocol.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/11/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

protocol HomeViewProtocol: AnyObject {
    
    func collabCreated (_ collabID: String)
    
    func moveToPersonalScheduleView ()
}
