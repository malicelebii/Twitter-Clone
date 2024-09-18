//
//  DateCalculator.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 18.09.2024.
//

import Foundation

struct DateCalculator {
    static let shared = DateCalculator()
    
    func timeDifference(from startDateString: String, to endDateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz" // September 18, 2024 at 12:00:00 AM UTC+3
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let startDate = dateFormatter.date(from: startDateString),
              let endDate = dateFormatter.date(from: endDateString) else {
            return ""
        }
        
        let differenceInSeconds = endDate.timeIntervalSince(startDate)
        
        let minutes = differenceInSeconds / 60
        let hours = minutes / 60
        let days = hours / 24
        
        if minutes < 60 {
            return "\(Int(minutes))m"
        } else if hours < 24 {
            return "\(Int(hours))h"
        } else {
            return "\(Int(days))d"
        }
    }
}
