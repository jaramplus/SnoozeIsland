//
//  Date+Extension.swift
//  SnoozeIsland
//
//  Created by jose Yun on 2/2/25.
//

import Foundation

extension Date {
    func formattedTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // Format for hours and minutes
        return dateFormatter.string(from: self)
    }
}

extension Date {
    // Function to return a new Date with the same time (hour, minute, second)
    // but the year, month, and day set to today's date.
    func setToTodayWithSameTime() -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) // Get today's date at midnight
        let components = calendar.dateComponents([.year, .month, .day], from: today)
        
        // Merge today's year, month, and day with the current time (hour, minute, second)
        let newDate = calendar.date(bySettingHour: calendar.component(.hour, from: self),
                                    minute: calendar.component(.minute, from: self),
                                    second: calendar.component(.second, from: self),
                                    of: calendar.date(from: components)!)
        
        return newDate!
    }
}
