import XCTest
@testable import PantryPal

final class IngredientMatcherTests: XCTestCase {

    func testExactMatch() {
        XCTAssertTrue(IngredientMatcher.matches(pantryItemName: "Garlic", ingredientName: "garlic"))
    }

    func testPluralMatchesSingular() {
        XCTAssertTrue(IngredientMatcher.matches(pantryItemName: "Tomatoes", ingredientName: "tomato"))
        XCTAssertTrue(IngredientMatcher.matches(pantryItemName: "Berry", ingredientName: "berries"))
    }

    func testDescriptivePantryNameMatches() {
        XCTAssertTrue(IngredientMatcher.matches(pantryItemName: "Red Bell Peppers", ingredientName: "bell pepper"))
        XCTAssertTrue(IngredientMatcher.matches(pantryItemName: "Ground Beef", ingredientName: "beef"))
    }

    func testPantrySubsetOfIngredient() {
        XCTAssertTrue(IngredientMatcher.matches(pantryItemName: "Oil", ingredientName: "olive oil"))
    }

    func testUnrelatedNamesDoNotMatch() {
        XCTAssertFalse(IngredientMatcher.matches(pantryItemName: "Milk", ingredientName: "flour"))
        XCTAssertFalse(IngredientMatcher.matches(pantryItemName: "Chicken", ingredientName: "chickpeas"))
    }

    func testEmptyNamesDoNotMatch() {
        XCTAssertFalse(IngredientMatcher.matches(pantryItemName: "", ingredientName: "garlic"))
    }
}

final class RecipeSuggesterTests: XCTestCase {

    func stockedPantry() -> Pantry {
        Pantry(items: [
            makeItem("Eggs", expiresInDays: 6),
            makeItem("Milk", expiresInDays: 1),   // expiring soon -> urgency boost
            makeItem("Cheddar Cheese", expiresInDays: 10),
            makeItem("Red Bell Pepper", expiresInDays: 2), // expiring soon
            makeItem("Onion", expiresInDays: 9),
            makeItem("Bananas", expiresInDays: 1), // expiring soon
            makeItem("Flour", expiresInDays: 120),
            makeItem("Rolled Oats", expiresInDays: 60),
            makeItem("Honey", expiresInDays: 300),
            makeItem("Cinnamon", expiresInDays: 400),
        ])
    }

    func testSuggestsRecipesByCoverage() {
        let suggestions = RecipeSuggester.suggest(from: stockedPantry(), asOf: testNow)
        XCTAssertFalse(suggestions.isEmpty)
        // Every suggestion must have at least one matched ingredient.
        for s in suggestions {
            XCTAssertFalse(s.matchedIngredients.isEmpty)
            XCTAssertGreaterThan(s.matchPercentage, 0)
        }
        // Sorted by score descending.
        let scores = suggestions.map(\.score)
        XCTAssertEqual(scores, scores.sorted(by: >))
    }

    func testUrgencyBoostsExpiringItems() {
        // Cheese Omelette matches egg, milk, cheese, bell pepper, onion — all on
        // hand, three of them expiring soon. It should outrank recipes whose
        // matches are all fresh.
        let suggestions = RecipeSuggester.suggest(from: stockedPantry(), asOf: testNow)
        let top = suggestions.first!
        XCTAssertEqual(top.recipe.id, "cheese-omelette")
        XCTAssertEqual(top.matchPercentage, 100, accuracy: 0.001)
        XCTAssertGreaterThan(top.urgencyScore, 0)
    }

    func testExpiredItemsDoNotCountAsOnHand() {
        var pantry = stockedPantry()
        // Expire the milk: omelette should lose a matched ingredient.
        if var milk = pantry.items.first(where: { $0.name == "Milk" }) {
            milk.expiryDate = daysFromNow(-1)
            pantry.update(milk)
        }
        let suggestions = RecipeSuggester.suggest(from: pantry, asOf: testNow)
        let omelette = suggestions.first(where: { $0.recipe.id == "cheese-omelette" })!
        XCTAssertFalse(omelette.matchedIngredients.contains("milk"))
        XCTAssertTrue(omelette.missingIngredients.contains("milk"))
        XCTAssertEqual(omelette.matchPercentage, 80, accuracy: 0.001)
    }

    func testMissingIngredientsListed() {
        let suggestions = RecipeSuggester.suggest(from: stockedPantry(), asOf: testNow)
        let pancakes = suggestions.first(where: { $0.recipe.id == "banana-pancakes" })!
        // banana, egg, flour, milk on hand; baking powder missing.
        XCTAssertEqual(pancakes.missingIngredients, ["baking powder"])
        XCTAssertEqual(pancakes.matchPercentage, 80, accuracy: 0.001)
    }

    func testEmptyPantrySuggestsNothing() {
        XCTAssertTrue(RecipeSuggester.suggest(from: Pantry(), asOf: testNow).isEmpty)
    }

    func testMinimumMatchFiltersWeakSuggestions() {
        let suggestions = RecipeSuggester.suggest(from: stockedPantry(), asOf: testNow, minimumMatch: 90)
        for s in suggestions {
            XCTAssertGreaterThanOrEqual(s.matchPercentage, 90)
        }
    }

    func testDatasetHasUniqueIDs() {
        let ids = RecipeDataset.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
        XCTAssertGreaterThanOrEqual(ids.count, 10)
    }
}

final class ShoppingListTests: XCTestCase {

    func testFromMissingIngredientsDedupes() {
        let suggestions = RecipeSuggester.suggest(from: stockedPantryForShopping(), asOf: testNow)
        let list = ShoppingList.fromMissingIngredients(of: suggestions)
        let names = list.items.map { $0.name.lowercased() }
        XCTAssertEqual(Set(names).count, names.count, "ingredients must be deduplicated")
        XCTAssertTrue(list.items.allSatisfy { $0.source == .recipe })
        XCTAssertFalse(list.items.isEmpty)
    }

    func testToggleAndClearChecked() {
        var list = ShoppingList()
        list.add(name: "Baking Powder")
        list.add(name: "Yeast")
        let firstID = list.items[0].id
        list.toggle(id: firstID)
        XCTAssertTrue(list.items[0].isChecked)
        XCTAssertEqual(list.remainingCount, 1)
        list.clearChecked()
        XCTAssertEqual(list.items.map(\.name), ["Yeast"])
    }

    func testAddIgnoresBlanksAndDuplicates() {
        var list = ShoppingList()
        list.add(name: "   ")
        list.add(name: "Milk")
        list.add(name: "milk") // duplicate, different case
        XCTAssertEqual(list.items.count, 1)
    }

    func testJSONRoundTrip() throws {
        var list = ShoppingList()
        list.add(name: "Baking Powder", detail: "for Banana Pancakes", source: .recipe)
        let restored = try ShoppingList.decodeFromJSON(list.encodeToJSON())
        XCTAssertEqual(restored, list)
    }

    // MARK: - Helpers

    private func stockedPantryForShopping() -> Pantry {
        Pantry(items: [
            makeItem("Eggs", expiresInDays: 6),
            makeItem("Milk", expiresInDays: 4),
            makeItem("Bananas", expiresInDays: 2),
        ])
    }
}
