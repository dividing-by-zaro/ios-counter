import SwiftUI

struct ColorHelper {
    static let presetColors: [(name: String, color: Color)] = [
        ("red", .red),
        ("orange", .orange),
        ("yellow", .yellow),
        ("green", .green),
        ("teal", .teal),
        ("blue", .blue),
        ("indigo", .indigo),
        ("purple", .purple),
        ("pink", .pink),
        ("brown", .brown),
        ("mint", .mint),
        ("cyan", .cyan),
    ]

    static func color(for name: String) -> Color {
        presetColors.first(where: { $0.name == name })?.color ?? .blue
    }
}
