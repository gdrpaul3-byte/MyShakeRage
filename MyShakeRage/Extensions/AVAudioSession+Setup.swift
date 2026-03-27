import AVFoundation

extension AVAudioSession {
    func configureMyShakeRagePlayback() throws {
        try setCategory(.playback, mode: .default, options: [.duckOthers])
        try setActive(true)
    }

    func configureMyShakeRageRecording() throws {
        try setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try setActive(true)
    }

    func deactivateMyShakeRageSession() {
        try? setActive(false, options: [.notifyOthersOnDeactivation])
    }
}
