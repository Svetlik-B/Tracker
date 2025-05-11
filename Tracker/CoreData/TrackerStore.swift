import CoreData
import UIKit

protocol TrackerStoreProtocol: NSObject {
    var onDidChangeContent: () -> Void { get set }
    var numberOfSections: Int { get }
    var haveTrackers: Bool { get }
    func numberOfItems(in section: Int) -> Int
    func sectionName(for section: Int) -> String?
    func tracker(at indexPath: IndexPath) -> Tracker
    func deleteTracker(at indexPath: IndexPath) throws
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    var onDidChangeContent: () -> Void = {}
    let fetchedResultsController: NSFetchedResultsController<TrackerCoreData>

    override convenience init() {
        self.init(context: Store.persistentContainer.viewContext)
    }

    init(context: NSManagedObjectContext) {
        self.context = context

        let fetchRequest: NSFetchRequest<TrackerCoreData> = NSFetchRequest(
            entityName: "TrackerCoreData"
        )
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.name", ascending: true),
            NSSortDescriptor(key: "name", ascending: true),
        ]
        let controller = NSFetchedResultsController<TrackerCoreData>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.name",
            cacheName: "AllTrackers"
        )
        try? controller.performFetch()
        self.fetchedResultsController = controller

        super.init()

        controller.delegate = self
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
        categoryStore: TrackerCategoryStore,
        categoryIndexPath: IndexPath
    ) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.color = UIColorTransformer.hexString(from: color)
        trackerCoreData.emoji = emoji
        trackerCoreData.name = name
        trackerCoreData.category = categoryStore.categoryCoreData(at: categoryIndexPath)
        trackerCoreData.schedule = ScheduleTransformer.data(from: schedule)
        try context.save()
    }
}

extension TrackerStore: TrackerStoreProtocol {
    var numberOfSections: Int { fetchedResultsController.sections?.count ?? 0 }
    var haveTrackers: Bool { (fetchedResultsController.sections?.count ?? 0) > 0 }
    func numberOfItems(in section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }
    func sectionName(for section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
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
    func deleteTracker(at indexPath: IndexPath) throws {
        let trackerToDelete = fetchedResultsController.object(at: indexPath)
        context.delete(trackerToDelete)
        try context.save()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        onDidChangeContent()
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
