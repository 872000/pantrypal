import SwiftUI
import PantryPal

struct RecipeListView: View {
    @Environment(PantryViewModel.self) private var pantryVM
    @Environment(ShoppingViewModel.self) private var shoppingVM

    var body: some View {
        NavigationStack {
            let suggestions = pantryVM.suggestions()
            List {
                if suggestions.isEmpty {
                    Section {
                        Text("Add pantry items to get recipe ideas based on what you have.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section {
                        Button("Add all missing ingredients to shopping list") {
                            shoppingVM.addMissingIngredients(from: suggestions)
                        }
                    }
                    Section("Best matches") {
                        ForEach(suggestions, id: \.recipe.id) { suggestion in
                            NavigationLink {
                                RecipeDetailView(suggestion: suggestion)
                            } label: {
                                RecipeRow(suggestion: suggestion)
                            }
                        }
                    }
                    Section("Browse all") {
                        ForEach(RecipeDataset.all, id: \.id) { recipe in
                            NavigationLink {
                                let empty = RecipeSuggestion(
                                    recipe: recipe,
                                    matchPercentage: 0,
                                    urgencyScore: 0,
                                    matchedIngredients: [],
                                    missingIngredients: recipe.ingredients
                                )
                                RecipeDetailView(suggestion: empty)
                            } label: {
                                HStack {
                                    Text(recipe.name)
                                    Spacer()
                                    Text("\(recipe.prepMinutes) min")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
        }
    }
}

struct RecipeRow: View {
    let suggestion: RecipeSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(suggestion.recipe.name).font(.headline)
                Spacer()
                Text("\(Int(suggestion.matchPercentage))%")
                    .font(.headline)
                    .foregroundStyle(matchColor)
            }
            Text("\(suggestion.matchedIngredients.count) of \(suggestion.recipe.ingredients.count) ingredients on hand")
                .font(.caption)
                .foregroundStyle(.secondary)
            if suggestion.urgencyScore > 0 {
                Label("Uses expiring items", systemImage: "timer")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }

    private var matchColor: Color {
        switch suggestion.matchPercentage {
        case 80...: return .green
        case 50..<80: return .orange
        default: return .secondary
        }
    }
}

struct RecipeDetailView: View {
    @Environment(ShoppingViewModel.self) private var shoppingVM
    let suggestion: RecipeSuggestion

    var body: some View {
        List {
            Section {
                HStack {
                    Label("\(suggestion.recipe.prepMinutes) min", systemImage: "clock")
                    Spacer()
                    Label("Serves \(suggestion.recipe.servings)", systemImage: "person.2")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                if !suggestion.recipe.tags.isEmpty {
                    Text(suggestion.recipe.tags.joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !suggestion.matchedIngredients.isEmpty {
                Section("You have") {
                    ForEach(suggestion.matchedIngredients, id: \.self) { ingredient in
                        Label(ingredient, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }

            if !suggestion.missingIngredients.isEmpty {
                Section("You need") {
                    ForEach(suggestion.missingIngredients, id: \.self) { ingredient in
                        Label(ingredient, systemImage: "circle")
                    }
                    Button("Add missing to shopping list") {
                        shoppingVM.addMissingIngredients(from: [suggestion])
                    }
                }
            }

            Section("Steps") {
                ForEach(Array(suggestion.recipe.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top) {
                        Text("\(index + 1).")
                            .fontWeight(.semibold)
                        Text(step)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .navigationTitle(suggestion.recipe.name)
    }
}
