import Foundation

enum FilterType: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case uncompleted = "Не завершенные"
}

enum TrackerFilter {
    case name(String)
    case day(String)
    case completed(Date)
    case uncompleted(Date)
}
