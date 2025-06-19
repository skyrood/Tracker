//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Rodion Kim on 2024/12/04.
//

struct TrackerCategory {
    let name: String
    let trackers: [Tracker]
}

extension TrackerCategory: Equatable {
    static func ==(lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        return lhs.name == rhs.name
    }
}
