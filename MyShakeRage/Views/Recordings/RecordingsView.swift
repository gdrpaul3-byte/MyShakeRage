import SwiftUI

struct RecordingsView: View {
    @ObservedObject var viewModel: RecordingsViewModel

    @State private var recordingSessionViewModel: RecordingSessionViewModel?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.98, blue: 0.88), Color(red: 1.0, green: 0.90, blue: 0.76)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        filterBar

                        if viewModel.filteredRecordings.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.filteredRecordings) { recording in
                                recordingCard(recording)
                            }
                        }
                    }
                    .padding(20)
                }

                Button {
                    recordingSessionViewModel = viewModel.makeRecordingSessionViewModel()
                } label: {
                    Label("Record", systemImage: "mic.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color.red)
                                .shadow(color: .red.opacity(0.25), radius: 10, y: 8)
                        )
                }
                .padding(22)
            }
            .navigationTitle("Recordings")
            .sheet(item: $recordingSessionViewModel) { sessionViewModel in
                RecordingSheet(viewModel: sessionViewModel)
            }
            .sheet(item: $viewModel.editingRecording) { recording in
                EditRecordingSheet(recording: recording) { name, intensity in
                    viewModel.saveEdits(for: recording.id, displayName: name, intensity: intensity)
                }
            }
            .confirmationDialog(
                "Delete this recording?",
                isPresented: Binding(
                    get: { viewModel.deletionCandidate != nil },
                    set: { if !$0 { viewModel.cancelDelete() } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteConfirmed()
                }
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDelete()
                }
            } message: {
                Text("The audio file and its saved label will both be removed.")
            }
            .task {
                viewModel.refresh()
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(title: "All", intensity: nil)
                ForEach(ShakeIntensity.allCases) { intensity in
                    filterChip(title: intensity.displayName, intensity: intensity)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Text("🎤")
                .font(.system(size: 64))
            Text("No recordings yet")
                .font(.title3.weight(.bold))
            Text("Make your first funny rage clip and assign it to a shake level.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.7))
        )
    }

    private func filterChip(title: String, intensity: ShakeIntensity?) -> some View {
        let isSelected = viewModel.selectedIntensity == intensity

        return Button {
            viewModel.selectedIntensity = intensity
        } label: {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.red : Color.white.opacity(0.72))
                )
        }
        .buttonStyle(.plain)
    }

    private func recordingCard(_ recording: RecordingItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(recording.displayName)
                        .font(.headline.weight(.bold))
                    Text(recording.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                IntensityBadge(intensity: recording.intensity)
            }

            HStack {
                Label(durationText(recording.duration), systemImage: "waveform")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                buttonRow(for: recording)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.75))
        )
    }

    private func buttonRow(for recording: RecordingItem) -> some View {
        HStack(spacing: 10) {
            Button("Play") {
                viewModel.preview(recording)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

            Button("Edit") {
                viewModel.startEditing(recording)
            }
            .buttonStyle(.bordered)

            Button("Delete", role: .destructive) {
                viewModel.confirmDelete(recording)
            }
            .buttonStyle(.bordered)
        }
        .font(.subheadline.weight(.semibold))
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
