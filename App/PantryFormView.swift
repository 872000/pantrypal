import SwiftUI
import PantryPal

struct PantryFormView: View {
    @Environment(PantryViewModel.self) private var pantryVM
    @Environment(\.dismiss) private var dismiss

    let existing: PantryItem?

    @State private var name: String
    @State private var quantity: Double
    @State private var unit: String
    @State private var category: PantryCategory
    @State private var hasExpiry: Bool
    @State private var expiryDate: Date

    init(item: PantryItem?) {
        self.existing = item
        _name = State(initialValue: item?.name ?? "")
        _quantity = State(initialValue: item?.quantity ?? 1)
        _unit = State(initialValue: item?.unit ?? "")
        _category = State(initialValue: item?.category ?? .other)
        _hasExpiry = State(initialValue: item?.expiryDate != nil)
        _expiryDate = State(initialValue: item?.expiryDate ?? Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("Name (e.g. Milk)", text: $name)
                    HStack {
                        TextField("Quantity", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                        TextField("Unit (L, pcs, kg…)", text: $unit)
                    }
                    Picker("Category", selection: $category) {
                        ForEach(PantryCategory.allCases, id: \.self) { category in
                            Text(category.label).tag(category)
                        }
                    }
                }
                Section("Expiry") {
                    Toggle("Has expiry date", isOn: $hasExpiry)
                    if hasExpiry {
                        DatePicker("Expires", selection: $expiryDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle(existing == nil ? "Add Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        if var existing {
            existing.name = name
            existing.quantity = quantity
            existing.unit = unit
            existing.category = category
            existing.expiryDate = hasExpiry ? expiryDate : nil
            pantryVM.update(existing)
        } else {
            pantryVM.add(PantryItem(
                name: name,
                quantity: quantity,
                unit: unit,
                category: category,
                expiryDate: hasExpiry ? expiryDate : nil,
                addedDate: Date()
            ))
        }
        dismiss()
    }
}
