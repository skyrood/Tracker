//
//  TrackerStore.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/06/19.
//

import CoreData
import UIKit

enum TrackerStoreError: Error {
    case categoryStoreInitializationFailed
    case decodingErrorInvalidCategoryName
    case decodingErrorInvalidTrackers
    case trackerNotFound
}

protocol TrackerStoreDelegate: AnyObject {
    func store( _ store: TrackerStore)
}

final class TrackerStore: NSObject {
    
    // MARK: - Public Properties
    static let shared = TrackerStore()
    
    var trackers: [Tracker] {
        guard let objects = self.fetchedResultsController.fetchedObjects,
              let trackers = try? objects.map({ try tracker(from: $0) })
        else { return [] }
        
        return trackers
    }
    
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    private let emptySchedule: Int = -1
    
    // MARK: - Initializers
    private override init() {
        context = CoreDataStack.shared.context
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch trackers: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func allTrackers() throws -> [TrackerCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    func addTracker(
        name: String,
        emoji: String,
        color: String,
        schedule: Weekday?,
        category: TrackerCategoryCoreData
    ) throws {
        let newTracker = TrackerCoreData(context: context)
        
        newTracker.id = UUID()
        newTracker.name = name
        newTracker.emoji = emoji
        newTracker.colorName = color
        newTracker.schedule = Int32(schedule?.rawValue ?? emptySchedule)
        newTracker.category = category
        CoreDataStack.shared.saveContext()
    }
    
    func updateTracker(
        id: UUID,
        name: String,
        emoji: String,
        color: String,
        schedule: Weekday?,
        category: TrackerCategoryCoreData
    ) throws {
        let updatedTracker = try tracker(from: id)
        
        updatedTracker.name = name
        updatedTracker.emoji = emoji
        updatedTracker.colorName = color
        updatedTracker.schedule = Int32(schedule?.rawValue ?? emptySchedule)
        updatedTracker.category = category
        
        CoreDataStack.shared.saveContext()
    }
    
    func deleteTracker(with id: UUID) throws {
        let trackerToDelete = try tracker(from: id)
        context.delete(trackerToDelete)
        CoreDataStack.shared.saveContext()
    }
    
    func tracker(from coreData: TrackerCoreData) throws -> Tracker {
        let schedule: Weekday? = coreData.schedule == -1 ? nil : Weekday(rawValue: Int(coreData.schedule))
        guard let name = coreData.name,
              let emoji = coreData.emoji,
              let colorName = coreData.colorName,
              let id = coreData.id else {
            throw NSError(domain: "TrackerCategoryStore", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid tracker data"])
        }
        
        return Tracker(
            id: id,
            name: name,
            emoji: emoji,
            colorName: colorName,
            schedule: schedule
        )
    }
    
    func tracker(from trackerId: UUID) throws -> TrackerCoreData {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId.uuidString)
        request.fetchLimit = 1
        
        guard let trackerCoreData = try context.fetch(request).first else {
            throw TrackerStoreError.trackerNotFound
        }
        
        return trackerCoreData
    }
}

// MARK: - extension NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.store(self)
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
}

// MARK: - testing/debugging methods
extension TrackerStore {
    func deleteAllTrackers() throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let trackers = try context.fetch(fetchRequest)
        
        for tracker in trackers {
            context.delete(tracker)
        }
        
        CoreDataStack.shared.saveContext()
    }
}
