import CoreData
import UIKit

final class TrackerRecordStore {
    private let context: NSManagedObjectContext

    convenience init() {
        self.init(context: Store.persistentContainer.viewContext)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackerRecordStore {
    func addTrackerRecord(date: Date, for tracker: TrackerCoreData) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = Calendar.current.startOfDay(for: date)
        trackerRecordCoreData.tracker = tracker
        try context.save()
    }
}
