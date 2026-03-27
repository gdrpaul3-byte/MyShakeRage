import AVFoundation
import SwiftUI
import UIKit

struct SettingsView: View {
    @ObservedObject var appModel: AppModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    sliderCard(
                        title: "Sensitivity",
                        subtitle: "Higher values trigger easier and feel more reactive.",
                        value: binding(
                            get: { appModel.settings.baseSensitivity },
                            set: { appModel.updateSettings { $0.baseSensitivity = $1 } }
                        ),
                        range: 0.7...1.6,
                        format: "%.2f"
                    )

                    sliderCard(
                        title: "Cooldown",
                        subtitle: "Stops rapid repeat playback after a hard shake.",
                        value: binding(
                            get: { appModel.settings.cooldownInterval },
                            set: { appModel.updateSettings { $0.cooldownInterval = $1 } }
                        ),
                        range: 0.8...3.0,
                        format: "%.1fs"
                    )

                    optionCard
                    permissionsCard
                    aboutCard
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.97, blue: 0.87), Color(red: 1.0, green: 0.91, blue: 0.82)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Settings")
        }
    }

    private var optionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Haptics", isOn: binding(
                get: { appModel.settings.hapticsEnabled },
                set: { appModel.updateSettings { $0.hapticsEnabled = $1 } }
            ))

            Picker("Haptic Strength", selection: binding(
                get: { appModel.settings.hapticStrength },
                set: { appModel.updateSettings { $0.hapticStrength = $1 } }
            )) {
                ForEach(HapticStrength.allCases) { strength in
                    Text(strength.displayName).tag(strength)
                }
            }
            .pickerStyle(.segmented)

            Picker("Playback Mode", selection: binding(
                get: { appModel.settings.playbackMode },
                set: { appModel.updateSettings { $0.playbackMode = $1 } }
            )) {
                ForEach(PlaybackMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Show Debug Overlay", isOn: binding(
                get: { appModel.settings.debugOverlayEnabled },
                set: { appModel.updateSettings { $0.debugOverlayEnabled = $1 } }
            ))
        }
        .padding(20)
        .background(cardBackground)
    }

    private var permissionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Microphone Access")
                .font(.headline)

            Text(permissionDescription)
                .foregroundStyle(.secondary)

            Button("Open App Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(cardBackground)
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)
            Text("MyShakeRage is a silly stress-relief toy. Shake your phone, hear a matching line, and keep everything safely on-device.")
            Text("Bundled sample slots are supported, but real sample files are not included yet.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(cardBackground)
    }

    private func sliderCard(
        title: String,
        subtitle: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        format: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(String(format: format, value.wrappedValue))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Slider(value: value, in: range)
                .tint(.red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(cardBackground)
    }

    private var permissionDescription: String {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            "Microphone access is enabled."
        case .denied:
            "Microphone access is currently denied."
        default:
            "Microphone access has not been decided yet."
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color.white.opacity(0.76))
    }

    private func binding<Value>(get: @escaping () -> Value, set: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: get, set: set)
    }
}
