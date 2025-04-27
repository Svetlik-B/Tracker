import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChange(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    private let fetchController: NSFetchedResultsController<TrackerCategoryCoreData>
    override convenience init() {
        self.init(context: Store.persistentContainer.viewContext)
    }

    init(context: NSManagedObjectContext) {
        self.context = context

        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchController = NSFetchedResultsController<TrackerCategoryCoreData>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        fetchController.delegate = self
        try? fetchController.performFetch()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        delegate?.trackerCategoryStoreDidChange(self)
    }
}

// MARK: - Implementation
extension TrackerCategoryStore {
    var numberOfCategories: Int {
        guard let sectionInfo = fetchController.sections?.first
        else { return 0 }
        return sectionInfo.numberOfObjects
    }
    func category(at indexPath: IndexPath) -> TrackerCategory {
        let category = fetchController.object(at: indexPath)
        return TrackerCategory(name: category.name ?? "")
    }
    func deleteCategory(at indexPath: IndexPath) throws {
        let categoryToDelete = fetchController.object(at: indexPath)
        context.delete(categoryToDelete)
        try context.save()
        
    }
    func getAllCategories() throws -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        return try context.fetch(request).map { coreDateCategory in
            TrackerCategory(name: coreDateCategory.name ?? "")
        }
    }
    func updateCategory(
        _ category: TrackerCategory,
        at indexPath: IndexPath
    ) throws {
        let coreDataCategory = fetchController.object(at: indexPath)
        coreDataCategory.name = category.name
        try context.save()
    }
    func addCategory(_ category: TrackerCategory) throws {
        guard !categoryExists(category)
        else {
            return
        }
        let coreDataCategory = TrackerCategoryCoreData(context: context)
        coreDataCategory.name = category.name
        try context.save()
    }
    func categoryExists(_ category: TrackerCategory) -> Bool {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "name == %@",
            category.name
        )
        guard let result = try? context.fetch(request)
        else { return false }

        return !result.isEmpty
    }
}
