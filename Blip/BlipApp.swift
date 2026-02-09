import SwiftUI
import SwiftData
import WidgetKit

@main
struct BlipApp: App {
    var body: some Scene {
        WindowGroup {
            CounterListView()
        }
        .modelContainer(SharedModelContainer.container)
    }

    init() {
        migrateToAppGroupIfNeeded()
        performAutoResets()
    }

    private func migrateToAppGroupIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: "didMigrateToAppGroup") else { return }

        let fileManager = FileManager.default
        let defaultStoreURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appending(path: "default.store")
        let sharedURL = SharedModelContainer.url

        guard fileManager.fileExists(atPath: defaultStoreURL.path()) else {
            defaults.set(true, forKey: "didMigrateToAppGroup")
            return
        }
        guard !fileManager.fileExists(atPath: sharedURL.path()) else {
            defaults.set(true, forKey: "didMigrateToAppGroup")
            return
        }

        do {
            let dir = sharedURL.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: dir.path()) {
                try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
            }
            // Copy main store and associated files
            for suffix in ["", "-wal", "-shm"] {
                let src = URL(fileURLWithPath: defaultStoreURL.path() + suffix)
                let dst = URL(fileURLWithPath: sharedURL.path() + suffix)
                if fileManager.fileExists(atPath: src.path) {
                    try fileManager.copyItem(at: src, to: dst)
                }
            }
        } catch {
            // Migration failed — first launch will create a fresh store
        }

        defaults.set(true, forKey: "didMigrateToAppGroup")
    }

    private func performAutoResets() {
        let container: ModelContainer
        do {
            container = try SharedModelContainer.makeContainer()
        } catch {
            return
        }
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<Counter>()
        guard let counters = try? context.fetch(descriptor) else { return }

        let calendar = Calendar.current
        let now = Date()
        var didReset = false

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
                didReset = true
            }
        }

        try? context.save()

        if didReset {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
