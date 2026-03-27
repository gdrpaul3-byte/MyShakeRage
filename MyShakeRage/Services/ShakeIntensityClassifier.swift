import Foundation

struct ShakeIntensityClassifier: Sendable {
    func classify(magnitude: Double, sensitivity: Double) -> ShakeIntensity? {
        let adjustedMagnitude = magnitude * max(sensitivity, 0.1)

        switch adjustedMagnitude {
        case ..<1.5:
            nil
        case 1.5..<2.5:
            .weak
        case 2.5..<4.0:
            .medium
        case 4.0..<6.0:
            .strong
        default:
            .extreme
        }
    }
}
