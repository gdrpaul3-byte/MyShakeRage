import Combine
import Foundation

@MainActor
final class RecordingsViewModel: ObservableObject {
    @Published var selectedIntensity: ShakeIntensity?
    @Published var editingRecording: RecordingItem?
    @Published var deletionCandidate: RecordingItem?
    @Published private(set) var recordings: [RecordingItem] = []

    private let appModel: AppModel
    private var cancellables: Set<AnyCancellable> = []

    init(appModel: AppModel) {
        self.appModel = appModel
        recordings = appModel.recordings

        appModel.$recordings
            .receive(on: RunLoop.main)
            .sink { [weak self] recordings in
                self?.recordings = recordings
            }
            .store(in: &cancellables)
    }

    var filteredRecordings: [RecordingItem] {
        guard let selectedIntensity else { return recordings }
        return recordings.filter { $0.intensity == selectedIntensity }
    }

    func refresh() {
        appModel.refreshRecordings()
    }

    func preview(_ item: RecordingItem) {
        appModel.playPreview(for: item)
    }

    func confirmDelete(_ item: RecordingItem) {
        deletionCandidate = item
    }

    func deleteConfirmed() {
        guard let deletionCandidate else { return }
        appModel.deleteRecording(deletionCandidate)
        self.deletionCandidate = nil
    }

    func cancelDelete() {
        deletionCandidate = nil
    }

    func startEditing(_ item: RecordingItem) {
        editingRecording = item
    }

    func saveEdits(for id: UUID, displayName: String, intensity: ShakeIntensity) {
        appModel.updateRecording(id: id, displayName: displayName, intensity: intensity)
        editingRecording = nil
    }

    func makeRecordingSessionViewModel() -> RecordingSessionViewModel {
        RecordingSessionViewModel(appModel: appModel) { [weak self] in
            self?.refresh()
        }
    }
}
