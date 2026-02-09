import SwiftUI
import SwiftData

struct CounterListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Counter.sortOrder) private var counters: [Counter]

    @State private var showAddSheet = false
    @State private var counterToEdit: Counter?
    @State private var counterToDelete: Counter?
    @State private var showDeleteConfirmation = false

    var body: some View {
        GeometryReader { geo in
            let cardHeight: CGFloat = 170
            let totalContentHeight = CGFloat(counters.count) * cardHeight
            let verticalPadding = max(0, (geo.size.height - totalContentHeight) / 2)

            List {
                ForEach(counters) { counter in
                    CounterCardView(counter: counter)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                counterToDelete = counter
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                counterToEdit = counter
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .contentMargins(.vertical, verticalPadding, for: .scrollContent)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .padding(.trailing, 16)
            .padding(.top, 8)
        }
        .sheet(isPresented: $showAddSheet) {
            CounterEditView()
        }
        .sheet(item: $counterToEdit) { counter in
            CounterEditView(counter: counter)
        }
        .confirmationDialog("Delete this counter?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let counterToDelete {
                    modelContext.delete(counterToDelete)
                    WidgetReloader.requestReload()
                }
                counterToDelete = nil
            }
        }
        .preferredColorScheme(.dark)
    }
}
