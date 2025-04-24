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
    func addTrackerRecord(
        _ trackerRecord: TrackerRecord,
        for tracker: TrackerCoreData
    ) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = trackerRecord.date
        trackerRecordCoreData.tracker = tracker
        try context.save()
    }    
}
