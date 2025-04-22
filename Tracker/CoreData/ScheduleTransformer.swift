import Foundation

enum ScheduleTransformer {
    static func data(from schedule: Tracker.Schedule) -> Data? {
        try? JSONEncoder().encode(schedule)
    }

    static func schedule(from data: Data?) -> Tracker.Schedule {
        guard
            let data,
            let schedule = try? JSONDecoder()
                .decode(Tracker.Schedule.self, from: data)
        else { return Tracker.Schedule() }
        return schedule
    }
}
