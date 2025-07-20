//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/06/21.
//

import CoreData

enum TrackerRecordStoreError: Error {
    case recordStoreInitializationFailed
    case decodingErrorInvalidRecordData
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func store( _ store: TrackerRecordStore)
}

final class TrackerRecordStore: NSObject {
    
    // MARK: - Public Properties
    static let shared = TrackerRecordStore()
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    var records: Set<TrackerRecord> {
        guard let recordObjects = fetchedResultsController.fetchedObjects else {
            return []
        }
        
        return Set(recordObjects.compactMap { try? trackerRecord(from: $0) })
    }
    
    // MARK: - Private Properties
    private let trackerStore: TrackerStore
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    // MARK: - Initializers
    private override init() {
        self.context = CoreDataStack.shared.context
        self.trackerStore = TrackerStore.shared
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [] // или нужные тебе сортировки
        
        self.fetchedResultsController = NSFetchedResultsController(
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
            fatalError("Failed to fetch tracker records: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func addRecord(_ record: TrackerRecord) {
        let alreadyExists = fetchedResultsController.fetchedObjects?.contains(where: {
            $0.tracker?.id == record.trackerId &&
            Calendar.current.isDate($0.date ?? .distantPast, inSameDayAs: record.date)
        }) ?? false
        
        guard !alreadyExists else {
            print("record already exists")
            return
        }
        
        let newRecord = TrackerRecordCoreData(context: context)
        newRecord.id = UUID()
        newRecord.date = record.date
        newRecord.tracker = try? trackerStore.tracker(from: record.trackerId)
        
        CoreDataStack.shared.saveContext()
    }
    
    func deleteRecord(_ record: TrackerRecord) {
        guard let recordToDelete = fetchedResultsController.fetchedObjects?.first(where: {
            $0.tracker?.id == record.trackerId && Calendar.current.isDate($0.date ?? .distantPast, inSameDayAs: record.date)
        }) else { return }
        
        context.delete(recordToDelete)
        CoreDataStack.shared.saveContext()
    }
    
    // MARK: - Private Methods
    private func trackerRecord(from coreDataRecord: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let trackerID = coreDataRecord.tracker?.id,
              let date = coreDataRecord.date else {
            throw TrackerRecordStoreError.decodingErrorInvalidRecordData
        }
        
        return TrackerRecord(trackerId: trackerID, date: date)
    }
}

// MARK: - extension NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.store(self)
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
}
