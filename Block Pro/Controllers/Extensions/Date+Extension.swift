//
//  Date+Extension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/18/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

extension Date {
    
    func daySuffix() -> String {

        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: self)
        
        switch dayOfMonth {
            
        case 1, 21, 31:
            return "st"
            
        case 2, 22:
            return "nd"
            
        case 3, 23:
            return "rd"
            
        default:
            return "th"
        }
    }
    
    func isBetween (startDate: Date, endDate: Date) -> Bool {
        
        if self > startDate && self < endDate {
            
            return true
        }
        
        else {
            return false
        }

        return (startDate ... endDate).contains(self)
        
        return (min(startDate, endDate) ... max(startDate, endDate)).contains(self)
    }
    
    func determineNumberOfWeeks () -> Int {
        
        let calendar = Calendar.current
        
        let interval = calendar.dateInterval(of: .month, for: self)
        
        let days = calendar.dateComponents([.day], from: interval!.start, to: interval!.end).day!
        
        let startOfMonth = interval!.start
        
        var loopCount: Int = 0
        var weekCount: Int = 0
        
        while loopCount < days {
            
            let currentDate: Date = calendar.date(byAdding: .day, value: loopCount, to: startOfMonth)!
            
            if (calendar.component(.weekday, from: currentDate) == 7) && (loopCount + 1 != days) {
                
                weekCount += 1
            }
            
            loopCount += 1
        }
        
        return weekCount
    }
}
