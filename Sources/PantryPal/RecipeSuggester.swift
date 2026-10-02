import Foundation

/// A recipe ranked against the current pantry.
public struct RecipeSuggestion: Equatable, Sendable {
    public var recipe: Recipe
    /// 0–100: share of the recipe's ingredients already in the pantry.
    public var matchPercentage: Double
    /// 0–100: share of the *matched* ingredients that are expiring soon.
    public var urgencyScore: Double
    public var matchedIngredients: [String]
    public var missingIngredients: [String]

    /// Ranking score: mostly ingredient coverage, boosted when the recipe
    /// would rescue items that are about to expire.
    public var score: Double {
        0.7 * matchPercentage + 0.3 * urgencyScore
    }
}

public enum RecipeSuggester {
    /// Ranks recipes by how many ingredients are on hand, boosting recipes
    /// that use up items expiring soon. Expired items never count as "on hand".
    public static func suggest(
        from pantry: Pantry,
        recipes: [Recipe] = RecipeDataset.all,
        asOf now: Date,
        soonThresholdDays: Int = 3,
        minimumMatch: Double = 1
    ) -> [RecipeSuggestion] {
        let usable = pantry.items.filter { item in
            if case .expired = item.status(asOf: now, soonThresholdDays: soonThresholdDays) {
                return false
            }
            return true
        }

        return recipes.compactMap { recipe in
            guard !recipe.ingredients.isEmpty else { return nil }
            var matched: [String] = []
            var missing: [String] = []
            var urgentMatched = 0

            for ingredient in recipe.ingredients {
                if let item = usable.first(where: {
                    IngredientMatcher.matches(pantryItemName: $0.name, ingredientName: ingredient)
                }) {
                    matched.append(ingredient)
                    if case .expiringSoon =
                        item.status(asOf: now, soonThresholdDays: soonThresholdDays) {
                        urgentMatched += 1
                    }
                } else {
                    missing.append(ingredient)
                }
            }

            let matchPercentage = Double(matched.count) / Double(recipe.ingredients.count) * 100
            guard matchPercentage >= minimumMatch, !matched.isEmpty else { return nil }
            let urgencyScore = Double(urgentMatched) / Double(matched.count) * 100

            return RecipeSuggestion(
                recipe: recipe,
                matchPercentage: matchPercentage,
                urgencyScore: urgencyScore,
                matchedIngredients: matched,
                missingIngredients: missing
            )
        }
        // Deterministic ranking: score, then coverage, then urgency, then name.
        .sorted { lhs, rhs in
            if abs(lhs.score - rhs.score) > 0.0001 { return lhs.score > rhs.score }
            if abs(lhs.matchPercentage - rhs.matchPercentage) > 0.0001 {
                return lhs.matchPercentage > rhs.matchPercentage
            }
            if abs(lhs.urgencyScore - rhs.urgencyScore) > 0.0001 {
                return lhs.urgencyScore > rhs.urgencyScore
            }
            return lhs.recipe.name < rhs.recipe.name
        }
    }
}
