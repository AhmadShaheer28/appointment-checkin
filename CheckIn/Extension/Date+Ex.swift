//
//  Date+Ex.swift
//  TennisFood
//
//  Created by Ahmad Shaheer on 18/09/2024.
//

import Foundation


extension Date {
    func convert(to format: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: self)
    }
    
    func toString(format: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: self)
    }

    
    func getDateValue() -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dateToCompare = calendar.startOfDay(for: self)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if dateToCompare == today {
            return NSLocalizedString("label_status_today", comment: "")
            
        } else if dateToCompare == yesterday {
            return NSLocalizedString("label_status_yesterday", comment: "")
            
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            return dateFormatter.string(from: self)
        }
    }
    
    enum DateStatus {
        case today
        case isPast
        case isUpcoming
    }
    
    func timeDueDisplay() -> (DateStatus, String) {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1 // Show only the largest unit (e.g., "2 hours" instead of "2 hours 5 minutes")
        
        let currentDate = Date()
        

        if let remainingTimeString = formatter.string(from: currentDate, to: self) {
            return (.isUpcoming, remainingTimeString)
        } else {
            return (.today, "")
        }
        
    }
}
