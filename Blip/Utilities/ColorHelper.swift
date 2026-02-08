import SwiftUI
import UIKit

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double((rgbValue & 0x0000FF)) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    var hexString: String {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0]
        let r = Int((components[0] * 255).rounded())
        let g = Int((components[1] * 255).rounded())
        let b = Int((components[2] * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

struct ColorHelper {
    static let presetColors: [(name: String, color: Color)] = [
        ("coral", Color(hex: "#F43F5E")),
        ("tangerine", Color(hex: "#F97316")),
        ("amber", Color(hex: "#EAB308")),
        ("emerald", Color(hex: "#10B981")),
        ("teal", Color(hex: "#14B8A6")),
        ("sky", Color(hex: "#0EA5E9")),
        ("cobalt", Color(hex: "#2563EB")),
        ("indigo", Color(hex: "#6366F1")),
        ("violet", Color(hex: "#8B5CF6")),
        ("fuchsia", Color(hex: "#D946EF")),
        ("slate", Color(hex: "#64748B")),
        ("zinc", Color(hex: "#3F3F46")),
    ]

    private static let legacyColorMap: [String: String] = [
        "red": "coral",
        "orange": "tangerine",
        "yellow": "amber",
        "green": "emerald",
        "blue": "cobalt",
        "purple": "violet",
        "pink": "fuchsia",
        "brown": "slate",
        "mint": "teal",
        "cyan": "sky",
    ]

    static func color(for name: String) -> Color {
        if name.hasPrefix("#") {
            return Color(hex: name)
        }
        let resolvedName = legacyColorMap[name] ?? name
        return presetColors.first(where: { $0.name == resolvedName })?.color ?? Color(hex: "#2563EB")
    }

    static func isCustomColor(_ name: String) -> Bool {
        name.hasPrefix("#") && !presetColors.contains(where: { $0.color.hexString == name })
    }
}
