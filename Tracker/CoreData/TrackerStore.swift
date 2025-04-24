import CoreData
import UIKit

final class TrackerStore {
    private let context: NSManagedObjectContext

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
    func addNewTracker(
        name: String,
        color: UIColor,
        emoji: String,
        schedule: Tracker.Schedule,
        category: TrackerCategory
    ) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", category.name)

        guard let categoryCoreData = try context.fetch(fetchRequest).first else {
            throw TrackerStoreError.categoryNotFound(category.name)
        }

        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.color = UIColorTransformer.hexString(from: color)
        trackerCoreData.emoji = emoji
        trackerCoreData.name = name
        trackerCoreData.category = categoryCoreData
        trackerCoreData.schedule = ScheduleTransformer.data(from: schedule)
        try context.save()
    }
}

extension TrackerCoreData {
    func findTrackerRecord(for date: Date) -> TrackerRecordCoreData? {
        guard let records = records as? Set<TrackerRecordCoreData>
        else { return nil }
        let dateStartOfDay = Calendar.current.startOfDay(for: date)
        for record in records {
            guard let date = record.date else { continue }
            let recordStartOfDay = Calendar.current.startOfDay(for: date)
            if dateStartOfDay == recordStartOfDay {
                return record
            }
        }
        return nil
    }
}

final class TrackerDataSource: NSObject {
    let fetchedResultsController = TrackerDataSource.createFetchedResultsController()
    let onDidChangeContent: () -> Void
    init(onDidChangeContent: @escaping () -> Void) {
        self.onDidChangeContent = onDidChangeContent
        super.init()
        fetchedResultsController.delegate = self
    }
}

extension TrackerDataSource: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        onDidChangeContent()
    }
}

extension TrackerDataSource {
    func sectionName(for section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
    var numberOfSections: Int { fetchedResultsController.sections?.count ?? 0 }
    func numberOfItems(in section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }
    func tracker(at indexPath: IndexPath) -> Tracker {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return Tracker(
            name: trackerCoreData.name ?? "",
            color: UIColorTransformer.color(from: trackerCoreData.color ?? ""),
            emoji: trackerCoreData.emoji ?? "",
            schedule: ScheduleTransformer.schedule(from: trackerCoreData.schedule),
            count: { trackerCoreData.records?.count ?? 0 },
            isCompleted: { trackerCoreData.findTrackerRecord(for: $0) != nil },
            toggleCompleted: { date in
                guard let record = trackerCoreData.findTrackerRecord(for: date)
                else {
                    if date > Date.now { return }
                    let trackerRecord = TrackerRecord(date: date)
                    try TrackerRecordStore().addTrackerRecord(
                        trackerRecord,
                        for: trackerCoreData
                    )
                    return
                }
                let context = record.managedObjectContext
                context?.delete(record)
                try context?.save()
            }
        )
    }
    var haveTrackers: Bool {
        (fetchedResultsController.sections?.count ?? 0) > 0
    }
}

extension TrackerDataSource {
    fileprivate static func createFetchedResultsController() -> NSFetchedResultsController<
        TrackerCoreData
    > {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = NSFetchRequest(
            entityName: "TrackerCoreData"
        )
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let controller = NSFetchedResultsController<TrackerCoreData>(
            fetchRequest: fetchRequest,
            managedObjectContext: Store.persistentContainer.viewContext,
            sectionNameKeyPath: "category.name",
            cacheName: "AllTrackers"
        )
        try? controller.performFetch()
        return controller
    }
}
