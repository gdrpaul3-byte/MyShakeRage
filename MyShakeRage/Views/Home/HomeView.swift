import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    @State private var characterScale: CGFloat = 1
    @State private var characterRotation: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 26) {
                        topSummaryCard
                        characterCard
                        ShakeMeterView(
                            magnitude: viewModel.currentMagnitude,
                            intensity: viewModel.currentIntensity,
                            cooldownRatio: viewModel.cooldownRatio,
                            showsDebugOverlay: viewModel.debugOverlayEnabled
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("MyShakeRage")
        }
        .onChange(of: viewModel.animationToken) { _, _ in
            animateCharacter()
        }
    }

    private var topSummaryCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Today's shakes")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(viewModel.todayShakeCount)")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.red)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(viewModel.playbackModeName)
                    .font(.headline.weight(.bold))
                IntensityBadge(intensity: viewModel.currentIntensity)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.82))
        )
    }

    private var characterCard: some View {
        VStack(spacing: 18) {
            Text(characterEmoji)
                .font(.system(size: 120))
                .scaleEffect(characterScale)
                .rotationEffect(.degrees(characterRotation))
                .shadow(color: .white.opacity(0.45), radius: 12, y: 8)

            Text(viewModel.statusText)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)

            Text("Shake it now")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 36)
                .fill(Color.white.opacity(0.68))
        )
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var characterEmoji: String {
        switch viewModel.currentIntensity {
        case .weak:
            "😤"
        case .medium:
            "😠"
        case .strong:
            "🤬"
        case .extreme:
            "🤯"
        case nil:
            "😤"
        }
    }

    private var gradientColors: [Color] {
        switch viewModel.currentIntensity {
        case .weak:
            [Color(red: 1.0, green: 0.97, blue: 0.73), Color(red: 1.0, green: 0.78, blue: 0.40)]
        case .medium:
            [Color(red: 1.0, green: 0.90, blue: 0.65), Color(red: 1.0, green: 0.60, blue: 0.35)]
        case .strong:
            [Color(red: 1.0, green: 0.82, blue: 0.55), Color(red: 0.98, green: 0.36, blue: 0.28)]
        case .extreme:
            [Color(red: 1.0, green: 0.74, blue: 0.67), Color(red: 0.92, green: 0.18, blue: 0.34)]
        case nil:
            [Color(red: 1.0, green: 0.96, blue: 0.83), Color(red: 1.0, green: 0.82, blue: 0.47)]
        }
    }

    private func animateCharacter() {
        withAnimation(.spring(response: 0.22, dampingFraction: 0.4)) {
            characterScale = 1.18
            characterRotation = -8
        }

        withAnimation(.spring(response: 0.42, dampingFraction: 0.7).delay(0.08)) {
            characterScale = 1
            characterRotation = 6
        }

        withAnimation(.easeOut(duration: 0.16).delay(0.16)) {
            characterRotation = 0
        }
    }
}
