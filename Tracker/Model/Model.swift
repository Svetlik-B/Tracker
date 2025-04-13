import Foundation

final class Model {
    static let shared = Model()
    var categories: [TrackerCategory]

    private init() {
        self.categories = [
            TrackerCategory(
                id: UUID(),
                name: "First",
                trackers: [
                    .init(
                        id: UUID(),
                        categoryID: UUID(),
                        name: "Tacker",
                        color: .Tracker.color4,
                        emoji: "😻",
                        schedule: [.monday, .sunday]
                    ),
                    .init(
                        id: UUID(),
                        categoryID: UUID(),
                        name: "Tacker",
                        color: .Tracker.color4,
                        emoji: "😻",
                        schedule: [.monday]
                    )
                ]
            ),
            TrackerCategory(id: UUID(), name: "Second", trackers: []),
        ]
    }
}

// MARK: - Interface
extension Model {
    func add(tracker: Tracker) {
        self.categories = self.categories.map { category in
            guard category.id == tracker.categoryID
            else { return category }
            return TrackerCategory(
                id: category.id,
                name: category.name,
                trackers: category.trackers + [tracker]
            )
        }
    }
    func categories(for weekday: Tracker.Weekday) -> [TrackerCategory] {
        Model.shared.categories.compactMap { category in
            let trackers: [Tracker] = category.trackers.compactMap { tracker in
                tracker.schedule.contains(weekday) ? tracker : nil
            }
            guard !trackers.isEmpty else { return nil }
            return TrackerCategory(
                id: category.id,
                name: category.name,
                trackers: trackers
            )
        }
    }
}
