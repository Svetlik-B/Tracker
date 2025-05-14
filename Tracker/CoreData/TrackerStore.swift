import CoreData
import UIKit

protocol TrackerStoreProtocol: NSObject {
    var onDidChangeContent: () -> Void { get set }
    var numberOfSections: Int { get }
    var haveTrackers: Bool { get }
    var categoryStore: TrackerCategoryStoreProtocol { get }
    func numberOfItems(in section: Int) -> Int
    func sectionName(for section: Int) -> String?
    func tracker(at indexPath: IndexPath) -> Tracker
    func deleteTracker(at indexPath: IndexPath) throws
    func editTracker(
        at indexPath: IndexPath,
        name: String,
        color: UIColor,
        emoji: String,
        schedule: Tracker.Schedule,
        categoryIndexPath: IndexPath
    ) throws
    func addNewTracker(
        name: String,
        color: UIColor,
        emoji: String,
        schedule: Tracker.Schedule,
        categoryIndexPath: IndexPath
    ) throws
    func pinTracker(at indexPath: IndexPath) throws
    func unpinTracker(at indexPath: IndexPath) throws
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

        let fetchRequest = TrackerCoreData.fetchRequest()
        
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
}

extension TrackerStore: TrackerStoreProtocol {
    var numberOfSections: Int { fetchedResultsController.sections?.count ?? 0 }
    var haveTrackers: Bool { (fetchedResultsController.sections?.count ?? 0) > 0 }
    var categoryStore: TrackerCategoryStoreProtocol { TrackerCategoryStore(context: context) }
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
        let categoryCoredData = trackerCoreData.category
        let categoryStore = TrackerCategoryStore(context: context)
        var categoryIndexPath = IndexPath()
        if let categoryCoredData,
           let indexPath = categoryStore.fetchController.indexPath(forObject: categoryCoredData) {
            categoryIndexPath = indexPath
        } else {
            fatalError("Не найдена категория")
        }
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
            },
            categoryStore: categoryStore,
            categoryIndexPath: categoryIndexPath,
            isPinned: trackerCoreData.category?.name == ""
        )
    }
    func deleteTracker(at indexPath: IndexPath) throws {
        let trackerToDelete = fetchedResultsController.object(at: indexPath)
        context.delete(trackerToDelete)
        try context.save()
    }
    func addNewTracker(
        name: String,
        color: UIColor,
        emoji: String,
        schedule: Tracker.Schedule,
        categoryIndexPath: IndexPath
    ) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.color = UIColorTransformer.hexString(from: color)
        trackerCoreData.emoji = emoji
        trackerCoreData.name = name
        let categoryStore = TrackerCategoryStore(context: context)
        trackerCoreData.category = categoryStore.categoryCoreData(at: categoryIndexPath)
        trackerCoreData.schedule = ScheduleTransformer.data(from: schedule)
        try context.save()
    }
    func editTracker(
        at indexPath: IndexPath,
        name: String,
        color: UIColor,
        emoji: String,
        schedule: Tracker.Schedule,
        categoryIndexPath: IndexPath
    ) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        trackerCoreData.color = UIColorTransformer.hexString(from: color)
        trackerCoreData.emoji = emoji
        trackerCoreData.name = name
        let categoryStore = TrackerCategoryStore(context: context)
        trackerCoreData.category = categoryStore.categoryCoreData(at: categoryIndexPath)
        trackerCoreData.schedule = ScheduleTransformer.data(from: schedule)
        try context.save()
    }
    func pinTracker(at indexPath: IndexPath) throws {
        let categoryStore = TrackerCategoryStore(context: context)
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        let pinnedCategory = try categoryStore.findOrCreateCategory(name: "")
        trackerCoreData.oldCategory = trackerCoreData.category?.name
        trackerCoreData.category = pinnedCategory
        try context.save()
    }
    func unpinTracker(at indexPath: IndexPath) throws {
        let categoryStore = TrackerCategoryStore(context: context)
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        let oldCategory = try categoryStore.findOrCreateCategory(
            name: trackerCoreData.oldCategory ?? ""
        )
        trackerCoreData.category = oldCategory
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
