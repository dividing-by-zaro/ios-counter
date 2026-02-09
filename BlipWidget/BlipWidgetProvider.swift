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
        await fetchEntry(for: configuration) ?? .placeholder
    }

    func timeline(for configuration: SelectCounterIntent, in context: Context) async -> Timeline<CounterWidgetEntry> {
        let entry = await fetchEntry(for: configuration) ?? .placeholder
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func fetchEntry(for configuration: SelectCounterIntent) async -> CounterWidgetEntry? {
        guard let counterID = configuration.counter?.id,
              let uuid = UUID(uuidString: counterID) else {
            return nil
        }

        do {
            let container = try SharedModelContainer.makeContainer()
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<Counter>(
                predicate: #Predicate<Counter> { $0.id == uuid }
            )
            guard let counter = try context.fetch(descriptor).first else { return nil }
            return CounterWidgetEntry(
                date: .now,
                title: counter.title,
                value: counter.value,
                goal: counter.goal,
                digitCount: counter.digitCount,
                isPlaceholder: false
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
        await fetchEntry(for: configuration)
    }

    func timeline(for configuration: SelectCountersIntent, in context: Context) async -> Timeline<MultiCounterWidgetEntry> {
        let entry = await fetchEntry(for: configuration)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func fetchEntry(for configuration: SelectCountersIntent) async -> MultiCounterWidgetEntry {
        let ids = configuration.counters.compactMap { UUID(uuidString: $0.id) }
        guard !ids.isEmpty else { return .placeholder }

        do {
            let container = try SharedModelContainer.makeContainer()
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<Counter>(sortBy: [SortDescriptor(\.sortOrder)])
            let allCounters = try context.fetch(descriptor)
            let matched = allCounters
                .filter { ids.contains($0.id) }
                .map { CounterSnapshot(title: $0.title, value: $0.value, goal: $0.goal) }
            guard !matched.isEmpty else { return .placeholder }
            return MultiCounterWidgetEntry(date: .now, counters: matched, isPlaceholder: false)
        } catch {
            return .placeholder
        }
    }
}
