import SwiftUI
import WidgetKit

struct BlipWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: CounterWidgetEntry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        default:
            CircularWidgetView(entry: entry)
        }
    }
}

struct BlipWidget: Widget {
    let kind: String = "BlipWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCounterIntent.self,
            provider: BlipWidgetProvider()
        ) { entry in
            BlipWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Blip Counter")
        .description("Display a counter on your lock screen.")
        .supportedFamilies([.accessoryCircular, .accessoryInline])
    }
}

struct BlipMultiWidget: Widget {
    let kind: String = "BlipMultiWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCountersIntent.self,
            provider: BlipMultiWidgetProvider()
        ) { entry in
            MultiCounterRectangularView(entry: entry)
        }
        .configurationDisplayName("Blip Counters")
        .description("Display multiple counters on your lock screen.")
        .supportedFamilies([.accessoryRectangular])
    }
}
