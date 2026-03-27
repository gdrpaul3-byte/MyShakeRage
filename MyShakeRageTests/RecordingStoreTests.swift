import XCTest
@testable import MyShakeRage

final class RecordingStoreTests: XCTestCase {
    private var temporaryDirectory: TemporaryDirectory!
    private var store: RecordingStore!

    override func setUpWithError() throws {
        temporaryDirectory = try TemporaryDirectory()
        store = RecordingStore(baseDirectoryURL: temporaryDirectory.url)
    }

    override func tearDownWithError() throws {
        try temporaryDirectory.remove()
    }

    func testSaveNewRecordingWritesMetadataAndCopiesAudioFile() throws {
        let sourceURL = try makeSourceFile(named: "input.m4a")

        let saved = try store.saveNewRecording(
            from: sourceURL,
            displayName: "Angry",
            intensity: .strong,
            duration: 1.2
        )

        let loaded = try store.loadRecordings()
        XCTAssertEqual(loaded, [saved])
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.url(for: saved).path(percentEncoded: false)))
    }

    func testLoadRecordingsReturnsNewestFirst() throws {
        let older = RecordingItem(
            id: UUID(),
            displayName: "Older",
            intensity: .weak,
            fileName: "older.m4a",
            createdAt: Date(timeIntervalSince1970: 100),
            updatedAt: Date(timeIntervalSince1970: 100),
            duration: 1
        )
        let newer = RecordingItem(
            id: UUID(),
            displayName: "Newer",
            intensity: .medium,
            fileName: "newer.m4a",
            createdAt: Date(timeIntervalSince1970: 200),
            updatedAt: Date(timeIntervalSince1970: 200),
            duration: 1
        )

        try store.replaceAllRecordingsForTesting([older, newer])

        XCTAssertEqual(try store.loadRecordings(), [newer, older])
    }

    func testUpdateRecordingPersistsNameAndIntensity() throws {
        let sourceURL = try makeSourceFile(named: "editable.m4a")
        var saved = try store.saveNewRecording(from: sourceURL, displayName: "Before", intensity: .weak, duration: 1)

        saved.displayName = "After"
        saved.intensity = .extreme
        saved.updatedAt = Date(timeIntervalSince1970: 999)

        try store.updateRecording(saved)

        let loaded = try XCTUnwrap(try store.loadRecordings().first)
        XCTAssertEqual(loaded.displayName, "After")
        XCTAssertEqual(loaded.intensity, .extreme)
    }

    func testDeleteRecordingRemovesFileAndMetadata() throws {
        let sourceURL = try makeSourceFile(named: "delete.m4a")
        let saved = try store.saveNewRecording(from: sourceURL, displayName: "Delete", intensity: .medium, duration: 1)

        try store.deleteRecording(saved)

        XCTAssertTrue(try store.loadRecordings().isEmpty)
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.url(for: saved).path(percentEncoded: false)))
    }

    private func makeSourceFile(named fileName: String) throws -> URL {
        let url = temporaryDirectory.url.appendingPathComponent(fileName)
        try Data("audio".utf8).write(to: url)
        return url
    }
}
