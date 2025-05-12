extension Int {
    var days: String{
        switch self {
        case let c where c % 100 >= 10 && c % 100 <= 20: "\(c) дней"
        case let c where c % 10 == 1: "\(c) день"
        case let c where c % 10 == 2: "\(c) дня"
        case let c where c % 10 == 3: "\(c) дня"
        case let c where c % 10 == 4: "\(c) дня"
        default: "\(self) дней"
        }
    }
}
