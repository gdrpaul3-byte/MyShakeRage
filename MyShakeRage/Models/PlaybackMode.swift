import Foundation

enum PlaybackMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case byIntensity
    case random

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .byIntensity:
            "By Intensity"
        case .random:
            "Random"
        }
    }
}
