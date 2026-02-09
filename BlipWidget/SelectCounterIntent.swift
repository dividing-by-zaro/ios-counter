import AppIntents
import SwiftData

struct CounterEntity: AppEntity {
    var id: String
    var title: String

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Counter")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }

    static var defaultQuery = CounterEntityQuery()
}

struct CounterEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [CounterEntity] {
        let container = try SharedModelContainer.makeContainer()
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Counter>()
        let counters = try context.fetch(descriptor)
        return counters
            .filter { identifiers.contains($0.id.uuidString) }
            .map { CounterEntity(id: $0.id.uuidString, title: $0.title) }
    }

    func suggestedEntities() async throws -> [CounterEntity] {
        let container = try SharedModelContainer.makeContainer()
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Counter>(sortBy: [SortDescriptor(\.sortOrder)])
        let counters = try context.fetch(descriptor)
        return counters.map { CounterEntity(id: $0.id.uuidString, title: $0.title) }
    }

    func defaultResult() async -> CounterEntity? {
        try? await suggestedEntities().first
    }
}

struct SelectCounterIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Counter"
    static var description = IntentDescription("Choose a counter to display")

    @Parameter(title: "Counter")
    var counter: CounterEntity?
}

struct SelectCountersIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Counters"
    static var description = IntentDescription("Choose counters to display")

    @Parameter(title: "Counters")
    var counters: [CounterEntity]
}
