import Foundation

enum HapticStrength: String, Codable, CaseIterable, Identifiable, Sendable {
    case soft
    case medium
    case firm

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .soft:
            "Soft"
        case .medium:
            "Medium"
        case .firm:
            "Firm"
        }
    }
}
