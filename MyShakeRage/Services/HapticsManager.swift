import Foundation
import UIKit

@MainActor
final class HapticsManager {
    func trigger(intensity: ShakeIntensity, strength: HapticStrength, enabled: Bool) {
        guard enabled else { return }

        let generator = UIImpactFeedbackGenerator(style: feedbackStyle(for: intensity, strength: strength))
        generator.prepare()
        generator.impactOccurred(intensity: feedbackIntensity(for: intensity, strength: strength))
    }

    private func feedbackStyle(for intensity: ShakeIntensity, strength: HapticStrength) -> UIImpactFeedbackGenerator.FeedbackStyle {
        switch (intensity, strength) {
        case (.weak, .soft):
            .soft
        case (.weak, _), (.medium, .soft):
            .light
        case (.medium, _), (.strong, .soft):
            .medium
        case (.strong, _):
            .heavy
        case (.extreme, .soft):
            .heavy
        case (.extreme, _):
            .rigid
        }
    }

    private func feedbackIntensity(for intensity: ShakeIntensity, strength: HapticStrength) -> CGFloat {
        let base: CGFloat

        switch intensity {
        case .weak:
            base = 0.35
        case .medium:
            base = 0.6
        case .strong:
            base = 0.85
        case .extreme:
            base = 1.0
        }

        switch strength {
        case .soft:
            return max(base - 0.2, 0.2)
        case .medium:
            return base
        case .firm:
            return min(base + 0.1, 1.0)
        }
    }
}
