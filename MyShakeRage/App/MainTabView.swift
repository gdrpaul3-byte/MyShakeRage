import SwiftUI

struct MainTabView: View {
    @ObservedObject var appModel: AppModel
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var recordingsViewModel: RecordingsViewModel

    var body: some View {
        TabView {
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label("Home", systemImage: "sparkles")
                }

            RecordingsView(viewModel: recordingsViewModel)
                .tabItem {
                    Label("Recordings", systemImage: "mic.circle.fill")
                }

            SettingsView(appModel: appModel)
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
        }
        .tint(.red)
    }
}
