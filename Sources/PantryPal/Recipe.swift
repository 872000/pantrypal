import Foundation

/// A recipe from the bundled offline dataset.
public struct Recipe: Identifiable, Codable, Hashable, Sendable {
    /// URL-safe slug, e.g. "veggie-stir-fry".
    public var id: String
    public var name: String
    public var ingredients: [String]
    public var steps: [String]
    public var tags: [String]
    public var prepMinutes: Int
    public var servings: Int

    public init(
        id: String,
        name: String,
        ingredients: [String],
        steps: [String],
        tags: [String] = [],
        prepMinutes: Int,
        servings: Int
    ) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.steps = steps
        self.tags = tags
        self.prepMinutes = prepMinutes
        self.servings = servings
    }
}
