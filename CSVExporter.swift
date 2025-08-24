import Foundation

final class CSVExporter {
    private let store: LogStore
    init(store: LogStore) { self.store = store }

    func exportCSV(for date: Date) -> URL? {
        let log = store.dayLog(for: date)
        var rows: [String] = []

        // Header
        rows.append("Area,Time,Pain,Numbness,Stiffness,Notes,Date")

        for area in BodyArea.allCases {
            let rowDict = log.entries[area.rawValue] ?? [:]
            for time in TimeSlot.allCases {
                let cell = rowDict[time.rawValue] ?? SymptomCell()
                let cols = [
                    area.rawValue,
                    time.rawValue,
                    String(cell.pain),
                    cell.numbness ? "Yes" : "No",
                    cell.stiffness.rawValue,
                    escape(cell.notes),
                    log.dateISO
                ]
                rows.append(cols.joined(separator: ","))
            }
        }

        let csv = rows.joined(separator: "\n")
        do {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("SymptomGrid_\(log.dateISO).csv")
            try csv.data(using: .utf8)?.write(to: url, options: [.atomic])
            return url
        } catch {
            print("CSV write error: \(error)")
            return nil
        }
    }

    private func escape(_ text: String) -> String {
        var t = text
        if t.contains("\"") || t.contains(",") || t.contains("\n") {
            t = "\"\(t.replacingOccurrences(of: "\"", with: "\\\""))\""
        }
        return t
    }
}
