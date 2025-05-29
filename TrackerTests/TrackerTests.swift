import SnapshotTesting
import XCTest

@testable import Tracker

final class TrackerTests: XCTestCase {
    func testNoTrackers() throws {
        let vc = TabBarController(trackerStore: TrackerStoreMock())
        assertSnapshot(of: vc, as: .image(drawHierarchyInKeyWindow: true), record: false)
    }
    func testNoResults() throws {
        let mock = TrackerStoreMock()
        mock.haveTrackers = true
        mock.haveResults = false
        let vc = TabBarController(trackerStore: mock)
        assertSnapshot(of: vc, as: .image(drawHierarchyInKeyWindow: true), record: false)
    }
    func testCollectionView() throws {
        let mock = TrackerStoreMock()
        mock.haveTrackers = true
        mock.haveResults = true
        let vc = TabBarController(trackerStore: mock)
        assertSnapshot(of: vc, as: .image(drawHierarchyInKeyWindow: true), record: false)
    }
}

final class TrackerStoreMock: NSObject, TrackerStoreProtocol {
    var onDidChangeContent: () -> Void = {}
    var numberOfSections: Int = 2
    var haveTrackers: Bool = false
    var haveResults: Bool = false
    var categoryStore: any TrackerCategoryStoreProtocol = TrackerCategoryStoreMock()
    func numberOfItems(in section: Int) -> Int { 5 }
    func sectionName(for section: Int) -> String? { "Тестовая категория \(section)" }
    func tracker(at indexPath: IndexPath) -> Tracker {
        Tracker(
            name: "Tracker \(indexPath.row)",
            color: Tracker.colors[indexPath.row],
            emoji: Tracker.emoji[indexPath.row],
            schedule: [.monday, .wednesday, .friday],
            count: { indexPath.row },
            isCompleted: { _ in indexPath.row > 0 },
            toggleCompleted: { _ in },
            categoryStore: TrackerCategoryStoreMock(),
            categoryIndexPath: IndexPath(),
            isPinned: false
        )
    }
    func deleteTracker(at indexPath: IndexPath) throws {}
    func editTracker(
        at indexPath: IndexPath,
        name: String,
        color: UIColor,
        emoji: String,
        schedule: Tracker.Schedule,
        categoryIndexPath: IndexPath
    ) throws {}
    func addNewTracker(
        name: String,
        color: UIColor,
        emoji: String,
        schedule: Tracker.Schedule,
        categoryIndexPath: IndexPath
    ) throws {}
    func pinTracker(at indexPath: IndexPath) throws {}
    func unpinTracker(at indexPath: IndexPath) throws {}
    func filterBy(_ filters: [TrackerFilter]) {}
    func getStatistics() throws -> [StatisticsCellView.ViewModel] { [] }
}

final class TrackerCategoryStoreMock: TrackerCategoryStoreProtocol {
    var delegate: (any TrackerCategoryStoreDelegate)?
    var numberOfCategories: Int = 1
    func category(at indexPath: IndexPath) -> TrackerCategory { .init(name: "Тестовая категория") }
    func updateCategory(_ category: TrackerCategory, at indexPath: IndexPath) throws {}
    func findOrCreateCategory(_ category: TrackerCategory) throws -> IndexPath { .init() }
    func deleteCategory(at indexPath: IndexPath) throws {}
}
