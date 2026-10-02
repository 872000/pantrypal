import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PantryListView()
                .tabItem { Label("Pantry", systemImage: "refrigerator") }
            RecipeListView()
                .tabItem { Label("Recipes", systemImage: "fork.knife") }
            ShoppingListView()
                .tabItem { Label("Shopping", systemImage: "cart") }
        }
    }
}
