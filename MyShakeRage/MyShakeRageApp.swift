import SwiftUI

@main
struct MyShakeRageApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var appModel: AppModel
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var recordingsViewModel: RecordingsViewModel

    init() {
        let appModel = AppModel()
        _appModel = StateObject(wrappedValue: appModel)
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(appModel: appModel))
        _recordingsViewModel = StateObject(wrappedValue: RecordingsViewModel(appModel: appModel))
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(
                appModel: appModel,
                homeViewModel: homeViewModel,
                recordingsViewModel: recordingsViewModel
            )
            .alert(item: $appModel.activeAlert) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onChange(of: scenePhase, initial: true) { _, newPhase in
                appModel.handleScenePhase(newPhase)
            }
        }
    }
}
