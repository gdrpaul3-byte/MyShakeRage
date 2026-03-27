import Foundation

final class RecordingStore {
    private let fileManager: FileManager
    private let baseDirectoryURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        fileManager: FileManager = .default,
        baseDirectoryURL: URL? = nil
    ) {
        self.fileManager = fileManager
        self.baseDirectoryURL = baseDirectoryURL ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func loadRecordings() throws -> [RecordingItem] {
        guard fileManager.fileExists(atPath: metadataURL.path) else {
            return []
        }

        let data = try Data(contentsOf: metadataURL)
        let recordings = try decoder.decode([RecordingItem].self, from: data)
        return recordings.sorted { lhs, rhs in
            if lhs.updatedAt == rhs.updatedAt {
                return lhs.createdAt > rhs.createdAt
            }
            return lhs.updatedAt > rhs.updatedAt
        }
    }

    func saveNewRecording(
        from temporaryFileURL: URL,
        displayName: String,
        intensity: ShakeIntensity,
        duration: TimeInterval,
        now: Date = .now
    ) throws -> RecordingItem {
        try ensureDirectoriesExist()

        let fileName = "\(UUID().uuidString).m4a"
        let destinationURL = recordingsDirectoryURL.appendingPathComponent(fileName)
        try fileManager.copyItem(at: temporaryFileURL, to: destinationURL)

        let item = RecordingItem(
            displayName: displayName,
            intensity: intensity,
            fileName: fileName,
            createdAt: now,
            updatedAt: now,
            duration: duration
        )

        var recordings = try loadRecordings()
        recordings.append(item)
        try persist(recordings)
        return item
    }

    func updateRecording(_ recording: RecordingItem) throws {
        var recordings = try loadRecordings()
        guard let index = recordings.firstIndex(where: { $0.id == recording.id }) else {
            return
        }

        recordings[index] = recording
        try persist(recordings)
    }

    func deleteRecording(_ recording: RecordingItem) throws {
        var recordings = try loadRecordings()
        recordings.removeAll { $0.id == recording.id }

        let fileURL = url(for: recording)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }

        try persist(recordings)
    }

    func url(for recording: RecordingItem) -> URL {
        recordingsDirectoryURL.appendingPathComponent(recording.fileName)
    }

    #if DEBUG
    func replaceAllRecordingsForTesting(_ recordings: [RecordingItem]) throws {
        try ensureDirectoriesExist()
        try persist(recordings)
    }
    #endif

    private var recordingsDirectoryURL: URL {
        baseDirectoryURL.appendingPathComponent("Recordings", isDirectory: true)
    }

    private var metadataURL: URL {
        baseDirectoryURL.appendingPathComponent("recordings.json")
    }

    private func ensureDirectoriesExist() throws {
        try fileManager.createDirectory(at: recordingsDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    }

    private func persist(_ recordings: [RecordingItem]) throws {
        try ensureDirectoriesExist()
        let data = try encoder.encode(recordings)
        try data.write(to: metadataURL, options: .atomic)
    }
}
