import SwiftUI

struct ShakeMeterView: View {
    let magnitude: Double
    let intensity: ShakeIntensity?
    let cooldownRatio: Double
    let showsDebugOverlay: Bool

    var body: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Live Shake")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "%.2f", magnitude))
                        .font(.system(.title3, design: .rounded).weight(.bold))
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.18))

                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [meterColor.opacity(0.7), meterColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * meterProgress)
                    }
                }
                .frame(height: 24)
            }

            HStack {
                IntensityBadge(intensity: intensity)
                Spacer()
                Text(cooldownRatio > 0 ? "Cooling down" : "Ready")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if showsDebugOverlay {
                VStack(alignment: .leading, spacing: 6) {
                    thresholdRow(label: "Weak", value: "1.5 - 2.5")
                    thresholdRow(label: "Medium", value: "2.5 - 4.0")
                    thresholdRow(label: "Strong", value: "4.0 - 6.0")
                    thresholdRow(label: "Extreme", value: "6.0+")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
        )
    }

    private var meterProgress: Double {
        min(max(magnitude / 8.0, 0), 1)
    }

    private var meterColor: Color {
        switch intensity {
        case .weak:
            .yellow
        case .medium:
            .orange
        case .strong:
            .red
        case .extreme:
            .pink
        case nil:
            .mint
        }
    }

    private func thresholdRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
    }
}
