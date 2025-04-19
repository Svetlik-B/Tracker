import CoreData
import UIKit

final class TrackerStore {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    convenience init() {
        self.init(context: Store.persistentContainer.viewContext)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: - Interface
extension TrackerStore {
    enum TrackerStoreError: Error {
        case categoryNotFound(String)
    }
    func addNewTracker(_ tracker: Tracker, category: TrackerCategory) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", category.name)

        guard let categoryCoreData = try context.fetch(fetchRequest).first else {
            throw TrackerStoreError.categoryNotFound(category.name)
        }

        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.category = categoryCoreData
        // TODO: tracker.schedule
        try context.save()
    }
}
