import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var currentMagnitude: Double
    @Published private(set) var currentIntensity: ShakeIntensity?
    @Published private(set) var todayShakeCount: Int
    @Published private(set) var statusText: String
    @Published private(set) var playbackModeName: String
    @Published private(set) var debugOverlayEnabled: Bool
    @Published private(set) var cooldownRatio: Double = 0
    @Published private(set) var animationToken = UUID()

    private let appModel: AppModel
    private var cancellables: Set<AnyCancellable> = []

    init(appModel: AppModel) {
        self.appModel = appModel
        currentMagnitude = appModel.shakeEngine.currentMagnitude
        currentIntensity = appModel.shakeEngine.currentIntensity
        todayShakeCount = appModel.todayShakeCount
        statusText = appModel.homeStatusMessage ?? "Shake it now"
        playbackModeName = appModel.settings.playbackMode.displayName
        debugOverlayEnabled = appModel.settings.debugOverlayEnabled

        bind()
    }

    private func bind() {
        appModel.shakeEngine.$currentMagnitude
            .receive(on: RunLoop.main)
            .sink { [weak self] magnitude in
                self?.currentMagnitude = magnitude
            }
            .store(in: &cancellables)

        appModel.shakeEngine.$currentIntensity
            .receive(on: RunLoop.main)
            .sink { [weak self] intensity in
                self?.currentIntensity = intensity
            }
            .store(in: &cancellables)

        appModel.shakeEngine.$cooldownRemaining
            .receive(on: RunLoop.main)
            .sink { [weak self] remaining in
                guard let self else { return }
                let total = max(self.appModel.settings.cooldownInterval, 0.001)
                self.cooldownRatio = min(max(remaining / total, 0), 1)
            }
            .store(in: &cancellables)

        appModel.$todayShakeCount
            .receive(on: RunLoop.main)
            .sink { [weak self] count in
                self?.todayShakeCount = count
            }
            .store(in: &cancellables)

        appModel.$homeStatusMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                self?.statusText = message ?? "Shake it now"
            }
            .store(in: &cancellables)

        appModel.$settings
            .receive(on: RunLoop.main)
            .sink { [weak self] settings in
                self?.playbackModeName = settings.playbackMode.displayName
                self?.debugOverlayEnabled = settings.debugOverlayEnabled
            }
            .store(in: &cancellables)

        appModel.$playbackPulseToken
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] token in
                self?.animationToken = token
            }
            .store(in: &cancellables)
    }
}
