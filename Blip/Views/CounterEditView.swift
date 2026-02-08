import SwiftUI
import SwiftData

struct CounterEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var counter: Counter?

    @State private var title: String = ""
    @State private var value: Int = 0
    @State private var stepIncrement: Int = 1
    @State private var hasGoal: Bool = false
    @State private var goal: Int = 100
    @State private var colorName: String = "blue"
    @State private var digitCount: Int = 1
    @State private var resetValue: Int = 0
    @State private var resetFrequency: ResetFrequency = .never
    @State private var showDeleteConfirmation = false

    private var isEditing: Bool { counter != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Counter name", text: $title)
                }

                Section("Value") {
                    LabeledContent("Current value") {
                        TextField("0", value: $value, format: .number)
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Step increment") {
                        TextField("1", value: $stepIncrement, format: .number)
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Digits to display") {
                    Picker("Digits shown", selection: $digitCount) {
                        Text("Auto").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Goal") {
                    Toggle("Set a goal", isOn: $hasGoal)
                    if hasGoal {
                        LabeledContent("Goal") {
                            TextField("100", value: $goal, format: .number)
                                .keyboardType(.numbersAndPunctuation)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(ColorHelper.presetColors, id: \.name) { preset in
                            Circle()
                                .fill(preset.color.gradient)
                                .frame(width: 36, height: 36)
                                .overlay {
                                    if colorName == preset.name {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                    }
                                }
                                .onTapGesture {
                                    colorName = preset.name
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Reset") {
                    LabeledContent("Reset to") {
                        TextField("0", value: $resetValue, format: .number)
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Reset frequency", selection: $resetFrequency) {
                        Text("Never").tag(ResetFrequency.never)
                        Text("Daily").tag(ResetFrequency.daily)
                        Text("Weekly").tag(ResetFrequency.weekly)
                        Text("Monthly").tag(ResetFrequency.monthly)
                    }
                }

                if isEditing {
                    Section {
                        Button("Delete Counter", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Counter" : "New Counter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .confirmationDialog("Delete this counter?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let counter {
                        modelContext.delete(counter)
                    }
                    dismiss()
                }
            }
            .onAppear {
                if let counter {
                    title = counter.title
                    value = counter.value
                    stepIncrement = counter.stepIncrement
                    hasGoal = counter.goal != nil
                    goal = counter.goal ?? 100
                    colorName = counter.colorName
                    digitCount = counter.digitCount
                    resetValue = counter.resetValue
                    resetFrequency = counter.resetFrequency
                }
            }
        }
    }

    private func save() {
        if let counter {
            counter.title = title
            counter.value = value
            counter.stepIncrement = stepIncrement
            counter.goal = hasGoal ? goal : nil
            counter.colorName = colorName
            counter.digitCount = digitCount
            counter.resetValue = resetValue
            counter.resetFrequency = resetFrequency
        } else {
            let newCounter = Counter(
                title: title,
                value: value,
                stepIncrement: stepIncrement,
                goal: hasGoal ? goal : nil,
                colorName: colorName,
                resetValue: resetValue,
                resetFrequency: resetFrequency,
                digitCount: digitCount
            )
            modelContext.insert(newCounter)
        }
    }
}
