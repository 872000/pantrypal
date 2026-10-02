import SwiftUI
import PantryPal

struct ShoppingListView: View {
    @Environment(ShoppingViewModel.self) private var shoppingVM
    @State private var newItemName = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("Add item", text: $newItemName)
                            .onSubmit(addItem)
                        Button("Add", action: addItem)
                            .disabled(newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                let remaining = shoppingVM.list.items.filter { !$0.isChecked }
                let checked = shoppingVM.list.items.filter { $0.isChecked }

                if !remaining.isEmpty {
                    Section("To buy (\(remaining.count))") {
                        ForEach(remaining) { item in
                            ShoppingRow(item: item) { shoppingVM.toggle(item) }
                                .swipeActions {
                                    Button("Delete", role: .destructive) {
                                        shoppingVM.remove(item)
                                    }
                                }
                        }
                    }
                }

                if !checked.isEmpty {
                    Section("In the cart") {
                        ForEach(checked) { item in
                            ShoppingRow(item: item) { shoppingVM.toggle(item) }
                        }
                        Button("Clear checked", role: .destructive) {
                            shoppingVM.clearChecked()
                        }
                    }
                }

                if shoppingVM.list.items.isEmpty {
                    Section {
                        Text("Your list is empty. Missing ingredients from recipes land here.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Shopping List")
        }
    }

    private func addItem() {
        shoppingVM.add(name: newItemName)
        newItemName = ""
    }
}

struct ShoppingRow: View {
    let item: ShoppingListItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isChecked ? .green : .secondary)
                VStack(alignment: .leading) {
                    Text(item.name)
                        .strikethrough(item.isChecked)
                        .foregroundStyle(item.isChecked ? .secondary : .primary)
                    if let detail = item.detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if item.source == .recipe {
                    Image(systemName: "fork.knife")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
