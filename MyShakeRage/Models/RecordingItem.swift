import Foundation

struct RecordingItem: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var displayName: String
    var intensity: ShakeIntensity
    var fileName: String
    var createdAt: Date
    var updatedAt: Date
    var duration: TimeInterval
    var isBundledSample: Bool

    init(
        id: UUID = UUID(),
        displayName: String,
        intensity: ShakeIntensity,
        fileName: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        duration: TimeInterval,
        isBundledSample: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.intensity = intensity
        self.fileName = fileName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.duration = duration
        self.isBundledSample = isBundledSample
    }
}
