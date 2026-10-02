import SwiftUI
import PantryPal

// MARK: - Pantry

@Observable
final class PantryViewModel {
    var pantry = Pantry()

    private let pantryURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("pantrypal-pantry.json")
    }()

    init() { load() }

    func add(_ item: PantryItem) { pantry.add(item); save() }
    func update(_ item: PantryItem) { pantry.update(item); save() }
    func remove(_ item: PantryItem) { pantry.remove(id: item.id); save() }

    func suggestions(now: Date = Date()) -> [RecipeSuggestion] {
        RecipeSuggester.suggest(from: pantry, asOf: now)
    }

    private func save() {
        try? pantry.encodeToJSON().write(to: pantryURL, options: .atomic)
    }

    private func load() {
        guard let data = try? Data(contentsOf: pantryURL),
              let decoded = try? Pantry.decodeFromJSON(data) else {
            seedSampleData()
            return
        }
        pantry = decoded
    }

    /// A few items on first launch so the app isn't empty.
    private func seedSampleData() {
        let now = Date()
        let calendar = Calendar.current
        func days(_ n: Int) -> Date? {
            calendar.date(byAdding: .day, value: n, to: now)
        }
        pantry = Pantry(items: [
            PantryItem(name: "Milk", quantity: 1, unit: "L", category: .dairy, expiryDate: days(2), addedDate: now),
            PantryItem(name: "Eggs", quantity: 12, unit: "pcs", category: .dairy, expiryDate: days(6), addedDate: now),
            PantryItem(name: "Bananas", quantity: 4, unit: "pcs", category: .produce, expiryDate: days(1), addedDate: now),
            PantryItem(name: "Rice", quantity: 2, unit: "kg", category: .grains, addedDate: now),
        ])
        save()
    }
}

// MARK: - Shopping list

@Observable
final class ShoppingViewModel {
    var list = ShoppingList()

    private let listURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("pantrypal-shopping.json")
    }()

    init() { load() }

    func addMissingIngredients(from suggestions: [RecipeSuggestion]) {
        let generated = ShoppingList.fromMissingIngredients(of: suggestions)
        for item in generated.items {
            list.add(name: item.name, detail: item.detail, source: .recipe)
        }
        save()
    }

    func add(name: String) { list.add(name: name); save() }
    func toggle(_ item: ShoppingListItem) { list.toggle(id: item.id); save() }
    func remove(_ item: ShoppingListItem) { list.remove(id: item.id); save() }
    func clearChecked() { list.clearChecked(); save() }

    private func save() {
        try? list.encodeToJSON().write(to: listURL, options: .atomic)
    }

    private func load() {
        guard let data = try? Data(contentsOf: listURL),
              let decoded = try? ShoppingList.decodeFromJSON(data) else { return }
        list = decoded
    }
}
