import CoreData

protocol TrackerCategoryStoreProtocol: AnyObject {
    var delegate: TrackerCategoryStoreDelegate? { get set }
    var numberOfCategories: Int { get }
    func category(at indexPath: IndexPath) -> TrackerCategory
    func updateCategory(_ category: TrackerCategory, at indexPath: IndexPath) throws
    func findOrCreateCategory(_ category: TrackerCategory) throws -> IndexPath
    func deleteCategory(at indexPath: IndexPath) throws
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChange(_ store: TrackerCategoryStoreProtocol)
}

final class TrackerCategoryStore: NSObject, TrackerCategoryStoreProtocol {
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    let fetchController: NSFetchedResultsController<TrackerCategoryCoreData>
    override convenience init() {
        self.init(context: Store.persistentContainer.viewContext)
    }

    init(context: NSManagedObjectContext) {
        self.context = context

        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
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
    func categoryCoreData(at indexPath: IndexPath) -> TrackerCategoryCoreData {
        fetchController.object(at: indexPath)
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
    func updateCategory(
        _ category: TrackerCategory,
        at indexPath: IndexPath
    ) throws {
        let coreDataCategory = fetchController.object(at: indexPath)
        coreDataCategory.name = category.name
        try context.save()
    }
    func findOrCreateCategory(name: String) throws -> TrackerCategoryCoreData {
        guard let category = findCategory(name: name)
        else {
            return try createCategory(name: name)
        }
        return category
    }
    func findOrCreateCategory(_ category: TrackerCategory) throws -> IndexPath {
        let categoryCoreData = try findOrCreateCategory(name: category.name)
        guard let indexPath = fetchController.indexPath(forObject: categoryCoreData)
        else {
            struct ImpossibleError: Error {}
            throw ImpossibleError()
        }
        return indexPath
    }
    func findCategory(name: String) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        return try? context.fetch(request).first
    }
    func findCategory(_ category: TrackerCategory) -> IndexPath? {
        guard let categoryCoreData = findCategory(name: category.name)
        else { return nil }
        return fetchController.indexPath(forObject: categoryCoreData)
    }
    func createCategory(name: String) throws -> TrackerCategoryCoreData {
        let coreDataCategory = TrackerCategoryCoreData(context: context)
        coreDataCategory.name = name
        try context.save()
        return coreDataCategory
    }
    func createCategory(_ category: TrackerCategory) throws -> IndexPath {
        let coreDataCategory = try createCategory(name: category.name)
        guard let indexPath = fetchController.indexPath(forObject: coreDataCategory)
        else {
            struct ImpossibleError: Error {}
            throw ImpossibleError()
        }
        return indexPath
    }
}

