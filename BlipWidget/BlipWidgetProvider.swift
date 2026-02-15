import WidgetKit
import SwiftData

struct CounterSnapshot {
    let title: String
    let value: Int
    let goal: Int?
}

struct CounterWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let value: Int
    let goal: Int?
    let digitCount: Int
    let isPlaceholder: Bool

    static var placeholder: CounterWidgetEntry {
        CounterWidgetEntry(
            date: .now,
            title: "Counter",
            value: 42,
            goal: 100,
            digitCount: 2,
            isPlaceholder: true
        )
    }
}

struct BlipWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CounterWidgetEntry {
        .placeholder
    }

    func snapshot(for configuration: SelectCounterIntent, in context: Context) async -> CounterWidgetEntry {
        await fetchEntry(for: configuration)?.entry ?? .placeholder
    }

    func timeline(for configuration: SelectCounterIntent, in context: Context) async -> Timeline<CounterWidgetEntry> {
        guard let result = await fetchEntry(for: configuration) else {
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
            return Timeline(entries: [.placeholder], policy: .after(nextUpdate))
        }

        var entries = [result.entry]
        let calendar = Calendar.current

        // Schedule a future entry at the reset boundary so the widget
        // shows the reset value around midnight (or week/month boundary).
        if let nextReset = result.nextResetDate {
            let resetEntry = CounterWidgetEntry(
                date: nextReset,
                title: result.entry.title,
                value: result.resetValue,
                goal: result.entry.goal,
                digitCount: result.entry.digitCount,
                isPlaceholder: false
            )
            entries.append(resetEntry)
            return Timeline(entries: entries, policy: .after(nextReset))
        }

        let nextUpdate = calendar.date(byAdding: .minute, value: 30, to: .now)!
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }

    private struct FetchResult {
        let entry: CounterWidgetEntry
        let nextResetDate: Date?
        let resetValue: Int
    }

    private func fetchEntry(for configuration: SelectCounterIntent) async -> FetchResult? {
        guard let counterID = configuration.counter?.id,
              let uuid = UUID(uuidString: counterID) else {
            return nil
        }

        do {
            let container = try SharedModelContainer.makeContainer()
            let modelContext = ModelContext(container)
            let descriptor = FetchDescriptor<Counter>(
                predicate: #Predicate<Counter> { $0.id == uuid }
            )
            guard let counter = try modelContext.fetch(descriptor).first else { return nil }

            // Apply pending reset if needed
            if CounterResetHelper.shouldReset(counter) {
                counter.value = counter.resetValue
                counter.lastResetDate = Date()
                try? modelContext.save()
            }

            let entry = CounterWidgetEntry(
                date: .now,
                title: counter.title,
                value: counter.value,
                goal: counter.goal,
                digitCount: counter.digitCount,
                isPlaceholder: false
            )

            return FetchResult(
                entry: entry,
                nextResetDate: CounterResetHelper.nextResetDate(for: counter),
                resetValue: counter.resetValue
            )
        } catch {
            return nil
        }
    }
}

struct MultiCounterWidgetEntry: TimelineEntry {
    let date: Date
    let counters: [CounterSnapshot]
    let isPlaceholder: Bool

    static var placeholder: MultiCounterWidgetEntry {
        MultiCounterWidgetEntry(
            date: .now,
            counters: [
                CounterSnapshot(title: "Steps", value: 4200, goal: 10000),
                CounterSnapshot(title: "Water", value: 5, goal: 8),
            ],
            isPlaceholder: true
        )
    }
}

struct BlipMultiWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MultiCounterWidgetEntry {
        .placeholder
    }

    func snapshot(for configuration: SelectCountersIntent, in context: Context) async -> MultiCounterWidgetEntry {
        await fetchEntry(for: configuration).entry
    }

    func timeline(for configuration: SelectCountersIntent, in context: Context) async -> Timeline<MultiCounterWidgetEntry> {
        let result = await fetchEntry(for: configuration)
        let calendar = Calendar.current
        var entries = [result.entry]

        // Schedule a future entry at the earliest reset boundary
        if let nextReset = result.earliestResetDate {
            let resetEntry = MultiCounterWidgetEntry(
                date: nextReset,
                counters: result.resetSnapshots,
                isPlaceholder: false
            )
            entries.append(resetEntry)
            return Timeline(entries: entries, policy: .after(nextReset))
        }

        let nextUpdate = calendar.date(byAdding: .minute, value: 30, to: .now)!
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }

    private struct MultiFetchResult {
        let entry: MultiCounterWidgetEntry
        let earliestResetDate: Date?
        let resetSnapshots: [CounterSnapshot]
    }

    private func fetchEntry(for configuration: SelectCountersIntent) async -> MultiFetchResult {
        let ids = configuration.counters.compactMap { UUID(uuidString: $0.id) }
        guard !ids.isEmpty else {
            return MultiFetchResult(entry: .placeholder, earliestResetDate: nil, resetSnapshots: [])
        }

        do {
            let container = try SharedModelContainer.makeContainer()
            let modelContext = ModelContext(container)
            let descriptor = FetchDescriptor<Counter>(sortBy: [SortDescriptor(\.sortOrder)])
            let allCounters = try modelContext.fetch(descriptor)
            let matched = allCounters.filter { ids.contains($0.id) }
            guard !matched.isEmpty else {
                return MultiFetchResult(entry: .placeholder, earliestResetDate: nil, resetSnapshots: [])
            }

            // Apply pending resets
            var didReset = false
            for counter in matched where CounterResetHelper.shouldReset(counter) {
                counter.value = counter.resetValue
                counter.lastResetDate = Date()
                didReset = true
            }
            if didReset { try? modelContext.save() }

            let snapshots = matched.map { CounterSnapshot(title: $0.title, value: $0.value, goal: $0.goal) }
            let entry = MultiCounterWidgetEntry(date: .now, counters: snapshots, isPlaceholder: false)

            // Find the earliest upcoming reset across all matched counters
            let nextResets = matched.compactMap { CounterResetHelper.nextResetDate(for: $0) }
            let earliestReset = nextResets.min()

            // Build snapshots showing what each counter looks like after that reset
            let resetSnapshots = matched.map { counter -> CounterSnapshot in
                if let next = CounterResetHelper.nextResetDate(for: counter), next == earliestReset {
                    return CounterSnapshot(title: counter.title, value: counter.resetValue, goal: counter.goal)
                }
                return CounterSnapshot(title: counter.title, value: counter.value, goal: counter.goal)
            }

            return MultiFetchResult(entry: entry, earliestResetDate: earliestReset, resetSnapshots: resetSnapshots)
        } catch {
            return MultiFetchResult(entry: .placeholder, earliestResetDate: nil, resetSnapshots: [])
        }
    }
}
