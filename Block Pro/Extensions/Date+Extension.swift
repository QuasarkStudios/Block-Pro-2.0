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
    
    //Func used to to ensure that time in the TimeConfigurationCells goes by 5 minute increments
    func adjustTime (roundDown: Bool) -> Date {
        
        var dateComponents = Calendar.current.dateComponents(in: .current, from: self)
    
        if let hour = dateComponents.hour, let minutes = dateComponents.minute {
            
            //If the current time is already in a increment of 5
            if minutes % 5 == 0 {
                
                //If the time should be rounded down, signifying that it is for a start TimeConfigurationCell
                if roundDown {
                    
                    //If the current time is 11:55 PM
                    if hour == 23 && minutes == 55 {
                        
                        //The start time should be moved back to 11:50 PM to allow the end time to be set to 11:55 PM
                        return Calendar.current.date(byAdding: .minute, value: -5, to: self) ?? Date()
                    }
                    
                    else {
                        
                        //Returning the current time because it is already properly configured
                        return self
                    }
                }
                
                //If the time should be rounded up, signifying that it is for a end TimeConfigurationCell
                else {
                    
                    //If the current time is 11:55 PM
                    if hour == 23 && minutes == 55 {
                        
                        //Returning the current time because it is already properly configured
                        return self
                    }
                    
                    else {
                        
                        //Incrementing the current time by 5 minutes because the end time should be 5 minutes after the start time
                        return Calendar.current.date(byAdding: .minute, value: 5, to: self) ?? Date()
                    }
                }
            }

            //If the current time isn't already in a increment of 5
            else {

                //If the time should be rounded down, signifying that it is for a start TimeConfigurationCell
                if roundDown {
                    
                    //Rounding down the current time
                    dateComponents = Calendar.current.dateComponents(in: .current, from: self.addingTimeInterval(-(Double((minutes % 5) * 60))))
                    
                    if let adjustedHour = dateComponents.hour, let adjustedMinutes = dateComponents.minute {
                        
                        //If the adjusted time is 11:55 PM
                        if adjustedHour == 23 && adjustedMinutes == 55 {
                            
                            //The start time should be moved back to 11:50 PM to allow the end time to be set to 11:55 PM
                            return Calendar.current.date(byAdding: .minute, value: -5, to: dateComponents.date ?? Date()) ?? Date()
                        }
                        
                        else {
                            
                            return dateComponents.date ?? Date()
                        }
                    }
                }
                
                else {
                    
                    //Rounding up the current time
                    dateComponents = Calendar.current.dateComponents(in: .current, from: self.addingTimeInterval((Double((5 - (minutes % 5)) * 60))))
                    
                    if let adjustedHour = dateComponents.hour, let adjustedMinutes = dateComponents.minute {
                        
                        //If the adjusted time is 12:00 AM
                        if adjustedHour == 0 && adjustedMinutes == 0 {
                            
                            //The end time should be moved back to 11:55 PM
                            return Calendar.current.date(byAdding: .minute, value: -5, to: dateComponents.date ?? Date()) ?? Date()
                        }
                        
                        else {
                            
                            return dateComponents.date ?? Date()
                        }
                    }
                }
            }
        }

        return Date() //Default
    }
}
