import Foundation

enum ScheduleTransformer {
    static func data(from schedule: Tracker.Schedule) -> String {
        schedule.sorted().map(\.short).joined(separator: ",")
    }

    static func schedule(from string: String?) -> Tracker.Schedule {
        guard let string
        else { return Tracker.Schedule() }
        let elements = string.split(separator: ",")
        let days = Tracker.Weekday.allCases.map(\.short)
        var schedule: Tracker.Schedule = []
        for element in elements {
            guard
                let index = days.firstIndex(of: String(element)),
                let weekday = Tracker.Weekday(rawValue: index)
            else { continue }
            schedule.insert(weekday)
        }
        return schedule
    }
}
