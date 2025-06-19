//
//  TrackerStore.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/06/19.
//

import CoreData

enum TrackerStoreError: Error {
    case categoryStoreInitializationFailed
    case decodingErrorInvalidCategoryName
    case decodingErrorInvalidTrackers
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
    func addTracker(name: String, with emoji: String, tile color: String, to category: TrackerCategoryCoreData) throws -> TrackerCoreData {
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = UUID()
        newTracker.name = name
        newTracker.emoji = emoji
        newTracker.colorHex = color
        newTracker.category = category
        
        return newTracker
    }
    
    private func tracker(from coreData: TrackerCoreData) throws -> Tracker {
        guard let name = coreData.name,
              let emoji = coreData.emoji,
              let colorHex = coreData.colorHex,
              let id = coreData.id else {
            throw NSError(domain: "TrackerCategoryStore", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid tracker data"])
        }
        
        return Tracker(
            id: 1,
            name: name,
            emoji: emoji,
            color: .red,
            schedule: []
        )
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
