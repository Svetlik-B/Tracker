struct Tracker {
    struct Schedule { }
    typealias ID = String
    typealias Emoji = String
    enum Color: Int {
        case color1 = 1
        case color2
    }
    
    var id: ID
    var name: String
    var color: Color
    var emoji: Emoji
    var schedule: Schedule
}
