import SwiftUI
import SwiftData

struct CounterListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Counter.sortOrder) private var counters: [Counter]

    @State private var showAddSheet = false
    @State private var counterToEdit: Counter?

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(counters) { counter in
                        CounterCardView(counter: counter)
                            .contextMenu {
                                Button {
                                    counterToEdit = counter
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    modelContext.delete(counter)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
                .frame(minHeight: geo.size.height)
            }
            .background(Color.black)
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
        .preferredColorScheme(.dark)
    }
}
