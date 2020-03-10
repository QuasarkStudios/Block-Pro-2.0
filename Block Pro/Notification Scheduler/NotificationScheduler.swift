//
//  NotificationScheduler.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/7/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationScheduler {
    
    func scheduleBlockNotificiation (_ blockDict: [String : Any]) {
        
        let formatter = DateFormatter()
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        let content = UNMutableNotificationContent()
        let trigger: UNCalendarNotificationTrigger
        let request: UNNotificationRequest
        
        let notificationDate: Date = blockDict["begins"] as! Date
        
        formatter.dateFormat = "yyyy"
        dateComponents.year = Int(formatter.string(from: notificationDate))!
        
        formatter.dateFormat = "MM"
        dateComponents.month = Int(formatter.string(from: notificationDate))
        
        formatter.dateFormat = "d"
        dateComponents.day = Int(formatter.string(from: notificationDate))!
        
        var notificationTime : Date = blockDict["begins"] as! Date
        notificationTime = notificationTime.addingTimeInterval(blockDict["minsBefore"] as! Double)
        
        formatter.dateFormat = "HH"
        dateComponents.hour = Int(formatter.string(from: notificationTime))!
        
        formatter.dateFormat = "mm"
        dateComponents.minute = Int(formatter.string(from: notificationTime))!

        formatter.dateFormat = "h:mm a"
        
        content.title = "Heads Up!!"
        content.body = "\(blockDict["name"] ?? "Block") at \(formatter.string(from: notificationDate))"
        content.sound = UNNotificationSound.default
        
        trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        request = UNNotificationRequest(identifier: blockDict["notificationID"] as! String, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func removePendingNotification () {
        
    }
}
