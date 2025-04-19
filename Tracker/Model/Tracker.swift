import Foundation
import UIKit

struct Tracker {
    enum Weekday: String, CaseIterable {
        case monday = "Понедельник"
        case tuesday = "Вторник"
        case wednesday = "Среда"
        case thursday = "Четверг"
        case friday = "Пятница"
        case saturday = "Суббота"
        case sunday = "Воскресенье"
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

extension Tracker.Weekday {
    var short: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    var calendarWeekday: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}

extension Tracker.Weekday: Comparable {
    static func < (lhs: Tracker.Weekday, rhs: Tracker.Weekday) -> Bool {
        lhs.value < rhs.value
    }
    var value: Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        case .saturday: return 5
        case .sunday: return 6
        }
    }

}
