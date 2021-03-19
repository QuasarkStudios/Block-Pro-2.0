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
    
    func scheduleCollabNotifications (collab: Collab) {
        
        let content = UNMutableNotificationContent()
        var trigger: UNCalendarNotificationTrigger
        var request: UNNotificationRequest
        
        for reminder in collab.reminders {
            
            if let startTime = collab.dates["startTime"], let reminderDate = calendar.date(byAdding: .minute, value: minutesToSubtractBy[reminder], to: startTime), Date() < reminderDate {
                
                var dateComponents = DateComponents()
                dateComponents.calendar = .current
                
                dateComponents.year = calendar.dateComponents(in: .current, from: reminderDate).year
                dateComponents.month = calendar.dateComponents(in: .current, from: reminderDate).month
                dateComponents.day = calendar.dateComponents(in: .current, from: reminderDate).day
                dateComponents.hour = calendar.dateComponents(in: .current, from: reminderDate).hour
                dateComponents.minute = calendar.dateComponents(in: .current, from: reminderDate).minute
                
                formatter.dateFormat = "h:mm a"
                
                content.title = "Heads Up!!"
                content.body =  "\(collab.name) at \(formatter.string(from: startTime))"
                content.sound = UNNotificationSound.default
                
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                request = UNNotificationRequest(identifier: "collabID: " + (collab.collabID) + "-\(reminder)", content: content, trigger: trigger)
        
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }
    
    func scheduleBlockNotifications (collab: Collab? = nil, _ block: Block) {
        
        for reminder in block.reminders ?? [] {
            
            if let startTime = block.starts, let reminderDate = calendar.date(byAdding: .minute, value: minutesToSubtractBy[reminder], to: startTime), Date() < reminderDate {
                
                let content = UNMutableNotificationContent()
                var trigger: UNCalendarNotificationTrigger
                var request: UNNotificationRequest
                
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
        
                if collab != nil {
                    
                    request = UNNotificationRequest(identifier: "collabID: \(collab!.collabID)" + " - " + "blockID: \(block.blockID!)" + "-\(reminder)", content: content, trigger: trigger)
                }
                
                else {
                    
                    request = UNNotificationRequest(identifier: "blockID: \(block.blockID!)" + "-\(reminder)", content: content, trigger: trigger)
                }
        
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }
    
    func getPendingNotifications (completion: @escaping ((_ requests: [UNNotificationRequest]) -> Void)) {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            
            completion(requests)
        }
    }
    
    func removePendingCollabNotifications (collabID: String, completion: @escaping (() -> Void)) {
        
        getPendingNotifications { (requests) in
            
            var pendingNotificationRequests: [String] = []
            
            for request in requests {
                
                if request.identifier.contains(collabID) && !request.identifier.contains("blockID:") {
                    
                    pendingNotificationRequests.append(request.identifier)
                }
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: pendingNotificationRequests)

            completion()
        }
    }
    
    func removePendingBlockNotifications (_ blockID: String, completion: @escaping (() -> Void)) {
        
        getPendingNotifications { (requests) in
            
            var pendingNotificationRequests: [String] = []
            
            for request in requests {
                
                if request.identifier.contains(blockID) {
                    
                    pendingNotificationRequests.append(request.identifier)
                }
            }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: pendingNotificationRequests)

            completion()
        }
    }
    
    func removeNotifications (identifers: [String]) {
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifers)
    }
}
