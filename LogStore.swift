import Foundation
import SwiftUI

final class LogStore: ObservableObject {
    @Published var selectedDate: Date = Date() {
        didSet { ensureDayExists(for: selectedDate) }
    }
    @Published private(set) var dayLogs: [String: DayLog] = [:]

    private let fileName = "SymptomLogs.json"

    init() {
        load()
        ensureDayExists(for: selectedDate)
    }

    // MARK: - Date formatting
    private func key(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.timeZone = TimeZone.current
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    // MARK: - Accessors
    func dayLog(for date: Date) -> DayLog {
        let k = key(for: date)
        return dayLogs[k] ?? makeEmptyDay(forKey: k)
    }

    func cell(for area: BodyArea, time: TimeSlot, date: Date) -> SymptomCell {
        var log = dayLog(for: date)
        if let cell = log.entries[area.rawValue]?[time.rawValue] {
            return cell
        } else {
            let cell = SymptomCell()
            var row = log.entries[area.rawValue] ?? [:]
            row[time.rawValue] = cell
            log.entries[area.rawValue] = row
            dayLogs[key(for: date)] = log
            save()
            return cell
        }
    }

    func setCell(_ cell: SymptomCell, for area: BodyArea, time: TimeSlot, date: Date) {
        var log = dayLog(for: date)
        var row = log.entries[area.rawValue] ?? [:]
        row[time.rawValue] = cell
        log.entries[area.rawValue] = row
        dayLogs[key(for: date)] = log
        save()
    }

    func resetDay(for date: Date) {
        let k = key(for: date)
        dayLogs[k] = makeEmptyDay(forKey: k)
        save()
    }

    // MARK: - Persistence
    private var fileURL: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent(fileName)
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([String: DayLog].self, from: data)
            self.dayLogs = decoded
        } catch {
            // First run or failed to load – start empty
            self.dayLogs = [:]
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(dayLogs)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Failed to save: \(error)")
        }
    }

    private func ensureDayExists(for date: Date) {
        let k = key(for: date)
        if dayLogs[k] == nil {
            dayLogs[k] = makeEmptyDay(forKey: k)
            save()
        }
    }

    private func makeEmptyDay(forKey k: String) -> DayLog {
        var log = DayLog(dateISO: k, entries: [:])
        for area in BodyArea.allCases {
            var row: [String: SymptomCell] = [:]
            for time in TimeSlot.allCases {
                row[time.rawValue] = SymptomCell()
            }
            log.entries[area.rawValue] = row
        }
        return log
    }
}
