import AVFoundation
import Foundation

enum AudioEngineError: LocalizedError {
    case playbackFailed

    var errorDescription: String? {
        switch self {
        case .playbackFailed:
            "The selected sound could not be played."
        }
    }
}

@MainActor
final class AudioEngine: NSObject {
    private var player: AVAudioPlayer?

    func play(url: URL) throws {
        try AVAudioSession.sharedInstance().configureMyShakeRagePlayback()
        player?.stop()

        let player = try AVAudioPlayer(contentsOf: url)
        player.prepareToPlay()

        guard player.play() else {
            throw AudioEngineError.playbackFailed
        }

        self.player = player
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
