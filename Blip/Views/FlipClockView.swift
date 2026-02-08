import SwiftUI

// MARK: - Public API

struct FlipClockView: View {
    let value: Int
    var digitCount: Int = 1

    var body: some View {
        let absValue = abs(value)
        let raw = String(absValue)
        let minDigits = max(digitCount, raw.count)
        let padded = String(repeating: "0", count: max(0, minDigits - raw.count)) + raw

        HStack(spacing: 4) {
            if value < 0 {
                staticDigitCard("−")
            }
            ForEach(Array(padded.enumerated()), id: \.offset) { _, char in
                FlipView(text: String(char))
            }
        }
    }

    private func staticDigitCard(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 36, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 18, height: 48)
    }
}

// MARK: - Flip View (single digit with animation)

private struct FlipView: View {
    let text: String

    @State private var newValue: String
    @State private var oldValue: String
    @State private var animateTop = false
    @State private var animateBottom = false

    init(text: String) {
        self.text = text
        _newValue = State(initialValue: text)
        _oldValue = State(initialValue: text)
    }

    var body: some View {
        VStack(spacing: 1) {
            ZStack {
                SingleFlipView(text: newValue, type: .top)
                SingleFlipView(text: oldValue, type: .top)
                    .rotation3DEffect(
                        .degrees(animateTop ? -90 : 0),
                        axis: (1, 0, 0),
                        anchor: .bottom,
                        perspective: 0.5
                    )
            }
            ZStack {
                SingleFlipView(text: oldValue, type: .bottom)
                SingleFlipView(text: newValue, type: .bottom)
                    .rotation3DEffect(
                        .degrees(animateBottom ? 0 : 90),
                        axis: (1, 0, 0),
                        anchor: .top,
                        perspective: 0.5
                    )
            }
        }
        .fixedSize()
        .onChange(of: text) { old, new in
            oldValue = old
            animateTop = false
            animateBottom = false

            withAnimation(.easeIn(duration: 0.2)) {
                newValue = new
                animateTop = true
            }
            withAnimation(.easeOut(duration: 0.2).delay(0.2)) {
                animateBottom = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                oldValue = new
            }
        }
    }
}

// MARK: - Half-card view (top or bottom slice of a digit)

private struct SingleFlipView: View {
    let text: String
    let type: FlipType

    enum FlipType {
        case top, bottom

        var clippedEdge: Edge.Set {
            self == .top ? .bottom : .top
        }
        var paddingEdges: Edge.Set {
            self == .top ? [.top, .leading, .trailing] : [.bottom, .leading, .trailing]
        }
        var alignment: Alignment {
            self == .top ? .bottom : .top
        }
        var cornerRadii: UnevenRoundedRectangle {
            switch self {
            case .top:
                UnevenRoundedRectangle(topLeadingRadius: 6, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 6)
            case .bottom:
                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 6, bottomTrailingRadius: 6, topTrailingRadius: 0)
            }
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: 42, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .fixedSize()
            .padding(type.clippedEdge, -22)
            .frame(width: 36, height: 26, alignment: type.alignment)
            .padding(type.paddingEdges, 6)
            .clipped()
            .background(type == .top ? Color(white: 0.18) : Color(white: 0.13))
            .clipShape(type.cornerRadii)
            .padding(type.clippedEdge, -3.5)
            .clipped()
    }
}
