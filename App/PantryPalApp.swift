import SwiftUI

@main
struct PantryPalApp: App {
    @State private var pantry = PantryViewModel()
    @State private var shopping = ShoppingViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(pantry)
                .environment(shopping)
        }
    }
}
