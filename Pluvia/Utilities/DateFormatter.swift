//
//  DateFormatter.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import Foundation

/*  class with closures to convert the unix time from json into differents readable date formats
*/
class DateFormatterUtils {

    static let shared: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return dateFormatter
    }()

    static let shortDateFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()

    static let timeFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
    }()

    static let customFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    static func formattedDate(from timestamp: Int, format: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    static func formattedCurrentDate(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
    }

    static func formattedDateWithStyle(from timestamp: Int, style: DateFormatter.Style) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: date)
    }

    static func formattedDate12Hour(from timestamp: TimeInterval) -> String {
            let date = Date(timeIntervalSince1970: timestamp)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            return dateFormatter.string(from: date)
    }
    
    static func formattedDate12Hour(from timestamp: TimeInterval, timeZone: TimeZone) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = timeZone // Set the timezone dynamically
        return dateFormatter.string(from: date)
    }
    
    static func formattedDynamicDateHour(from timestamp: TimeInterval, timeZone: TimeZone) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = uses12HourClock() ? "h:mm a" : "HH:mm" // Dynamically choose format
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: date)
    }
    
    static func formattedDynamicHour(from timeInterval: TimeInterval, timeZone: TimeZone) -> String {
            let formatter = DateFormatter()
            formatter.timeZone = timeZone
            formatter.dateFormat = uses12HourClock() ? "ha" : "HH" // Choose format dynamically
            return formatter.string(from: Date(timeIntervalSince1970: timeInterval))
        }

    static func formattedDateWithDay(from timestamp: TimeInterval) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh a E"
            let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
            return dateString
    }

    static func formattedDateWithWeekdayAndDay(from timestamp: TimeInterval) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE dd"
            return dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    }


    static func formattedDateTime(from timestamp: TimeInterval) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy 'at' h a"
            return dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
    
    // Helper method to determine if the user prefers a 12-hour or 24-hour clock
        static func uses12HourClock() -> Bool {
            let locale = Locale.current
            let formatter = DateFormatter()
            formatter.locale = locale
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            let dateString = formatter.string(from: Date())
            return dateString.contains("AM") || dateString.contains("PM")
        }


}

