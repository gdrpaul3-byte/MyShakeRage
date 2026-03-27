import SwiftUI

struct WaveformBarsView: View {
    let levels: [Double]

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                RoundedRectangle(cornerRadius: 8)
                    .fill(barGradient(index: index))
                    .frame(width: 10, height: max(18, 140 * level))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(.horizontal, 10)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.5))
        )
    }

    private func barGradient(index: Int) -> LinearGradient {
        let hueShift = Double(index) / Double(max(levels.count, 1))
        return LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.78 - (0.1 * hueShift), blue: 0.25),
                Color(red: 1.0, green: 0.36, blue: 0.28 + (0.2 * hueShift))
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
}
