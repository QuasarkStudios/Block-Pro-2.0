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

protocol MemberConfigurationProtocol: AnyObject {
    
    func moveToAddMemberView ()
    
    func memberDeleted (_ userID: String)
}

protocol ReminderConfigurationProtocol: AnyObject {
    
    func reminderSelected (_ selectedReminders: [Int])
    
    func reminderDeleted (_ deletedReminder: Int) 
}

protocol PhotosConfigurationProtocol: AnyObject {
    
    func presentAddPhotoAlert ()
}

protocol LocationsConfigurationProtocol: AnyObject {
    
    func attachLocationSelected()
}

protocol VoiceMemosConfigurationProtocol: AnyObject {
    
    func attachMemoSelected()
    
    func recordingCancelled()
    
    func voiceMemoSaved(_ voiceMemo: VoiceMemo)
    
    func voiceMemoNameChanged (_ voiceMemoID: String, _ name: String?)
    
    func voiceMemoDeleted (_ voiceMemo: VoiceMemo)
}

protocol LinksConfigurationProtocol: AnyObject {
    
    func attachLinkSelected ()
    
    func linkEntered (_ linkID: String, _ url: String)
    
    func linkIconSaved (_ linkID: String, _ icon: UIImage?)
    
    func linkRenamed (_ linkID: String, _ name: String)
    
    func linkDeleted (_ linkID: String)
}
