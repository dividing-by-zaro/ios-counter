import Foundation
import SwiftData

enum SharedModelContainer {
    static let appGroupID = "group.com.izaro.blip"

    static var url: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
            .appending(path: "Blip.sqlite")
    }

    @MainActor
    static var container: ModelContainer = {
        let schema = Schema([Counter.self])
        let config = ModelConfiguration("Blip", url: url)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    private static let _widgetContainer: ModelContainer = {
        let schema = Schema([Counter.self])
        let config = ModelConfiguration("Blip", url: url)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    static func makeContainer() throws -> ModelContainer {
        _widgetContainer
    }
}
