import SwiftUI
import SwiftData
import WidgetKit

struct CounterCardView: View {
    @Bindable var counter: Counter

    var body: some View {
        let bgColor = ColorHelper.color(for: counter.colorName)

        VStack(spacing: 12) {
            HStack {
                Text(counter.title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                if let goal = counter.goal {
                    if counter.value >= goal {
                        Label("Done", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.25))
                            .clipShape(Capsule())
                    } else {
                        Text("\(goal)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.25))
                            .clipShape(Capsule())
                    }
                }
            }

            HStack {
                Button {
                    counter.value -= counter.stepIncrement
                    counter.lastUpdatedDate = Date()
                    WidgetCenter.shared.reloadAllTimelines()
                } label: {
                    Image(systemName: "minus")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                FlipClockView(value: counter.value, digitCount: counter.digitCount)

                Spacer()

                Button {
                    counter.value += counter.stepIncrement
                    counter.lastUpdatedDate = Date()
                    WidgetCenter.shared.reloadAllTimelines()
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)

            HStack {
                Spacer()
                Text(formattedLastUpdated(counter.lastUpdatedDate))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(bgColor.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func formattedLastUpdated(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mma"
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"
            return formatter.string(from: date)
        }

        let daysAgo = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: now)).day ?? 0

        if daysAgo < 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE h:mma"
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"
            return formatter.string(from: date)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}
