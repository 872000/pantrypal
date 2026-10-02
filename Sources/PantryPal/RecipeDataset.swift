import Foundation

/// Bundled offline recipe dataset. Everything runs on-device — no network.
public enum RecipeDataset {
    public static let all: [Recipe] = [
        Recipe(
            id: "veggie-stir-fry",
            name: "Veggie Stir Fry",
            ingredients: ["bell pepper", "broccoli", "soy sauce", "rice", "garlic", "oil"],
            steps: [
                "Cook the rice according to package directions.",
                "Heat oil in a wok over high heat; add garlic for 30 seconds.",
                "Add bell pepper and broccoli; stir-fry 4–5 minutes until crisp-tender.",
                "Splash in soy sauce, toss, and serve over rice.",
            ],
            tags: ["vegetarian", "quick", "dinner"],
            prepMinutes: 20,
            servings: 2
        ),
        Recipe(
            id: "tomato-pasta",
            name: "Tomato Pasta",
            ingredients: ["pasta", "tomato", "garlic", "onion", "olive oil", "basil"],
            steps: [
                "Boil pasta in salted water until al dente; reserve a cup of pasta water.",
                "Soften onion and garlic in olive oil, add chopped tomato and simmer 10 minutes.",
                "Toss pasta through the sauce with a splash of pasta water; top with basil.",
            ],
            tags: ["vegetarian", "dinner"],
            prepMinutes: 25,
            servings: 2
        ),
        Recipe(
            id: "chicken-fried-rice",
            name: "Chicken Fried Rice",
            ingredients: ["chicken", "rice", "egg", "carrot", "peas", "soy sauce"],
            steps: [
                "Scramble the egg in a hot oiled wok; set aside.",
                "Stir-fry diced chicken until cooked through; add carrot and peas.",
                "Add day-old rice, soy sauce and the egg; toss until heated through.",
            ],
            tags: ["dinner", "quick"],
            prepMinutes: 20,
            servings: 2
        ),
        Recipe(
            id: "banana-pancakes",
            name: "Banana Pancakes",
            ingredients: ["banana", "egg", "flour", "milk", "baking powder"],
            steps: [
                "Mash the banana; whisk with egg and milk.",
                "Fold in flour and baking powder until just combined.",
                "Cook ladles of batter in a buttered pan, 2 minutes per side.",
            ],
            tags: ["vegetarian", "breakfast"],
            prepMinutes: 15,
            servings: 2
        ),
        Recipe(
            id: "greek-salad",
            name: "Greek Salad",
            ingredients: ["cucumber", "tomato", "feta", "olive oil", "onion"],
            steps: [
                "Chop cucumber, tomato and onion into chunky pieces.",
                "Crumble feta over the top; drizzle generously with olive oil.",
                "Season, toss gently and serve immediately.",
            ],
            tags: ["vegetarian", "no-cook", "lunch"],
            prepMinutes: 10,
            servings: 2
        ),
        Recipe(
            id: "cheese-omelette",
            name: "Cheese Omelette",
            ingredients: ["egg", "milk", "cheese", "bell pepper", "onion"],
            steps: [
                "Whisk eggs with a splash of milk; season.",
                "Soften pepper and onion in a buttered pan.",
                "Pour in eggs; when nearly set, add cheese, fold and serve.",
            ],
            tags: ["vegetarian", "breakfast", "quick"],
            prepMinutes: 10,
            servings: 1
        ),
        Recipe(
            id: "lentil-soup",
            name: "Lentil Soup",
            ingredients: ["lentils", "carrot", "onion", "garlic", "cumin"],
            steps: [
                "Soften onion, carrot and garlic in oil for 5 minutes.",
                "Add lentils, cumin and water; simmer 25 minutes until tender.",
                "Blend half the soup for a creamy texture; season and serve.",
            ],
            tags: ["vegetarian", "soup", "budget"],
            prepMinutes: 35,
            servings: 4
        ),
        Recipe(
            id: "quesadilla",
            name: "Quesadilla",
            ingredients: ["tortilla", "cheese", "bell pepper", "onion"],
            steps: [
                "Layer cheese, diced pepper and onion over half a tortilla.",
                "Fold and cook in a dry pan 2–3 minutes per side until golden.",
                "Rest a minute, slice into wedges and serve.",
            ],
            tags: ["vegetarian", "quick", "lunch"],
            prepMinutes: 12,
            servings: 1
        ),
        Recipe(
            id: "smoothie-bowl",
            name: "Smoothie Bowl",
            ingredients: ["banana", "milk", "yogurt", "honey", "berries"],
            steps: [
                "Blend banana, berries, yogurt and milk until thick.",
                "Pour into a bowl; drizzle with honey.",
                "Top with extra berries and serve immediately.",
            ],
            tags: ["vegetarian", "no-cook", "breakfast"],
            prepMinutes: 5,
            servings: 1
        ),
        Recipe(
            id: "garlic-butter-rice",
            name: "Garlic Butter Rice",
            ingredients: ["rice", "garlic", "butter", "peas"],
            steps: [
                "Cook the rice and keep warm.",
                "Melt butter; toast sliced garlic until golden.",
                "Stir garlic butter and peas through the rice; season.",
            ],
            tags: ["vegetarian", "side", "budget"],
            prepMinutes: 20,
            servings: 2
        ),
        Recipe(
            id: "tuna-salad-sandwich",
            name: "Tuna Salad Sandwich",
            ingredients: ["tuna", "bread", "mayo", "celery", "onion"],
            steps: [
                "Drain tuna; mix with mayo, diced celery and onion.",
                "Season and pile onto bread.",
                "Toast in a pan if you like it warm and crisp.",
            ],
            tags: ["lunch", "quick", "no-cook"],
            prepMinutes: 10,
            servings: 1
        ),
        Recipe(
            id: "overnight-oats",
            name: "Overnight Oats",
            ingredients: ["oats", "milk", "banana", "honey", "cinnamon"],
            steps: [
                "Combine oats, milk, honey and cinnamon in a jar.",
                "Refrigerate overnight (at least 6 hours).",
                "Top with sliced banana and serve cold.",
            ],
            tags: ["vegetarian", "no-cook", "breakfast"],
            prepMinutes: 5,
            servings: 1
        ),
    ]
}
