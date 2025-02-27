//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/04.
//

import UIKit

struct TrackerRecord: Hashable {
    let trackerId: UInt
    let date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackerId)
        hasher.combine(Calendar.current.startOfDay(for: date))
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.trackerId == rhs.trackerId
        && Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}
