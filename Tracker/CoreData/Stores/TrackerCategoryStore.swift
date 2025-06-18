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
    
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    lazy var categories: [TrackerCategory] = {
        guard let objects = self.fetchedResultsController.fetchedObjects,
              let categories = try? objects.map({ try category(from: $0) })
        else { return [] }
        
        return categories
    }()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    // MARK: - Initializers
    convenience override init() {
        let context = CoreDataStack.shared.context
        do {
            try self.init(context: context)
        } catch {
            fatalError("Не удалось инициализировать TrackerCategoryStore: \(error)")
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: true)]
        
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
    func getOrCreateCategory(named name: String) throws -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        if let existingCategory = try context.fetch(request).first {
            print("Category named\"\(name)\" already exists")
            return existingCategory
        } else {
            print("creating new category named \"\(name)\"")
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = name
            newCategory.id = UUID()
            CoreDataStack.shared.saveContext()
            return newCategory
        }
    }
    
    // MARK: - Private Methods
    private func category(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let categoryName = trackerCategoryCoreData.name else {
            throw TrackerCategoryStoreError.decodingErrorInvalidCategoryName
        }
        guard let trackers = try? trackerCategoryCoreData.trackers?.map({ try tracker(from: $0 as! TrackerCoreData) }) else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackers
        }
        
        return TrackerCategory(name: categoryName, trackers: trackers)
    }
    
    // Пока заглушка
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
        
        CoreDataStack.shared.saveContext()
    }
}
