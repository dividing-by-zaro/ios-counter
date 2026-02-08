import SwiftUI
import SwiftData

@main
struct BlipApp: App {
    var body: some Scene {
        WindowGroup {
            CounterListView()
        }
        .modelContainer(for: Counter.self)
    }

    init() {
        performAutoResets()
    }

    private func performAutoResets() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: Counter.self)
        } catch {
            return
        }
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<Counter>()
        guard let counters = try? context.fetch(descriptor) else { return }

        let calendar = Calendar.current
        let now = Date()

        for counter in counters {
            guard counter.resetFrequency != .never else { continue }

            let shouldReset: Bool
            switch counter.resetFrequency {
            case .daily:
                shouldReset = !calendar.isDate(counter.lastResetDate, inSameDayAs: now)
            case .weekly:
                let lastWeek = calendar.component(.weekOfYear, from: counter.lastResetDate)
                let lastYear = calendar.component(.yearForWeekOfYear, from: counter.lastResetDate)
                let currentWeek = calendar.component(.weekOfYear, from: now)
                let currentYear = calendar.component(.yearForWeekOfYear, from: now)
                shouldReset = lastWeek != currentWeek || lastYear != currentYear
            case .monthly:
                let lastMonth = calendar.component(.month, from: counter.lastResetDate)
                let lastYear = calendar.component(.year, from: counter.lastResetDate)
                let currentMonth = calendar.component(.month, from: now)
                let currentYear = calendar.component(.year, from: now)
                shouldReset = lastMonth != currentMonth || lastYear != currentYear
            case .never:
                shouldReset = false
            }

            if shouldReset {
                counter.value = counter.resetValue
                counter.lastResetDate = now
            }
        }

        try? context.save()
    }
}
