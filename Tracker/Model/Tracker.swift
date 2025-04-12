import Foundation
import UIKit

struct Tracker {
    enum Weekday: String, CaseIterable, Comparable {
        static func < (lhs: Tracker.Weekday, rhs: Tracker.Weekday) -> Bool {
            lhs.index < rhs.index
        }
        
        case monday = "Понедельник"
        case tuesday = "Вторник"
        case wednesday = "Среда"
        case thursday = "Четверг"
        case friday = "Пятница"
        case saturday = "Суббота"
        case sunday = "Воскресенье"
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
        var index: Int {
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
    typealias Emoji = String
    typealias Schedule = Set<Weekday>
    typealias Color = UIColor
    var id: UUID
    var categoryID: UUID
    var name: String
    var color: Color
    var emoji: Emoji
    var schedule: Schedule
}
