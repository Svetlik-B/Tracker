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
                        schedule: [.monday, .wednesday]
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
}
