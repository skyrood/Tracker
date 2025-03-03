//
//  Weekday.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/02/26.
//

import Foundation

struct Weekday: OptionSet {
    let rawValue: Int
    
    static let monday = Weekday(rawValue: 1 << 0)
    static let tuesday = Weekday(rawValue: 1 << 1)
    static let wednesday = Weekday(rawValue: 1 << 2)
    static let thursday = Weekday(rawValue: 1 << 3)
    static let friday = Weekday(rawValue: 1 << 4)
    static let saturday = Weekday(rawValue: 1 << 5)
    static let sunday = Weekday(rawValue: 1 << 6)
}
