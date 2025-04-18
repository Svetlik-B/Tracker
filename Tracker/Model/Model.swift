import Foundation

final class Model {
    static let shared = Model()
    var categories: [TrackerCategory] = [
        .init(id: UUID(), name: "Тестовая категория", trackers: [])
    ]
    var records: [TrackerRecord] = []
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
    func count(trackerId: UUID) -> Int {
        records
            .filter { $0.id == trackerId }
            .count
    }
    func addRecord(trackerId: UUID, date: Date) {
        records.append(TrackerRecord(id: trackerId, date: date))
    }
    func deleteRecord(trackerId: UUID, date: Date) {
        records.removeAll {
            $0.id == trackerId
                && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    func isCompleted(trackerId: UUID, on date: Date) -> Bool {
        var result = false
        for record in records {
            guard
                record.id == trackerId,
                Calendar.current.isDate(record.date, inSameDayAs: date)
            else { continue }
            result = true
            break
        }
        return result
    }
}
