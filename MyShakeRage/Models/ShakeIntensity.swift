import Foundation

enum ShakeIntensity: String, Codable, CaseIterable, Identifiable, Sendable {
    case weak
    case medium
    case strong
    case extreme

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weak:
            "Weak"
        case .medium:
            "Medium"
        case .strong:
            "Strong"
        case .extreme:
            "Extreme"
        }
    }
}
