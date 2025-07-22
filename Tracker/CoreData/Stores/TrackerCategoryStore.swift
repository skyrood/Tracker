//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/06/18.
//

import CoreData

enum TrackerCategoryStoreError: Error {
    case categoryStoreInitializationFailed
    case decodingErrorInvalidCategoryName
    case decodingErrorInvalidTrackers
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store( _ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Public Properties
    static let shared = TrackerCategoryStore()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var categories: [TrackerCategory] {
        guard let categoryObjects = fetchedResultsController.fetchedObjects else { return [] }
        
        let trackersCoreDataList: [TrackerCoreData]
        do {
            trackersCoreDataList = try trackerStore.allTrackers()
        } catch {
            print("Error loading trackers: \(error)")
            return []
        }
        
        let groupedTrackers = Dictionary(grouping: trackersCoreDataList, by: { $0.category?.name })
        
        return categoryObjects.compactMap { coreDataCategory in
            guard let name = coreDataCategory.name else { return nil }
            let trackersForCategory = groupedTrackers[name] ?? []
            let trackers: [Tracker] = trackersForCategory.compactMap { try? trackerStore.tracker(from: $0) }
            return TrackerCategory(name: name, trackers: trackers)
        }
    }
    
    // MARK: - Private Properties
    private let trackerStore: TrackerStore
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    // MARK: - Initializers
    private override init() {
        self.context = CoreDataStack.shared.context
        self.trackerStore = TrackerStore.shared
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: true)]
        
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
            fatalError("Failed to fetch tracker categories: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func getOrCreateCategory(named name: String) throws -> TrackerCategory {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        if let existingCategory = try context.fetch(request).first {
            return try category(from: existingCategory)
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = name
            newCategory.id = UUID()
            CoreDataStack.shared.saveContext()
            
            return try category(from: newCategory)
        }
    }
    
    func addOrUpdateTracker(
        trackerID: UUID? = nil,
        name: String,
        emoji: String,
        color: String,
        schedule: Weekday?,
        to category: TrackerCategory
    ) throws {
        let coreDataCategory = try coreDataCategory(for: category)
        
        if let id = trackerID, (try? trackerStore.tracker(from: id)) != nil {
            try trackerStore.updateTracker(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
                schedule: schedule,
                category: coreDataCategory
            )
        } else {
            try trackerStore.addTracker(
                name: name,
                emoji: emoji,
                color: color,
                schedule: schedule,
                category: coreDataCategory
            )
        }
        
        delegate?.store(self)
    }
    
    func deleteTracker(with id: UUID) throws {
        try trackerStore.deleteTracker(with: id)
        delegate?.store(self)
    }
    
    func refreshStore() throws {
        try fetchedResultsController.performFetch()
        delegate?.store(self)
    }
    
    // MARK: - Private Methods
    private func category(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let categoryName = trackerCategoryCoreData.name else {
            throw TrackerCategoryStoreError.decodingErrorInvalidCategoryName
        }
        
        guard let trackersCoreData = trackerCategoryCoreData.trackers as? Set<TrackerCoreData> else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackers
        }
        
        let trackers: [Tracker] = try trackersCoreData.map { try trackerStore.tracker(from: $0) }
        
        return TrackerCategory(name: categoryName, trackers: trackers)
    }
    
    private func coreDataCategory(for category: TrackerCategory) throws -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", category.name)
        request.fetchLimit = 1
        
        guard let categoryCoreData = try context.fetch(request).first else {
            throw TrackerCategoryStoreError.decodingErrorInvalidCategoryName
        }
        
        return categoryCoreData
    }
}

// MARK: - extension NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.store(self)
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
}

// MARK: - testing/debugging methods
extension TrackerCategoryStore {
    func deleteAllCategories() throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let categories = try context.fetch(fetchRequest)
        
        for category in categories {
            context.delete(category)
        }
        
        try trackerStore.deleteAllTrackers()
        
        CoreDataStack.shared.saveContext()
    }
}
