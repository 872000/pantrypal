import Foundation

/// Fuzzy matching between pantry item names and recipe ingredient names.
///
/// Matches when the normalized word sets are equal, or when one is a subset
/// of the other — so "red bell peppers" matches "bell pepper", "ground beef"
/// matches "beef", and "olive oil" matches "oil".
public enum IngredientMatcher {
    public static func normalize(_ name: String) -> String {
        var s = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // Naive English singularization for common plurals.
        if s.hasSuffix("ies"), s.count > 4 {
            s = String(s.dropLast(3)) + "y"          // berries -> berry
        } else if s.hasSuffix("toes"), s.count > 5 {
            s = String(s.dropLast(2))                // tomatoes -> tomato, potatoes -> potato
        } else if s.hasSuffix("ses") || s.hasSuffix("xes") || s.hasSuffix("zes")
                    || s.hasSuffix("ches") || s.hasSuffix("shes"), s.count > 5 {
            s = String(s.dropLast(2))                // boxes -> box, dishes -> dish
        } else if s.hasSuffix("s"), !s.hasSuffix("ss"), s.count > 3 {
            s = String(s.dropLast())                 // carrots -> carrot
        }
        return s
    }

    private static func words(_ name: String) -> Set<String> {
        Set(normalize(name).split(separator: " ").map(String.init))
    }

    /// True when the pantry item can stand in for the recipe ingredient.
    public static func matches(pantryItemName: String, ingredientName: String) -> Bool {
        let pantryWords = words(pantryItemName)
        let ingredientWords = words(ingredientName)
        guard !pantryWords.isEmpty, !ingredientWords.isEmpty else { return false }
        return pantryWords == ingredientWords
            || ingredientWords.isSubset(of: pantryWords)
            || pantryWords.isSubset(of: ingredientWords)
    }
}
