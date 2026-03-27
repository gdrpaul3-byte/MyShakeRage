import SwiftUI

struct AlertContext: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
}

@MainActor
final class AppModel: ObservableObject {
    @Published var settings: AppSettings
    @Published private(set) var recordings: [RecordingItem] = []
    @Published private(set) var bundledSamples: [RecordingItem] = []
    @Published private(set) var todayShakeCount: Int
    @Published private(set) var playbackPulseToken = UUID()
    @Published private(set) var lastTriggeredIntensity: ShakeIntensity?
    @Published var homeStatusMessage: String?
    @Published var activeAlert: AlertContext?

    let shakeEngine: ShakeEngine
    let audioEngine: AudioEngine
    let recordingStore: RecordingStore
    let settingsStore: SettingsStore
    let hapticsManager: HapticsManager

    private let playbackSelector: PlaybackSelector
    private let bundle: Bundle
    private var statusResetTask: Task<Void, Never>?

    init(
        shakeEngine: ShakeEngine = ShakeEngine(),
        audioEngine: AudioEngine = AudioEngine(),
        recordingStore: RecordingStore = RecordingStore(),
        settingsStore: SettingsStore = SettingsStore(),
        hapticsManager: HapticsManager = HapticsManager(),
        playbackSelector: PlaybackSelector = PlaybackSelector(),
        bundle: Bundle = .main
    ) {
        self.shakeEngine = shakeEngine
        self.audioEngine = audioEngine
        self.recordingStore = recordingStore
        self.settingsStore = settingsStore
        self.hapticsManager = hapticsManager
        self.playbackSelector = playbackSelector
        self.bundle = bundle

        let initialSettings = settingsStore.loadSettings()
        settings = initialSettings
        todayShakeCount = settingsStore.shakeCount(for: .now)

        bundledSamples = Self.loadBundledSamples(from: bundle)
        refreshRecordings()
        shakeEngine.applySettings(initialSettings)

        shakeEngine.onShake = { [weak self] event in
            self?.handleShake(event)
        }
    }

    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            todayShakeCount = settingsStore.shakeCount(for: .now)
            shakeEngine.start()
        case .inactive, .background:
            shakeEngine.stop()
        @unknown default:
            shakeEngine.stop()
        }
    }

    func updateSettings(_ mutate: (inout AppSettings) -> Void) {
        var copy = settings
        mutate(&copy)
        settings = copy
        shakeEngine.applySettings(copy)

        do {
            try settingsStore.saveSettings(copy)
        } catch {
            present(error, title: "Could not save settings")
        }
    }

    func refreshRecordings() {
        do {
            recordings = try recordingStore.loadRecordings()
        } catch {
            recordings = []
            present(error, title: "Could not load recordings")
        }
    }

    func playPreview(for item: RecordingItem) {
        do {
            guard let url = url(for: item) else {
                homeStatus("Missing audio file.")
                return
            }

            try audioEngine.play(url: url)
        } catch {
            present(error, title: "Playback failed")
        }
    }

    func saveRecording(from temporaryURL: URL, displayName: String, intensity: ShakeIntensity, duration: TimeInterval) -> Bool {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedName = trimmedName.isEmpty ? generatedRecordingName() : trimmedName

        do {
            _ = try recordingStore.saveNewRecording(
                from: temporaryURL,
                displayName: resolvedName,
                intensity: intensity,
                duration: duration
            )
            refreshRecordings()
            homeStatus("Saved \(resolvedName)")
            return true
        } catch {
            present(error, title: "Could not save recording")
            return false
        }
    }

    func updateRecording(id: UUID, displayName: String, intensity: ShakeIntensity) {
        guard var item = recordings.first(where: { $0.id == id }) else { return }

        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            item.displayName = trimmedName
        }

        item.intensity = intensity
        item.updatedAt = .now

        do {
            try recordingStore.updateRecording(item)
            refreshRecordings()
        } catch {
            present(error, title: "Could not update recording")
        }
    }

    func deleteRecording(_ item: RecordingItem) {
        do {
            try recordingStore.deleteRecording(item)
            refreshRecordings()
            homeStatus("Deleted \(item.displayName)")
        } catch {
            present(error, title: "Could not delete recording")
        }
    }

    private func handleShake(_ event: ShakeEvent) {
        let selected = playbackSelector.selectRecording(
            for: event.intensity,
            mode: settings.playbackMode,
            userRecordings: recordings,
            bundledSamples: bundledSamples
        )

        guard let selected else {
            lastTriggeredIntensity = event.intensity
            playbackPulseToken = UUID()
            homeStatus("No sound for this level yet")
            return
        }

        guard let url = url(for: selected) else {
            homeStatus("Missing audio file.")
            return
        }

        do {
            try audioEngine.play(url: url)
            hapticsManager.trigger(
                intensity: event.intensity,
                strength: settings.hapticStrength,
                enabled: settings.hapticsEnabled
            )
            settingsStore.incrementShakeCount()
            todayShakeCount = settingsStore.shakeCount(for: .now)
            lastTriggeredIntensity = event.intensity
            playbackPulseToken = UUID()
            homeStatus(selected.displayName)
        } catch {
            present(error, title: "Playback failed")
        }
    }

    private func url(for item: RecordingItem) -> URL? {
        if item.isBundledSample {
            let fileName = (item.fileName as NSString).deletingPathExtension
            let ext = (item.fileName as NSString).pathExtension
            return bundle.url(forResource: fileName, withExtension: ext, subdirectory: "BundledSamples")
        }

        return recordingStore.url(for: item)
    }

    private func generatedRecordingName() -> String {
        "Rage \(String(format: "%02d", recordings.count + 1))"
    }

    private func homeStatus(_ message: String) {
        statusResetTask?.cancel()
        homeStatusMessage = message

        statusResetTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            self?.homeStatusMessage = nil
        }
    }

    private func present(_ error: Error, title: String) {
        activeAlert = AlertContext(title: title, message: error.localizedDescription)
    }

    private static func loadBundledSamples(from bundle: Bundle) -> [RecordingItem] {
        ShakeIntensity.allCases.compactMap { intensity in
            let fileName = "sample_\(intensity.rawValue)_01.m4a"
            let resourceName = "sample_\(intensity.rawValue)_01"

            guard bundle.url(forResource: resourceName, withExtension: "m4a", subdirectory: "BundledSamples") != nil else {
                return nil
            }

            return RecordingItem(
                displayName: "\(intensity.displayName) Sample",
                intensity: intensity,
                fileName: fileName,
                duration: 0,
                isBundledSample: true
            )
        }
    }
}
