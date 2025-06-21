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
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    lazy var trackers: [Tracker] = {
        guard let objects = self.fetchedResultsController.fetchedObjects,
              let trackers = try? objects.map({ try tracker(from: $0) })
        else { return [] }
        
        return trackers
    }()
    
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    // MARK: - Initializers
    convenience override init() {
        let context = CoreDataStack.shared.context
        
        do {
            try self.init(context: context)
        } catch {
            fatalError("Не удалось инициализировать TrackerStore: \(error)")
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        self.fetchedResultsController = fetchedResultsController
        
        try fetchedResultsController.performFetch()
    }
    
    // MARK: - Overrides Methods
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    func allTrackers() throws -> [TrackerCoreData] {
         return fetchedResultsController.fetchedObjects ?? []
//        return try objects.map({ try tracker(from: $0) })
    }
    
    func addTracker(name: String, emoji: String, color: String, schedule: Weekday, category: TrackerCategoryCoreData) throws -> Tracker {
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = UUID()
        newTracker.name = name
        newTracker.emoji = emoji
        newTracker.colorName = color
        newTracker.schedule = Int32(schedule.rawValue)
        newTracker.category = category
        CoreDataStack.shared.saveContext()
        
        return try tracker(from: newTracker)
    }
    
    func tracker(from coreData: TrackerCoreData) throws -> Tracker {
        let schedule = Weekday(rawValue: Int(coreData.schedule))
        guard let name = coreData.name,
              let emoji = coreData.emoji,
              let colorName = coreData.colorName,
              !schedule.isEmpty,
              let id = coreData.id else {
            throw NSError(domain: "TrackerCategoryStore", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid tracker data"])
        }
        
        return Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: UIColor(named: colorName) ?? .gray,
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
    
    // MARK: - Private Methods
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
