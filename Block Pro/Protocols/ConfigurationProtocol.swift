//
//  ConfigurationProtocol.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/29/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

protocol NameConfigurationProtocol: AnyObject {
    
    func nameEntered (_ text: String)
}

protocol TimeConfigurationProtocol: AnyObject {
    
    func presentCalendar (startsCalendar: Bool)
    
    func dismissCalendar (startsCalendar: Bool)
    
    func expandCalendarCellHeight (expand: Bool)
    
    func timeEntered (startTime: Date?, endTime: Date?)
}
