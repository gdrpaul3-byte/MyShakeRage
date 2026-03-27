import Foundation

struct ShakeEvent: Equatable, Sendable {
    let magnitude: Double
    let intensity: ShakeIntensity
    let timestamp: Date
}
