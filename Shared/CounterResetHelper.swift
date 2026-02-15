import Foundation
import SwiftData

enum CounterResetHelper {
    /// Checks all counters and resets any that are past their reset boundary.
    /// Returns true if any counter was reset.
    @discardableResult
    static func performResets(in container: ModelContainer) -> Bool {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Counter>()
        guard let counters = try? context.fetch(descriptor) else { return false }

        let calendar = Calendar.current
        let now = Date()
        var didReset = false

        for counter in counters {
            if shouldReset(counter, calendar: calendar, now: now) {
                counter.value = counter.resetValue
                counter.lastResetDate = now
                counter.lastUpdatedDate = resetBoundary(for: counter, calendar: calendar, now: now)
                didReset = true
            }
        }

        try? context.save()
        return didReset
    }

    /// Whether a single counter needs to be reset right now.
    static func shouldReset(_ counter: Counter, calendar: Calendar = .current, now: Date = .init()) -> Bool {
        switch counter.resetFrequency {
        case .daily:
            return !calendar.isDate(counter.lastResetDate, inSameDayAs: now)
        case .weekly:
            let lastWeek = calendar.component(.weekOfYear, from: counter.lastResetDate)
            let lastYear = calendar.component(.yearForWeekOfYear, from: counter.lastResetDate)
            let currentWeek = calendar.component(.weekOfYear, from: now)
            let currentYear = calendar.component(.yearForWeekOfYear, from: now)
            return lastWeek != currentWeek || lastYear != currentYear
        case .monthly:
            let lastMonth = calendar.component(.month, from: counter.lastResetDate)
            let lastYear = calendar.component(.year, from: counter.lastResetDate)
            let currentMonth = calendar.component(.month, from: now)
            let currentYear = calendar.component(.year, from: now)
            return lastMonth != currentMonth || lastYear != currentYear
        case .never:
            return false
        }
    }

    /// The next reset boundary for a counter (e.g. next midnight for daily).
    /// Returns nil if the counter never resets.
    static func nextResetDate(for counter: Counter, calendar: Calendar = .current, after now: Date = .init()) -> Date? {
        switch counter.resetFrequency {
        case .daily:
            return calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        case .weekly:
            return calendar.nextDate(after: now, matching: DateComponents(weekday: calendar.firstWeekday), matchingPolicy: .nextTime)
        case .monthly:
            var components = calendar.dateComponents([.year, .month], from: now)
            components.month! += 1
            components.day = 1
            return calendar.date(from: components)
        case .never:
            return nil
        }
    }

    // MARK: - Private

    private static func resetBoundary(for counter: Counter, calendar: Calendar, now: Date) -> Date {
        switch counter.resetFrequency {
        case .daily:
            return calendar.startOfDay(for: now)
        case .weekly:
            return calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: now).date ?? calendar.startOfDay(for: now)
        case .monthly:
            return calendar.dateComponents([.calendar, .year, .month], from: now).date ?? calendar.startOfDay(for: now)
        case .never:
            return now
        }
    }
}
