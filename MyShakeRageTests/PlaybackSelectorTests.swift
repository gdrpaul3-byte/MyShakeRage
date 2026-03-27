import XCTest
@testable import MyShakeRage

final class PlaybackSelectorTests: XCTestCase {
    func testIntensityModeSelectsOnlyMatchingUserRecording() {
        let matching = RecordingItem(displayName: "Match", intensity: .strong, fileName: "match.m4a", duration: 1)
        let other = RecordingItem(displayName: "Other", intensity: .weak, fileName: "other.m4a", duration: 1)
        let selector = PlaybackSelector(randomIndex: { _, _ in 0 })

        let selected = selector.selectRecording(
            for: .strong,
            mode: .byIntensity,
            userRecordings: [other, matching],
            bundledSamples: []
        )

        XCTAssertEqual(selected, matching)
    }

    func testIntensityModeFallsBackToBundledSample() {
        let bundled = RecordingItem(
            displayName: "Bundled",
            intensity: .medium,
            fileName: "sample_medium_01.m4a",
            duration: 1,
            isBundledSample: true
        )
        let selector = PlaybackSelector(randomIndex: { _, _ in 0 })

        let selected = selector.selectRecording(
            for: .medium,
            mode: .byIntensity,
            userRecordings: [],
            bundledSamples: [bundled]
        )

        XCTAssertEqual(selected, bundled)
    }

    func testRandomModeSelectsAcrossAllUserRecordings() {
        let weak = RecordingItem(displayName: "Weak", intensity: .weak, fileName: "weak.m4a", duration: 1)
        let extreme = RecordingItem(displayName: "Extreme", intensity: .extreme, fileName: "extreme.m4a", duration: 1)
        let selector = PlaybackSelector(randomIndex: { _, upperBound in upperBound - 1 })

        let selected = selector.selectRecording(
            for: .weak,
            mode: .random,
            userRecordings: [weak, extreme],
            bundledSamples: []
        )

        XCTAssertEqual(selected, extreme)
    }

    func testReturnsNilWhenNoCandidatesExist() {
        let selector = PlaybackSelector(randomIndex: { _, _ in 0 })

        let selected = selector.selectRecording(
            for: .weak,
            mode: .byIntensity,
            userRecordings: [],
            bundledSamples: []
        )

        XCTAssertNil(selected)
    }
}
