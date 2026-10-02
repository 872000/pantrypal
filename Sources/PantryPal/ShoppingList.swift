import Foundation

public enum ShoppingItemSource: String, Codable, Sendable {
    case manual
    case recipe
}

public struct ShoppingListItem: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var detail: String?
    public var isChecked: Bool
    public var source: ShoppingItemSource

    public init(
        id: UUID = UUID(),
        name: String,
        detail: String? = nil,
        isChecked: Bool = false,
        source: ShoppingItemSource = .manual
    ) {
        self.id = id
        self.name = name
        self.detail = detail
        self.isChecked = isChecked
        self.source = source
    }
}

/// A simple check-off shopping list. Pure value type — encode to JSON to persist.
public struct ShoppingList: Codable, Equatable, Sendable {
    public private(set) var items: [ShoppingListItem]

    public init(items: [ShoppingListItem] = []) {
        self.items = items
    }

    public mutating func add(name: String, detail: String? = nil, source: ShoppingItemSource = .manual) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // Avoid exact duplicates among unchecked items.
        guard !items.contains(where: { !$0.isChecked && $0.name.lowercased() == trimmed.lowercased() }) else { return }
        items.append(ShoppingListItem(name: trimmed, detail: detail, source: source))
    }

    public mutating func toggle(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isChecked.toggle()
    }

    public mutating func remove(id: UUID) {
        items.removeAll { $0.id == id }
    }

    public mutating func clearChecked() {
        items.removeAll { $0.isChecked }
    }

    public var remainingCount: Int {
        items.filter { !$0.isChecked }.count
    }

    /// Builds a list from the missing ingredients of recipe suggestions.
    /// Ingredients are deduplicated case-insensitively and tagged with the
    /// recipe they came from.
    public static func fromMissingIngredients(of suggestions: [RecipeSuggestion]) -> ShoppingList {
        var list = ShoppingList()
        var seen = Set<String>()
        for suggestion in suggestions {
            for ingredient in suggestion.missingIngredients {
                let key = ingredient.lowercased()
                guard !seen.contains(key) else { continue }
                seen.insert(key)
                list.add(
                    name: ingredient,
                    detail: "for \(suggestion.recipe.name)",
                    source: .recipe
                )
            }
        }
        return list
    }

    // MARK: - Persistence helpers

    public func encodeToJSON() throws -> Data {
        try JSONEncoder().encode(self)
    }

    public static func decodeFromJSON(_ data: Data) throws -> ShoppingList {
        try JSONDecoder().decode(ShoppingList.self, from: data)
    }
}
