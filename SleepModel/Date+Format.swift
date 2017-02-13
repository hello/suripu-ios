//
//  Date+Format.swift
//  Sense
//
//  Created by Jimmy Lu on 1/30/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension Date {
    
    fileprivate static let isoDateFormat = "yyyy-MM-dd"

    static func from(isoDateOnly: String?) -> Date? {
        guard let isoDate = isoDateOnly else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = Date.isoDateFormat
        return formatter.date(from: isoDate)
    }
    
}


