import CoreData
import UIKit

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    convenience init() {
        self.init(context: Store.persistentContainer.viewContext)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: - Implementation
extension TrackerCategoryStore {
    func getAllCategories() throws -> [TrackerCategory] {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        return try context.fetch(request).map { coreDateCategory in
            TrackerCategory(name: coreDateCategory.name ?? "")
        }
    }
}
