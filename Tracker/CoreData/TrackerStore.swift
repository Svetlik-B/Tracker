import CoreData
import UIKit

protocol TrackerStoreProtocol: NSObject {
    var onDidChangeContent: () -> Void { get set }
    var numberOfSections: Int { get }
    var haveTrackers: Bool { get }
    var haveResults: Bool { get }
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
    func filterBy(_ filters: [TrackerFilter])
    func getStatistics() throws -> [StatisticsCellView.ViewModel]
}

extension TrackerStoreProtocol {
    func updateFilters(
        date: Date,
        searchString: String,
        filter: FilterType
    ) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        switch filter {
        case .all:
            filterBy([.name(searchString), .day(date.weekday.short)])
        case .today:
            let today = Calendar.current.startOfDay(for: Date())
            if Calendar.current.startOfDay(for: date) == today {
                filterBy([.name(searchString), .day(date.weekday.short)])
            } else {
                filterBy([.name(searchString)])
            }
        case .completed:
            filterBy(
                [
                    .name(searchString),
                    .completed(startOfDay),
                    .day(date.weekday.short),
                ]
            )
        case .uncompleted:
            filterBy(
                [
                    .name(searchString),
                    .uncompleted(startOfDay),
                    .day(date.weekday.short),
                ]
            )
        }
    }
}

private let trackerStoreCacheName = "TrackerStoreCache"

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
            cacheName: trackerStoreCacheName
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

extension TrackerFilter {
    fileprivate var predicate: NSPredicate? {
        switch self {
        case .name(let name):
            name.isEmpty
                ? nil
                : NSPredicate(format: "name CONTAINS[cd] %@", name)
        case .day(let day):
            NSPredicate(format: "(schedule = '') OR (schedule CONTAINS %@)", day)
        case .completed(let date):
            NSPredicate(
                format: "records.date CONTAINS %@",
                Calendar.current.startOfDay(for: date) as NSDate
            )
        case .uncompleted(let date):
            NSPredicate(
                format: "SUBQUERY(records.date, $r, $r.date == %@).@count == 0",
                Calendar.current.startOfDay(for: date) as NSDate
            )
        }
    }
}

extension TrackerStore: TrackerStoreProtocol {
    var numberOfSections: Int { fetchedResultsController.sections?.count ?? 0 }
    var haveTrackers: Bool {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let trackersCount = ( try? context.count(for: fetchRequest)) ?? 0
        return trackersCount > 0
    }
    var haveResults: Bool { (fetchedResultsController.sections?.count ?? 0) > 0 }
    var categoryStore: TrackerCategoryStoreProtocol { TrackerCategoryStore(context: context) }
    func isIdealDate(_ startOfDay: Date) throws -> Bool? {
        let day = startOfDay.weekday.short
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = .init(format: "schedule CONTAINS[cd] %@", day)
        let trackers = try context.fetch(fetchRequest)
        guard trackers.isEmpty == false else { return nil }
        for tracker in trackers {
            if !tracker.isCompleted(on: startOfDay) {
                return false
            }
        }
        return true
    }
    func getStatistics() throws -> [StatisticsCellView.ViewModel] {
        var result = [StatisticsCellView.ViewModel]()
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)
        ]
        let records = try context.fetch(fetchRequest)
        for record in records {
            print(record.date?.formatted() ?? "No date",  record.tracker?.name ?? "No tracker")
        }
        
        let ideals = try Set(records.compactMap(\.date))
            .sorted(by: >)
            .map(isIdealDate)
        let idealDays = ideals.filter { $0 == true } .count
        var bestPeriod = 0
        for ideal in ideals {
            if ideal == false { break }
            bestPeriod += 1
        }
        
        guard let firstRecordDate = records.first?.date
        else { return result }
        
        let today = Calendar.current.startOfDay(for: Date())
        let difference = Calendar.current.dateComponents([.day], from: firstRecordDate, to: today)
        let differenceDays = difference.day ?? 0
        let totalDays = differenceDays + 1
        guard totalDays > 0
        else { return result }
        
        result.append(.init(amount: bestPeriod, text: "Лучший период"))
        result.append(.init(amount: idealDays, text: "Идеальные дни"))
        result.append(.init(amount: records.count, text: "Трекеров завершено"))
        result.append(.init(amount: records.count / totalDays, text: "Среднее значение"))
        
        return result
    }
    func filterBy(_ filters: [TrackerFilter]) {
        let predicates = filters.compactMap(\.predicate)
        if predicates.isEmpty {
            fetchedResultsController.fetchRequest.predicate = nil
            print("no predicates")
        } else {
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            print(predicate)
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        NSFetchedResultsController<TrackerCoreData>.deleteCache(withName: trackerStoreCacheName)
        try? fetchedResultsController.performFetch()
    }
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
            let indexPath = categoryStore.fetchController.indexPath(forObject: categoryCoredData)
        {
            categoryIndexPath = indexPath
        } else {
            fatalError("Не найдена категория")
        }
        return Tracker(
            name: trackerCoreData.name ?? "",
            color: UIColorTransformer.color(from: trackerCoreData.color ?? ""),
            emoji: trackerCoreData.emoji ?? "",
            schedule: ScheduleTransformer.schedule(from: trackerCoreData.schedule),
            count: {
                trackerCoreData.records?.count ?? 0
            },
            isCompleted: { trackerCoreData.findTrackerRecord(for: $0) != nil },
            toggleCompleted: { [weak self] date in
                try self?.toggleCompleted(trackerCoreData: trackerCoreData, date: date)
            },
            categoryStore: categoryStore,
            categoryIndexPath: categoryIndexPath,
            isPinned: trackerCoreData.category?.name == ""
        )
    }
    func toggleCompleted(trackerCoreData: TrackerCoreData, date: Date) throws {
        if let record = trackerCoreData.findTrackerRecord(for: date) {
            self.context.delete(record)
        } else {
            if date > Date.now { return }
            try TrackerRecordStore(context: self.context).addTrackerRecord(
                date: date,
                for: trackerCoreData
            )
        }
        try context.save()
    }
    func uncompletedTrackersCount(for date: Date) -> Int {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "(records.@count == 0) OR (NONE records.date = %@)",
            Calendar.current.startOfDay(for: date) as NSDate
        )
        return (try? context.count(for: fetchRequest)) ?? 0
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
        trackerCoreData.schedule = ScheduleTransformer.data(from: schedule)
        let categoryStore = TrackerCategoryStore(context: context)
        trackerCoreData.category = categoryStore.categoryCoreData(at: categoryIndexPath)
        try context.save()
        try fetchedResultsController.performFetch()
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
    func isCompleted(on date: Date) -> Bool {
        let records = self.records as? Set<TrackerRecordCoreData> ?? []
        for record in records {
            if record.date == Calendar.current.startOfDay(for: date) {
                return true
            }
        }
        return false
    }
}
