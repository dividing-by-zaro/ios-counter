import SwiftUI
import WidgetKit

struct CircularWidgetView: View {
    let entry: CounterWidgetEntry

    var body: some View {
        Group {
            if let goal = entry.goal, goal > 0 {
                Gauge(value: Double(entry.value), in: 0...Double(goal)) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(entry.value)")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                }
                .gaugeStyle(.accessoryCircular)
            } else {
                Text("\(entry.value)")
                    .font(.system(.title2, design: .rounded, weight: .bold))
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct RectangularWidgetView: View {
    let entry: CounterWidgetEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("\(entry.value)")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.5)
            }

            Spacer()

            if let goal = entry.goal, goal > 0 {
                Gauge(value: Double(entry.value), in: 0...Double(goal)) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(entry.value)/\(goal)")
                        .font(.system(.caption2, design: .rounded))
                }
                .gaugeStyle(.accessoryCircular)
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct MultiCounterRectangularView: View {
    let entry: MultiCounterWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(Array(entry.counters.prefix(3).enumerated()), id: \.offset) { _, counter in
                HStack {
                    Text(counter.title)
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .lineLimit(1)
                    Spacer()
                    if let goal = counter.goal, goal > 0 {
                        Text("\(counter.value)/\(goal)")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                    } else {
                        Text("\(counter.value)")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                    }
                }
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct InlineWidgetView: View {
    let entry: CounterWidgetEntry

    var body: some View {
        Text("\(entry.title): \(entry.value)")
    }
}
