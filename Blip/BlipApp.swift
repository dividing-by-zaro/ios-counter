import SwiftUI
import SwiftData

@main
struct BlipApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            CounterListView()
        }
        .modelContainer(SharedModelContainer.container)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                if CounterResetHelper.performResets(in: SharedModelContainer.container) {
                    WidgetReloader.requestReload()
                }
            }
        }
    }

    init() {
        migrateToAppGroupIfNeeded()
        CounterResetHelper.performResets(in: SharedModelContainer.container)
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
}
