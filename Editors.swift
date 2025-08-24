import SwiftUI

struct EditorSheet: View {
    let area: BodyArea
    let time: TimeSlot
    @State var cell: SymptomCell
    var onSave: (SymptomCell) -> Void

    init(area: BodyArea, time: TimeSlot, initial: SymptomCell, onSave: @escaping (SymptomCell) -> Void) {
        self.area = area
        self.time = time
        self._cell = State(initialValue: initial)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("\(area.rawValue) – \(time.rawValue)")) {
                    HStack {
                        Text("Pain")
                        Spacer()
                        Text("\(cell.pain)")
                    }
                    Slider(value: Binding(
                        get: { Double(cell.pain) },
                        set: { cell.pain = Int($0.rounded()) }
                    ), in: 0...10, step: 1)

                    Toggle("Numbness", isOn: $cell.numbness)

                    Picker("Stiffness", selection: $cell.stiffness) {
                        ForEach(Stiffness.allCases) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }

                    TextField("Notes", text: $cell.notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(cell)
                        dismiss()
                    }
                }
            }
        }
    }

    @Environment(\._dismiss) private var dismiss
}
