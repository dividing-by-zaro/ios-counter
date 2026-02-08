import Foundation
import SwiftData

enum ResetFrequency: String, Codable, CaseIterable {
    case never
    case daily
    case weekly
    case monthly
}

@Model
final class Counter {
    var id: UUID
    var title: String
    var value: Int
    var stepIncrement: Int
    var goal: Int?
    var colorName: String
    var resetValue: Int
    var resetFrequency: ResetFrequency
    var lastResetDate: Date
    var createdAt: Date
    var sortOrder: Int
    var digitCount: Int
    var lastUpdatedDate: Date

    init(
        title: String = "Counter",
        value: Int = 0,
        stepIncrement: Int = 1,
        goal: Int? = nil,
        colorName: String = "blue",
        resetValue: Int = 0,
        resetFrequency: ResetFrequency = .never,
        sortOrder: Int = 0,
        digitCount: Int = 1
    ) {
        self.id = UUID()
        self.title = title
        self.value = value
        self.stepIncrement = stepIncrement
        self.goal = goal
        self.colorName = colorName
        self.resetValue = resetValue
        self.resetFrequency = resetFrequency
        self.lastResetDate = Date()
        self.createdAt = Date()
        self.sortOrder = sortOrder
        self.digitCount = digitCount
        self.lastUpdatedDate = Date()
    }
}
