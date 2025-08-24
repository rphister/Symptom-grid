import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: LogStore
    @State private var showCSV = false
    @State private var csvURL: URL? = nil
    @State private var editingTarget: (BodyArea, TimeSlot)? = nil

    private let firstColumnWidth: CGFloat = 130

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                DatePicker("Date", selection: $store.selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(.horizontal)

                headerRow

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(BodyArea.allCases) { area in
                            HStack(spacing: 8) {
                                Text(area.rawValue)
                                    .frame(width: firstColumnWidth, alignment: .leading)
                                    .font(.callout.weight(.semibold))
                                    .padding(8)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.4)))

                                ForEach(TimeSlot.allCases) { time in
                                    CellSummaryView(
                                        cell: store.cell(for: area, time: time, date: store.selectedDate)
                                    )
                                    .onTapGesture {
                                        editingTarget = (area, time)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                HStack {
                    Button(role: .destructive) {
                        store.resetDay(for: store.selectedDate)
                    } label: {
                        Label("Reset Day", systemImage: "trash")
                    }

                    Spacer()

                    Button {
                        let exporter = CSVExporter(store: store)
                        if let url = exporter.exportCSV(for: store.selectedDate) {
                            csvURL = url
                            showCSV = true
                        }
                    } label: {
                        Label("Export CSV", systemImage: "square.and.arrow.up")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 6)
            }
            .navigationTitle("Symptom Grid")
        }
        .sheet(item: $editingTarget, content: { target in
            let area = target.0, time = target.1
            let current = store.cell(for: area, time: time, date: store.selectedDate)
            EditorSheet(
                area: area,
                time: time,
                initial: current,
                onSave: { updated in
                    store.setCell(updated, for: area, time: time, date: store.selectedDate)
                }
            )
            .presentationDetents([.fraction(0.7), .large])
        })
        .sheet(isPresented: $showCSV, onDismiss: { csvURL = nil }) {
            if let url = csvURL {
                ActivityView(activityItems: [url])
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 8) {
            Text("Symptom / Time")
                .frame(width: firstColumnWidth, alignment: .leading)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)

            ForEach(TimeSlot.allCases) { t in
                Text(t.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}

struct CellSummaryView: View {
    let cell: SymptomCell

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Pain: \(cell.pain)")
                Spacer()
                if cell.numbness { Image(systemName: "bolt.fill").accessibilityLabel("Numbness") }
            }
            Text(cell.stiffness.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
            if !cell.notes.isEmpty {
                Text(cell.notes)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.4)))
        .contentShape(Rectangle())
    }
}

extension (BodyArea, TimeSlot): Identifiable {
    public var id: String { "\(self.0.rawValue)-\(self.1.rawValue)" }
}
