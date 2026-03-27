import SwiftUI
import UIKit

struct RecordingSheet: View {
    @ObservedObject var viewModel: RecordingSessionViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.98, blue: 0.80), Color(red: 1.0, green: 0.86, blue: 0.73)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        permissionCard
                        WaveformBarsView(levels: viewModel.meterLevels)
                        timerCard
                        controlsSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Recording")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        viewModel.discard()
                        dismiss()
                    }
                }
            }
            .alert("Recording Issue", isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.alertMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    viewModel.alertMessage = nil
                }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
            .task {
                viewModel.prepare()
            }
        }
    }

    private var permissionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Microphone")
                .font(.headline)

            switch viewModel.permissionState {
            case .granted:
                Text("Ready to capture your funniest rage clip.")
                    .foregroundStyle(.secondary)
            case .undetermined:
                Text("We need mic access so you can record your own voice lines.")
                    .foregroundStyle(.secondary)
            case .denied:
                Text("Microphone access is off. Open Settings to enable recording.")
                    .foregroundStyle(.secondary)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.65))
        )
    }

    private var timerCard: some View {
        VStack(spacing: 8) {
            Text("Elapsed")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(formattedDuration(viewModel.elapsedTime))
                .font(.system(size: 40, weight: .black, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.7))
        )
    }

    private var controlsSection: some View {
        VStack(spacing: 18) {
            Button {
                viewModel.toggleRecording()
            } label: {
                ZStack {
                    Circle()
                        .fill(viewModel.isRecording ? Color.red : Color.orange)
                        .frame(width: 120, height: 120)
                    Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            if viewModel.hasRecordedClip {
                VStack(spacing: 14) {
                    TextField("Clip name", text: $viewModel.draftName)
                        .textFieldStyle(.roundedBorder)

                    Picker("Intensity", selection: $viewModel.selectedIntensity) {
                        ForEach(ShakeIntensity.allCases) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)

                    HStack(spacing: 12) {
                        Button("Discard", role: .destructive) {
                            viewModel.discard()
                        }
                        .buttonStyle(.bordered)

                        Button("Save") {
                            if viewModel.save() {
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white.opacity(0.72))
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
