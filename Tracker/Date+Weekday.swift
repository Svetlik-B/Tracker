import Foundation

extension Date {
    var weekday: Tracker.Weekday {
        let weekday = Calendar.current
            .dateComponents([.weekday], from: self)
            .weekday ?? 0
        return Tracker.Weekday(rawValue: (weekday + 5) % 7) ?? .monday
    }
}
