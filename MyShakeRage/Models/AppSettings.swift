import Foundation

struct AppSettings: Codable, Equatable, Sendable {
    var baseSensitivity: Double
    var cooldownInterval: TimeInterval
    var hapticsEnabled: Bool
    var hapticStrength: HapticStrength
    var playbackMode: PlaybackMode
    var debugOverlayEnabled: Bool

    static let `default` = AppSettings(
        baseSensitivity: 1.0,
        cooldownInterval: 1.5,
        hapticsEnabled: true,
        hapticStrength: .medium,
        playbackMode: .byIntensity,
        debugOverlayEnabled: false
    )
}
