import SwiftUI
import PantryPal

struct PantryListView: View {
    @Environment(PantryViewModel.self) private var pantryVM
    @State private var searchText = ""
    @State private var showingForm = false
    @State private var editingItem: PantryItem?

    var body: some View {
        NavigationStack {
            List {
                expiryAlertSection

                let items = pantryVM.pantry
                    .search(searchText)
                    .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                ForEach(items) { item in
                    PantryRow(item: item, now: Date())
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                pantryVM.remove(item)
                            }
                            Button("Edit") { editingItem = item }
                                .tint(.blue)
                        }
                }
            }
            .navigationTitle("Pantry")
            .searchable(text: $searchText, prompt: "Search items")
            .toolbar {
                Button { showingForm = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showingForm) { PantryFormView(item: nil) }
            .sheet(item: $editingItem) { item in PantryFormView(item: item) }
        }
    }

    @ViewBuilder
    private var expiryAlertSection: some View {
        let now = Date()
        let expired = pantryVM.pantry.expired(asOf: now)
        let soon = pantryVM.pantry.expiringSoon(asOf: now)
        if !expired.isEmpty || !soon.isEmpty {
            Section("Needs attention") {
                if !expired.isEmpty {
                    Label("\(expired.count) expired — toss or compost", systemImage: "trash")
                        .foregroundStyle(.red)
                }
                if !soon.isEmpty {
                    Label("\(soon.count) expiring soon — cook these first", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}

struct PantryRow: View {
    let item: PantryItem
    let now: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.headline)
                Text(quantityText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            expiryBadge
        }
    }

    private var quantityText: String {
        let qty = item.quantity.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", item.quantity)
            : String(format: "%.1f", item.quantity)
        return [qty, item.unit, item.category.label]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    @ViewBuilder
    private var expiryBadge: some View {
        switch item.status(asOf: now) {
        case .expired(let daysAgo):
            Text(daysAgo == 1 ? "Expired yesterday" : "Expired \(daysAgo)d ago")
                .font(.caption).foregroundStyle(.red)
        case .expiringSoon(let daysLeft):
            Text(daysLeft == 0 ? "Expires today" : "\(daysLeft)d left")
                .font(.caption).foregroundStyle(.orange)
        case .fresh(let daysLeft):
            Text("\(daysLeft)d left")
                .font(.caption).foregroundStyle(.secondary)
        case .noExpiry:
            EmptyView()
        }
    }
}
