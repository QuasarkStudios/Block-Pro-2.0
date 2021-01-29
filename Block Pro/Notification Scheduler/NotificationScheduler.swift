//
//  NotificationScheduler.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/7/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
//import UserNotifications

class NotificationScheduler {
    
    let formatter = DateFormatter()
    var calendar = Calendar.current
    
    func scheduleBlockNotification (collab: Collab? = nil, _ block: Block) {
        
        if let startTime = block.starts, startTime > Date() {
            
            let content = UNMutableNotificationContent()
            var trigger: UNCalendarNotificationTrigger
            var request: UNNotificationRequest
            
            for reminder in block.reminders ?? [] {
                
                if let reminderDate = calendar.date(byAdding: .minute, value: minutesToSubtractBy[reminder], to: startTime) {
                    
                    var dateComponents = DateComponents()
                    dateComponents.calendar = .current
                    
                    dateComponents.year = calendar.dateComponents(in: .current, from: reminderDate).year
                    dateComponents.month = calendar.dateComponents(in: .current, from: reminderDate).month
                    dateComponents.day = calendar.dateComponents(in: .current, from: reminderDate).day
                    dateComponents.hour = calendar.dateComponents(in: .current, from: reminderDate).hour
                    dateComponents.minute = calendar.dateComponents(in: .current, from: reminderDate).minute
                    
                    formatter.dateFormat = "h:mm a"
                    
                    content.title = collab?.name ?? "Heads Up!!"
                    content.body =  "\(block.name ?? "Block") at \(formatter.string(from: startTime))"
                    content.sound = UNNotificationSound.default
                    
                    trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
                    request = UNNotificationRequest(identifier: (collab?.collabID ?? "") + " - " + block.blockID! + "-\(reminder)", content: content, trigger: trigger)
            
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//
//            UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
//
//                requests.forEach({ print($0) })
//            }
//        }
    }
    
    func scheduleBlockNotificiation2 (_ blockDict: [String : Any]) {

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
    
    func getPendingNotifications (completion: @escaping ((_ requests: [UNNotificationRequest]) -> Void)) {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            
            completion(requests)
        }
    }
    
    func removePendingBlockNotifications (_ blockID: String, completion: @escaping (() -> Void)) {
        
        getPendingNotifications { (requests) in
            
            var pendingNotificationIdentifiers: [String] = []
            
            for request in requests {
                
                if request.identifier.contains(blockID) {
                    
                    pendingNotificationIdentifiers.append(request.identifier)
                }
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: pendingNotificationIdentifiers)
            
            completion()
        }
    }
}
