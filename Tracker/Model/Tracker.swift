import Foundation
import UIKit

struct Tracker {
    enum Weekday: Int, CaseIterable, Codable {
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        case sunday
    }
    typealias Emoji = String
    typealias Schedule = Set<Weekday>
    var id: UUID
    var name: String
    var color: UIColor
    var emoji: Emoji
    var schedule: Schedule
}

extension Tracker {
    static let colors: [UIColor] = [
        .Tracker.color1,
        .Tracker.color2,
        .Tracker.color3,
        .Tracker.color4,
        .Tracker.color5,
        .Tracker.color6,
        .Tracker.color7,
        .Tracker.color8,
        .Tracker.color9,
        .Tracker.color10,
        .Tracker.color11,
        .Tracker.color12,
        .Tracker.color13,
        .Tracker.color14,
        .Tracker.color15,
        .Tracker.color16,
        .Tracker.color17,
        .Tracker.color18,
    ]
    static let emoji = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪",
    ]
}

extension Tracker.Weekday: Comparable {
    static func < (lhs: Tracker.Weekday, rhs: Tracker.Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Tracker.Weekday {
    var long: String {
        switch self {
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        case .sunday: "Воскресенье"
        }

    }
    var short: String {
        switch self {
        case .monday: "Пн"
        case .tuesday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        case .sunday: "Вс"
        }
    }
    var calendarWeekday: Int {
        switch self {
        case .sunday: 1
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        }
    }
}
