//
//  StatisticsService.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/07/20.
//

import UIKit

struct Statistics {
    let bestPeriod: Int
    let perfectDays: Int
    let trackersCompleted: Int
    let completedAverage: Int
}

final class StatisticsService {
    
    // MARK: - Public Methods
    var onDidUpdate: (() -> Void)?
    
    var isEmpty: Bool {
        return trackerRecordStore.records.isEmpty
    }
    
    // MARK: - Private Properties
    private let trackerRecordStore: TrackerRecordStore
    private let trackerStore: TrackerStore
    
    // MARK: - Initializers
    convenience init() {
        let trackerRecordStore = TrackerRecordStore.shared
        let trackerStore = TrackerStore.shared
        self.init(trackerRecordStore: trackerRecordStore, trackerStore: trackerStore)
    }
    
    init(trackerRecordStore: TrackerRecordStore, trackerStore: TrackerStore) {
        self.trackerRecordStore = trackerRecordStore
        self.trackerStore = trackerStore
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackerRecordsDidChange),
            name: .trackerRecordsDidChange,
            object: nil
        )
    }
    
    // MARK: - Public Methods
    func calculate() -> Statistics {
        let records = trackerRecordStore.records
        let allTrackers = trackerStore.trackers
        
        return Statistics(
            bestPeriod: bestPeriod(from: records, allTrackers: allTrackers),
            perfectDays: perfectDays(from: records, allTrackers: allTrackers),
            trackersCompleted: trackersCompleted(from: records),
            completedAverage: averageCompletionRate(from: records)
        )
    }
    
    // MARK: - Private Methods
    private func bestPeriod(from records: Set<TrackerRecord>, allTrackers: [Tracker]) -> Int {
        let calendar = Calendar.current
        let groupedRecords = Dictionary(grouping: records) { calendar.startOfDay(for: $0.date) }
        
        let allScheduledDays = findAllScheduledDays(from: allTrackers)
        let sortedDays = allScheduledDays.sorted()
        
        var maxStreak = 0
        var currentStreak = 0
        
        for day in sortedDays {
            let scheduledTrackers = allTrackers.filter { isTracker($0, scheduledFor: day) }
            let expectedIDs = Set(scheduledTrackers.map { $0.id })
            let completedIDs = Set(groupedRecords[day]?.map { $0.trackerId } ?? [])
            
            if expectedIDs.isEmpty {
                continue
            }
            
            if completedIDs == expectedIDs {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return maxStreak
    }
    
    private func perfectDays(from records: Set<TrackerRecord>, allTrackers: [Tracker]) -> Int {
        let calendar = Calendar.current
        let groupedRecords = Dictionary(grouping: records) { calendar.startOfDay(for: $0.date) }
        
        var count = 0
        
        for (day, recordsInDay) in groupedRecords {
            let scheduledTrackers = allTrackers.filter { isTracker($0, scheduledFor: day) }
            let expectedIDs = Set(scheduledTrackers.map { $0.id })
            
            let completedIDs = Set(recordsInDay.map { $0.trackerId })
            
            if !expectedIDs.isEmpty && expectedIDs == completedIDs {
                count += 1
            }
        }
        
        return count
    }
    
    private func trackersCompleted(from records: Set<TrackerRecord>) -> Int {
        return records.count
    }
    
    private func averageCompletionRate(from records: Set<TrackerRecord>) -> Int {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: records) { calendar.startOfDay(for: $0.date) }
        let dayCount = grouped.map { $0.value.count }
        
        guard !dayCount.isEmpty else {
            return 0
        }
        let total = dayCount.reduce(0, +)
        let average = Double(total) / Double(dayCount.count)
        
        return Int(round(average))
    }
    
    private func findAllScheduledDays(from trackers: [Tracker]) -> Set<Date> {
        var result = Set<Date>()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for offset in -365...0 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            
            let hasAtLeastOneTracker = trackers.contains(where: { isTracker($0, scheduledFor: date) })
            if hasAtLeastOneTracker {
                result.insert(calendar.startOfDay(for: date))
            }
        }
        
        return result
    }
    
    private func isTracker(_ tracker: Tracker, scheduledFor date: Date) -> Bool {
        guard let schedule = tracker.schedule else { return false }
        
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        
        let weekdayBit = 1 << ((weekdayIndex + 5) % 7)
        return schedule.contains(Weekday(rawValue: weekdayBit))
    }
    
    @objc private func handleTrackerRecordsDidChange() {
        _ = calculate()
        onDidUpdate?()
    }
}
