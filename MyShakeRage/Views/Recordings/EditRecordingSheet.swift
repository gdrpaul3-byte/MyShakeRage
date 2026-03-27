import SwiftUI

struct EditRecordingSheet: View {
    let recording: RecordingItem
    let onSave: (String, ShakeIntensity) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draftName: String
    @State private var intensity: ShakeIntensity

    init(recording: RecordingItem, onSave: @escaping (String, ShakeIntensity) -> Void) {
        self.recording = recording
        self.onSave = onSave
        _draftName = State(initialValue: recording.displayName)
        _intensity = State(initialValue: recording.intensity)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Clip name", text: $draftName)
                }

                Section("Intensity") {
                    Picker("Intensity", selection: $intensity) {
                        ForEach(ShakeIntensity.allCases) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Edit Clip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draftName, intensity)
                        dismiss()
                    }
                }
            }
        }
    }
}
