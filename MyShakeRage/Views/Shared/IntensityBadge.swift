import SwiftUI

struct IntensityBadge: View {
    let intensity: ShakeIntensity?

    var body: some View {
        Text(intensity?.displayName ?? "Idle")
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(color.opacity(0.9))
            )
    }

    private var color: Color {
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
            .gray
        }
    }
}
