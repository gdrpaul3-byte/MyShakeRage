import Foundation

struct PlaybackSelector {
    typealias RandomIndexProvider = (_ lowerBound: Int, _ upperBound: Int) -> Int

    private let randomIndex: RandomIndexProvider

    init(randomIndex: @escaping RandomIndexProvider = { lowerBound, upperBound in
        Int.random(in: lowerBound..<upperBound)
    }) {
        self.randomIndex = randomIndex
    }

    func selectRecording(
        for intensity: ShakeIntensity,
        mode: PlaybackMode,
        userRecordings: [RecordingItem],
        bundledSamples: [RecordingItem]
    ) -> RecordingItem? {
        let pool: [RecordingItem]

        switch mode {
        case .byIntensity:
            let matchingUsers = userRecordings.filter { $0.intensity == intensity }
            if !matchingUsers.isEmpty {
                pool = matchingUsers
            } else {
                pool = bundledSamples.filter { $0.intensity == intensity }
            }
        case .random:
            pool = !userRecordings.isEmpty ? userRecordings : bundledSamples
        }

        guard !pool.isEmpty else {
            return nil
        }

        return pool[randomIndex(0, pool.count)]
    }
}
