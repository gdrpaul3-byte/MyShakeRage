import Combine
import CoreMotion
import Foundation

@MainActor
final class ShakeEngine: ObservableObject {
    @Published private(set) var currentMagnitude: Double = 0
    @Published private(set) var currentIntensity: ShakeIntensity?
    @Published private(set) var cooldownRemaining: TimeInterval = 0

    var onShake: ((ShakeEvent) -> Void)?

    private let motionManager: CMMotionManager
    private let classifier: ShakeIntensityClassifier
    private let updateQueue: OperationQueue

    private var sensitivity: Double
    private var cooldownInterval: TimeInterval
    private var lastTriggeredAt: Date?

    init(
        motionManager: CMMotionManager = CMMotionManager(),
        classifier: ShakeIntensityClassifier = ShakeIntensityClassifier(),
        sensitivity: Double = AppSettings.default.baseSensitivity,
        cooldownInterval: TimeInterval = AppSettings.default.cooldownInterval
    ) {
        self.motionManager = motionManager
        self.classifier = classifier
        self.sensitivity = sensitivity
        self.cooldownInterval = cooldownInterval

        let queue = OperationQueue()
        queue.name = "MyShakeRage.ShakeEngine"
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 1
        self.updateQueue = queue
    }

    func applySettings(_ settings: AppSettings) {
        sensitivity = settings.baseSensitivity
        cooldownInterval = settings.cooldownInterval
    }

    func start() {
        guard motionManager.isAccelerometerAvailable, !motionManager.isAccelerometerActive else {
            return
        }

        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.startAccelerometerUpdates(to: updateQueue) { [weak self] data, _ in
            guard let self, let data else { return }

            let magnitude = Self.magnitude(for: data.acceleration)
            let now = Date()
            let intensity = self.classifier.classify(magnitude: magnitude, sensitivity: self.sensitivity)

            Task { @MainActor [weak self] in
                self?.handleMotionSample(magnitude: magnitude, intensity: intensity, timestamp: now)
            }
        }
    }

    func stop() {
        motionManager.stopAccelerometerUpdates()
        currentMagnitude = 0
        currentIntensity = nil
        cooldownRemaining = 0
    }

    private func handleMotionSample(magnitude: Double, intensity: ShakeIntensity?, timestamp: Date) {
        currentMagnitude = magnitude
        currentIntensity = intensity

        guard let intensity else {
            cooldownRemaining = cooldownTimeRemaining(at: timestamp)
            return
        }

        let remaining = cooldownTimeRemaining(at: timestamp)
        cooldownRemaining = remaining

        guard remaining == 0 else {
            return
        }

        lastTriggeredAt = timestamp
        cooldownRemaining = cooldownInterval
        onShake?(ShakeEvent(magnitude: magnitude, intensity: intensity, timestamp: timestamp))
    }

    private func cooldownTimeRemaining(at timestamp: Date) -> TimeInterval {
        guard let lastTriggeredAt else {
            return 0
        }

        let elapsed = timestamp.timeIntervalSince(lastTriggeredAt)
        return max(cooldownInterval - elapsed, 0)
    }

    private static func magnitude(for acceleration: CMAcceleration) -> Double {
        let x = acceleration.x
        let y = acceleration.y
        let z = acceleration.z
        return sqrt((x * x) + (y * y) + (z * z))
    }
}
