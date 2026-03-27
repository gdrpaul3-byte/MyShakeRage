import AVFoundation
import Foundation

@MainActor
final class RecordingSessionViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate {
    let id = UUID()

    enum PermissionState {
        case undetermined
        case granted
        case denied
    }

    @Published private(set) var permissionState: PermissionState
    @Published private(set) var isRecording = false
    @Published private(set) var hasRecordedClip = false
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var meterLevels: [Double] = Array(repeating: 0.08, count: 20)
    @Published var draftName = ""
    @Published var selectedIntensity: ShakeIntensity = .weak
    @Published var alertMessage: String?

    private let appModel: AppModel
    private let onSave: () -> Void

    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var temporaryFileURL: URL?
    private var recordedDuration: TimeInterval = 0

    init(appModel: AppModel, onSave: @escaping () -> Void = {}) {
        self.appModel = appModel
        self.onSave = onSave

        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            permissionState = .granted
        case .denied:
            permissionState = .denied
        default:
            permissionState = .undetermined
        }

        super.init()
    }

    func prepare() {
        if permissionState == .undetermined {
            requestPermission()
        }
    }

    func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            Task { @MainActor [weak self] in
                self?.permissionState = granted ? .granted : .denied
            }
        }
    }

    func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    func startRecording() {
        guard permissionState == .granted else {
            requestPermission()
            return
        }

        do {
            try AVAudioSession.sharedInstance().configureMyShakeRageRecording()

            let tempURL = makeTemporaryURL()
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let recorder = try AVAudioRecorder(url: tempURL, settings: settings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true

            guard recorder.record() else {
                alertMessage = "Recording could not start."
                return
            }

            self.recorder = recorder
            temporaryFileURL = tempURL
            elapsedTime = 0
            recordedDuration = 0
            hasRecordedClip = false
            isRecording = true
            draftName = ""
            startTimer()
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func stopRecording() {
        guard let recorder else { return }

        recorder.stop()
        recordedDuration = recorder.currentTime
        isRecording = false
        hasRecordedClip = temporaryFileURL != nil
        stopTimer()
        AVAudioSession.sharedInstance().deactivateMyShakeRageSession()
    }

    func save() -> Bool {
        guard let temporaryFileURL else {
            alertMessage = "There is no recording to save yet."
            return false
        }

        let didSave = appModel.saveRecording(
            from: temporaryFileURL,
            displayName: draftName,
            intensity: selectedIntensity,
            duration: max(recordedDuration, elapsedTime)
        )

        guard didSave else {
            return false
        }

        cleanupAfterSaveOrDiscard(removeTempFile: true)
        onSave()
        return true
    }

    func discard() {
        cleanupAfterSaveOrDiscard(removeTempFile: true)
    }

    func recorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            alertMessage = "Recording stopped unexpectedly."
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateMeterLevels()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateMeterLevels() {
        guard let recorder else { return }

        recorder.updateMeters()
        elapsedTime = recorder.currentTime

        let averagePower = recorder.averagePower(forChannel: 0)
        let normalizedLevel = max(0.05, min(1.0, (averagePower + 60) / 60))

        meterLevels.removeFirst()
        meterLevels.append(normalizedLevel)
    }

    private func makeTemporaryURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")
    }

    private func cleanupAfterSaveOrDiscard(removeTempFile: Bool) {
        stopTimer()
        recorder?.stop()
        recorder = nil
        isRecording = false
        elapsedTime = 0
        recordedDuration = 0
        hasRecordedClip = false
        meterLevels = Array(repeating: 0.08, count: 20)
        draftName = ""
        selectedIntensity = .weak

        if removeTempFile, let temporaryFileURL {
            try? FileManager.default.removeItem(at: temporaryFileURL)
        }

        temporaryFileURL = nil
    }
}
