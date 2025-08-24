import Foundation

enum BodyArea: String, CaseIterable, Codable, Identifiable {
    case hands = "Hands"
    case elbows = "Elbows"
    case shoulders = "Shoulders"
    case knees = "Knees"
    case ankles = "Ankles"

    var id: String { rawValue }
}

enum TimeSlot: String, CaseIterable, Codable, Identifiable {
    case morning = "Morning"
    case midday = "Midday"
    case evening = "Evening"
    case night = "Night"

    var id: String { rawValue }
}

enum Stiffness: String, CaseIterable, Codable, Identifiable {
    case none = "None"
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"

    var id: String { rawValue }
}

struct SymptomCell: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var pain: Int = 0                 // 0...10
    var numbness: Bool = false
    var stiffness: Stiffness = .none
    var notes: String = ""
}

struct DayLog: Codable {
    var dateISO: String               // yyyy-MM-dd
    // entries[BodyArea.rawValue] -> [TimeSlot.rawValue: SymptomCell]
    var entries: [String: [String: SymptomCell]] = [:]
}
